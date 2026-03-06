import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/prayer_model.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_calculation_service.dart';
import '../services/widget_service.dart';
import 'settings_provider.dart';

class PrayerProvider extends ChangeNotifier with WidgetsBindingObserver {
  PrayerProvider(this._settings) {
    // Snapshot initial settings values so we can detect future changes.
    _prevCalcMethod      = _settings.calcMethod;
    _prevMadhab          = _settings.madhab;
    _prevLanguage        = _settings.language;
    _prevMasterNotif     = _settings.masterNotifEnabled;
    _prevPreAdzanEnabled = _settings.preAdzanEnabled;
    _prevPreAdzanMinutes = _settings.preAdzanMinutes;
    _settings.addListener(_onSettingsChanged);
  }

  // ── Services ──────────────────────────────────────────────────────────────
  final SettingsProvider _settings;
  final _location = LocationService();
  final _calc     = PrayerCalculationService();

  // ── Public state ──────────────────────────────────────────────────────────
  List<PrayerInfo>   prayerTimes = [];
  PrayerInfo?        nextPrayer;
  String             cityName     = '';
  String             gregorianDate = '';
  String             hijriDate    = '';
  String             countdown    = '--:--:--';
  bool               isLoading    = true;
  String?            error;
  Map<String, bool>  notifPrefs   = {};

  // ── Internal ──────────────────────────────────────────────────────────────
  Timer?    _ticker;
  Timer?    _midnightTimer;
  DateTime? _calcDate;
  bool      _initialized = false;
  late Box  _box;
  int       _lastWidgetUpdateMinute = -1; // tracks per-minute widget refresh

  // Cached GPS coordinates (avoids re-fetching when only calc settings change)
  double? _lastLat;
  double? _lastLng;

  // Settings change detection
  CalcMethod?    _prevCalcMethod;
  MadhabSetting? _prevMadhab;
  AppLanguage?   _prevLanguage;
  bool?          _prevMasterNotif;
  bool?          _prevPreAdzanEnabled;
  int?           _prevPreAdzanMinutes;

  // ── Hijri month names ─────────────────────────────────────────────────────
  static const _hijriMonthsId = [
    'Muharram', 'Safar', 'Rabiul Awal', 'Rabiul Akhir',
    'Jumadil Awal', 'Jumadil Akhir', 'Rajab', "Sya'ban",
    'Ramadhan', 'Syawal', "Dzulqa'idah", 'Dzulhijjah',
  ];
  static const _hijriMonthsEn = [
    'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
    'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', "Sha'ban",
    'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
  ];

  // ── Gregorian → Hijri conversion (Dershowitz–Reingold algorithm) ──────────
  static (int, int, int) _gregorianToHijri(int gy, int gm, int gd) {
    final fixed = _gregorianToFixed(gy, gm, gd);
    return _hijriFromFixed(fixed);
  }

  static bool _isGregorianLeap(int y) =>
      y % 4 == 0 && (y % 100 != 0 || y % 400 == 0);

  static int _gregorianToFixed(int y, int m, int d) {
    return 365 * (y - 1) +
        (y - 1) ~/ 4 -
        (y - 1) ~/ 100 +
        (y - 1) ~/ 400 +
        (367 * m - 362) ~/ 12 +
        (m <= 2 ? 0 : _isGregorianLeap(y) ? -1 : -2) +
        d;
  }

  static const _islamicEpoch = 227015;

  static int _islamicToFixed(int year, int month, int day) {
    return _islamicEpoch - 1 +
        (year - 1) * 354 +
        (3 + 11 * year) ~/ 30 +
        29 * (month - 1) +
        month ~/ 2 +
        day;
  }

