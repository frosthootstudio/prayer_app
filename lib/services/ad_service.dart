import 'dart:io' show Platform;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

/// Manages App Open Ad lifecycle for Waktu Shalat.
///
/// **Guards (Bulan 2 — full implementation):**
/// - [Premium bypass] supporters who bought `premium_lifetime` see no ads
/// - [Install kindness] no ads in the first 24h after install
/// - [Cooldown] minimum 4h between consecutive ads
/// - [Daily cap] max 3 ads per calendar day
/// - [Prayer-time skip] no ads within ±10 min of any of today's adzan times
///
/// **Tunable for testing via --dart-define** (see constants below).
///
/// **Why singleton:** App Open Ads are app-global (one at a time, tied to
/// app lifecycle). Sharing a single instance keeps state consistent.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // ── Ad unit IDs ────────────────────────────────────────────────────────
  // Frosthoot Studio production AdMob account (Publisher ID:
  // pub-4236028330675226, registered 2026-04-27). Swapped from Google's
  // official test IDs at end of Bulan 2 (2026-04-29) after all guards
  // verified on Waydroid.
  //
  // Test IDs kept commented for quick rollback if needed:
  //   _androidTestAppOpenUnitId = 'ca-app-pub-3940256099942544/9257395921'
  //   _iosTestAppOpenUnitId     = 'ca-app-pub-3940256099942544/5575463023'
  //
  // iOS is NOT YET registered in AdMob — iOS not shipped. When iOS ships,
  // register iOS app in AdMob Console + add real iOS unit ID below.
  //
  // ⚠️  DO NOT click ads on dev devices once these are live — risk of
  //     AdMob "invalid traffic" account flag.

  static const String _androidProdAppOpenUnitId =
      'ca-app-pub-4236028330675226/7453854346';
  static const String _iosProdAppOpenUnitId =
      'ca-app-pub-3940256099942544/5575463023'; // still TEST until iOS ships

  String get _appOpenUnitId {
    if (Platform.isAndroid) return _androidProdAppOpenUnitId;
    if (Platform.isIOS) return _iosProdAppOpenUnitId;
    throw UnsupportedError('AdMob only supports Android & iOS');
  }

  // ── Tunable guard constants ────────────────────────────────────────────
  //
  // Override via --dart-define for fast testing. Examples:
  //   --dart-define=AD_COOLDOWN_MINUTES=1     (instead of 240 = 4h)
  //   --dart-define=AD_KINDNESS_HOURS=0       (skip 24h kindness window)
  //   --dart-define=AD_PRAYER_WINDOW_MINUTES=2 (smaller skip window)
  //   --dart-define=AD_DAILY_CAP=99           (effectively no cap)
  //
  // Production builds always use defaults (no dart-define passed).

  static const int _kCooldownMinutes =
      int.fromEnvironment('AD_COOLDOWN_MINUTES', defaultValue: 240);
  static const int _kKindnessHours =
      int.fromEnvironment('AD_KINDNESS_HOURS', defaultValue: 24);
  static const int _kPrayerWindowMinutes =
      int.fromEnvironment('AD_PRAYER_WINDOW_MINUTES', defaultValue: 10);
  static const int _kDailyCap =
      int.fromEnvironment('AD_DAILY_CAP', defaultValue: 3);

  static Duration get _cooldown => const Duration(minutes: _kCooldownMinutes);
  static Duration get _kindnessWindow =>
      const Duration(hours: _kKindnessHours);
  static Duration get _prayerWindowHalf =>
      const Duration(minutes: _kPrayerWindowMinutes);

  // ── Hive keys (in `settings` box) ──────────────────────────────────────
  // The `settings` box is opened by SettingsProvider during boot, so it's
  // safe to read/write here once init has run.

  static const String _kInstallFirstSeenMsKey = 'ad_install_first_seen_ms';
  static const String _kLastShownMsKey = 'ad_last_shown_ms';
  static const String _kCountTodayKey = 'ad_count_today';
  static const String _kCountDateKey = 'ad_count_date'; // YYYY-MM-DD

  Box get _box => Hive.box('settings');

  // ── State ──────────────────────────────────────────────────────────────

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isLoading = false;
  DateTime? _loadedAt;

  /// App Open Ads expire after 4 hours per Google's contract.
  static const Duration _adValidityWindow = Duration(hours: 4);

  bool get _isAdAvailable {
    if (_appOpenAd == null || _loadedAt == null) return false;
    return DateTime.now().difference(_loadedAt!) < _adValidityWindow;
  }

  // ── Public API ─────────────────────────────────────────────────────────

  /// Called once during app boot. Stamps install timestamp on very first
  /// launch and triggers first ad load in background.
  Future<void> initialize() async {
    _stampFirstLaunchIfNeeded();
    await loadAd();
  }

  /// Loads (or reloads) the App Open Ad. Safe to call repeatedly — guards
  /// against double-load via both the in-flight `_isLoading` flag and the
  /// already-loaded `_appOpenAd` reference. Without the in-flight flag,
  /// two concurrent loads (e.g., AdService.initialize racing with the
  /// cold-start postFrameCallback) would both succeed and the second
  /// would overwrite + leak the first.
  Future<void> loadAd() async {
    if (_appOpenAd != null) return;
    if (_isLoading) return;
    _isLoading = true;

    try {
      await AppOpenAd.load(
        adUnitId: _appOpenUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            _loadedAt = DateTime.now();
            _isLoading = false;
            debugPrint('[AdService] App Open Ad loaded');
          },
          onAdFailedToLoad: (error) {
            _appOpenAd = null;
            _loadedAt = null;
            _isLoading = false;
            debugPrint('[AdService] App Open Ad load failed: $error');
            FirebaseCrashlytics.instance.recordError(
              error, StackTrace.current,
              reason: 'app_open_ad_load_failed', fatal: false,
            );
          },
        ),
      );
    } catch (e) {
      _isLoading = false;
      debugPrint('[AdService] loadAd threw: $e');
      FirebaseCrashlytics.instance.recordError(
        e, StackTrace.current,
        reason: 'ad_service_load_threw', fatal: false,
      );
    }
  }

  /// Shows the loaded App Open Ad if all guards pass.
  ///
  /// Caller must provide:
  /// - [prayerTimesToday]: today's adzan times (used for prayer-window skip)
  /// - [isPremium]: whether the user has bought premium (skips ad entirely)
  ///
  /// Returns silently if any guard fails. Reasons are logged via
  /// `debugPrint` for verification.
  Future<void> showAdIfAvailable({
    required List<DateTime> prayerTimesToday,
    required bool isPremium,
  }) async {
    final skipReason = _checkGuards(
      prayerTimesToday: prayerTimesToday,
      isPremium: isPremium,
    );
    if (skipReason != null) {
      debugPrint('[AdService] Skipping ad: $skipReason');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _isShowingAd = true;
        _recordShown();
        debugPrint('[AdService] Ad shown');
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        _loadedAt = null;
        loadAd(); // preload next
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        _loadedAt = null;
        debugPrint('[AdService] Ad failed to show: $error');
        FirebaseCrashlytics.instance.recordError(
          error, StackTrace.current,
          reason: 'app_open_ad_show_failed', fatal: false,
        );
        loadAd();
      },
    );

    await _appOpenAd!.show();
  }

  // ── Guards ─────────────────────────────────────────────────────────────

  /// Returns null if ad can show, otherwise a human-readable skip reason.
  ///
  /// All Hive access is wrapped in try/catch so a not-yet-open box (edge
  /// case if init failed) never crashes the host code path.
  String? _checkGuards({
    required List<DateTime> prayerTimesToday,
    required bool isPremium,
  }) {
    // 1. Premium bypass — supporters never see ads.
    if (isPremium) return 'user is premium';

    // 2. Already showing — defensive guard against double-trigger.
    if (_isShowingAd) return 'already showing an ad';

    // 3. Ad must be loaded. If not, kick off a load and bail (next chance
    //    will likely succeed).
    if (!_isAdAvailable) {
      loadAd();
      return 'no ad loaded yet, requesting fetch';
    }

    final Box box;
    try {
      box = _box;
    } catch (e) {
      // Hive `settings` box not open — bail safe (no ad).
      return 'settings box not open ($e)';
    }

    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;

    // 4. Install kindness window — no ads in the first 24h. New users get
    //    a clean experience to learn the app before being monetized.
    var installMs = box.get(_kInstallFirstSeenMsKey) as int?;
    if (installMs == null) {
      // Fallback stamp — if init didn't get to stamp this, do it now so
      // the kindness window starts from this first ad attempt.
      box.put(_kInstallFirstSeenMsKey, nowMs);
      installMs = nowMs;
      debugPrint('[AdService] Lazy-stamped install_ms=$nowMs');
    }
    final installAge = Duration(milliseconds: nowMs - installMs);
    if (installAge < _kindnessWindow) {
      final remaining = _kindnessWindow - installAge;
      final label = remaining.inHours > 0
          ? '${remaining.inHours}h'
          : '${remaining.inMinutes}m';
      return 'install kindness window ($label left)';
    }

    // 5. Cooldown — minimum N minutes between ads.
    final lastShownMs = box.get(_kLastShownMsKey) as int?;
    if (lastShownMs != null) {
      final sinceLast = Duration(milliseconds: nowMs - lastShownMs);
      if (sinceLast < _cooldown) {
        final remaining = _cooldown - sinceLast;
        final label = remaining.inMinutes > 0
            ? '${remaining.inMinutes}m'
            : '${remaining.inSeconds}s';
        return 'cooldown active ($label left)';
      }
    }

    // 6. Daily cap — max N ads per calendar day. Date rollover handled by
    //    comparing today's date string to stored date string.
    final today = DateFormat('yyyy-MM-dd').format(now);
    final countDate = box.get(_kCountDateKey) as String?;
    final countToday = countDate == today
        ? (box.get(_kCountTodayKey, defaultValue: 0) as int)
        : 0;
    if (countToday >= _kDailyCap) {
      return 'daily cap reached ($countToday/$_kDailyCap)';
    }

    // 7. Prayer-time window — skip if within ±N min of any adzan today.
    //    Worship moments should never be interrupted by ads.
    for (final prayerTime in prayerTimesToday) {
      final diff = now.difference(prayerTime).abs();
      if (diff < _prayerWindowHalf) {
        return 'within prayer-time window '
            '(±${_prayerWindowHalf.inMinutes}m of adzan)';
      }
    }

    return null; // All guards passed.
  }

  // ── Persistence helpers ────────────────────────────────────────────────

  /// Stamps the install timestamp on very first launch (idempotent).
  void _stampFirstLaunchIfNeeded() {
    try {
      final existing = _box.get(_kInstallFirstSeenMsKey) as int?;
      if (existing == null) {
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        _box.put(_kInstallFirstSeenMsKey, nowMs);
        debugPrint('[AdService] First launch detected, stamped install_ms=$nowMs');
      }
    } catch (e) {
      // Settings box not yet open — initialize() can be called before
      // SettingsProvider.initialize() finishes if init order changes.
      // Stamp lazily later (guards re-check).
      debugPrint('[AdService] Could not stamp first launch yet: $e');
    }
  }

  /// Records a successful ad-show event: timestamp + daily counter
  /// increment with date rollover.
  void _recordShown() {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final countDate = _box.get(_kCountDateKey) as String?;
    final currentCount =
        countDate == today ? (_box.get(_kCountTodayKey, defaultValue: 0) as int) : 0;

    _box.put(_kLastShownMsKey, now.millisecondsSinceEpoch);
    _box.put(_kCountDateKey, today);
    _box.put(_kCountTodayKey, currentCount + 1);

    debugPrint(
      '[AdService] Recorded ad show: count=${currentCount + 1}/$_kDailyCap, '
      'date=$today',
    );
  }

  // ── Debug helpers (for verification on Waydroid) ───────────────────────

  /// Returns a human-readable snapshot of guard state. Use for debug
  /// logging or a future debug screen.
  Map<String, dynamic> debugSnapshot() {
    final now = DateTime.now();
    final installMs = _box.get(_kInstallFirstSeenMsKey) as int?;
    final lastShownMs = _box.get(_kLastShownMsKey) as int?;
    final today = DateFormat('yyyy-MM-dd').format(now);
    final countDate = _box.get(_kCountDateKey) as String?;
    final countToday =
        countDate == today ? (_box.get(_kCountTodayKey, defaultValue: 0) as int) : 0;

    return {
      'isAdLoaded': _isAdAvailable,
      'isShowingAd': _isShowingAd,
      'installAge': installMs == null
          ? 'not stamped'
          : '${Duration(milliseconds: now.millisecondsSinceEpoch - installMs).inHours}h',
      'lastShownAgo': lastShownMs == null
          ? 'never'
          : '${Duration(milliseconds: now.millisecondsSinceEpoch - lastShownMs).inMinutes}m',
      'countToday': '$countToday/$_kDailyCap',
      'guardsActive': {
        'kindnessHours': _kKindnessHours,
        'cooldownMinutes': _kCooldownMinutes,
        'prayerWindowMinutes': _kPrayerWindowMinutes,
        'dailyCap': _kDailyCap,
      },
    };
  }
}
