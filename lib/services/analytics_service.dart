import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Singleton wrapper around [FirebaseAnalytics] used throughout the app.
///
/// Why a singleton:
/// - One [FirebaseAnalyticsObserver] instance is shared with `MaterialApp`,
///   which auto-logs `screen_view` for every named route push.
/// - Custom event helpers live in one place so callers don't pass strings
///   ad-hoc (avoids typos that fragment Firebase reports).
///
/// All log methods are fire-and-forget — failures are swallowed so analytics
/// never breaks the user-facing flow.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  late final FirebaseAnalytics _analytics;
  late final FirebaseAnalyticsObserver _observer;

  bool _ready = false;

  FirebaseAnalyticsObserver get observer => _observer;
  FirebaseAnalytics get analytics => _analytics;

  /// Must be called once after `Firebase.initializeApp()` completes.
  Future<void> initialize() async {
    _analytics = FirebaseAnalytics.instance;
    _observer  = FirebaseAnalyticsObserver(analytics: _analytics);

    // In debug builds we still want events to flow to DebugView; in release
    // collection is always on.
    await _analytics.setAnalyticsCollectionEnabled(true);
    _ready = true;
  }

  // ── Custom events ──────────────────────────────────────────────────────
  // Keep parameter names short (<40 chars) and lowercase_snake_case per
  // Firebase reserved-name rules.

  Future<void> logPrayerTimeViewed({required String prayer}) =>
      _safe(() => _analytics.logEvent(
            name: 'prayer_time_viewed',
            parameters: {'prayer': prayer},
          ));

  Future<void> logSurahOpened({required int surahNumber}) =>
      _safe(() => _analytics.logEvent(
            name: 'surah_opened',
            parameters: {'surah_number': surahNumber},
          ));

  Future<void> logAyahBookmarked({
    required int surahNumber,
    required int ayahNumber,
  }) =>
      _safe(() => _analytics.logEvent(
            name: 'ayah_bookmarked',
            parameters: {
              'surah_number': surahNumber,
              'ayah_number': ayahNumber,
            },
          ));

  Future<void> logDzikirCompleted({required String category}) =>
      _safe(() => _analytics.logEvent(
            name: 'dzikir_completed',
            parameters: {'category': category},
          ));

  Future<void> logQiblaOpened() =>
      _safe(() => _analytics.logEvent(name: 'qibla_opened'));

  Future<void> logSettingsOpened() =>
      _safe(() => _analytics.logEvent(name: 'settings_opened'));

  Future<void> logMurottalPlayed({
    required int surahNumber,
    required String reciter,
  }) =>
      _safe(() => _analytics.logEvent(
            name: 'murottal_played',
            parameters: {
              'surah_number': surahNumber,
              'reciter': reciter,
            },
          ));

  // ── IAP / monetization events (Bulan 3) ────────────────────────────────
  // Funnel: support_screen_viewed → purchase_initiated → purchase_completed
  //                                                    → purchase_failed
  //                                                    → purchase_canceled
  // Restore flow: purchase_restored

  Future<void> logSupportScreenViewed() =>
      _safe(() => _analytics.logEvent(name: 'support_screen_viewed'));

  Future<void> logPurchaseInitiated({required String productId}) =>
      _safe(() => _analytics.logEvent(
            name: 'purchase_initiated',
            parameters: {'product_id': productId},
          ));

  Future<void> logPurchaseCompleted({
    required String productId,
    String? priceLocalized,
    String? currencyCode,
  }) =>
      _safe(() => _analytics.logEvent(
            name: 'purchase_completed',
            parameters: {
              'product_id': productId,
              'price_localized': ?priceLocalized,
              'currency': ?currencyCode,
            },
          ));

  Future<void> logPurchaseFailed({
    required String productId,
    String? reason,
  }) =>
      _safe(() => _analytics.logEvent(
            name: 'purchase_failed',
            parameters: {
              'product_id': productId,
              'reason': ?reason,
            },
          ));

  Future<void> logPurchaseCanceled({required String productId}) =>
      _safe(() => _analytics.logEvent(
            name: 'purchase_canceled',
            parameters: {'product_id': productId},
          ));

  Future<void> logPurchaseRestored({required String productId}) =>
      _safe(() => _analytics.logEvent(
            name: 'purchase_restored',
            parameters: {'product_id': productId},
          ));

  // ── User properties (long-lived, used for audience segmentation) ───────

  Future<void> setUserLanguage(String code) =>
      _safe(() => _analytics.setUserProperty(name: 'language', value: code));

  Future<void> setUserCalculationMethod(String method) =>
      _safe(() => _analytics.setUserProperty(
            name: 'calc_method',
            value: method,
          ));

  Future<void> setUserArabicFont(String font) =>
      _safe(() => _analytics.setUserProperty(name: 'arabic_font', value: font));

  Future<void> setIsPremium(bool premium) =>
      _safe(() => _analytics.setUserProperty(
            name: 'is_premium',
            value: premium ? 'true' : 'false',
          ));

  // ── Internal ───────────────────────────────────────────────────────────

  Future<void> _safe(Future<void> Function() op) async {
    if (!_ready) return;
    try {
      await op();
    } catch (e, stack) {
      debugPrint('Analytics error: $e\n$stack');
    }
  }
}
