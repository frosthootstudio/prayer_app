import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/prayer_model.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tracking_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/next_prayer_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigateToTracking});

  final VoidCallback? onNavigateToTracking;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerProvider>();
    final settings = context.watch<SettingsProvider>();

    // ── Loading ───────────────────────────────────────────────────────────────
    if (provider.isLoading && provider.prayerTimes.isEmpty) {
      return Center(child: CircularProgressIndicator(color: context.appAccent));
    }

    // ── Error ─────────────────────────────────────────────────────────────────
    if (provider.error != null) {
      return _ErrorView(
        message: provider.error!,
        onRetry: () => context.read<PrayerProvider>().retryLocation(),
      );
    }

    // ── Main UI ───────────────────────────────────────────────────────────────
    final prayers = provider.prayerTimes;

    final nextIdx = prayers.indexWhere((p) => p.isNext);
    final currentIdx =
        nextIdx > 0 ? nextIdx - 1 : (nextIdx == -1 ? prayers.length - 1 : -1);

    final syuruq  = _findPrayer(prayers, 'sunrise');
    final dhuhr   = _findPrayer(prayers, 'dhuhr');
    final maghrib = _findPrayer(prayers, 'maghrib');

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ── Date header ────────────────────────────────────────────────────
          _DateHeader(
            hijriDate:    provider.hijriDate,
            gregorianDate: provider.gregorianDate,
          ),

          const SizedBox(height: 10),

          // ── Current + next prayer cards ────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: NextPrayerCard(),
          ),

          const SizedBox(height: 8),

          // ── Ibadah progress bar (tappable shortcut) ─────────────────────
          if (widget.onNavigateToTracking != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _IbadahProgressRow(onTap: widget.onNavigateToTracking!),
            ),

          // ── Prayer group card + sun info ───────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _PrayerGroupCard(
                    prayers:            prayers,
                    currentIdx:         currentIdx,
                    cityName:           provider.cityName,
                    notifPrefs:         provider.notifPrefs,
                    masterNotifEnabled: settings.masterNotifEnabled,
                    onRefresh: () =>
                        context.read<PrayerProvider>().retryLocation(),
                    onToggleNotif: (key) =>
                        context.read<PrayerProvider>().toggleNotification(key),
                  ),

                  const SizedBox(height: 8),

                  if (syuruq != null && dhuhr != null && maghrib != null)
                    _SunInfoCard(
                      syuruqTime:  syuruq.time,
                      dhuhrTime:   dhuhr.time,
                      maghribTime: maghrib.time,
                    ),

                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PrayerInfo? _findPrayer(List<PrayerInfo> list, String key) {
    try {
      return list.firstWhere((p) => p.key == key);
    } catch (_) {
      return null;
    }
  }
}

// ── Prayer group card ─────────────────────────────────────────────────────────

class _PrayerGroupCard extends StatelessWidget {
  final List<PrayerInfo> prayers;
  final int currentIdx;
  final String cityName;
  final Map<String, bool> notifPrefs;
  final bool masterNotifEnabled;
  final VoidCallback onRefresh;
  final void Function(String key) onToggleNotif;

