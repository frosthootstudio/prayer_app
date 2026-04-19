import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/prayer_calculation_service.dart';

enum AdzanSound {
  // rawResource = filename (no extension) used for:
  //   • android/app/src/main/res/raw/<rawResource>.mp3  → notification sound
  //   • assets/audio/<rawResource>.mp3                  → in-app preview
  // Indices are persisted to Hive — do NOT reorder.
  adzan    ('Adzan',         'adzan'),      // index 0
  adzanFajr('Adzan Subuh',  'adzan_fajr'), // index 1
  none     ('Suara Bawaan HP', '');         // index 2

  const AdzanSound(this.displayName, this.rawResource);
  final String displayName;
  final String rawResource;

  bool get hasAudio => rawResource.isNotEmpty;

  /// URI for awesome_notifications NotificationChannel.soundSource.
  /// Returns null for [none] (channel uses default system alarm).
  String? get soundSource =>
      hasAudio ? 'resource://raw/$rawResource' : null;

  /// Flutter asset path for in-app preview.
  String? get assetPath =>
      hasAudio ? 'audio/$rawResource.mp3' : null;
}

class SettingsProvider extends ChangeNotifier {
  // ── Persisted settings ────────────────────────────────────────────────────
  ThemeMode      themeMode          = ThemeMode.system;
  AppLanguage    language           = AppLanguage.id;
  CalcMethod     calcMethod         = CalcMethod.kemenag;
  MadhabSetting  madhab             = MadhabSetting.shafi;
  bool           autoLocation       = true;
  bool           masterNotifEnabled = true;
  bool           preAdzanEnabled    = false;
  int            preAdzanMinutes    = 10;
  Map<String, int> prayerTimeOffsets = const {
    'fajr': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0,
  };
  AdzanSound     adzanSound         = AdzanSound.adzan;
  AdzanSound     adzanSoundFajr    = AdzanSound.adzanFajr;
  double         adzanVolume        = 0.8;

