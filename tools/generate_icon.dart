// Icon generator for Waktu Shalat app.
// Run: flutter test tools/generate_icon.dart
//
// Outputs:
//   assets/icon/app_icon.png            – full icon (1024×1024, navy bg + mosque)
//   assets/icon/app_icon_foreground.png – foreground only (transparent bg, gold mosque)

// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Generate app icon PNGs', (WidgetTester tester) async {
    const size = 1024;

    await tester.runAsync(() async {
      await Directory('assets/icon').create(recursive: true);

      // Full icon: navy background + gold mosque
      await _generate(
        path: 'assets/icon/app_icon.png',
        size: size,
        drawBackground: true,
      );

      // Adaptive foreground: transparent bg, gold mosque
      await _generate(
        path: 'assets/icon/app_icon_foreground.png',
        size: size,
        drawBackground: false,
      );
    });

    print('\n✓ Icons saved to assets/icon/');
  });
}

// ── Render & save ─────────────────────────────────────────────────────────────

Future<void> _generate({
  required String path,
  required int size,
  required bool drawBackground,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(
    recorder,
    ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
  );

  _drawIcon(canvas, size.toDouble(), drawBackground: drawBackground);

  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  await File(path).writeAsBytes(byteData!.buffer.asUint8List());
  print('  Saved $path');
}

// ── Icon drawing ──────────────────────────────────────────────────────────────

void _drawIcon(ui.Canvas canvas, double size, {required bool drawBackground}) {
  final center = ui.Offset(size / 2, size / 2);

  if (drawBackground) {
    // Navy background circle
    canvas.drawCircle(
      center,
      size / 2,
      ui.Paint()
        ..color = const ui.Color(0xFF1A1C2E)
        ..style = ui.PaintingStyle.fill,
    );

    // Subtle geometric ring (gold, 15 % opacity)
    canvas.drawCircle(
      center,
      size * 0.445,
      ui.Paint()
        ..color = const ui.Color(0x26D4A057)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = size * 0.028,
    );
  }

  // Scale drawing from 1024 coordinate space
  canvas.save();
  canvas.scale(size / 1024.0, size / 1024.0);

  final gold = ui.Paint()
    ..color = const ui.Color(0xFFD4A057)
    ..style = ui.PaintingStyle.fill;

  _drawMosque(canvas, gold);

  canvas.restore();
}

// ── Mosque silhouette ─────────────────────────────────────────────────────────

void _drawMosque(ui.Canvas canvas, ui.Paint paint) {
  // ── Left minaret ─────────────────────────────────────────────────────────
  // Balcony shelf
  canvas.drawRect(const ui.Rect.fromLTWH(226, 450, 84, 16), paint);
  // Shaft
  canvas.drawRect(const ui.Rect.fromLTWH(248, 406, 44, 324), paint);
  // Pointed cap
  canvas.drawPath(
    ui.Path()
      ..moveTo(248, 406)
      ..lineTo(270, 322)
      ..lineTo(292, 406)
      ..close(),
    paint,
  );

  // ── Right minaret (mirror around x = 512) ────────────────────────────────
  canvas.drawRect(const ui.Rect.fromLTWH(714, 450, 84, 16), paint);
  canvas.drawRect(const ui.Rect.fromLTWH(732, 406, 44, 324), paint);
  canvas.drawPath(
    ui.Path()
      ..moveTo(732, 406)
      ..lineTo(754, 322)
      ..lineTo(776, 406)
      ..close(),
    paint,
  );

  // ── Main building base ────────────────────────────────────────────────────
  // rect: x=292→732 (440px wide), y=520→730 (210px tall)
  canvas.drawRect(const ui.Rect.fromLTWH(292, 520, 440, 210), paint);

  // ── Central dome (filled upper half-disc) ─────────────────────────────────
  // Dome: center=(512,520), radius=220  →  top at y=300
  // Bounding box for the full circle: fromLTWH(292, 300, 440, 440)
  final domePath = ui.Path()
    ..moveTo(292, 520) // left edge of dome base
    ..arcTo(
      const ui.Rect.fromLTWH(292, 300, 440, 440),
      math.pi, // start at 9 o'clock (left)
      -math.pi, // sweep CCW → upper semicircle
      false,
    )
    ..close(); // line back to (292, 520)
  canvas.drawPath(domePath, paint);

  // Finial ball on top of dome
  canvas.drawCircle(const ui.Offset(512, 300), 24, paint);

  // ── Crescent on top of finial ─────────────────────────────────────────────
  // Outer disc
  final outer = ui.Path()
    ..addOval(
      ui.Rect.fromCircle(center: const ui.Offset(512, 242), radius: 52),
    );
  // Inner disc (shifted right + up to carve out the crescent shape)
  final inner = ui.Path()
    ..addOval(
      ui.Rect.fromCircle(center: const ui.Offset(526, 234), radius: 40),
    );
  canvas.drawPath(
    ui.Path.combine(ui.PathOperation.difference, outer, inner),
    paint,
  );
}
