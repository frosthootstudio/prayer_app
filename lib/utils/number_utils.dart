/// Converts Western (ASCII) digits to Arabic-Indic numerals (٠١٢٣٤٥٦٧٨٩).
/// Applied to prayer times and countdowns when language is Arabic.
String toArabicNumerals(String input) {
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic  = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (int i = 0; i < western.length; i++) {
    input = input.replaceAll(western[i], arabic[i]);
  }
  return input;
}
