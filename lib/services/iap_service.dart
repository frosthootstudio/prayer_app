import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'analytics_service.dart';

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
    }
  }

  /// Triggers the Play Store purchase flow for premium lifetime.
  ///
  /// Returns true if the purchase flow was launched (NOT if purchase
  /// succeeded — that arrives async via [_handlePurchaseUpdates]).
  Future<bool> buyPremium() async {
    final product = premiumProduct;
    if (product == null) {
      debugPrint('[IapService] buyPremium: product not loaded');
      return false;
    }

    try {
      final param = PurchaseParam(productDetails: product);
      return await _iap.buyNonConsumable(purchaseParam: param);
    } catch (e, stack) {
      debugPrint('[IapService] buyPremium error: $e\n$stack');
      return false;
    }
  }

  /// Restores past purchases. Call from a "Restore Purchases" button in
  /// settings — required by Play Store policy for non-consumable IAPs.
  Future<void> restore() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('[IapService] restore error: $e');
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
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.productID == premiumLifetimeId) {
            await _grantPremium(purchase);
          }
          break;

        case PurchaseStatus.error:
          debugPrint(
            '[IapService] Purchase error (${purchase.productID}): '
            '${purchase.error?.message}',
          );
          break;

        case PurchaseStatus.canceled:
          debugPrint('[IapService] Purchase canceled: ${purchase.productID}');
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
      debugPrint('[IapService] Premium GRANTED (token=${purchase.purchaseID})');
    } catch (e, stack) {
      debugPrint('[IapService] grantPremium error: $e\n$stack');
    }
  }

  /// Tear down subscriptions. Call from `dispose` if you ever stop using
  /// the singleton (currently not needed — singleton lives for app lifetime).
  void dispose() {
    _purchaseSub?.cancel();
    _purchaseSub = null;
    _initialized = false;
  }
}
