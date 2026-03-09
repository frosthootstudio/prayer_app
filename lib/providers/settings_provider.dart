import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/prayer_calculation_service.dart';

enum AdzanSound {
  makkah('Adzan Makkah',  'https://audio.islamway.net/adhan/adhan_makka.mp3'),
  madinah('Adzan Madinah', 'https://audio.islamway.net/adhan/adhan_madina.mp3'),
  subuh('Adzan Subuh',    'https://audio.islamway.net/adhan/adhan_subuh.mp3'),
  none('Tanpa Suara',     '');

  const AdzanSound(this.displayName, this.url);
  final String displayName;
  final String url;

  bool get hasAudio => url.isNotEmpty;
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
  AdzanSound     adzanSound         = AdzanSound.makkah;
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
    adzanSound        = AdzanSound.values[(_box.get('adzanSound', defaultValue: 0) as int).clamp(0, AdzanSound.values.length - 1)];
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
    'adzanSound':         'Pilih Suara Adzan',
    'adzanVolume':        'Volume Adzan',
    'previewAdzan':       'Pratinjau',
    // MIUI/HyperOS guidance
    'miuiSection':        'Optimasi MIUI / HyperOS',
    'miuiInfo':           'Pada Xiaomi/MIUI, matikan optimasi baterai agar notifikasi adzan tidak terlambat atau hilang.',
    'miuiStep1':          '1. Pengaturan HP → Aplikasi → Waktu Shalat',
    'miuiStep2':          '2. Baterai → pilih "Tidak ada batasan"',
    'miuiStep3':          '3. Notifikasi → Aktifkan semua',
    'miuiStep4':          '4. Kunci di recent apps: tahan ikon → Kunci',
    'openBatterySettings':'Buka Pengaturan Baterai',
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
    'adzanSound':         'Select Adzan Sound',
    'adzanVolume':        'Adzan Volume',
    'previewAdzan':       'Preview',
    // MIUI/HyperOS guidance
    'miuiSection':        'MIUI / HyperOS Optimization',
    'miuiInfo':           'On Xiaomi/MIUI devices, disable battery optimization to prevent delayed or missing prayer notifications.',
    'miuiStep1':          '1. Phone Settings → Apps → Waktu Shalat',
    'miuiStep2':          '2. Battery → select "No restrictions"',
    'miuiStep3':          '3. Notifications → Enable all',
    'miuiStep4':          '4. Pin in recent apps: hold icon → Lock',
    'openBatterySettings':'Open Battery Settings',
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
