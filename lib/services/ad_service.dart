import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages App Open Ad lifecycle for Waktu Shalat.
///
/// **Scope (Ship 3 — scaffolding):**
/// - Loads & shows a single App Open Ad on demand.
/// - Hardcoded TEST ad unit IDs (Google official) — safe to ship to dev.
/// - Production ad unit IDs are swapped in once AdMob account is approved.
///
/// **NOT yet implemented (deferred to Bulan 2):**
/// - Cooldown (4h between ads)
/// - Daily cap (max 3/day)
/// - Skip during prayer time window
/// - Skip first 24h after install
/// - Premium user bypass
///
/// **Why singleton:** App Open Ads are app-global (one at a time, tied to
/// app lifecycle). Sharing a single instance keeps state consistent.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // ── Ad unit IDs ────────────────────────────────────────────────────────
  // Google's official test IDs — render real-looking ads but never bill
  // and never get the AdMob account flagged.
  // Source: https://developers.google.com/admob/flutter/test-ads
  //
  // Production IDs (Frosthoot Studio AdMob, registered 2026-04-27):
  //   Android App ID         : ca-app-pub-4236028330675226~1941898552
  //                            (also in AndroidManifest.xml meta-data)
  //   Android App Open unit  : ca-app-pub-4236028330675226/7453854346
  //   iOS App Open unit      : (not yet registered — iOS not shipped)
  //
  // SWAP to production when Bulan 2 (App Open Ad implementation) is ready
  // AND all guards (cooldown, daily cap, prayer-time skip, premium bypass)
  // are wired. Using prod IDs in dev = risk of "invalid traffic" account
  // flag from Google.

  static const String _androidTestAppOpenUnitId =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _iosTestAppOpenUnitId =
      'ca-app-pub-3940256099942544/5575463023';

  String get _appOpenUnitId {
    if (Platform.isAndroid) return _androidTestAppOpenUnitId;
    if (Platform.isIOS) return _iosTestAppOpenUnitId;
    throw UnsupportedError('AdMob only supports Android & iOS');
  }

  // ── State ──────────────────────────────────────────────────────────────

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  DateTime? _loadedAt;

  /// App Open Ads expire after 4 hours per Google's contract.
  static const Duration _adValidityWindow = Duration(hours: 4);

  bool get _isAdAvailable {
    if (_appOpenAd == null || _loadedAt == null) return false;
    return DateTime.now().difference(_loadedAt!) < _adValidityWindow;
  }

  // ── Public API ─────────────────────────────────────────────────────────

  /// Called once during app boot. Triggers first ad load in background.
  Future<void> initialize() async {
    await loadAd();
  }

  /// Loads (or reloads) the App Open Ad. Safe to call repeatedly — guards
  /// against double-load.
  Future<void> loadAd() async {
    if (_appOpenAd != null) return;

    await AppOpenAd.load(
      adUnitId: _appOpenUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _loadedAt  = DateTime.now();
          debugPrint('[AdService] App Open Ad loaded');
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          _loadedAt  = null;
          debugPrint('[AdService] App Open Ad load failed: $error');
        },
      ),
    );
  }

  /// Shows the loaded App Open Ad if available.
  ///
  /// **Note:** This method does NOT yet implement cooldown, daily cap,
  /// prayer-time skip, first-24h grace period, or premium bypass — those
  /// guards belong in Bulan 2 (App Open Ad implementation phase).
  /// For now, callers are responsible for deciding when to call this.
  Future<void> showAdIfAvailable() async {
    if (_isShowingAd) {
      debugPrint('[AdService] Already showing an ad, skipping');
      return;
    }
    if (!_isAdAvailable) {
      debugPrint('[AdService] No ad available, loading a new one');
      await loadAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _isShowingAd = true;
        debugPrint('[AdService] Ad shown');
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        _loadedAt  = null;
        loadAd(); // preload next
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        _loadedAt  = null;
        debugPrint('[AdService] Ad failed to show: $error');
        loadAd();
      },
    );

    await _appOpenAd!.show();
  }
}
