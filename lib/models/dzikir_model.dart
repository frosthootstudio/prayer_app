class DzikirItem {
  final String id;
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final int count;
  final String category;

  const DzikirItem({
    required this.id,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.count,
    required this.category,
  });
}
