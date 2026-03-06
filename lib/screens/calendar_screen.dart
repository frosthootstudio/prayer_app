import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/calendar_provider.dart';
import '../providers/settings_provider.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<SettingsProvider, CalendarProvider>(
      create: (ctx) => CalendarProvider(ctx.read<SettingsProvider>()),
      update: (_, settings, previous) => previous ?? CalendarProvider(settings),
      child: const _CalendarBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _CalendarBody extends StatelessWidget {
  const _CalendarBody();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final cal      = context.watch<CalendarProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.getLabel('hijriCalendar')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _HijriHeader(cal: cal, settings: settings),
          const SizedBox(height: 8),
          _CalendarCard(cal: cal, settings: settings),
          const SizedBox(height: 12),
          _SelectedDayCard(cal: cal, settings: settings),
          const SizedBox(height: 12),
          _UpcomingEventsCard(cal: cal, settings: settings),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Hijri month header ────────────────────────────────────────────────────────

class _HijriHeader extends StatelessWidget {
  final CalendarProvider cal;
  final SettingsProvider settings;

  const _HijriHeader({required this.cal, required this.settings});

  @override
  Widget build(BuildContext context) {
    final h     = cal.hijriFor(cal.focusedDay);
    final arName = cal.hijriMonthName(h.hMonth, arabic: true);
    final locName = cal.hijriMonthName(h.hMonth);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252840) : const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4A057).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$locName ${h.hYear} H',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD4A057),
                  ),
                ),
                Text(
                  '${h.hDay} $locName ${h.hYear}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            arName,
            style: GoogleFonts.amiri(
              fontSize: 22,
              color: const Color(0xFFD4A057),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Table calendar card ───────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  final CalendarProvider cal;
  final SettingsProvider settings;

  const _CalendarCard({required this.cal, required this.settings});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold   = const Color(0xFFD4A057);
    final locale = settings.isEnglish ? 'en_US' : 'id_ID';

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF252840) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: TableCalendar<IslamicEvent>(
          locale: locale,
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(2035, 12, 31),
          focusedDay: cal.focusedDay,
          selectedDayPredicate: (day) => isSameDay(day, cal.selectedDay),
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: ''},
          startingDayOfWeek: StartingDayOfWeek.monday,
          eventLoader: cal.getEventsForDay,
          onDaySelected: cal.selectDay,
          onPageChanged: cal.setFocusedDay,
          headerVisible: true,
          daysOfWeekHeight: 32,
          rowHeight: 56,

          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: Icon(Icons.chevron_left, color: gold),
            rightChevronIcon: Icon(Icons.chevron_right, color: gold),
            titleTextStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            headerPadding: const EdgeInsets.symmetric(vertical: 4),
          ),


          calendarStyle: const CalendarStyle(
            // All cell decorations handled by custom builders (_DayCell).
            // cellMargin creates the visible gaps between tiles.
            outsideDaysVisible: true,
            cellMargin: EdgeInsets.all(2.5),
            markersMaxCount: 3,
            markerSize: 5,
            markerMargin: EdgeInsets.symmetric(horizontal: 0.5),
            markersAlignment: Alignment.bottomCenter,
          ),

          calendarBuilders: CalendarBuilders(
            // Custom day-of-week header: Ahad instead of Minggu/Min
            dowBuilder: (ctx, date) {
              const daysId = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Ahad'];
              const daysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final label = settings.isEnglish
                  ? daysEn[date.weekday - 1]
                  : daysId[date.weekday - 1];
              return Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              );
            },
            // Show event dots with correct colors
            markerBuilder: (ctx, date, events) {
              if (events.isEmpty) return null;
              final dots = events.take(3).map((e) => Container(
                width: 5, height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 0.5),
                decoration: BoxDecoration(color: e.color, shape: BoxShape.circle),
              )).toList();
              return Positioned(
                bottom: 4,
                child: Row(mainAxisSize: MainAxisSize.min, children: dots),
              );
            },
            // Show Hijri day number below Gregorian
            defaultBuilder: (ctx, date, _) => _DayCell(date: date, cal: cal),
            todayBuilder:   (ctx, date, _) => _DayCell(date: date, cal: cal, isToday: true),
            selectedBuilder:(ctx, date, _) => _DayCell(date: date, cal: cal, isSelected: true),
            outsideBuilder: (ctx, date, _) => _DayCell(date: date, cal: cal, isOutside: true),
          ),
        ),
      ),
    );
  }
}

