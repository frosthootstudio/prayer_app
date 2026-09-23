class ProphetModel {
  final int id;
  final String name;
  final String arabicName;
  final String era;
  final String place;
  final bool isUlulAzmi;
  final List<String> miracles;
  final String story;
  final List<String> moralLessons;

  const ProphetModel({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.era,
    required this.place,
    required this.isUlulAzmi,
    required this.miracles,
    required this.story,
    required this.moralLessons,
  });
}