  late Box _box;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _box = await Hive.openBox('settings');
    _load();
  }

  void _load() {
    themeMode  = _parseTheme(_box.get('themeMode', defaultValue: 'system') as String);
    language   = AppLanguage.values[(_box.get('language',  defaultValue: 0) as int).clamp(0, AppLanguage.values.length - 1)];
    calcMethod = CalcMethod.values[(_box.get('calcMethod', defaultValue: 0) as int).clamp(0, CalcMethod.values.length - 1)];
    madhab     = MadhabSetting.values[(_box.get('madhab',  defaultValue: 0) as int).clamp(0, MadhabSetting.values.length - 1)];
    autoLocation       = _box.get('autoLocation',       defaultValue: true)  as bool;
    masterNotifEnabled = _box.get('masterNotifEnabled', defaultValue: true)  as bool;
    preAdzanEnabled    = _box.get('preAdzanEnabled',    defaultValue: false) as bool;
    preAdzanMinutes   = (_box.get('preAdzanMinutes', defaultValue: 10) as int).clamp(5, 30);
    prayerTimeOffsets = {
      for (final k in const ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'])
        k: (_box.get('prayerOffset_$k', defaultValue: 0) as int).clamp(-10, 10),
    };
    adzanSound        = AdzanSound.values[(_box.get('adzanSound',      defaultValue: 0) as int).clamp(0, AdzanSound.values.length - 1)];
    adzanSoundFajr    = AdzanSound.values[(_box.get('adzanSoundFajr', defaultValue: 1) as int).clamp(0, AdzanSound.values.length - 1)];
    adzanVolume       = (_box.get('adzanVolume', defaultValue: 0.8) as double).clamp(0.0, 1.0);
  }

  // ── Human-readable labels ─────────────────────────────────────────────────

  String get themeModeLabel => switch (themeMode) {
        ThemeMode.light => getLabel('light'),
        ThemeMode.dark  => getLabel('dark'),
        _               => getLabel('followSystem'),
      };

  // ── Prayer name localisation ───────────────────────────────────────────────

  static const _namesId = <String, String>{
    'fajr'    : 'Subuh',
    'sunrise' : 'Syuruq',
    'dhuhr'   : 'Dzuhur',
    'asr'     : 'Ashar',
    'maghrib' : 'Maghrib',
    'isha'    : 'Isya',
  };

  static const _namesEn = <String, String>{
    'fajr'    : 'Fajr',
    'sunrise' : 'Sunrise',
    'dhuhr'   : 'Dhuhr',
    'asr'     : 'Asr',
    'maghrib' : 'Maghrib',
    'isha'    : 'Isha',
  };

  String getPrayerName(String key) =>
      (language == AppLanguage.en ? _namesEn : _namesId)[key] ?? key;

  // ── UI string localisation ─────────────────────────────────────────────────

  static const _labelsId = <String, String>{
    'currentPrayer':      'Shalat sekarang',
    'nextPrayer':         'Shalat berikutnya',
    'today':              'Hari ini',
    'allPrayersPassed':   'Semua shalat telah lewat',
    'ends':               'Berakhir',
    'adhan':              'Adzan',
    'sunRise':            'Matahari Terbit',
    'solarNoon':          'Tengah Hari',
    'sunSet':             'Matahari Terbenam',
    'tryAgain':           'Coba Lagi',
    'settings':           'Pengaturan',
    'location':           'Lokasi',
    'city':               'Kota',
    'refreshLocation':    'Deteksi Ulang Lokasi',
    'autoLocation':       'Gunakan Lokasi Otomatis',
    'calcMethod':         'Metode Kalkulasi',
    'method':             'Metode',
    'madhab':             'Madhab',
    'notifications':      'Notifikasi',
    'enableAllNotif':     'Aktifkan Semua Notifikasi',
    'preAdzan':           'Pengingat Sebelum Adzan',
    'preAdzanMinutes':    'Menit Sebelum Adzan',
    'timeCorrection':     'Koreksi Waktu',
    'appearance':         'Tampilan',
    'theme':              'Tema',
    'language':           'Bahasa',
    'about':              'Tentang',
    'version':            'Versi',
    'developedBy':        'Dibuat oleh',
    'followSystem':       'Ikuti Sistem',
    'light':              'Terang',
    'dark':               'Gelap',
    'home':               'Beranda',
    'qibla':              'Kiblat',
    'metalWarning':       'Jauhkan dari benda logam dan perangkat elektronik untuk akurasi terbaik',
    'sensorUnavailable':  'Sensor kompas tidak tersedia di perangkat ini',
    'noLocationQibla':    'Izin lokasi diperlukan untuk menghitung arah Kiblat',
    'ibadah':             'Ibadah',
    'ibadahToday':        'Ibadah hari ini',
    'dzikir':             'Dzikir & Doa',
    // Calendar
    'kalender':           'Kalender',
    'hijriCalendar':      'Kalender Hijriah',
    'islamicEvents':      'Hari Besar Islam',
    'upcomingEvents':     'Acara Mendatang',
    'sunnahFasting':      'Puasa Sunnah',
    'noEvents':           'Tidak ada peristiwa',
    // Quran
    'quran':              'Al-Qur\'an',
    // Adzan audio
    'adzanAudio':         'Suara Adzan',
    'adzanSound':         'Adzan (Umum)',
    'adzanSoundFajr':     'Adzan Subuh',
    'adzanVolume':        'Volume Adzan',
    'previewAdzan':       'Pratinjau',
    // Device optimization guidance (generic section title)
    'miuiSection':        'Optimasi Notifikasi',
    'openBatterySettings':'Buka Pengaturan Baterai',
    // Xiaomi/MIUI
    'miuiInfo':           'Pada Xiaomi/MIUI, matikan optimasi baterai agar notifikasi adzan tidak terlambat atau hilang.',
    'miuiStep1':          '1. Pengaturan → Aplikasi → Waktu Shalat → Baterai → Tidak ada batasan',
    'miuiStep2':          '2. Pengaturan → Aplikasi → Waktu Shalat → Notifikasi → Aktifkan semua',
    'miuiStep3':          '3. Security → Izin → Autostart → Aktifkan Waktu Shalat',
    'miuiStep4':          '4. Kunci di recent apps: tahan ikon app → Kunci 🔒',
    // Samsung/OneUI
    'samsungInfo':        'Pada Samsung OneUI, pastikan baterai tidak dibatasi dan app tidak masuk daftar tidur.',
    'samsungStep1':       '1. Pengaturan → Aplikasi → Waktu Shalat → Baterai → Tidak Dibatasi',
    'samsungStep2':       '2. Pengaturan → Perawatan perangkat → Baterai → Batas penggunaan latar belakang → Hapus Waktu Shalat',
    'samsungStep3':       '3. Pengaturan → Notifikasi → Notifikasi lanjutan → Izinkan notifikasi saat layar mati',
    // Oppo/ColorOS
    'oppoInfo':           'Pada OPPO/ColorOS, aktifkan autostart dan nonaktifkan pembatas baterai.',
    'oppoStep1':          '1. Pengaturan → Baterai → Manajemen baterai app → Waktu Shalat → Tidak dibatasi',
    'oppoStep2':          '2. Pengaturan → Manajemen app → Autostart → Aktifkan Waktu Shalat',
    'oppoStep3':          '3. Pengaturan → Notifikasi → Waktu Shalat → Aktifkan semua',
    // Vivo/FuntouchOS
    'vivoInfo':           'Pada Vivo/FuntouchOS, izinkan berjalan di latar belakang dan aktifkan autostart.',
    'vivoStep1':          '1. Pengaturan → Baterai → Konsumsi daya latar belakang → Waktu Shalat → Izinkan',
    'vivoStep2':          '2. i-Manager → Manajemen app → Autostart → Aktifkan Waktu Shalat',
    'vivoStep3':          '3. Pengaturan → Notifikasi → Waktu Shalat → Izinkan notifikasi',
    // Huawei/EMUI
    'huaweiInfo':         'Pada Huawei/EMUI, atur peluncuran app ke manual dan aktifkan semua.',
    'huaweiStep1':        '1. Pengaturan → Baterai → Peluncuran app → Waktu Shalat → Kelola manual → Aktifkan semua',
    'huaweiStep2':        '2. Pengaturan → Notifikasi → Waktu Shalat → Izinkan notifikasi',
    'huaweiStep3':        '3. Telepon Manager → App yang dilindungi → Tambahkan Waktu Shalat',
    // Realme/RealmeUI
    'realmeInfo':         'Pada Realme/RealmeUI, aktifkan autostart dan nonaktifkan optimasi baterai.',
    'realmeStep1':        '1. Pengaturan → Manajemen app → Penggunaan daya → Waktu Shalat → Tidak dibatasi',
    'realmeStep2':        '2. Pengaturan → Manajemen app → Autostart → Aktifkan Waktu Shalat',
    'realmeStep3':        '3. Pengaturan → Notifikasi → Waktu Shalat → Aktifkan semua',
    // Generic (other manufacturers)
    'genericOptInfo':     'Untuk notifikasi adzan tepat waktu, nonaktifkan optimasi baterai untuk Waktu Shalat.',
    'genericOptStep1':    '1. Pengaturan → Aplikasi → Waktu Shalat → Baterai → Tidak dibatasi',
    'genericOptStep2':    '2. Pengaturan → Aplikasi → Waktu Shalat → Notifikasi → Aktifkan semua',
    // Permission fix UI
    'testNotif':          'Test Notifikasi Sekarang',
    'testNotifSent':      'Notifikasi test akan muncul dalam 10 detik',
    'fixNotif':           'Perbaiki Notifikasi Adzan',
    'notifWarning':       'Notifikasi adzan mungkin terlambat. Tap untuk perbaiki.',
    'permNotif':          'Izin Notifikasi',
    'permBattery':        'Baterai Tidak Dibatasi',
    'permExactAlarm':     'Alarm Tepat Waktu',
    'permMiuiLock':       'Kunci di Recent Apps',
    'allowAll':           'Izinkan Semua',
    'recheckAll':         'Cek Ulang',
    'fixAuto':            'Perbaiki Otomatis',
    'onboardPermTitle':   'Aktifkan Notifikasi Adzan',
    'onboardPermSub':     'Agar adzan tidak terlambat, izinkan Waktu Shalat berjalan di latar belakang tanpa batasan baterai.',
    'allPermsActive':     'Semua izin aktif!',
    'permActive':         'Aktif',
    'permPending':        'Belum',
    'rateApp':            'Beri Rating Aplikasi',
  };

  static const _labelsEn = <String, String>{
    'currentPrayer':      'Current Prayer',
    'nextPrayer':         'Next Prayer',
    'today':              'Today',
    'allPrayersPassed':   'All prayers passed',
    'ends':               'Ends',
    'adhan':              'Adhan',
    'sunRise':            'Sunrise',
    'solarNoon':          'Solar Noon',
    'sunSet':             'Sunset',
    'tryAgain':           'Try Again',
    'settings':           'Settings',
    'location':           'Location',
    'city':               'City',
    'refreshLocation':    'Refresh Location',
    'autoLocation':       'Use Auto Location',
    'calcMethod':         'Calculation Method',
    'method':             'Method',
    'madhab':             'Madhab',
    'notifications':      'Notifications',
    'enableAllNotif':     'Enable All Notifications',
    'preAdzan':           'Pre-Adhan Reminder',
    'preAdzanMinutes':    'Minutes Before Adhan',
    'timeCorrection':     'Time Correction',
    'appearance':         'Appearance',
    'theme':              'Theme',
    'language':           'Language',
    'about':              'About',
    'version':            'Version',
    'developedBy':        'Developed by',
    'followSystem':       'Follow System',
    'light':              'Light',
    'dark':               'Dark',
    'home':               'Home',
    'qibla':              'Qibla',
    'metalWarning':       'Keep away from metal and electronic devices for best accuracy',
    'sensorUnavailable':  'Compass sensor not available on this device',
    'noLocationQibla':    'Location permission is required to calculate Qibla direction',
    'ibadah':             'Ibadah',
    'ibadahToday':        "Today's Ibadah",
    'dzikir':             'Dzikir & Doa',
    // Calendar
    'kalender':           'Calendar',
    'hijriCalendar':      'Hijri Calendar',
    'islamicEvents':      'Islamic Events',
    'upcomingEvents':     'Upcoming Events',
    'sunnahFasting':      'Sunnah Fasting',
    'noEvents':           'No events',
    // Quran
    'quran':              'Al-Qur\'an',
    // Adzan audio
    'adzanAudio':         'Adzan Audio',
    'adzanSound':         'Adzan (General)',
    'adzanSoundFajr':     'Fajr Adzan',
    'adzanVolume':        'Adzan Volume',
    'previewAdzan':       'Preview',
    // Device optimization guidance (generic section title)
    'miuiSection':        'Notification Optimization',
    'openBatterySettings':'Open Battery Settings',
    // Xiaomi/MIUI
    'miuiInfo':           'On Xiaomi/MIUI, disable battery optimization so prayer notifications are not delayed.',
    'miuiStep1':          '1. Settings → Apps → Waktu Shalat → Battery → No restrictions',
    'miuiStep2':          '2. Settings → Apps → Waktu Shalat → Notifications → Enable all',
    'miuiStep3':          '3. Security → Permissions → Autostart → Enable Waktu Shalat',
    'miuiStep4':          '4. Pin in recent apps: hold app icon → Lock 🔒',
    // Samsung/OneUI
    'samsungInfo':        'On Samsung OneUI, ensure battery is unrestricted and the app is not sleeping.',
    'samsungStep1':       '1. Settings → Apps → Waktu Shalat → Battery → Unrestricted',
    'samsungStep2':       '2. Settings → Device Care → Battery → Background limits → Remove Waktu Shalat',
    'samsungStep3':       '3. Settings → Notifications → Advanced → Allow when screen off',
    // Oppo/ColorOS
    'oppoInfo':           'On OPPO/ColorOS, enable autostart and disable battery restrictions.',
    'oppoStep1':          '1. Settings → Battery → App battery management → Waktu Shalat → No restrictions',
    'oppoStep2':          '2. Settings → App management → Autostart → Enable Waktu Shalat',
    'oppoStep3':          '3. Settings → Notifications → Waktu Shalat → Enable all',
    // Vivo/FuntouchOS
    'vivoInfo':           'On Vivo/FuntouchOS, allow background activity and enable autostart.',
    'vivoStep1':          '1. Settings → Battery → Background power consumption → Waktu Shalat → Allow',
    'vivoStep2':          '2. i-Manager → App manager → Autostart → Enable Waktu Shalat',
    'vivoStep3':          '3. Settings → Notifications → Waktu Shalat → Allow',
    // Huawei/EMUI
    'huaweiInfo':         'On Huawei/EMUI, set app launch to manual and enable all options.',
    'huaweiStep1':        '1. Settings → Battery → App launch → Waktu Shalat → Manual → Enable all',
    'huaweiStep2':        '2. Settings → Notifications → Waktu Shalat → Allow',
    'huaweiStep3':        '3. Phone Manager → Protected apps → Add Waktu Shalat',
    // Realme/RealmeUI
    'realmeInfo':         'On Realme/RealmeUI, enable autostart and disable battery optimization.',
    'realmeStep1':        '1. Settings → App management → Power usage → Waktu Shalat → No restrictions',
    'realmeStep2':        '2. Settings → App management → Autostart → Enable Waktu Shalat',
    'realmeStep3':        '3. Settings → Notifications → Waktu Shalat → Enable all',
    // Generic (other manufacturers)
    'genericOptInfo':     'For on-time prayer notifications, disable battery optimization for Waktu Shalat.',
    'genericOptStep1':    '1. Settings → Apps → Waktu Shalat → Battery → Unrestricted',
    'genericOptStep2':    '2. Settings → Apps → Waktu Shalat → Notifications → Enable all',
    // Permission fix UI
    'testNotif':          'Test Notification Now',
    'testNotifSent':      'Test notification will appear in 10 seconds',
    'fixNotif':           'Fix Prayer Notifications',
    'notifWarning':       'Prayer notifications may be delayed. Tap to fix.',
    'permNotif':          'Notification Permission',
    'permBattery':        'Battery Unrestricted',
    'permExactAlarm':     'Exact Alarm',
    'permMiuiLock':       'Pin in Recent Apps',
    'allowAll':           'Allow All',
    'recheckAll':         'Recheck',
    'fixAuto':            'Auto Fix',
    'onboardPermTitle':   'Enable Prayer Notifications',
    'onboardPermSub':     'To ensure timely adhan alerts, allow Waktu Shalat to run in the background without battery restrictions.',
    'allPermsActive':     'All permissions active!',
    'permActive':         'Active',
    'permPending':        'Pending',
    'rateApp':            'Rate this App',
  };

  String getLabel(String key) =>
      (language == AppLanguage.en ? _labelsEn : _labelsId)[key] ?? key;

  bool get isEnglish => language == AppLanguage.en;

  String getMadhabLabel(MadhabSetting m) => switch (m) {
        MadhabSetting.shafi  => language == AppLanguage.en ? "Shafi'i" : "Syafi'i",
        MadhabSetting.hanafi => 'Hanafi',
      };

  // ── Setters ───────────────────────────────────────────────────────────────

  Future<void> setThemeMode(ThemeMode m) async {
    themeMode = m;
    await _box.put('themeMode', _themeStr(m));
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage l) async {
    language = l;
    await _box.put('language', l.index);
    notifyListeners();
  }

  Future<void> setCalcMethod(CalcMethod m) async {
    calcMethod = m;
    await _box.put('calcMethod', m.index);
    notifyListeners();
  }

  Future<void> setMadhab(MadhabSetting m) async {
    madhab = m;
    await _box.put('madhab', m.index);
    notifyListeners();
  }

  Future<void> setAutoLocation(bool v) async {
    autoLocation = v;
    await _box.put('autoLocation', v);
    notifyListeners();
  }

  Future<void> setMasterNotif(bool v) async {
    masterNotifEnabled = v;
    await _box.put('masterNotifEnabled', v);
    notifyListeners();
  }

  Future<void> setPreAdzanEnabled(bool v) async {
    preAdzanEnabled = v;
    await _box.put('preAdzanEnabled', v);
    notifyListeners();
  }

  Future<void> setPreAdzanMinutes(int v) async {
    preAdzanMinutes = v.clamp(5, 30);
    await _box.put('preAdzanMinutes', preAdzanMinutes);
    notifyListeners();
  }

  Future<void> setPrayerOffset(String key, int v) async {
    prayerTimeOffsets = {...prayerTimeOffsets, key: v.clamp(-10, 10)};
    await _box.put('prayerOffset_$key', prayerTimeOffsets[key]);
    notifyListeners();
  }

  Future<void> setAdzanSound(AdzanSound s) async {
    adzanSound = s;
    await _box.put('adzanSound', s.index);
    notifyListeners();
  }

  Future<void> setAdzanSoundFajr(AdzanSound s) async {
    adzanSoundFajr = s;
    await _box.put('adzanSoundFajr', s.index);
    notifyListeners();
  }

  Future<void> setAdzanVolume(double v) async {
    adzanVolume = v.clamp(0.0, 1.0);
    await _box.put('adzanVolume', adzanVolume);
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static ThemeMode _parseTheme(String s) => switch (s) {
        'light' => ThemeMode.light,
        'dark'  => ThemeMode.dark,
        _       => ThemeMode.system,
      };

  static String _themeStr(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark  => 'dark',
        _               => 'system',
      };
}
