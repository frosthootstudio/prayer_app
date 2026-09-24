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
      case 'amiri_quran':
      case 'amiri':       family = 'AmiriQuran';      size = fontSize; break;
      case 'noto_naskh':  family = 'NotoNaskhArabic'; size = fontSize; break;
      case 'scheherazade':
      case 'lateef':
      default:            family = 'ScheherazadeNew'; size = fontSize; break;
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
      'key':    'scheherazade',
      'name':   'Scheherazade',
      'descId': 'Standar Kemenag RI / Indonesia',
      'descEn': 'Standard Indonesian Ministry of Religious Affairs (Kemenag)',
      'style':  'IndoPak',
    },
    {
      'key':    'amiri_quran',
      'name':   'Amiri Quran',
      'descId': 'Mushaf Madinah — Standar Global',
      'descEn': 'Madinah Mushaf — Global standard',
      'style':  'Uthmani',
    },
    {
      'key':    'noto_naskh',
      'name':   'Noto Naskh',
      'descId': 'Modern & minimalis, mudah dibaca',
      'descEn': 'Modern & clean, easy to read',
      'style':  'Modern',
    },
  ];

  static String displayName(String key) {
    final effectiveKey = (key == 'amiri') ? 'amiri_quran' : (key == 'lateef' ? 'scheherazade' : key);
    return availableFonts.firstWhere(
      (f) => f['key'] == effectiveKey,
      orElse: () => availableFonts.first,
    )['name']!;
  }

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
