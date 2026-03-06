import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/dzikir_data.dart';

class DzikirProvider extends ChangeNotifier {
  // In-memory counters — reset on app restart (intentional for daily use)
  final Map<String, int> _counters = {};

  // Hive-backed favorites set
  Set<String> _favorites = {};
  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox('dzikir_favorites');
    _favorites = _box.keys.cast<String>().toSet();
  }

  // ── Counters ──────────────────────────────────────────────────────────────

  int getCount(String id) => _counters[id] ?? 0;

  bool isDone(String id) {
    final item = DzikirData.all.firstWhere((i) => i.id == id);
    return getCount(id) >= item.count;
  }

  void increment(String id) {
    final item = DzikirData.all.firstWhere((i) => i.id == id);
    final current = _counters[id] ?? 0;
    if (current < item.count) {
      _counters[id] = current + 1;
      notifyListeners();
    }
  }

  void reset(String id) {
    _counters.remove(id);
    notifyListeners();
  }

  void resetAll() {
    _counters.clear();
    notifyListeners();
  }

  // ── Favorites ─────────────────────────────────────────────────────────────

  bool isFavorite(String id) => _favorites.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
      await _box.delete(id);
    } else {
      _favorites.add(id);
      await _box.put(id, true);
    }
    notifyListeners();
  }
}
