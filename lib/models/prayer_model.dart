class PrayerInfo {
  final String name;    // Indonesian label: "Subuh", "Syuruq", …
  final String key;     // adhan key: "fajr", "sunrise", …
  final DateTime time;
  final bool isPassed;
  final bool isNext;

  const PrayerInfo({
    required this.name,
    required this.key,
    required this.time,
    required this.isPassed,
    required this.isNext,
  });

  PrayerInfo copyWith({
    String? name,
    String? key,
    DateTime? time,
    bool? isPassed,
    bool? isNext,
  }) {
    return PrayerInfo(
      name: name ?? this.name,
      key: key ?? this.key,
      time: time ?? this.time,
      isPassed: isPassed ?? this.isPassed,
      isNext: isNext ?? this.isNext,
    );
  }
}
