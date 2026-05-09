import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../services/analytics_service.dart';
import '../services/iap_service.dart';
import '../utils/app_theme.dart';

/// Donation-style paywall: "Hilangkan Iklan & Dukung Pengembang".
///
/// Reachable from Settings → "Dukungan" section. Shows two states based on
/// [IapService.instance.isPremiumNotifier]:
///   - Pre-purchase: hero icon + 4 benefit checks + price CTA + restore link
///   - Post-purchase: filled heart + "Jazākallāhu khayrān!" thank-you
///
/// Listens to [IapService.instance.purchaseStatus] to surface snackbars on
/// success/error/cancel/restore — no manual refresh needed.
class SupportDeveloperScreen extends StatefulWidget {
  const SupportDeveloperScreen({super.key});

  @override
  State<SupportDeveloperScreen> createState() => _SupportDeveloperScreenState();
}

class _SupportDeveloperScreenState extends State<SupportDeveloperScreen> {
  IapPurchaseStatus _lastShownStatus = IapPurchaseStatus.idle;

  @override
  void initState() {
    super.initState();
    // Log paywall view once per screen open. Fired in postFrameCallback so
    // the analytics call doesn't slow the first paint.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.instance.logSupportScreenViewed();
    });
    IapService.instance.purchaseStatus.addListener(_onPurchaseStatusChanged);
  }

  @override
  void dispose() {
    IapService.instance.purchaseStatus.removeListener(_onPurchaseStatusChanged);
    super.dispose();
  }

  // ── Purchase status → snackbar bridge ──────────────────────────────────

  void _onPurchaseStatusChanged() {
    final status = IapService.instance.purchaseStatus.value;
    if (status == _lastShownStatus) return;
    _lastShownStatus = status;
    if (!mounted) return;

    final settings = context.read<SettingsProvider>();
    String? message;
    Color? bg;
    IconData? icon;

    switch (status) {
      case IapPurchaseStatus.success:
        message = settings.getLabel('supportPurchaseSuccess');
        bg = const Color(0xFF2E7D32); // success green
        icon = Icons.check_circle_outline_rounded;
        break;
      case IapPurchaseStatus.error:
        // Show localized message to user. Raw BillingClient errors (e.g.
        // "Service not available", "BILLING_UNAVAILABLE") are cryptic for
        // end users — they're already forwarded to Firebase Analytics via
        // logPurchaseFailed.reason for debugging.
        message = settings.getLabel('supportPurchaseFailed');
        bg = const Color(0xFFC62828); // error red
        icon = Icons.error_outline_rounded;
        break;
      case IapPurchaseStatus.productUnavailable:
        message = settings.getLabel('supportProductUnavailable');
        bg = const Color(0xFFEF6C00); // warning orange
        icon = Icons.cloud_off_outlined;
        break;
      case IapPurchaseStatus.restored:
        message = settings.getLabel('supportRestoreSuccess');
        bg = const Color(0xFF2E7D32);
        icon = Icons.restart_alt_rounded;
        break;
      case IapPurchaseStatus.noPurchaseToRestore:
        message = settings.getLabel('supportRestoreNothing');
        bg = const Color(0xFF546E7A); // neutral blue-grey
        icon = Icons.info_outline_rounded;
        break;
      case IapPurchaseStatus.canceled:
      case IapPurchaseStatus.idle:
      case IapPurchaseStatus.processing:
        // No snackbar — user-initiated cancel is silent; spinner shown
        // for processing; idle is the resting state.
        break;
    }

    if (message == null) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );

    // Reset status after a delay so re-opening the screen doesn't replay
    // the same snackbar.
    Future<void>.delayed(const Duration(seconds: 5), () {
      if (mounted) IapService.instance.clearPurchaseStatus();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: context.appTextPrimary,
        title: ValueListenableBuilder<bool>(
          valueListenable: IapService.instance.isPremiumNotifier,
          builder: (_, isPremium, _) => Text(
            isPremium
                ? settings.getLabel('supportStatusActive')
                : settings.getLabel('supportTitle'),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: IapService.instance.isPremiumNotifier,
        builder: (_, isPremium, _) {
          return isPremium
              ? _PremiumThanksView(settings: settings)
              : _PaywallView(settings: settings);
        },
      ),
    );
  }
}

// ── Pre-purchase paywall view ─────────────────────────────────────────────

class _PaywallView extends StatelessWidget {
  final SettingsProvider settings;

  const _PaywallView({required this.settings});

