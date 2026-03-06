import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quran/quran.dart' as quran;

// ── Bookmark model ────────────────────────────────────────────────────────────

class QuranBookmark {
  final int surah;
  final int ayah;
  const QuranBookmark({required this.surah, required this.ayah});

  String toKey() => '$surah:$ayah';

  static QuranBookmark? fromKey(String key) {
    final parts = key.split(':');
    if (parts.length != 2) return null;
    final s = int.tryParse(parts[0]);
    final a = int.tryParse(parts[1]);
    if (s == null || a == null) return null;
    return QuranBookmark(surah: s, ayah: a);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

class QuranProvider extends ChangeNotifier {
  static const _kFontSize        = 'q_fontSize';
  static const _kShowTranslation = 'q_showTranslation';
  static const _kShowTranslit    = 'q_showTranslit';
  static const _kLastSurah       = 'q_lastSurah';
  static const _kLastAyah        = 'q_lastAyah';

  late Box _prefsBox;
  late Box _bookmarksBox;

  double _fontSize        = 24.0;
  bool   _showTranslation = true;
  bool   _showTranslit    = true;
  int?   _lastReadSurah;
  int?   _lastReadAyah;
  List<QuranBookmark> _bookmarks = [];

  // ── Getters ───────────────────────────────────────────────────────────────

  double              get fontSize        => _fontSize;
  bool                get showTranslation => _showTranslation;
  bool                get showTranslit    => _showTranslit;
  int?                get lastReadSurah   => _lastReadSurah;
  int?                get lastReadAyah    => _lastReadAyah;
  List<QuranBookmark> get bookmarks       => List.unmodifiable(_bookmarks);

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _prefsBox     = await Hive.openBox('quran_prefs');
    _bookmarksBox = await Hive.openBox('quran_bookmarks');

    _fontSize        = (_prefsBox.get(_kFontSize, defaultValue: 24.0) as double).clamp(18.0, 32.0);
    _showTranslation = _prefsBox.get(_kShowTranslation, defaultValue: true)  as bool;
    _showTranslit    = _prefsBox.get(_kShowTranslit,    defaultValue: true)   as bool;
    _lastReadSurah   = _prefsBox.get(_kLastSurah) as int?;
    _lastReadAyah    = _prefsBox.get(_kLastAyah)  as int?;

    _bookmarks = _bookmarksBox.values
        .cast<String>()
        .map(QuranBookmark.fromKey)
        .whereType<QuranBookmark>()
        .toList();
  }

  // ── Reading preferences ───────────────────────────────────────────────────

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(18.0, 32.0);
    await _prefsBox.put(_kFontSize, _fontSize);
    notifyListeners();
  }

  Future<void> toggleTranslation() async {
    _showTranslation = !_showTranslation;
    await _prefsBox.put(_kShowTranslation, _showTranslation);
    notifyListeners();
  }

  Future<void> toggleTranslit() async {
    _showTranslit = !_showTranslit;
    await _prefsBox.put(_kShowTranslit, _showTranslit);
    notifyListeners();
  }

  // ── Last read ─────────────────────────────────────────────────────────────

  Future<void> setLastRead(int surah, int ayah) async {
    _lastReadSurah = surah;
    _lastReadAyah  = ayah;
    await _prefsBox.put(_kLastSurah, surah);
    await _prefsBox.put(_kLastAyah,  ayah);
    notifyListeners();
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  bool isBookmarked(int surah, int ayah) =>
      _bookmarks.any((b) => b.surah == surah && b.ayah == ayah);

  Future<void> toggleBookmark(int surah, int ayah) async {
    final key = '$surah:$ayah';
    if (isBookmarked(surah, ayah)) {
      _bookmarks.removeWhere((b) => b.surah == surah && b.ayah == ayah);
      await _bookmarksBox.delete(key);
    } else {
      _bookmarks.insert(0, QuranBookmark(surah: surah, ayah: ayah));
      await _bookmarksBox.put(key, key);
    }
    notifyListeners();
  }

  // ── Search ────────────────────────────────────────────────────────────────

  List<int> filteredSurahs(String query) {
    if (query.isEmpty) return List.generate(quran.totalSurahCount, (i) => i + 1);
    final q = query.toLowerCase();
    return List.generate(quran.totalSurahCount, (i) => i + 1).where((s) {
      return quran.getSurahName(s).toLowerCase().contains(q) ||
             quran.getSurahNameEnglish(s).toLowerCase().contains(q) ||
             quran.getSurahNameArabic(s).contains(query) ||
             '$s' == query;
    }).toList();
  }
}
