import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/prayer_tracking_model.dart';
import '../services/ramadan_service.dart';

class TrackingProvider extends ChangeNotifier {
  // ── Master task list ────────────────────────────────────────────────────────

  static const List<Map<String, String>> ramadanTasks = [
    {'key': 'sahur',    'label': 'Sahur',                'category': 'ramadan'},
    {'key': 'tarawih',  'label': 'Shalat Tarawih',       'category': 'ramadan'},
    {'key': 'tadarus',  'label': "Tadarus Al-Qur'an",    'category': 'ramadan'},
    {'key': 'itikaf',   'label': "I'tikaf",              'category': 'ramadan'},
    {'key': 'sedekah',  'label': 'Sedekah',              'category': 'ramadan'},
  ];

  static const List<Map<String, String>> ibadahTasks = [
    {'key': 'tahajud',               'label': 'Tahajud',                          'category': 'malam'},
    {'key': 'witir',                 'label': 'Shalat Witir',                     'category': 'malam'},
    {'key': 'sunnah_qabliyah_subuh', 'label': 'Sunnah Qabliyah Subuh',            'category': 'subuh'},
    {'key': 'subuh',                 'label': 'Shalat Subuh',                     'category': 'subuh'},
    {'key': 'quran_dzikir_pagi',     'label': "Baca Al-Qur'an & Dzikir Pagi",     'category': 'pagi'},
    {'key': 'al_ikhlas_waqiah',      'label': 'Al-Ikhlas 10x & Al-Waqiah',        'category': 'pagi'},
    {'key': 'dhuha',                 'label': 'Shalat Dhuha',                     'category': 'pagi'},
    {'key': 'sunnah_qabliyah_zuhur', 'label': 'Sunnah Qabliyah Zuhur',            'category': 'zuhur'},
    {'key': 'zuhur',                 'label': 'Shalat Zuhur',                     'category': 'zuhur'},
    {'key': 'sunnah_badiyah_zuhur',  'label': 'Sunnah Badiyah Zuhur',             'category': 'zuhur'},
    {'key': 'sunnah_qabliyah_ashar', 'label': 'Sunnah Qabliyah Ashar',            'category': 'ashar'},
    {'key': 'ashar',                 'label': 'Shalat Ashar',                     'category': 'ashar'},
    {'key': 'dzikir_petang',         'label': 'Dzikir Petang',                    'category': 'petang'},
    {'key': 'sunnah_qabliyah_maghrib','label': 'Sunnah Qabliyah Maghrib',         'category': 'maghrib'},
    {'key': 'maghrib',               'label': 'Shalat Maghrib',                   'category': 'maghrib'},
    {'key': 'sunnah_badiyah_maghrib','label': 'Sunnah Badiyah Maghrib',            'category': 'maghrib'},
    {'key': 'sunnah_qabliyah_isya',  'label': 'Sunnah Qabliyah Isya',             'category': 'isya'},
    {'key': 'isya',                  'label': 'Shalat Isya',                      'category': 'isya'},
    {'key': 'sunnah_badiyah_isya',   'label': 'Sunnah Badiyah Isya',              'category': 'isya'},
    {'key': 'al_mulk',               'label': 'Al-Mulk Sebelum Tidur',            'category': 'malam'},
  ];

  static const int totalTasks = 20;

  // ── State ──────────────────────────────────────────────────────────────────

  late Box<IbadahTracking> _box;
  bool _ramadanModeEnabled = true;

  // In-memory cache for today (reactive)
  final Map<String, bool>      _statusToday     = {};
  final Map<String, DateTime?> _timestampsToday = {};
  String _lastLoadedDate = '';

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _box = await Hive.openBox<IbadahTracking>('ibadah_tracking');
    _loadToday();
  }

  void _loadToday() {
    final today = todayKey;
    _lastLoadedDate = today;
    _statusToday.clear();
    _timestampsToday.clear();
    for (final task in effectiveTasks) {
      final k     = task['key']!;
      final entry = _box.get('${today}_$k');
      _statusToday[k]     = entry?.isDone   ?? false;
      _timestampsToday[k] = entry?.timestamp;
    }
  }

  void setRamadanMode(bool v) {
    if (_ramadanModeEnabled == v) return;
    _ramadanModeEnabled = v;
    _loadToday();
    notifyListeners();
  }

  /// Reloads today's data silently if the calendar day has rolled over.
  /// Safe to call inside getters — does NOT call notifyListeners().
  void _ensureToday() {
    if (todayKey != _lastLoadedDate) _loadToday();
  }

  // ── Ramadan accessors ─────────────────────────────────────────────────────

  bool get isRamadanActive => _ramadanModeEnabled && RamadanService.isRamadan();

  List<Map<String, String>> get effectiveTasks =>
      isRamadanActive ? [...ibadahTasks, ...ramadanTasks] : ibadahTasks;

  int get effectiveTotalTasks => effectiveTasks.length;

  // ── Public accessors ──────────────────────────────────────────────────────

  String get todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Map<String, bool> get todayStatus {
    _ensureToday();
    return Map.unmodifiable(_statusToday);
  }

  Map<String, DateTime?> get todayTimestamps {
    _ensureToday();
    return Map.unmodifiable(_timestampsToday);
  }

  int get todayCount {
    _ensureToday();
    return _statusToday.values.where((v) => v).length;
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  Future<void> toggleTask(String date, String taskKey) async {
    final hiveKey = '${date}_$taskKey';
    final current = _box.get(hiveKey);
    final nowDone = !(current?.isDone ?? false);
    final now     = nowDone ? DateTime.now() : null;

    await _box.put(
      hiveKey,
      IbadahTracking(
        date: date, taskKey: taskKey, isDone: nowDone, timestamp: now,
      ),
    );

    if (date == todayKey) {
      _statusToday[taskKey]     = nowDone;
      _timestampsToday[taskKey] = now;
    }
    notifyListeners();
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  int getCompletionCount(String date) {
    if (date == todayKey) return todayCount;
    int count = 0;
    for (final task in ibadahTasks) {
      if (_box.get('${date}_${task['key']}')?.isDone == true) count++;
    }
    return count;
  }

  /// Returns completion counts for the last 7 days (index 0 = 6 days ago, 6 = today).
  List<int> getWeeklyStats() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day     = now.subtract(Duration(days: 6 - i));
      final dateStr = DateFormat('yyyy-MM-dd').format(day);
      return getCompletionCount(dateStr);
    });
  }
}
