import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

import 'settings_provider.dart';

// ── Islamic event model ───────────────────────────────────────────────────────

class IslamicEvent {
  final String nameId;
  final String nameEn;
  final int hijriMonth;
  final int hijriDay;
  final Color color;

  const IslamicEvent({
    required this.nameId,
    required this.nameEn,
    required this.hijriMonth,
    required this.hijriDay,
    required this.color,
  });

  String name(bool isEnglish) => isEnglish ? nameEn : nameId;
}

// ── Islamic events data ───────────────────────────────────────────────────────

const _islamicEvents = <IslamicEvent>[
  IslamicEvent(nameId: 'Tahun Baru Islam',   nameEn: 'Islamic New Year',      hijriMonth: 1,  hijriDay: 1,  color: Color(0xFF4CAF50)),
  IslamicEvent(nameId: 'Hari Asyura',        nameEn: 'Day of Ashura',         hijriMonth: 1,  hijriDay: 10, color: Color(0xFF2196F3)),
  IslamicEvent(nameId: 'Maulid Nabi SAW',    nameEn: 'Mawlid an-Nabi',        hijriMonth: 3,  hijriDay: 12, color: Color(0xFFD4A057)),
  IslamicEvent(nameId: 'Isra Mi\'raj',       nameEn: "Isra' Mi'raj",          hijriMonth: 7,  hijriDay: 27, color: Color(0xFF9C27B0)),
  IslamicEvent(nameId: 'Nisfu Sya\'ban',     nameEn: "Nisfu Sha'ban",         hijriMonth: 8,  hijriDay: 15, color: Color(0xFF00BCD4)),
  IslamicEvent(nameId: 'Awal Ramadhan',      nameEn: 'Start of Ramadan',      hijriMonth: 9,  hijriDay: 1,  color: Color(0xFFFF9800)),
  IslamicEvent(nameId: 'Nuzulul Qur\'an',    nameEn: "Nuzul al-Qur'an",       hijriMonth: 9,  hijriDay: 17, color: Color(0xFFD4A057)),
  IslamicEvent(nameId: 'Lailatul Qadar',     nameEn: 'Laylat al-Qadr',        hijriMonth: 9,  hijriDay: 27, color: Color(0xFFE91E63)),
  IslamicEvent(nameId: 'Idul Fitri',         nameEn: 'Eid al-Fitr',           hijriMonth: 10, hijriDay: 1,  color: Color(0xFF4CAF50)),
  IslamicEvent(nameId: 'Idul Fitri H+2',     nameEn: 'Eid al-Fitr Day 2',     hijriMonth: 10, hijriDay: 2,  color: Color(0xFF4CAF50)),
  IslamicEvent(nameId: 'Hari Arafah',        nameEn: 'Day of Arafah',         hijriMonth: 12, hijriDay: 9,  color: Color(0xFFFF5722)),
  IslamicEvent(nameId: 'Idul Adha',          nameEn: 'Eid al-Adha',           hijriMonth: 12, hijriDay: 10, color: Color(0xFFD4A057)),
  IslamicEvent(nameId: 'Hari Tasyrik',       nameEn: 'Tashriq Days',          hijriMonth: 12, hijriDay: 11, color: Color(0xFFFF9800)),
  IslamicEvent(nameId: 'Hari Tasyrik',       nameEn: 'Tashriq Days',          hijriMonth: 12, hijriDay: 12, color: Color(0xFFFF9800)),
  IslamicEvent(nameId: 'Hari Tasyrik',       nameEn: 'Tashriq Days',          hijriMonth: 12, hijriDay: 13, color: Color(0xFFFF9800)),
];

// ── Provider ──────────────────────────────────────────────────────────────────

class CalendarProvider extends ChangeNotifier {
  CalendarProvider(this._settings);

  final SettingsProvider _settings;

  DateTime _focusedDay   = DateTime.now();
  DateTime _selectedDay  = DateTime.now();

  DateTime get focusedDay  => _focusedDay;
  DateTime get selectedDay => _selectedDay;

  // ── Hijri conversion ──────────────────────────────────────────────────────

  HijriCalendar hijriFor(DateTime date) => HijriCalendar.fromDate(date);

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
  // Arabic month names for decorative header
  static const _hijriMonthsAr = [
    'مُحَرَّم', 'صَفَر', 'رَبِيعُ ٱلْأَوَّل', 'رَبِيعُ ٱلثَّانِي',
    'جُمَادَى ٱلْأُولَى', 'جُمَادَى ٱلثَّانِيَة', 'رَجَب', 'شَعْبَان',
    'رَمَضَان', 'شَوَّال', 'ذُو ٱلْقَعْدَة', 'ذُو ٱلْحِجَّة',
  ];

  String hijriMonthName(int month, {bool arabic = false}) {
    final idx = (month - 1).clamp(0, 11);
    if (arabic) return _hijriMonthsAr[idx];
    return _settings.isEnglish ? _hijriMonthsEn[idx] : _hijriMonthsId[idx];
  }

  // ── Selection ─────────────────────────────────────────────────────────────

  void selectDay(DateTime day, DateTime focused) {
    _selectedDay = day;
    _focusedDay  = focused;
    notifyListeners();
  }

