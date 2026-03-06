import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../models/prayer_model.dart';
import '../services/prayer_calculation_service.dart';

/// Pushes prayer data to Android home screen widgets via [HomeWidget].
///
/// Call [update] after every prayer time recalculation (including the
/// per-minute ticker when the "next prayer" changes).
class WidgetService {
  WidgetService._();

  static const _androidSmall  = 'PrayerWidgetSmallProvider';
  static const _androidMedium = 'PrayerWidgetMediumProvider';

  /// Saves current prayer data to widget shared storage and triggers a widget
  /// redraw. Safe to call frequently — HomeWidget debounces the broadcasts.
  static Future<void> update({
    required List<PrayerInfo> prayers,
    required AppLanguage language,
  }) async {
    try {
      // Locate next prayer
      final nextIdx    = prayers.indexWhere((p) => p.isNext);
      final nextPrayer = nextIdx >= 0 ? prayers[nextIdx] : null;
      final allPassed  = nextPrayer == null;

      // Up to 3 upcoming prayers after next (skip sunrise for widget)
      final upcoming = prayers
          .skip(nextIdx >= 0 ? nextIdx + 1 : 0)
          .where((p) => p.key != 'sunrise' && !p.isPassed)
          .take(3)
          .toList();

      final lang = language == AppLanguage.en ? 'en' : 'id';

      await Future.wait([
        HomeWidget.saveWidgetData<String>(
          'next_prayer_name',
          nextPrayer?.name ?? '—',
        ),
        HomeWidget.saveWidgetData<String>(
          'next_prayer_time',
          nextPrayer != null ? _hhmm(nextPrayer.time) : '—',
        ),
        HomeWidget.saveWidgetData<int>(
          'next_prayer_millis',
          nextPrayer?.time.millisecondsSinceEpoch ?? 0,
        ),
        HomeWidget.saveWidgetData<bool>('all_prayers_passed', allPassed),
        HomeWidget.saveWidgetData<String>(
          'prayer_list',
          jsonEncode(
            upcoming
                .map((p) => {'name': p.name, 'time': _hhmm(p.time)})
                .toList(),
          ),
        ),
        HomeWidget.saveWidgetData<String>('language', lang),
      ]);

      await Future.wait([
        HomeWidget.updateWidget(androidName: _androidSmall),
        HomeWidget.updateWidget(androidName: _androidMedium),
      ]);
    } catch (_) {
      // Widget update is best-effort; never crash the app if it fails.
    }
  }

  static String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
