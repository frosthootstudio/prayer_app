class RamadanService {
  RamadanService._();

  // ── Dershowitz–Reingold calendar arithmetic ───────────────────────────────
  // (same algorithm used in PrayerProvider for date display)

  static bool _isGregorianLeap(int y) =>
      y % 4 == 0 && (y % 100 != 0 || y % 400 == 0);

  static int _gregorianToFixed(int y, int m, int d) =>
      365 * (y - 1) +
      (y - 1) ~/ 4 -
      (y - 1) ~/ 100 +
      (y - 1) ~/ 400 +
      (367 * m - 362) ~/ 12 +
      (m <= 2 ? 0 : _isGregorianLeap(y) ? -1 : -2) +
      d;

  static const int _islamicEpoch = 227015;

  static int _islamicToFixed(int year, int month, int day) =>
      _islamicEpoch - 1 +
      (year - 1) * 354 +
      (3 + 11 * year) ~/ 30 +
      29 * (month - 1) +
      month ~/ 2 +
      day;

  static (int, int, int) _hijriFromFixed(int fixed) {
    final year      = (30 * (fixed - _islamicEpoch) + 10646) ~/ 10631;
    final priorDays = fixed - _islamicToFixed(year, 1, 1);
    final month     = ((11 * priorDays + 330) ~/ 325).clamp(1, 12);
    final day       = fixed - _islamicToFixed(year, month, 1) + 1;
    return (year, month, day);
  }

  static (int, int, int) _gregorianToHijri(int gy, int gm, int gd) =>
      _hijriFromFixed(_gregorianToFixed(gy, gm, gd));

  // RD number of Unix epoch (1 Jan 1970): _gregorianToFixed(1970, 1, 1) = 719163
  static const int _unixEpochRD = 719163;

  static DateTime _fixedToDate(int fixed) => DateTime.fromMillisecondsSinceEpoch(
        (fixed - _unixEpochRD) * 86400000,
        isUtc: true,
      );

  // ── Internal helpers ──────────────────────────────────────────────────────

  static (int, int, int) _todayHijri() {
    final now = DateTime.now();
    return _gregorianToHijri(now.year, now.month, now.day);
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns true if today is in Hijri month 9 (Ramadan).
  static bool isRamadan() => _todayHijri().$2 == 9;

  /// Returns the current Hijri day (1–30) if it is Ramadan, otherwise null.
  static int? currentRamadanDay() {
    final h = _todayHijri();
    return h.$2 == 9 ? h.$3 : null;
  }

  /// Returns true on odd nights 21, 23, 25, 27, 29 of Ramadan.
  static bool isLailatulQadarNight() {
    final day = currentRamadanDay();
    return day != null && day >= 21 && day % 2 == 1;
  }

  /// Days remaining until the first day of the next (or current) Ramadan.
  /// Returns 0 if today is already in Ramadan.
  static int daysUntilRamadan() {
    if (isRamadan()) return 0;
    final h          = _todayHijri();
    final targetYear = h.$2 < 9 ? h.$1 : h.$1 + 1;
    final ramFixed   = _islamicToFixed(targetYear, 9, 1);
    final now        = DateTime.now();
    final todFixed   = _gregorianToFixed(now.year, now.month, now.day);
    return (ramFixed - todFixed).clamp(0, 365);
  }

  /// Gregorian dates of odd Lailatul Qadar candidate nights (21, 23, 25, 27, 29)
  /// for the current Ramadan year (or upcoming if not yet Ramadan).
  static List<(int hijriDay, DateTime date)> lailatulQadarDates() {
    final h  = _todayHijri();
    final hy = (isRamadan() || h.$2 < 9) ? h.$1 : h.$1 + 1;
    return [21, 23, 25, 27, 29].map((d) {
      return (d, _fixedToDate(_islamicToFixed(hy, 9, d)));
    }).toList();
  }
}
