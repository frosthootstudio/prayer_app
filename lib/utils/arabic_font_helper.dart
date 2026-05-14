import 'package:flutter/material.dart';

class ArabicFontHelper {
  ArabicFontHelper._();

  static TextStyle getStyle(
    String fontKey, {
    double fontSize = 24,
    Color? color,
    double height = 2.0,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final String family;
    final double size;
    switch (fontKey) {
      case 'amiri':       family = 'Amiri';           size = fontSize;     break;
      case 'amiri_quran': family = 'AmiriQuran';      size = fontSize;     break;
      case 'noto_naskh':  family = 'NotoNaskhArabic'; size = fontSize;     break;
      case 'lateef':      family = 'Lateef';          size = fontSize + 4; break;
      case 'scheherazade':
      default:            family = 'ScheherazadeNew'; size = fontSize;     break;
    }
    // inherit:false — prevents merge with GoogleFonts.poppinsTextTheme which
    // injects package:'google_fonts' into the DefaultTextStyle chain, causing
    // Flutter to resolve 'ScheherazadeNew' as a google_fonts font (not found)
    // instead of our bundled asset font.
    // package:null + fontFamilyFallback:[] — explicitly clear any inherited
    // package prefix and fallback list from the parent DefaultTextStyle.
    return TextStyle(
      inherit:             false,
      fontFamily:          family,
      package:             null,
      fontFamilyFallback:  const <String>[],
      fontSize:            size,
      color:               color ?? const Color(0xFFE8E8F0),
      height:              height,
      fontWeight:          fontWeight,
      decoration:          TextDecoration.none,
      decorationColor:     const Color(0x00000000),
      decorationStyle:     TextDecorationStyle.solid,
      decorationThickness: 1.0,
      textBaseline:        TextBaseline.alphabetic,
    );
  }

  static const List<Map<String, String>> availableFonts = [
    {
      'key':    'amiri',
      'name':   'Amiri',
      'descId': 'Naskh klasik — standar mushaf',
      'descEn': 'Classic Naskh — mushaf standard',
      'style':  'Uthmani',
    },
    {
      'key':    'amiri_quran',
      'name':   'Amiri Quran',
      'descId': 'Naskh khusus mushaf — gaya Madinah',
      'descEn': 'Mushaf-specialized Naskh — Madinah style',
      'style':  'Uthmani',
    },
    {
      'key':    'scheherazade',
      'name':   'Scheherazade',
      'descId': 'Tradisional Indonesia/Pakistan',
      'descEn': 'Traditional Indonesia/Pakistan',
      'style':  'IndoPak',
    },
    {
      'key':    'noto_naskh',
      'name':   'Noto Naskh',
      'descId': 'Bersih, mudah dibaca',
      'descEn': 'Clean, easy to read',
      'style':  'Modern',
    },
    {
      'key':    'lateef',
      'name':   'Lateef',
      'descId': 'Gaya kaligrafi tradisional',
      'descEn': 'Traditional calligraphic style',
      'style':  'Indo-Pak',
    },
  ];

  static String displayName(String key) =>
      availableFonts.firstWhere(
        (f) => f['key'] == key,
        orElse: () => availableFonts.first,
      )['name']!;

  /// Strips Uthmani-only Unicode marks. NOT called by default —
  /// fontFamilyFallback in getStyle handles missing glyphs. Kept as
  /// opt-in escape hatch if fallback rendering is undesirable.
  static String normalizeArabicText(String text, String fontKey) {
    if (fontKey == 'amiri' || fontKey == 'amiri_quran' || fontKey == 'noto_naskh') return text;
    return text
        .replaceAll('ٱ', 'ا')                          // U+0671 alef wasla → alef
        .replaceAll('ٰ', '')                            // U+0670 dagger alef
        .replaceAll(RegExp('[ۖ-ۭ]'), '');    // Quran annotation marks
  }
}
