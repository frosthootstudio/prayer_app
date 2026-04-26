class DzikirItem {
  final String  id;
  final String  title;
  final String  arabic;
  final String  latin;
  final String  translation;
  final int     count;
  final String  category;
  final String  reference;
  final String? note;
  // 'uthmani' = Mushaf Madinah / Tanzil encoding (Quranic ayat)
  // 'arabic'  = standard diacritised Arabic (hadith / dua)
  final String  arabicScript;

  const DzikirItem({
    required this.id,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.count,
    required this.category,
    required this.reference,
    this.note,
    this.arabicScript = 'uthmani',
  });
}
