import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'analytics_service.dart';

/// Coarse purchase-flow status surfaced to UI via [IapService.purchaseStatus].
/// UI listens with `ValueListenableBuilder` and renders loading/success/error
/// states + snackbars accordingly.
enum IapPurchaseStatus {
  /// Default state — nothing happening.
  idle,

  /// `buyPremium()` called, waiting for Play Store sheet result.
  processing,

  /// Purchase confirmed by Play Store and granted in Hive.
  success,

  /// Purchase failed (network, payment, etc.). See [IapService.lastErrorMessage].
  error,

  /// User dismissed the Play Store sheet without purchasing.
  canceled,

  /// `buyPremium()` called but [IapService.premiumProduct] is null
  /// (e.g., Play Store hasn't fetched products yet, or product not configured
  /// in Play Console).
  productUnavailable,

  /// `restore()` succeeded and at least one past purchase was found + granted.
  restored,

  /// `restore()` completed but no past purchase exists for this account.
  noPurchaseToRestore,
}

/// Manages In-App Purchases for Waktu Shalat.
///
/// **Scope (Ship 4 — scaffolding):**
/// - Initializes IAP plugin & queries product details from Play Store.
/// - Listens to purchaseStream and grants/restores premium on success.
/// - Persists premium state in Hive (`settings` box).
/// - Syncs premium status to Firebase Analytics user property.
///
/// **NOT yet implemented (deferred):**
/// - Paywall UI (Ship 5 / Bulan 3).
/// - Server-side receipt verification (low priority for one-time IAP — Google
///   handles signature validation locally via the plugin).
/// - Donation product variants (planned for Bulan 4).
///
/// **Why singleton:** purchaseStream is a single global subscription, and
/// premium state is app-wide. Mirrors AnalyticsService / AdService pattern.
///
/// **Hive dependency:** This service reads/writes `Hive.box('settings')`.
/// Caller MUST ensure that box is open before calling [initialize] — in this
/// app, that happens via `SettingsProvider.initialize()` in `main.dart`.
class IapService {
  IapService._();
  static final IapService instance = IapService._();

  // ── Product IDs ────────────────────────────────────────────────────────
  // Must match Play Console product configuration EXACTLY (case-sensitive).
  // Create these in Play Console → Monetize → Products → In-app products
  // BEFORE shipping a build that calls IAP, otherwise queryProductDetails
  // returns notFoundIDs and `products` stays empty.

  static const String premiumLifetimeId = 'premium_lifetime';

  static const Set<String> _productIds = {
    premiumLifetimeId,
  };

  // ── Hive keys (uses already-open `settings` box) ───────────────────────

  static const String _kIsPremiumKey      = 'iap_is_premium';
  static const String _kPurchaseTokenKey  = 'iap_purchase_token';

  // ── State ──────────────────────────────────────────────────────────────

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  List<ProductDetails> _products = [];
  bool _initialized = false;

  /// Tracks whether we're inside a `restore()` call. Set true before the
  /// `restorePurchases()` future is awaited; checked when the stream fires
  /// `PurchaseStatus.restored` to flip [_restoredAnyPurchase] true.
  bool _restoring = false;
  bool _restoredAnyPurchase = false;

  // ── Listenable state surfaces (consumed by UI) ─────────────────────────
  //
  // `ValueNotifier` is the lightest-weight observable Flutter widget pattern;
  // UI uses `ValueListenableBuilder` to rebuild on change without needing a
  // Provider wrapper. Initial values are set in `initialize()` after Hive
  // is read.

  /// True if user owns premium. UI listens to auto-rebuild thank-you state.
  final ValueNotifier<bool> isPremiumNotifier = ValueNotifier(false);

  /// Coarse purchase flow state (idle/processing/success/error/etc.).
  /// UI listens to show loading spinner + snackbars.
  final ValueNotifier<IapPurchaseStatus> purchaseStatus =
      ValueNotifier(IapPurchaseStatus.idle);

  /// Last error message from a failed purchase (if any). Cleared on next
  /// successful flow start.
  final ValueNotifier<String?> lastErrorMessage = ValueNotifier(null);

  /// True once Play Store has returned product details. UI listens so the
  /// "Dukung" button can transition from disabled (loading) to enabled
  /// (with price label) without needing manual refresh.
  final ValueNotifier<bool> productsReadyNotifier = ValueNotifier(false);

  /// True if the user has purchased premium (read from Hive).
  /// Returns false on any error so the app fails closed (= no premium).
  bool get isPremium {
    try {
      return Hive.box('settings').get(_kIsPremiumKey, defaultValue: false)
          as bool;
    } catch (_) {
      return false;
    }
  }