  static (int, int, int) _hijriFromFixed(int fixed) {
    final year     = (30 * (fixed - _islamicEpoch) + 10646) ~/ 10631;
    final priorDays = fixed - _islamicToFixed(year, 1, 1);
    final month    = ((11 * priorDays + 330) ~/ 325).clamp(1, 12);
    final day      = fixed - _islamicToFixed(year, month, 1) + 1;
    return (year, month, day);
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addObserver(this);
    _box = await Hive.openBox('settings');
    _loadNotifPrefs();

    // Load cached GPS coordinates so we can skip GPS when autoLocation=false
    _lastLat = _box.get('lastLat') as double?;
    _lastLng = _box.get('lastLng') as double?;

    await NotificationService.initialize();
    await NotificationService.requestPermission();

    await _refreshAll();
    _scheduleMidnightRefresh();
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _refreshAll();
        _scheduleMidnightRefresh();
        break;
      case AppLifecycleState.paused:
        _cancelTimers();
        break;
      default:
        break;
    }
  }

  // ── Settings change handler ────────────────────────────────────────────────
  //
  // Called whenever SettingsProvider notifies. Only triggers work when the
  // fields that actually affect prayer calculation or notifications change.

  void _onSettingsChanged() {
    if (!_initialized) return;

    final calcChanged = _settings.calcMethod != _prevCalcMethod ||
        _settings.madhab != _prevMadhab ||
        _settings.language != _prevLanguage;
    final notifChanged = _settings.masterNotifEnabled != _prevMasterNotif;
    final preAdzanChanged = _settings.preAdzanEnabled != _prevPreAdzanEnabled ||
        _settings.preAdzanMinutes != _prevPreAdzanMinutes;

    _prevCalcMethod      = _settings.calcMethod;
    _prevMadhab          = _settings.madhab;
    _prevLanguage        = _settings.language;
    _prevMasterNotif     = _settings.masterNotifEnabled;
    _prevPreAdzanEnabled = _settings.preAdzanEnabled;
    _prevPreAdzanMinutes = _settings.preAdzanMinutes;

    if (calcChanged && _lastLat != null) {
      _recalculate();
    } else if (notifChanged || preAdzanChanged) {
      _applyMasterNotif();
    }
  }

  // ── Public actions ────────────────────────────────────────────────────────

  /// Force a full GPS refresh regardless of autoLocation setting.
  Future<void> retryLocation() async {
    _lastLat = null;
    _lastLng = null;
    await _refreshAll();
  }

  /// Toggle adzan notification on/off for [key] (e.g. 'fajr').
  /// Persists to Hive; respects master notif setting.
  Future<void> toggleNotification(String key) async {
    final next = !(notifPrefs[key] ?? true);
    notifPrefs = {...notifPrefs, key: next};
    await _box.put('notif_$key', next);

    if (_settings.masterNotifEnabled) {
      final prayer = prayerTimes.where((p) => p.key == key).firstOrNull;
      if (next && prayer != null) {
        await NotificationService.scheduleOne(prayer);
        if (_settings.preAdzanEnabled) {
          await NotificationService.schedulePreAdzan(
            prayer,
            _settings.preAdzanMinutes,
            isEnglish: _settings.isEnglish,
          );
        }
      } else {
        await NotificationService.cancelOne(key);
        await NotificationService.cancelPreAdzan(key);
      }
    }

    notifyListeners();
  }

  // ── Core refresh ─────────────────────────────────────────────────────────

  Future<void> _refreshAll() async {
    isLoading = true;
    error     = null;
    notifyListeners();

    try {
      // Decide whether to use GPS or cached coordinates
      final needGps = _settings.autoLocation || _lastLat == null;

      if (needGps) {
        final position = await _location.getCurrentPosition();
        if (position == null) {
          error     = _settings.language == AppLanguage.en
              ? 'Location permission required.\nOpen Settings and allow location access.'
              : 'Izin lokasi diperlukan.\nBuka Pengaturan dan izinkan akses lokasi.';
          isLoading = false;
          notifyListeners();
          return;
        }
        _lastLat = position.latitude;
        _lastLng = position.longitude;
        _box.put('lastLat', _lastLat);
        _box.put('lastLng', _lastLng);

        // Reverse-geocode city name (best-effort, non-blocking)
        cityName = _box.get('lastCity', defaultValue: '') as String;
        _location.getCityName(_lastLat!, _lastLng!).then((name) {
          if (name != cityName) {
            cityName = name;
            _box.put('lastCity', name);
            notifyListeners();
          }
        });
      } else {
        // Use cached position; keep the last known city name
        cityName = _box.get('lastCity', defaultValue: '') as String;
      }

      final now = DateTime.now();
      _calcDate   = now;
      prayerTimes = _calc.calculate(
        _lastLat!,
        _lastLng!,
        method:   _settings.calcMethod,
        madhab:   _settings.madhab,
        language: _settings.language,
      );

      _updateDates(now);
      _updateNextPrayer();

      isLoading = false;
      notifyListeners();

      // Schedule notifications (respects master switch + per-prayer prefs)
      _scheduleNotifications();

      // Push fresh prayer data to home screen widgets
      unawaited(WidgetService.update(
        prayers:  prayerTimes,
        language: _settings.language,
      ));

      _startTicker();
    } catch (e) {
      error     = _settings.language == AppLanguage.en
          ? 'Failed to load prayer times.\n$e'
          : 'Gagal memuat waktu shalat.\n$e';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Recalculate prayer times using cached GPS coordinates.
  /// Called when calc method / madhab / language changes.
  Future<void> _recalculate() async {
    if (_lastLat == null || _lastLng == null) return;

    final now = DateTime.now();
    _calcDate   = now;
    prayerTimes = _calc.calculate(
      _lastLat!,
      _lastLng!,
      method:   _settings.calcMethod,
      madhab:   _settings.madhab,
      language: _settings.language,
    );

    _updateDates(now);
    _updateNextPrayer();
    _scheduleNotifications();

    // Push recalculated prayer data to home screen widgets
    unawaited(WidgetService.update(
      prayers:  prayerTimes,
      language: _settings.language,
    ));

    notifyListeners();
  }

  void _applyMasterNotif() {
    if (_settings.masterNotifEnabled) {
      NotificationService.scheduleAll(
        prayerTimes,
        notifPrefs,
        preAdzanEnabled: _settings.preAdzanEnabled,
        preAdzanMinutes: _settings.preAdzanMinutes,
        isEnglish:       _settings.isEnglish,
      );
    } else {
      NotificationService.cancelAll();
    }
  }

  void _scheduleNotifications() {
    if (_settings.masterNotifEnabled) {
      NotificationService.scheduleAll(
        prayerTimes,
        notifPrefs,
        preAdzanEnabled: _settings.preAdzanEnabled,
        preAdzanMinutes: _settings.preAdzanMinutes,
        isEnglish:       _settings.isEnglish,
      );
    } else {
      NotificationService.cancelAll();
    }
  }

  // ── Notification preference helpers ───────────────────────────────────────

  void _loadNotifPrefs() {
    notifPrefs = {
      for (final key in const ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'])
        key: _box.get('notif_$key', defaultValue: true) as bool,
    };
  }

  // ── Date helpers ──────────────────────────────────────────────────────────

  void _updateDates(DateTime now) {
    final isEn    = _settings.language == AppLanguage.en;
    final locale  = isEn ? 'en_US' : 'id_ID';
    gregorianDate = DateFormat('EEEE, d MMMM yyyy', locale).format(now);

    try {
      final h      = _gregorianToHijri(now.year, now.month, now.day);
      final months = isEn ? _hijriMonthsEn : _hijriMonthsId;
      final month  = months[(h.$2 - 1).clamp(0, 11)];
      hijriDate    = '${h.$3} $month ${h.$1} H';
    } catch (_) {
      hijriDate = '';
    }
  }

  void _updateNextPrayer() {
    if (prayerTimes.isEmpty) return;
    prayerTimes = _calc.refreshStatus(prayerTimes);
    nextPrayer  = prayerTimes.firstWhere(
      (p) => p.isNext,
      orElse: () => prayerTimes.last,
    );
    if (!prayerTimes.any((p) => p.isNext)) nextPrayer = null;
  }

  // ── Countdown ticker ──────────────────────────────────────────────────────

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();

    if (_calcDate != null && now.day != _calcDate!.day) {
      _refreshAll();
      return;
    }

    _updateNextPrayer();

    if (nextPrayer == null) {
      countdown = '--:--:--';
    } else {
      final diff = nextPrayer!.time.difference(now);
      if (diff.isNegative) {
        countdown = '--:--:--';
      } else {
        final h = diff.inHours.toString().padLeft(2, '0');
        final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
        countdown = '$h:$m:$s';
      }
    }

    // Update home screen widget once per minute (not every second)
    if (now.minute != _lastWidgetUpdateMinute) {
      _lastWidgetUpdateMinute = now.minute;
      unawaited(WidgetService.update(
        prayers:  prayerTimes,
        language: _settings.language,
      ));
    }

    notifyListeners();
  }

  // ── Midnight auto-refresh ─────────────────────────────────────────────────

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now      = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1)
        .add(const Duration(seconds: 5));
    _midnightTimer = Timer(midnight.difference(now), _refreshAll);
  }

  void _cancelTimers() {
    _ticker?.cancel();
    _midnightTimer?.cancel();
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    WidgetsBinding.instance.removeObserver(this);
    _cancelTimers();
    super.dispose();
  }
}
