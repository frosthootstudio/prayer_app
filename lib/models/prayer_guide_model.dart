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
  final List<PrayerGuideStep> steps;
  final String? specialDuaArabic;
  final String? specialDuaLatin;
  final String? specialDuaTranslation;

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
    required this.steps,
    this.specialDuaArabic,
    this.specialDuaLatin,
    this.specialDuaTranslation,
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