// ── Day cell with Hijri overlay ───────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime date;
  final CalendarProvider cal;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;

  const _DayCell({
    required this.date,
    required this.cal,
    this.isToday    = false,
    this.isSelected = false,
    this.isOutside  = false,
  });

  @override
  Widget build(BuildContext context) {
    const gold   = Color(0xFFD4A057);
    final scheme = Theme.of(context).colorScheme;
    final h      = cal.hijriFor(date);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFriday = date.weekday == DateTime.friday;

    final Color fridayTile = isFriday
        ? gold.withValues(alpha: isDark ? 0.14 : 0.09)
        : Colors.transparent;

    final bgColor = isSelected
        ? gold
        : fridayTile;

    final fgColor = isSelected
        ? Colors.white
        : isToday
            ? gold
            : isOutside
                ? scheme.onSurface.withValues(alpha: 0.28)
                : date.weekday == DateTime.sunday
                    ? const Color(0xFFE57373)
                    : date.weekday == DateTime.saturday
                        ? const Color(0xFF90CAF9)
                        : scheme.onSurface;

    final hijriColor = isSelected
        ? Colors.white.withValues(alpha: 0.70)
        : isToday
            ? gold.withValues(alpha: 0.65)
            : scheme.onSurface.withValues(alpha: isOutside ? 0.20 : 0.35);

    // SizedBox.expand fills the full cell slot allocated by table_calendar,
    // ensuring every background tile is exactly the same size.
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: !isSelected && isToday
              ? Border.all(color: gold, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: isSelected ? 14 : 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: fgColor,
              ),
            ),
            Text(
              '${h.hDay}',
              style: TextStyle(fontSize: 7.5, color: hijriColor, height: 1.1),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Selected day detail card ──────────────────────────────────────────────────

class _SelectedDayCard extends StatelessWidget {
  final CalendarProvider cal;
  final SettingsProvider settings;

  const _SelectedDayCard({required this.cal, required this.settings});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final scheme  = Theme.of(context).colorScheme;
    final locale  = settings.isEnglish ? 'en_US' : 'id_ID';
    final h       = cal.hijriFor(cal.selectedDay);
    final monthNm = cal.hijriMonthName(h.hMonth);
    final events  = cal.getEventsForDate(cal.selectedDay);
    final fast    = cal.getSunnahFastInfo();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252840) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gregorian date
            Text(
              DateFormat('EEEE, d MMMM yyyy', locale).format(cal.selectedDay),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            // Hijri date
            Text(
              '${h.hDay} $monthNm ${h.hYear} H',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFFD4A057),
                fontWeight: FontWeight.w500,
              ),
            ),

            if (events.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                settings.getLabel('islamicEvents'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              ...events.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(color: e.color, shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Text(
                        e.name(settings.isEnglish),
                        style: TextStyle(fontSize: 13, color: scheme.onSurface),
                      ),
                    ),
                  ],
                ),
              )),
            ],

            if (fast != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A057).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD4A057).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFD4A057), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        settings.getLabel('sunnahFasting'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD4A057),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(fast, style: TextStyle(fontSize: 12, color: scheme.onSurface)),
                  ],
                ),
              ),
            ],

            if (events.isEmpty && fast == null) ...[
              const SizedBox(height: 10),
              Text(
                settings.getLabel('noEvents'),
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
    );
  }
}

// ── Upcoming events card ──────────────────────────────────────────────────────

class _UpcomingEventsCard extends StatelessWidget {
  final CalendarProvider cal;
  final SettingsProvider settings;

  const _UpcomingEventsCard({required this.cal, required this.settings});

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final scheme   = Theme.of(context).colorScheme;
    final locale   = settings.isEnglish ? 'en_US' : 'id_ID';
    final upcoming = cal.upcomingEvents(count: 5);

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF252840) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              settings.getLabel('upcomingEvents'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (upcoming.isEmpty)
              Text(
                settings.getLabel('noEvents'),
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              )
            else
              ...upcoming.map((item) {
                final h       = cal.hijriFor(item.gregorianDate);
                final monthNm = cal.hijriMonthName(h.hMonth);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8, height: 8,
                        margin: const EdgeInsets.only(top: 4, right: 10),
                        decoration: BoxDecoration(
                          color: item.event.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.event.name(settings.isEnglish),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurface,
                              ),
                            ),
                            Text(
                              '${DateFormat('d MMM yyyy', locale).format(item.gregorianDate)}'
                              '  •  ${h.hDay} $monthNm ${h.hYear} H',
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