  /// Available products fetched from Play Store. Empty until [initialize]
  /// completes successfully.
  List<ProductDetails> get products => List.unmodifiable(_products);

  ProductDetails? get premiumProduct {
    for (final p in _products) {
      if (p.id == premiumLifetimeId) return p;
    }
    return null;
  }

  // ── Public API ─────────────────────────────────────────────────────────

  /// Called once during app boot (after Hive `settings` box is open).
  /// Safe to call repeatedly — guards against double-init.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Hydrate notifier from Hive immediately so UI built before async init
    // finishes still gets correct state.
    isPremiumNotifier.value = isPremium;

    try {
      final available = await _iap.isAvailable();
      if (!available) {
        debugPrint('[IapService] Store not available (no Play Store on device?)');
        return;
      }

      // Subscribe to purchase updates BEFORE querying — covers the case
      // where Play Store delivers a pending purchase from a prior session.
      _purchaseSub = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _purchaseSub?.cancel(),
        onError: (Object e) =>
            debugPrint('[IapService] purchaseStream error: $e'),
      );

      await _queryProducts();

      // Push current premium state to Analytics user property so
      // dashboards can segment by free vs premium from boot.
      AnalyticsService.instance.setIsPremium(isPremium);

      debugPrint(
        '[IapService] Initialized. isPremium=$isPremium, '
        'products=${_products.length}',
      );
    } catch (e, stack) {
      debugPrint('[IapService] init error: $e\n$stack');
    }
  }

  /// Re-queries Play Store for product details. Safe to call to refresh
  /// pricing (e.g., after locale change).
  Future<void> _queryProducts() async {
    final response = await _iap.queryProductDetails(_productIds);

    if (response.error != null) {
      debugPrint('[IapService] queryProducts error: ${response.error}');
    }
    if (response.notFoundIDs.isNotEmpty) {
      // Expected on dev devices where the app isn't uploaded to Play Console
      // yet, OR when the product hasn't been activated in Play Console.
      debugPrint(
        '[IapService] Products NOT FOUND: ${response.notFoundIDs}',
      );
    }

    _products = response.productDetails;
    if (_products.isNotEmpty) {
      debugPrint(
        '[IapService] Products loaded: '
        '${_products.map((p) => "${p.id}=${p.price}").join(", ")}',
      );
      // Notify UI so the "Dukung" CTA can transition from loading to
      // enabled-with-price.
      productsReadyNotifier.value = true;
    }
  }

  /// Triggers the Play Store purchase flow for premium lifetime.
  ///
  /// Returns true if the purchase flow was launched (NOT if purchase
  /// succeeded — that arrives async via [_handlePurchaseUpdates] which
  /// updates [purchaseStatus] / [isPremiumNotifier]).
  ///
  /// UI should listen to [purchaseStatus] for status updates rather than
  /// relying on this return value.
  Future<bool> buyPremium() async {
    lastErrorMessage.value = null;

    final product = premiumProduct;
    if (product == null) {
      debugPrint('[IapService] buyPremium: product not loaded');
      purchaseStatus.value = IapPurchaseStatus.productUnavailable;
      AnalyticsService.instance.logPurchaseFailed(
        productId: premiumLifetimeId,
        reason: 'product_unavailable',
      );
      return false;
    }

    try {
      purchaseStatus.value = IapPurchaseStatus.processing;
      AnalyticsService.instance.logPurchaseInitiated(
        productId: premiumLifetimeId,
      );

      final param = PurchaseParam(productDetails: product);
      final launched = await _iap.buyNonConsumable(purchaseParam: param);
      if (!launched) {
        // Sheet didn't open — treat as error so UI clears the spinner.
        purchaseStatus.value = IapPurchaseStatus.error;
        lastErrorMessage.value = 'Failed to launch purchase flow';
        AnalyticsService.instance.logPurchaseFailed(
          productId: premiumLifetimeId,
          reason: 'launch_failed',
        );
      }
      return launched;
    } catch (e, stack) {
      debugPrint('[IapService] buyPremium error: $e\n$stack');
      purchaseStatus.value = IapPurchaseStatus.error;
      lastErrorMessage.value = e.toString();
      AnalyticsService.instance.logPurchaseFailed(
        productId: premiumLifetimeId,
        reason: e.toString(),
      );
      return false;
    }
  }

  /// Restores past purchases. Call from a "Restore Purchases" button in
  /// settings — required by Play Store policy for non-consumable IAPs.
  ///
  /// `restorePurchases()` returns immediately and the actual restore events
  /// arrive on the purchase stream. If no past purchase exists, the stream
  /// never fires — so we use a 5s timeout to distinguish:
  ///   - found purchase → [purchaseStatus] = restored (set by stream handler)
  ///   - timeout reached, nothing came → [purchaseStatus] = noPurchaseToRestore
  Future<void> restore() async {
    lastErrorMessage.value = null;
    purchaseStatus.value = IapPurchaseStatus.processing;
    _restoring = true;
    _restoredAnyPurchase = false;

    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('[IapService] restore error: $e');
      purchaseStatus.value = IapPurchaseStatus.error;
      lastErrorMessage.value = e.toString();
      _restoring = false;
      return;
    }

    // Wait briefly for stream events. If none came, conclude that there's
    // nothing to restore.
    await Future<void>.delayed(const Duration(seconds: 5));
    _restoring = false;
    if (!_restoredAnyPurchase) {
      purchaseStatus.value = IapPurchaseStatus.noPurchaseToRestore;
    }
  }

  // ── Internal: purchase update handler ──────────────────────────────────

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          debugPrint('[IapService] Purchase pending: ${purchase.productID}');
          // Keep purchaseStatus as processing — Play Store sheet still open.
          break;

        case PurchaseStatus.purchased:
          if (purchase.productID == premiumLifetimeId) {
            await _grantPremium(purchase);
            purchaseStatus.value = IapPurchaseStatus.success;
            AnalyticsService.instance.logPurchaseCompleted(
              productId: premiumLifetimeId,
              priceLocalized: premiumProduct?.price,
              currencyCode: premiumProduct?.currencyCode,
            );
          }
          break;

        case PurchaseStatus.restored:
          if (purchase.productID == premiumLifetimeId) {
            await _grantPremium(purchase);
            _restoredAnyPurchase = true;
            // Only emit `restored` status if this came from an explicit
            // restore() call. Stream-driven restores at boot shouldn't
            // pop a snackbar mid-app-launch.
            if (_restoring) {
              purchaseStatus.value = IapPurchaseStatus.restored;
            }
            AnalyticsService.instance.logPurchaseRestored(
              productId: premiumLifetimeId,
            );
          }
          break;

        case PurchaseStatus.error:
          debugPrint(
            '[IapService] Purchase error (${purchase.productID}): '
            '${purchase.error?.message}',
          );
          purchaseStatus.value = IapPurchaseStatus.error;
          lastErrorMessage.value = purchase.error?.message;
          AnalyticsService.instance.logPurchaseFailed(
            productId: purchase.productID,
            reason: purchase.error?.message ?? 'unknown',
          );
          break;

        case PurchaseStatus.canceled:
          debugPrint('[IapService] Purchase canceled: ${purchase.productID}');
          purchaseStatus.value = IapPurchaseStatus.canceled;
          AnalyticsService.instance.logPurchaseCanceled(
            productId: purchase.productID,
          );
          break;
      }

      // Always acknowledge the purchase, otherwise Play refunds it after 3
      // days. This applies to errors/cancels too — pendingCompletePurchase
      // signals whether acknowledgment is needed.
      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (e) {
          debugPrint('[IapService] completePurchase error: $e');
        }
      }
    }
  }

  Future<void> _grantPremium(PurchaseDetails purchase) async {
    try {
      final box = Hive.box('settings');
      await box.put(_kIsPremiumKey, true);
      await box.put(_kPurchaseTokenKey, purchase.purchaseID);
      AnalyticsService.instance.setIsPremium(true);
      // Notify UI — listeners (paywall, Settings entry) auto-rebuild.
      isPremiumNotifier.value = true;
      debugPrint('[IapService] Premium GRANTED (token=${purchase.purchaseID})');
    } catch (e, stack) {
      debugPrint('[IapService] grantPremium error: $e\n$stack');
    }
  }

  /// Resets [purchaseStatus] back to idle. Call after UI has shown the
  /// success/error snackbar so subsequent rebuilds don't re-show it.
  void clearPurchaseStatus() {
    purchaseStatus.value = IapPurchaseStatus.idle;
    lastErrorMessage.value = null;
  }

  /// Tear down subscriptions. Call from `dispose` if you ever stop using
  /// the singleton (currently not needed — singleton lives for app lifetime).
  void dispose() {
    _purchaseSub?.cancel();
    _purchaseSub = null;
    _initialized = false;
  }
}