  const _PrayerGroupCard({
    required this.prayers,
    required this.currentIdx,
    required this.cityName,
    required this.notifPrefs,
    required this.masterNotifEnabled,
    required this.onRefresh,
    required this.onToggleNotif,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Container(
      decoration: BoxDecoration(
        color: context.appCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appDivider, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.appCardShadow,
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Location header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: context.appAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      cityName.isNotEmpty ? cityName : '—',
                      style: GoogleFonts.poppins(
                        color: context.appTextPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: onRefresh,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.appRefreshBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.refresh_rounded,
                        size: 14,
                        color: context.appAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider below location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Divider(
                height: 1, thickness: 1, color: context.appDivider,
              ),
            ),

            // ── Prayer rows ──────────────────────────────────────────────────
            for (int i = 0; i < prayers.length; i++) ...[
              _PrayerRow(
                prayer:         prayers[i],
                prayerName:     settings.getPrayerName(prayers[i].key),
                isCurrent:      i == currentIdx,
                notifEnabled:   masterNotifEnabled &&
                    (notifPrefs[prayers[i].key] ?? true),
                onToggleNotif:  () => onToggleNotif(prayers[i].key),
              ),
              if (i < prayers.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Divider(
                    height: 1, thickness: 0.5, color: context.appDivider,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Single prayer row ─────────────────────────────────────────────────────────

class _PrayerRow extends StatelessWidget {
  final PrayerInfo prayer;
  final String prayerName;
  final bool isCurrent;
  final bool notifEnabled;
  final VoidCallback? onToggleNotif;

  const _PrayerRow({
    required this.prayer,
    required this.prayerName,
    this.isCurrent = false,
    this.notifEnabled = true,
    this.onToggleNotif,
  });

  @override
  Widget build(BuildContext context) {
    final isPassed  = prayer.isPassed;
    final isSunrise = prayer.key == 'sunrise';

    final Color nameColor = isCurrent
        ? context.appAccent
        : isPassed
            ? context.appTextFaded
            : context.appTextPrimary;

    return Container(
      color: isCurrent ? context.appRowHighlight : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // ── Colored icon circle ───────────────────────────────────────────
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isPassed
                  ? context.appIconPassedBg
                  : _iconBgColor(prayer.key),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _prayerIcon(prayer.key),
              size: 16,
              color: isPassed
                  ? context.appIconPassedFg
                  : _iconFgColor(prayer.key),
            ),
          ),

          const SizedBox(width: 12),

          // ── Prayer name (localised) ────────────────────────────────────────
          Expanded(
            child: Text(
              prayerName,
              style: GoogleFonts.poppins(
                color: nameColor,
                fontSize: 13.5,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),

          // ── Prayer time ───────────────────────────────────────────────────
          Text(
            DateFormat('HH:mm').format(prayer.time),
            style: GoogleFonts.poppins(
              color: nameColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          const SizedBox(width: 10),

          // ── Bell icon (interactive toggle) ────────────────────────────────
          if (!isSunrise)
            GestureDetector(
              onTap: onToggleNotif,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  notifEnabled
                      ? Icons.notifications_rounded
                      : Icons.notifications_off_outlined,
                  size: 15,
                  color: notifEnabled
                      ? (isPassed ? context.appIconPassedFg : context.appAccent)
                      : context.appBellOff,
                ),
              ),
            )
          else
            const SizedBox(width: 18),
        ],
      ),
    );
  }

  static Color _iconBgColor(String key) => switch (key) {
        'fajr'    => const Color(0xFFEEF2FF),
        'sunrise' => const Color(0xFFFFFBEB),
        'dhuhr'   => const Color(0xFFFFF7ED),
        'asr'     => const Color(0xFFECFDF5),
        'maghrib' => const Color(0xFFFFF1F2),
        'isha'    => const Color(0xFFF5F3FF),
        _         => const Color(0xFFF5F5F5),
      };

  static Color _iconFgColor(String key) => switch (key) {
        'fajr'    => const Color(0xFF6366F1),
        'sunrise' => const Color(0xFFF59E0B),
        'dhuhr'   => const Color(0xFFF97316),
        'asr'     => const Color(0xFF10B981),
        'maghrib' => const Color(0xFFF43F5E),
        'isha'    => const Color(0xFF8B5CF6),
        _         => Colors.grey,
      };

  static IconData _prayerIcon(String key) => switch (key) {
        'fajr'    => Icons.nights_stay_rounded,
        'sunrise' => Icons.wb_twilight_rounded,
        'dhuhr'   => Icons.wb_sunny_rounded,
        'asr'     => Icons.brightness_5_rounded,
        'maghrib' => Icons.brightness_4_rounded,
        'isha'    => Icons.nights_stay_rounded,
        _         => Icons.circle_outlined,
      };
}

// ── Sun info card ─────────────────────────────────────────────────────────────

class _SunInfoCard extends StatelessWidget {
  final DateTime syuruqTime;
  final DateTime dhuhrTime;
  final DateTime maghribTime;

  const _SunInfoCard({
    required this.syuruqTime,
    required this.dhuhrTime,
    required this.maghribTime,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm');
    return Container(
      decoration: BoxDecoration(
        color: context.appCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appDivider, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.appCardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Builder(
          builder: (ctx) {
            final s = ctx.watch<SettingsProvider>();
            return Row(
              children: [
                _SunSection(
                  icon:  Icons.wb_twilight_rounded,
                  label: s.getLabel('sunRise'),
                  time:  fmt.format(syuruqTime),
                ),
                VerticalDivider(
                  width: 1, thickness: 1, indent: 10, endIndent: 10,
                  color: ctx.appSunDivider,
                ),
                _SunSection(
                  icon:  Icons.wb_sunny_rounded,
                  label: s.getLabel('solarNoon'),
                  time:  fmt.format(dhuhrTime),
                ),
                VerticalDivider(
                  width: 1, thickness: 1, indent: 10, endIndent: 10,
                  color: ctx.appSunDivider,
                ),
                _SunSection(
                  icon:  Icons.brightness_4_rounded,
                  label: s.getLabel('sunSet'),
                  time:  fmt.format(maghribTime),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SunSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;

  const _SunSection({
    required this.icon,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: context.appAccent),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: context.appTextSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              time,
              style: GoogleFonts.poppins(
                color: context.appTextPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date header ───────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final String hijriDate;
  final String gregorianDate;

  const _DateHeader({
    required this.hijriDate,
    required this.gregorianDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
      child: Column(
        children: [
          if (hijriDate.isNotEmpty)
            Text(
              hijriDate,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: context.appTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          Text(
            gregorianDate,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: context.appTextSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ibadah progress row (home screen shortcut) ───────────────────────────────

class _IbadahProgressRow extends StatelessWidget {
  final VoidCallback onTap;
  const _IbadahProgressRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrackingProvider>();
    final settings = context.watch<SettingsProvider>();
    final count    = tracking.todayCount;
    final pct      = count / TrackingProvider.totalTasks;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: context.appCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.appDivider),
        ),
        child: Row(
          children: [
            Icon(Icons.checklist_outlined, size: 15, color: context.appAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        settings.getLabel('ibadahToday'),
                        style: GoogleFonts.poppins(
                          color: context.appTextSecondary,
                          fontSize: 11,
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
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: context.appDivider,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4ADE80),
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 16, color: context.appTextFaded),
          ],
        ),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 64,
              color: context.appAccent.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: context.appTextSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                context.watch<SettingsProvider>().getLabel('tryAgain'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