  void navigateMonth(int delta) {
    _focusedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month + delta,
      1,
    );
    notifyListeners();
  }

  void setFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  // ── Events ────────────────────────────────────────────────────────────────

  List<IslamicEvent> getEventsForDate(DateTime date) {
    final h = hijriFor(date);
    return _islamicEvents
        .where((e) => e.hijriMonth == h.hMonth && e.hijriDay == h.hDay)
        .toList();
  }

  List<IslamicEvent> getEventsForDay(DateTime date) => getEventsForDate(date);

  // ── Upcoming events (next 5) ──────────────────────────────────────────────

  List<({IslamicEvent event, DateTime gregorianDate})> upcomingEvents({int count = 5}) {
    final today   = DateTime.now();
    final results = <({IslamicEvent event, DateTime gregorianDate})>[];
    var   cursor  = today;

    while (results.length < count) {
      final events = getEventsForDate(cursor);
      for (final e in events) {
        if (results.length < count) {
          results.add((event: e, gregorianDate: cursor));
        }
      }
      cursor = cursor.add(const Duration(days: 1));
      // Safety: don't loop more than 400 days
      if (cursor.difference(today).inDays > 400) break;
    }
    return results;
  }

  // ── Sunnah fasting info for selected day ─────────────────────────────────

  String? getSunnahFastInfo() {
    final h    = hijriFor(_selectedDay);
    final day  = _selectedDay.weekday; // 1=Mon … 7=Sun
    final isEn = _settings.isEnglish;
    final List<String> reasons = [];

    // Monday / Thursday
    if (day == DateTime.monday || day == DateTime.thursday) {
      reasons.add(isEn ? 'Monday/Thursday fast (Sunnah)' : 'Puasa Senin/Kamis (Sunnah)');
    }
    // Ayyamul Bidh: 13, 14, 15 of any Hijri month
    if (h.hDay == 13 || h.hDay == 14 || h.hDay == 15) {
      reasons.add(isEn ? 'Ayyamul Bidh (White Days fast)' : 'Puasa Ayyamul Bidh');
    }
    // Day of Arafah (9 Dhul Hijjah) — for non-pilgrims
    if (h.hMonth == 12 && h.hDay == 9) {
      reasons.add(isEn ? 'Day of Arafah fast (erases 2 years of sins)' : 'Puasa Hari Arafah (menghapus dosa 2 tahun)');
    }
    // Ashura (10 Muharram)
    if (h.hMonth == 1 && h.hDay == 10) {
      reasons.add(isEn ? 'Ashura fast (erases 1 year of sins)' : 'Puasa Asyura (menghapus dosa 1 tahun)');
    }
    // Tasu\'a (9 Muharram)
    if (h.hMonth == 1 && h.hDay == 9) {
      reasons.add(isEn ? "Tasu'a fast (day before Ashura)" : "Puasa Tasu'a (sebelum Asyura)");
    }
    // Six days of Shawwal
    if (h.hMonth == 10 && h.hDay >= 2 && h.hDay <= 7) {
      reasons.add(isEn ? 'Six days of Shawwal fast' : 'Puasa 6 hari Syawal');
    }
    // No fasting on Eid days and Tasyrik days
    if ((h.hMonth == 10 && h.hDay == 1) ||
        (h.hMonth == 12 && h.hDay >= 10 && h.hDay <= 13)) {
      return isEn ? 'Fasting is prohibited today (Eid/Tasyrik)' : 'Puasa diharamkan hari ini (Ied/Tasyrik)';
    }

    if (reasons.isEmpty) return null;
    return reasons.join('\n');
  }

  /// Returns the name of any Sunnah fast for the given [date], or null if none.
  String? getSunnahFastTitle(DateTime date, {bool isEnglish = false}) {
    final h   = hijriFor(date);
    final day = date.weekday;

    // Disallowed fasting days (Eid al-Fitr, Eid al-Adha + Tashriq)
    if ((h.hMonth == 10 && h.hDay == 1) ||
        (h.hMonth == 12 && h.hDay >= 10 && h.hDay <= 13)) {
      return null;
    }
    // Ramadan is obligatory (Fardhu), not Sunnah
    if (h.hMonth == 9) return null;

    if (h.hDay == 13 || h.hDay == 14 || h.hDay == 15) {
      return isEnglish ? 'Ayyamul Bidh Fast' : 'Puasa Ayyamul Bidh';
    }
    if (day == DateTime.monday) {
      return isEnglish ? 'Monday Sunnah Fast' : 'Puasa Sunnah Senin';
    }
    if (day == DateTime.thursday) {
      return isEnglish ? 'Thursday Sunnah Fast' : 'Puasa Sunnah Kamis';
    }
    if (h.hMonth == 12 && h.hDay == 9) {
      return isEnglish ? 'Day of Arafah Fast' : 'Puasa Hari Arafah';
    }
    if (h.hMonth == 1 && h.hDay == 10) {
      return isEnglish ? 'Ashura Fast' : 'Puasa Asyura';
    }
    if (h.hMonth == 1 && h.hDay == 9) {
      return isEnglish ? "Tasu'a Fast" : "Puasa Tasu'a";
    }
    if (h.hMonth == 10 && h.hDay >= 2 && h.hDay <= 7) {
      return isEnglish ? 'Shawwal Sunnah Fast' : 'Puasa Sunnah Syawal';
    }
    return null;
  }
}
