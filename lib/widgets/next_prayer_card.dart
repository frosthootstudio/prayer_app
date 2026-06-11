import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';
import '../utils/time_format.dart';
import 'countdown_timer.dart';

/// Two side-by-side cards: current prayer (left) + next prayer (right).
class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    // Select only the values this card renders, packed in a record (value
    // equality) — the provider notifies every second for the countdown
    // ticker, but this card only needs to rebuild on prayer transitions.
    // (currentKey, currentTime, nextKey, nextTime, isEmpty)
    final sel = context.select<PrayerProvider,
        (String?, DateTime?, String?, DateTime?, bool)>((p) {
      final prayers = p.prayerTimes;
      if (prayers.isEmpty) return (null, null, null, null, true);
      final nextIdx = prayers.indexWhere((x) => x.isNext);
      final current = (nextIdx > 0) ? prayers[nextIdx - 1] : null;
      return (
        current?.key,
        current?.time,
        p.nextPrayer?.key,
        p.nextPrayer?.time,
        false,
      );
    });

    if (sel.$5) return const SizedBox.shrink();

    final currentKey  = sel.$1;
    final currentTime = sel.$2;
    final nextKey     = sel.$3;
    final nextTime    = sel.$4;

    return Row(
      children: [
        // ── Left: current prayer ───────────────────────────────────────────
        Expanded(
          child: _PrayerCard(
            label: settings.getLabel('currentPrayer'),
            prayerName: currentKey != null
                ? settings.getPrayerName(currentKey)
                : '—',
            timeStr: currentKey != null
                ? formatPrayerTime(context, currentTime!)
                : '—',
            subLine: (currentKey != null && nextTime != null)
                ? '${settings.getLabel('ends')} · ${formatPrayerTime(context, nextTime)}'
                : '',
            isWarm: true,
          ),
        ),

        const SizedBox(width: 12),

        // ── Right: next prayer ─────────────────────────────────────────────
        Expanded(
          child: nextKey != null
              ? _PrayerCard(
                  label: settings.getLabel('nextPrayer'),
                  prayerName: settings.getPrayerName(nextKey),
                  timeStr: formatPrayerTime(context, nextTime!),
                  subLine:
                      '${settings.getLabel('adhan')} · ${formatPrayerTime(context, nextTime)}',
                  isWarm: false,
                  showCountdown: true,
                )
              : _PrayerCard(
                  label: settings.getLabel('today'),
                  prayerName: 'Alhamdulillah',
                  timeStr: '',
                  subLine: settings.getLabel('allPrayersPassed'),
                  isWarm: false,
                ),
        ),
      ],
    );
  }
}

// ── Single prayer card ────────────────────────────────────────────────────────

class _PrayerCard extends StatelessWidget {
  final String label;
  final String prayerName;
  final String timeStr;
  final String subLine;
  final bool isWarm;
  final bool showCountdown;

  const _PrayerCard({
    required this.label,
    required this.prayerName,
    required this.timeStr,
    required this.subLine,
    required this.isWarm,
    this.showCountdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: isWarm ? context.appCardWarm : context.appCardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.appCardShadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Mosque silhouette (CustomPainter) ──────────────────────────
          Positioned(
            bottom: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(80, 68),
              painter: _MosquePainter(
                color: isWarm
                    ? context.appMosqueOverlayWarm
                    : context.appMosqueOverlayLight,
              ),
            ),
          ),

          // ── Card content ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: context.appTextSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),

                // Prayer name
                Text(
                  prayerName,
                  style: GoogleFonts.poppins(
                    color: context.appAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),

                // Time
                if (timeStr.isNotEmpty)
                  Text(
                    timeStr,
                    style: GoogleFonts.poppins(
                      color: context.appTextPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),

                const SizedBox(height: 3),

                // Sub line or countdown
                if (showCountdown) ...[
                  Text(
                    subLine,
                    style: GoogleFonts.poppins(
                      color: context.appTextSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const CountdownTimer(),
                ] else
                  Text(
                    subLine,
                    style: GoogleFonts.poppins(
                      color: context.appTextSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mosque silhouette CustomPainter ──────────────────────────────────────────
//
// Simplified mosque profile: two minarets flanking a central dome,
// all drawn with paths so it scales cleanly and avoids emoji rendering
// inconsistencies across devices.

class _MosquePainter extends CustomPainter {
  final Color color;
  const _MosquePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path();

    // ── Left minaret ──────────────────────────────────────────────────────
    path.addRect(Rect.fromLTWH(w * 0.04, h * 0.30, w * 0.12, h * 0.70));
    path.moveTo(w * 0.04, h * 0.30);
    path.lineTo(w * 0.10, h * 0.10);
    path.lineTo(w * 0.16, h * 0.30);
    path.close();
    path.addRect(Rect.fromLTWH(w * 0.02, h * 0.42, w * 0.16, h * 0.04));

    // ── Right minaret ─────────────────────────────────────────────────────
    path.addRect(Rect.fromLTWH(w * 0.84, h * 0.30, w * 0.12, h * 0.70));
    path.moveTo(w * 0.84, h * 0.30);
    path.lineTo(w * 0.90, h * 0.10);
    path.lineTo(w * 0.96, h * 0.30);
    path.close();
    path.addRect(Rect.fromLTWH(w * 0.82, h * 0.42, w * 0.16, h * 0.04));

    // ── Central dome + walls ──────────────────────────────────────────────
    path.addRect(Rect.fromLTWH(w * 0.22, h * 0.48, w * 0.56, h * 0.52));

    final domeRect = Rect.fromLTWH(w * 0.28, h * 0.16, w * 0.44, h * 0.40);
    path.arcTo(domeRect, 3.14159, 3.14159, false);
    path.lineTo(w * 0.28, h * 0.48);
    path.close();

    // Small crescent on dome tip
    final crescentCenter = Offset(w * 0.50, h * 0.13);
    final outer = Path()
      ..addOval(Rect.fromCircle(center: crescentCenter, radius: w * 0.055));
    final inner = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(crescentCenter.dx + w * 0.03, crescentCenter.dy),
          radius: w * 0.042));
    final crescent = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(path, paint);
    canvas.drawPath(crescent, paint);
  }

  @override
  bool shouldRepaint(_MosquePainter old) => old.color != color;
}
