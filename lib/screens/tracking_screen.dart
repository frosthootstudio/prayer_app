import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/tracking_provider.dart';
import '../services/prayer_calculation_service.dart';
import '../utils/app_theme.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrackingProvider>();
    final settings = context.watch<SettingsProvider>();
    final today    = tracking.todayKey;
    final count    = tracking.todayCount;
    final lang     = settings.language;

    // Pre-compute flat list: String = category header, Map = task
    final List<Object> items = [];
    String? lastCat;
    for (final task in tracking.effectiveTasks) {
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
            child: _SummaryCard(
              count: count,
              total: tracking.effectiveTotalTasks,
              language: lang,
              streak: tracking.getDailyStreak(),
            ),
          ),

          // ── Task list ─────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                if (item is String) {
                  return _CategoryHeader(cat: item, language: lang);
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
              language: lang,
              completionRate: tracking.weeklyCompletionRate,
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
  final int         count;
  final int         total;
  final AppLanguage language;
  final int         streak;

  const _SummaryCard({
    required this.count,
    required this.total,
    required this.language,
    required this.streak,
  });

  static String _t(AppLanguage l, {required String ar, required String en, required String id}) =>
      l == AppLanguage.ar ? ar : l == AppLanguage.en ? en : id;

  @override
  Widget build(BuildContext context) {
    final pct = count / total;
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
                  _t(language, ar: 'عبادات اليوم', en: "Today's Ibadah", id: 'Ibadah hari ini'),
                  style: GoogleFonts.poppins(
                    color: context.appTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (streak > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFF97316).withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 10.5)),
                        const SizedBox(width: 3),
                        Text(
                          _t(language,
                            ar: '$streak يوم',
                            en: '$streak day streak',
                            id: '$streak hari streak',
                          ),
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFF97316),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  '$count/$total',
                  style: GoogleFonts.poppins(
                    color: count == total
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
                  color: count == total
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
              _motivationText(count, total, language),
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

  static String _motivationText(int count, int total, AppLanguage lang) {
    if (count == total) { return _t(lang,
      ar: 'ما شاء الله، يوم مثالي! 🎉',
      en: 'MashaAllah, a perfect day! 🎉',
      id: 'MasyaAllah, sempurna hari ini! 🎉'); }
    final pct = total > 0 ? count * 100 ~/ total : 0;
    if (pct >= 76) { return _t(lang,
      ar: 'تقريبًا، أكمل! 🌟',
      en: 'Almost there, keep going! 🌟',
      id: 'Hampir sempurna, sedikit lagi! 🌟'); }
    if (pct >= 51) { return _t(lang,
      ar: 'رائع، استمر! ⭐',
      en: 'Great progress, stay consistent! ⭐',
      id: 'Luar biasa, terus istiqomah! ⭐'); }
    if (pct >= 26) { return _t(lang,
      ar: 'منتصف الطريق، تشجع! 💪',
      en: 'Halfway there, keep it up! 💪',
      id: 'Sudah setengah jalan, semangat! 💪'); }
    return _t(lang,
      ar: 'ابدأ يومك بالبسملة 🌅',
      en: 'Start the day with Bismillah 🌅',
      id: 'Yuk mulai hari dengan bismillah 🌅');
  }
}

// ── Category header ───────────────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  final String      cat;
  final AppLanguage language;

  const _CategoryHeader({required this.cat, required this.language});

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
            _categoryLabel(cat, language),
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
        'ramadan' => const Color(0xFFD4A057),
        _         => const Color(0xFF6B7280),
      };

  static String _categoryLabel(String cat, AppLanguage lang) => switch (cat) {
        'malam'   => _t(lang, ar: 'ليل',    en: 'NIGHT',   id: 'MALAM'),
        'subuh'   => _t(lang, ar: 'فجر',    en: 'FAJR',    id: 'SUBUH'),
        'pagi'    => _t(lang, ar: 'صباح',   en: 'MORNING', id: 'PAGI'),
        'zuhur'   => _t(lang, ar: 'ظهر',    en: 'DHUHR',   id: 'ZUHUR'),
        'ashar'   => _t(lang, ar: 'عصر',    en: 'ASR',     id: 'ASHAR'),
        'petang'  => _t(lang, ar: 'مساء',   en: 'EVENING', id: 'PETANG'),
        'maghrib' => _t(lang, ar: 'مغرب',   en: 'MAGHRIB', id: 'MAGHRIB'),
        'isya'    => _t(lang, ar: 'عشاء',   en: 'ISHA',    id: 'ISYA'),
        'ramadan' => _t(lang, ar: 'رمضان',  en: 'RAMADAN', id: 'RAMADAN'),
        _         => cat.toUpperCase(),
      };

  static String _t(AppLanguage l, {required String ar, required String en, required String id}) =>
      l == AppLanguage.ar ? ar : l == AppLanguage.en ? en : id;
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
  final List<int>   stats; // 7 values, index 6 = today
  final AppLanguage language;
  final double      completionRate;

  const _WeeklyStatsCard({
    required this.stats,
    required this.language,
    required this.completionRate,
  });

  static String _t(AppLanguage l, {required String ar, required String en, required String id}) =>
      l == AppLanguage.ar ? ar : l == AppLanguage.en ? en : id;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final pctInt = (completionRate * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appDivider),
          boxShadow: [
            BoxShadow(
              color: context.appCardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights_rounded, size: 16, color: context.appAccent),
                const SizedBox(width: 6),
                Text(
                  _t(language, ar: 'إحصائيات ٧ أيام', en: 'Weekly Stats (7 Days)', id: 'Statistik 7 Hari Terakhir'),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.appTextPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.appAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$pctInt%',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.appAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final day     = now.subtract(Duration(days: 6 - i));
                final isToday = i == 6;
                return _DayCircle(
                  letter:  _dayLetter(day.weekday, language),
                  count:   stats[i],
                  isToday: isToday,
                  accentColor: context.appAccent,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Weekday abbreviations (1=Mon … 7=Sun)
  static String _dayLetter(int weekday, AppLanguage lang) {
    const lettersAr = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
    const lettersEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const lettersId = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    final letters   = lang == AppLanguage.ar ? lettersAr
                    : lang == AppLanguage.en ? lettersEn
                    : lettersId;
    return letters[weekday - 1];
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
