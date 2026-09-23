class PrayerGuideStep {
  final String title;
  final String? arabic;
  final String? latin;
  final String? translation;
  final String? notes;

  const PrayerGuideStep({
    required this.title,
    this.arabic,
    this.latin,
    this.translation,
    this.notes,
  });
}

class RecommendedSurah {
  final String rakaat;
  final String surahName;
  final String? arabicSurahName;
  final String virtue;

  const RecommendedSurah({
    required this.rakaat,
    required this.surahName,
    this.arabicSurahName,
    required this.virtue,
  });
}

class PrayerGuideItem {
  final String id;
  final String title;
  final String arabicTitle;
  final String category; // 'fardhu' or 'sunnah'
  final int rakaat;
  final String rakaatNote;
  final String time;
  final String description;
  final String virtue;
  final String niatArabic;
  final String niatLatin;
  final String niatTranslation;
  final List<RecommendedSurah> recommendedSurahs;
  final List<PrayerGuideStep>? specialSteps; // For prayers with unique steps like Janazah
  final String? specialDuaArabic;
  final String? specialDuaLatin;
  final String? specialDuaTranslation;
  final String? specialDuaTitle;

  const PrayerGuideItem({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.category,
    required this.rakaat,
    required this.rakaatNote,
    required this.time,
    required this.description,
    required this.virtue,
    required this.niatArabic,
    required this.niatLatin,
    required this.niatTranslation,
    this.recommendedSurahs = const [],
    this.specialSteps,
    this.specialDuaArabic,
    this.specialDuaLatin,
    this.specialDuaTranslation,
    this.specialDuaTitle,
  });
}

class PrayerRuleItem {
  final String title;
  final String description;
  final List<String> points;

  const PrayerRuleItem({
    required this.title,
    required this.description,
    required this.points,
  });
}