  @override
  Widget build(BuildContext context) {
    final accent = context.appAccent;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            // ── Hero icon ─────────────────────────────────────────────────
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 64,
                  color: accent,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Title + subtitle ──────────────────────────────────────────
            Text(
              settings.getLabel('supportHeroTitle'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.appTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              settings.getLabel('supportHeroSubtitle'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: context.appTextSecondary,
              ),
            ),

            const SizedBox(height: 28),

            // ── Benefit checklist ─────────────────────────────────────────
            _BenefitCard(
              accent: accent,
              items: [
                settings.getLabel('supportBenefit1'),
                settings.getLabel('supportBenefit2'),
                settings.getLabel('supportBenefit3'),
                settings.getLabel('supportBenefit4'),
              ],
            ),

            const SizedBox(height: 28),

            // ── CTA button (reactive to purchaseStatus + product load) ────
            _BuyButton(settings: settings, accent: accent),

            const SizedBox(height: 12),

            // ── Restore purchase ──────────────────────────────────────────
            Center(
              child: TextButton(
                onPressed: () => IapService.instance.restore(),
                style: TextButton.styleFrom(
                  foregroundColor: context.appTextSecondary,
                  textStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text(settings.getLabel('supportRestore')),
              ),
            ),

            const SizedBox(height: 16),

            // ── Footer disclaimer ─────────────────────────────────────────
            Text(
              settings.getLabel('supportFooter'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                height: 1.5,
                color: context.appTextFaded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Benefit checklist card ────────────────────────────────────────────────

class _BenefitCard extends StatelessWidget {
  final Color accent;
  final List<String> items;

  const _BenefitCard({required this.accent, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_rounded, color: accent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    items[i],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.appTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (i < items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

// ── CTA button ────────────────────────────────────────────────────────────
//
// Listens to both purchaseStatus (for spinner during processing) and
// isPremiumNotifier (defensive — won't render in premium state because
// parent ValueListenableBuilder hides this widget, but cheap to add).
// Price label comes from IapService.premiumProduct.price (locale-aware
// from Play Store).

class _BuyButton extends StatelessWidget {
  final SettingsProvider settings;
  final Color accent;

  const _BuyButton({required this.settings, required this.accent});

  @override
  Widget build(BuildContext context) {
    // Listen to BOTH notifiers — purchaseStatus (for processing spinner) and
    // productsReadyNotifier (so the button enables itself once Play Store
    // returns product details, without manual refresh).
    return ListenableBuilder(
      listenable: Listenable.merge([
        IapService.instance.purchaseStatus,
        IapService.instance.productsReadyNotifier,
      ]),
      builder: (_, _) {
        final status = IapService.instance.purchaseStatus.value;
        final productsReady = IapService.instance.productsReadyNotifier.value;
        final product = IapService.instance.premiumProduct;
        final price = product?.price;

        final isProcessing = status == IapPurchaseStatus.processing;
        final canBuy = productsReady && product != null && !isProcessing;

        return SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: canBuy ? () => IapService.instance.buyPremium() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: accent.withValues(alpha: 0.4),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.85),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _buildButtonContent(
              isProcessing: isProcessing,
              productsReady: productsReady,
              price: price,
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent({
    required bool isProcessing,
    required bool productsReady,
    required String? price,
  }) {
    if (isProcessing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            settings.getLabel('supportLoading'),
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (!productsReady || price == null) {
      // Products still loading from Play Store. Show subdued state so the
      // user understands it's not broken — just waiting on the network.
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            settings.getLabel('supportLoading'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.favorite_rounded, size: 20),
        const SizedBox(width: 10),
        Text(
          '${settings.getLabel('supportButton')}  $price',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Post-purchase thank-you view ──────────────────────────────────────────

class _PremiumThanksView extends StatelessWidget {
  final SettingsProvider settings;

  const _PremiumThanksView({required this.settings});

  @override
  Widget build(BuildContext context) {
    final accent = context.appAccent;

    return SafeArea(
      top: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Filled heart hero ───────────────────────────────────────
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.25),
                      accent.withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 76,
                  color: accent,
                ),
              ),

              const SizedBox(height: 28),

              // ── Title (Jazākallāhu khayrān per locale) ──────────────────
              Text(
                settings.getLabel('supportThanksTitle'),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.appTextPrimary,
                ),
              ),

              const SizedBox(height: 16),

              // ── Message ─────────────────────────────────────────────────
              Text(
                settings.getLabel('supportThanksMessage'),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.6,
                  color: context.appTextSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // ── Status pill ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      settings.getLabel('supportBenefit1'),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
