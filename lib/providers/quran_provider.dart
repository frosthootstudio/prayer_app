import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
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
  static const _kShowTranslation = 'q_showTranslation';
  static const _kShowTranslit    = 'q_showTranslit';
  static const _kLastSurah       = 'q_lastSurah';
  static const _kLastAyah        = 'q_lastAyah';

  late Box _prefsBox;
  late Box _bookmarksBox;
  late Box _translitCacheBox;
  late Box _uthmaniCacheBox;

  bool   _showTranslation = true;
  bool   _showTranslit    = true;
  int?   _lastReadSurah;
  int?   _lastReadAyah;
  List<QuranBookmark> _bookmarks = [];

  // ── Getters ───────────────────────────────────────────────────────────────

  bool                get showTranslation => _showTranslation;
  bool                get showTranslit    => _showTranslit;
  int?                get lastReadSurah   => _lastReadSurah;
  int?                get lastReadAyah    => _lastReadAyah;
  List<QuranBookmark> get bookmarks       => List.unmodifiable(_bookmarks);

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _prefsBox          = await Hive.openBox('quran_prefs');
    _bookmarksBox      = await Hive.openBox('quran_bookmarks');
    _translitCacheBox  = await Hive.openBox('quran_translit_cache');
    _uthmaniCacheBox   = await Hive.openBox('quran_uthmani_cache');

    _showTranslation = _prefsBox.get(_kShowTranslation, defaultValue: true) as bool;
    _showTranslit    = _prefsBox.get(_kShowTranslit,    defaultValue: true) as bool;
    _lastReadSurah   = _prefsBox.get(_kLastSurah) as int?;
    _lastReadAyah    = _prefsBox.get(_kLastAyah)  as int?;

    _bookmarks = _bookmarksBox.values
        .cast<String>()
        .map(QuranBookmark.fromKey)
        .whereType<QuranBookmark>()
        .toList();
  }

  // ── Reading preferences ───────────────────────────────────────────────────

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

  // ── Transliteration ───────────────────────────────────────────────────────

  static const _kTranslitTtlMs = 30 * 24 * 60 * 60 * 1000; // 30 days

  final Map<int, List<String>> _transliterationCache = {};

  // TODO: Migrate to official Kemenag API when approval obtained.
  // Register at: https://quran-api.kemenag.go.id — email: lajnah@kemenag.go.id

  /// Returns verse-level Latin transliteration for [surahNumber].
  ///
  /// Load order:
  ///   1. In-memory cache (instant)
  ///   2. Hive disk cache (30-day TTL, works offline)
  ///   3. Primary API  — equran.id  (Kemenag-based, correct teksLatin)
  ///   4. Fallback API — api.quran.com word-by-word
  ///   5. null → caller shows "Latin tidak tersedia"
  Future<List<String>?> fetchTransliteration(int surahNumber) async {
    // 1. Memory
    if (_transliterationCache.containsKey(surahNumber)) {
      return _transliterationCache[surahNumber]!;
    }

    // 2. Disk cache
    final cacheKey  = 'surah_$surahNumber';
    final rawCached = _translitCacheBox.get(cacheKey) as String?;
    if (rawCached != null) {
      try {
        final map   = json.decode(rawCached) as Map<String, dynamic>;
        final ageMs = DateTime.now().millisecondsSinceEpoch - (map['ts'] as int);
        if (ageMs < _kTranslitTtlMs) {
          final list = (map['list'] as List).cast<String>();
          _transliterationCache[surahNumber] = list;
          return list;
        }
      } catch (_) {}
    }

    // 3. Primary — equran.id (Indonesian Kemenag transliteration)
    final primary = await _fetchEquranId(surahNumber);
    if (primary != null) {
      _transliterationCache[surahNumber] = primary;
      await _persistCacheTo(_translitCacheBox, cacheKey, primary);
      return primary;
    }

    // 4. Fallback — api.quran.com word-by-word
    final fallback = await _fetchQuranCom(surahNumber);
    if (fallback != null) {
      _transliterationCache[surahNumber] = fallback;
      await _persistCacheTo(_translitCacheBox, cacheKey, fallback);
      return fallback;
    }

    return null;
  }

  Future<List<String>?> _fetchEquranId(int surahNumber) async {
    try {
      final response = await http
          .get(Uri.parse('https://equran.id/api/v2/surat/$surahNumber'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final ayat = (data['data']['ayat'] as List).cast<Map<String, dynamic>>();
        return ayat.map((a) => a['teksLatin'] as String).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<List<String>?> _fetchQuranCom(int surahNumber) async {
    try {
      final uri = Uri.parse(
        'https://api.quran.com/api/v4/verses/by_chapter/$surahNumber'
        '?words=true&word_fields=transliteration&per_page=300&fields=verse_number',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data   = json.decode(response.body) as Map<String, dynamic>;
        final verses = (data['verses'] as List).cast<Map<String, dynamic>>();
        return verses.map((v) {
          final words = (v['words'] as List).cast<Map<String, dynamic>>();
          return words
              .where((w) => (w['char_type_name'] as String?) != 'end')
              .map((w) {
                final t = w['transliteration'] as Map<String, dynamic>?;
                return (t?['text'] as String? ?? '').trim();
              })
              .where((s) => s.isNotEmpty)
              .join(' ');
        }).toList();
      }
    } catch (_) {}
    return null;
  }

  // ── Uthmani text ──────────────────────────────────────────────────────────

  static const _kUthmaniTtlMs = 365 * 24 * 60 * 60 * 1000; // 1 year — text is immutable

  final Map<int, List<String>> _uthmaniCache = {};

  /// Returns full Uthmani-script verse list for [surahNumber] (0-indexed).
  ///
  /// Load order:
  ///   1. In-memory cache (instant)
  ///   2. Hive disk cache (1-year TTL, works offline)
  ///   3. api.quran.com /api/v4/quran/verses/uthmani
  ///   4. null → caller falls back to quran.getVerse()
  Future<List<String>?> fetchUthmaniText(int surahNumber) async {
    // 1. Memory
    if (_uthmaniCache.containsKey(surahNumber)) {
      return _uthmaniCache[surahNumber]!;
    }

    // 2. Disk cache
    final cacheKey  = 'surah_$surahNumber';
    final rawCached = _uthmaniCacheBox.get(cacheKey) as String?;
    if (rawCached != null) {
      try {
        final map   = json.decode(rawCached) as Map<String, dynamic>;
        final ageMs = DateTime.now().millisecondsSinceEpoch - (map['ts'] as int);
        if (ageMs < _kUthmaniTtlMs) {
          final list = (map['list'] as List).cast<String>();
          _uthmaniCache[surahNumber] = list;
          return list;
        }
      } catch (_) {}
    }

    // 3. Network — api.quran.com Uthmani script
    try {
      final uri = Uri.parse(
        'https://api.quran.com/api/v4/quran/verses/uthmani'
        '?chapter_number=$surahNumber',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data   = json.decode(response.body) as Map<String, dynamic>;
        final verses = (data['verses'] as List).cast<Map<String, dynamic>>();
        final list   = verses.map((v) => v['text_uthmani'] as String).toList();
        _uthmaniCache[surahNumber] = list;
        await _persistCacheTo(_uthmaniCacheBox, cacheKey, list);
        return list;
      }
    } catch (_) {}

    // 4. Failure — caller uses quran.getVerse() fallback
    return null;
  }

  // ── Cache helpers ─────────────────────────────────────────────────────────

  Future<void> _persistCacheTo(Box box, String key, List<String> list) async {
    try {
      await box.put(key, json.encode({
        'ts':   DateTime.now().millisecondsSinceEpoch,
        'list': list,
      }));
    } catch (_) {}
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
