import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../models/prayer_model.dart';
import '../services/prayer_calculation_service.dart';
import '../widgets/share_card.dart';

class ShareService {
  /// Renders [ShareCard] off-screen (1080×1080 px) and shares via native sheet.
  static Future<void> shareScheduleImage({
    required BuildContext context,
    required List<PrayerInfo> prayers,
    required String cityName,
    required String gregorianDate,
    required String hijriDate,
    DateTime? imsakTime,
    AppLanguage language = AppLanguage.id,
  }) async {
    final controller = ScreenshotController();

    final Uint8List bytes = await controller.captureFromLongWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: ShareCard(
          prayers:       prayers,
          cityName:      cityName,
          gregorianDate: gregorianDate,
          hijriDate:     hijriDate,
          imsakTime:     imsakTime,
          language:      language,
        ),
      ),
      pixelRatio: 1.0,
      delay: const Duration(milliseconds: 100),
    );

    final tmpDir  = await getTemporaryDirectory();
    final file    = File('${tmpDir.path}/prayer_schedule.png');
    await file.writeAsBytes(bytes);

    // share_plus v13: static Share.shareXFiles removed; use SharePlus
    // instance with ShareParams. Behavior identical, just different shape.
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: _buildShareText(
          prayers:       prayers,
          cityName:      cityName,
          gregorianDate: gregorianDate,
          hijriDate:     hijriDate,
          imsakTime:     imsakTime,
          language:      language,
        ),
      ),
    );
  }

  /// Saves the schedule image directly to the device gallery.
  static Future<bool> saveToGallery({
    required BuildContext context,
    required List<PrayerInfo> prayers,
    required String cityName,
    required String gregorianDate,
    required String hijriDate,
    DateTime? imsakTime,
    AppLanguage language = AppLanguage.id,
  }) async {
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) return false;
      }

      final controller = ScreenshotController();
      final Uint8List bytes = await controller.captureFromLongWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: ShareCard(
            prayers:       prayers,
            cityName:      cityName,
            gregorianDate: gregorianDate,
            hijriDate:     hijriDate,
            imsakTime:     imsakTime,
            language:      language,
          ),
        ),
        pixelRatio: 1.0,
        delay: const Duration(milliseconds: 100),
      );

      final tmpDir = await getTemporaryDirectory();
      final file   = File('${tmpDir.path}/prayer_schedule_gallery.png');
      await file.writeAsBytes(bytes);
      await Gal.putImage(file.path, album: 'Waktu Shalat');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Plain-text fallback for clipboard copy.
  static String buildCopyText({
    required List<PrayerInfo> prayers,
    required String cityName,
    required String gregorianDate,
    required String hijriDate,
    DateTime? imsakTime,
    AppLanguage language = AppLanguage.id,
  }) => _buildShareText(
        prayers:       prayers,
        cityName:      cityName,
        gregorianDate: gregorianDate,
        hijriDate:     hijriDate,
        imsakTime:     imsakTime,
        language:      language,
      );

  static String _buildShareText({
    required List<PrayerInfo> prayers,
    required String cityName,
    required String gregorianDate,
    required String hijriDate,
    DateTime? imsakTime,
    required AppLanguage language,
  }) {
    final isAr = language == AppLanguage.ar;
    final isEn = language == AppLanguage.en;

    final buf = StringBuffer();
    buf.writeln('🕌 ${isAr ? "وقت الصلاة" : isEn ? "Prayer Times" : "Waktu Shalat"}');
    if (cityName.isNotEmpty) buf.writeln('📍 $cityName');
    if (hijriDate.isNotEmpty) buf.writeln('📅 $hijriDate');
    buf.writeln('📅 $gregorianDate');
    buf.writeln();

    if (imsakTime != null) {
      buf.writeln('🌙 ${isAr ? "إمساك" : "Imsak"} — ${_fmt(imsakTime)}');
    }

    for (final p in prayers) {
      if (p.key == 'sunrise') continue;
      final emoji = _prayerEmoji(p.key);
      buf.writeln('$emoji ${p.name} — ${_fmt(p.time)}');
    }

    buf.writeln();
    buf.write(isAr
        ? 'من تطبيق وقت الصلاة 🕌'
        : isEn
            ? 'Shared via Waktu Shalat app 🕌'
            : 'Dibagikan via aplikasi Waktu Shalat 🕌');

    return buf.toString();
  }

  static String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  static String _prayerEmoji(String key) => switch (key) {
        'fajr'    => '🌄',
        'dhuhr'   => '☀️',
        'asr'     => '🌤',
        'maghrib' => '🌅',
        'isha'    => '🌙',
        _         => '🕐',
      };
}
