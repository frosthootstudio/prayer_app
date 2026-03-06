import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/tracking_provider.dart';
import '../utils/app_theme.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrackingProvider>();
    final settings = context.watch<SettingsProvider>();
    final today    = tracking.todayKey;
    final count    = tracking.todayCount;
    final isEn     = settings.isEnglish;

    // Pre-compute flat list: String = category header, Map = task
    final List<Object> items = [];
    String? lastCat;
    for (final task in TrackingProvider.ibadahTasks) {
      final cat = task['category']!;
      if (cat != lastCat) {
        items.add(cat);
        lastCat = cat;
      }
      items.add(task);
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Screen title ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                settings.getLabel('ibadah'),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: context.appAccent,
                ),
              ),
            ),
          ),

          // ── Summary card ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SummaryCard(count: count, isEn: isEn),
          ),

          // ── Task list ─────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                if (item is String) {
                  return _CategoryHeader(cat: item, isEn: isEn);
                }
                final task    = item as Map<String, String>;
                final taskKey = task['key']!;
                final isDone  = tracking.todayStatus[taskKey]     ?? false;
                final ts      = tracking.todayTimestamps[taskKey];
                return _TaskRow(
                  label:    task['label']!,
                  isDone:   isDone,
                  timestamp: ts,
                  onTap: () => context
                      .read<TrackingProvider>()
                      .toggleTask(today, taskKey),
                );
              },
            ),
          ),

          // ── Weekly stats ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _WeeklyStatsCard(
              stats: tracking.getWeeklyStats(),
              isEn: isEn,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int  count;
  final bool isEn;

  const _SummaryCard({required this.count, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final pct = count / TrackingProvider.totalTasks;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appDivider),
          boxShadow: [
            BoxShadow(
              color: context.appCardShadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isEn ? "Today's Ibadah" : 'Ibadah hari ini',
                  style: GoogleFonts.poppins(
                    color: context.appTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '$count/${TrackingProvider.totalTasks}',
                  style: GoogleFonts.poppins(
                    color: count == TrackingProvider.totalTasks
                        ? const Color(0xFF22C55E)
                        : context.appAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: count == TrackingProvider.totalTasks
                      ? const Color(0xFF22C55E)
                      : context.appTextFaded,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: context.appDivider,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF4ADE80),
                ),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _motivationText(count, isEn),
              style: GoogleFonts.poppins(
                color: context.appTextPrimary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _motivationText(int count, bool isEn) {
    if (count == TrackingProvider.totalTasks) {
      return isEn ? 'MashaAllah, a perfect day! 🎉' : 'MasyaAllah, sempurna hari ini! 🎉';
    }
    final pct = count * 100 ~/ TrackingProvider.totalTasks;
    if (pct >= 76) return isEn ? 'Almost there, keep going! 🌟' : 'Hampir sempurna, sedikit lagi! 🌟';
    if (pct >= 51) return isEn ? 'Great progress, stay consistent! ⭐' : 'Luar biasa, terus istiqomah! ⭐';
    if (pct >= 26) return isEn ? 'Halfway there, keep it up! 💪' : 'Sudah setengah jalan, semangat! 💪';
    return isEn ? 'Start the day with Bismillah 🌅' : 'Yuk mulai hari dengan bismillah 🌅';
  }
}

// ── Category header ───────────────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  final String cat;
  final bool   isEn;

  const _CategoryHeader({required this.cat, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(cat);
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _categoryLabel(cat, isEn),
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  static Color _categoryColor(String cat) => switch (cat) {
        'malam'   => const Color(0xFF8B5CF6),
        'subuh'   => const Color(0xFF6366F1),
        'pagi'    => const Color(0xFFF59E0B),
        'zuhur'   => const Color(0xFFF97316),
        'ashar'   => const Color(0xFF10B981),
        'petang'  => const Color(0xFFF43F5E),
        'maghrib' => const Color(0xFFEF4444),
        'isya'    => const Color(0xFF7C3AED),
        _         => const Color(0xFF6B7280),
      };

  static String _categoryLabel(String cat, bool isEn) => switch (cat) {
        'malam'   => isEn ? 'NIGHT'   : 'MALAM',
        'subuh'   => isEn ? 'FAJR'    : 'SUBUH',
        'pagi'    => isEn ? 'MORNING' : 'PAGI',
        'zuhur'   => isEn ? 'DHUHR'   : 'ZUHUR',
        'ashar'   => isEn ? 'ASR'     : 'ASHAR',
        'petang'  => isEn ? 'EVENING' : 'PETANG',
        'maghrib' => isEn ? 'MAGHRIB' : 'MAGHRIB',
        'isya'    => isEn ? 'ISHA'    : 'ISYA',
        _         => cat.toUpperCase(),
      };
}

// ── Task row ──────────────────────────────────────────────────────────────────

class _TaskRow extends StatelessWidget {
  final String     label;
  final bool       isDone;
  final DateTime?  timestamp;
  final VoidCallback onTap;

  const _TaskRow({
    required this.label,
    required this.isDone,
    required this.timestamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = timestamp != null
        ? DateFormat('HH:mm').format(timestamp!)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isDone
                ? const Color(0xFF22C55E).withValues(alpha: 0.08)
                : context.appCardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDone
                  ? const Color(0xFF22C55E).withValues(alpha: 0.30)
                  : context.appDivider,
            ),
          ),
          child: Row(
            children: [
              // Checkbox circle
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF22C55E) : Colors.transparent,
                  border: isDone
                      ? null
                      : Border.all(color: context.appTextFaded, width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),

              const SizedBox(width: 12),

              // Label
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color:      isDone ? context.appTextFaded : context.appTextPrimary,
                    fontSize:   13.5,
                    fontWeight: FontWeight.w500,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: context.appTextFaded,
                  ),
                ),
              ),

              // Timestamp
              if (timeStr != null) ...[
                const SizedBox(width: 8),
                Text(
                  timeStr,
                  style: GoogleFonts.poppins(
                    color:      const Color(0xFF22C55E),
                    fontSize:   11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Weekly stats card ─────────────────────────────────────────────────────────

class _WeeklyStatsCard extends StatelessWidget {
  final List<int> stats; // 7 values, index 6 = today
  final bool isEn;

  const _WeeklyStatsCard({required this.stats, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.appCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appDivider),
          boxShadow: [
            BoxShadow(
              color: context.appCardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            final day     = now.subtract(Duration(days: 6 - i));
            final isToday = i == 6;
            return _DayCircle(
              letter:  _dayLetter(day.weekday, isEn),
              count:   stats[i],
              isToday: isToday,
              accentColor: context.appAccent,
            );
          }),
        ),
      ),
    );
  }

  // Weekday abbreviations (1=Mon … 7=Sun)
  static String _dayLetter(int weekday, bool isEn) {
    const lettersId = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    const lettersEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return (isEn ? lettersEn : lettersId)[weekday - 1];
  }
}

class _DayCircle extends StatelessWidget {
  final String letter;
  final int    count;
  final bool   isToday;
  final Color  accentColor;

  const _DayCircle({
    required this.letter,
    required this.count,
    required this.isToday,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final fill = _circleColor(count);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          letter,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: context.appTextSecondary,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color:  fill,
            shape:  BoxShape.circle,
            border: isToday
                ? Border.all(color: accentColor, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '$count',
              style: const TextStyle(
                color:      Colors.white,
                fontSize:   11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Color _circleColor(int count) {
    if (count == TrackingProvider.totalTasks) return const Color(0xFF16A34A); // dark green
    final pct = count * 100 ~/ TrackingProvider.totalTasks;
    if (pct >= 75) return const Color(0xFF4ADE80); // light green
    if (pct >= 50) return const Color(0xFFF97316); // orange
    return const Color(0xFF9CA3AF);                 // grey
  }
}
