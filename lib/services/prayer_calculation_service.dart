import 'package:adhan/adhan.dart';

import '../models/prayer_model.dart';

// ── Enums shared across the app ────────────────────────────────────────────────

enum CalcMethod {
  kemenag,
  mwl,
  egyptian,
  isna,
  ummAlQura;

  String get label => switch (this) {
        CalcMethod.kemenag   => 'Kemenag Indonesia',
        CalcMethod.mwl       => 'Muslim World League',
        CalcMethod.egyptian  => 'Egyptian General Authority',
        CalcMethod.isna      => 'ISNA (North America)',
        CalcMethod.ummAlQura => 'Umm Al-Qura (Makkah)',
      };
}

enum MadhabSetting {
  shafi,
  hanafi;

  String get label => switch (this) {
        MadhabSetting.shafi  => "Syafi'i",
        MadhabSetting.hanafi => 'Hanafi',
      };
}

enum AppLanguage {
  id,
  en;

  String get label => switch (this) {
        AppLanguage.id => 'Indonesia',
        AppLanguage.en => 'English',
      };
}

// ── Service ────────────────────────────────────────────────────────────────────

class PrayerCalculationService {
  static const _namesId = ['Subuh', 'Syuruq', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
  static const _namesEn = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static const _keys    = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'];

  static CalculationParameters _getParams(
    CalcMethod method,
    MadhabSetting madhab,
  ) {
    late CalculationParameters params;
    switch (method) {
      case CalcMethod.kemenag:
        params = CalculationMethod.other.getParameters();
        params.fajrAngle  = 20.0;
        params.ishaAngle  = 18.0;
      case CalcMethod.mwl:
        // ignore: deprecated_member_use
        params = CalculationMethod.muslim_world_league.getParameters();
      case CalcMethod.egyptian:
        params = CalculationMethod.egyptian.getParameters();
      case CalcMethod.isna:
        // ignore: deprecated_member_use
        params = CalculationMethod.north_america.getParameters();
      case CalcMethod.ummAlQura:
        // ignore: deprecated_member_use
        params = CalculationMethod.umm_al_qura.getParameters();
    }
    params.madhab =
        madhab == MadhabSetting.hanafi ? Madhab.hanafi : Madhab.shafi;
    return params;
  }

  /// Calculates the 6 daily prayer times for [lat]/[lng].
  List<PrayerInfo> calculate(
    double lat,
    double lng, {
    DateTime? forDate,
    CalcMethod method       = CalcMethod.kemenag,
    MadhabSetting madhab    = MadhabSetting.shafi,
    AppLanguage language    = AppLanguage.id,
  }) {
    final target      = forDate ?? DateTime.now();
    final coordinates = Coordinates(lat, lng);
    final params      = _getParams(method, madhab);
    final date        = DateComponents.from(target);
    final pt          = PrayerTimes(coordinates, date, params);
    final now         = DateTime.now();

    final names = language == AppLanguage.en ? _namesEn : _namesId;
    final times = [
      pt.fajr, pt.sunrise, pt.dhuhr, pt.asr, pt.maghrib, pt.isha,
    ];

    final nextIdx = times.indexWhere((t) => t.isAfter(now));

    return List.generate(
      6,
      (i) => PrayerInfo(
        name:     names[i],
        key:      _keys[i],
        time:     times[i],
        isPassed: times[i].isBefore(now),
        isNext:   i == nextIdx,
      ),
    );
  }

  /// Re-stamps isPassed / isNext on an existing list using current time.
  List<PrayerInfo> refreshStatus(List<PrayerInfo> prayers) {
    final now     = DateTime.now();
    final nextIdx = prayers.indexWhere((p) => p.time.isAfter(now));
    return prayers.indexed.map(((int, PrayerInfo) e) {
      final i = e.$1;
      final p = e.$2;
      return p.copyWith(
        isPassed: p.time.isBefore(now),
        isNext:   i == nextIdx,
      );
    }).toList();
  }
}
