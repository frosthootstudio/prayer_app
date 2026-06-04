import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/prayer_model.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tracking_provider.dart';
import '../services/permission_service.dart';
import '../services/ramadan_service.dart';
import '../utils/app_theme.dart';
import '../utils/time_format.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/permission_fix_sheet.dart';
import '../widgets/share_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigateToTracking});

  final VoidCallback? onNavigateToTracking;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showPermBanner = false;

  // ── Prayer schedule swiper state ──────────────────────────────────────────
  // Page 0 = today, page 1 = tomorrow. User swipes left on the schedule card
  // to peek tomorrow's prayer times without leaving the home screen.
  late final PageController _scheduleController;
  int _schedulePage = 0;

  @override
  void initState() {
    super.initState();
    _scheduleController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().initialize();
      _checkPermissions();
    });
  }

  @override
  void dispose() {
    _scheduleController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final allOk = await PermissionService.allGranted();
    if (mounted) setState(() => _showPermBanner = !allOk);
  }

  void _showPermissionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PermissionFixSheet(
        isXiaomi: PermissionService.isXiaomiDevice,
        onDone: () {
          Navigator.pop(ctx);
          _checkPermissions();
        },
      ),
    );
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
          // ── Permission warning banner ───────────────────────────────────────
          if (_showPermBanner)
            NotifWarningBanner(
              onTap: () => _showPermissionSheet(context),
            ),

          // ── Date header ────────────────────────────────────────────────────
          _DateHeader(
            hijriDate:     provider.hijriDate,
            gregorianDate: provider.gregorianDate,
            showCrescent:  settings.ramadanMode && RamadanService.isRamadan(),
          ),

          // ── Ramadan banner ─────────────────────────────────────────────────
          if (settings.ramadanMode) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _RamadanBanner(isEnglish: settings.isEnglish),
            ),
          ],

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
          // Wrapped in SingleChildScrollView so content gracefully scrolls on
          // short screens (e.g. when Ramadan card + Sun info are both visible).
          // Without this, the inner Column overflows the Expanded constraint.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Swipeable schedule: page 0 = today, page 1 = tomorrow.
                  // PageView needs a fixed height when nested inside a
                  // SingleChildScrollView (otherwise infinite-height conflict).
                  // Height tuned to fit the worst case (Ramadan + Imsak row);
                  // slight overshoot in non-Ramadan mode is acceptable.
                  SizedBox(
                    height: provider.isRamadanActive ? 430 : 380,
                    child: PageView(
                      controller: _scheduleController,
                      onPageChanged: (i) =>
                          setState(() => _schedulePage = i),
                      children: [
                        // Today
                        _PrayerGroupCard(
                          prayers:            prayers,
                          currentIdx:         currentIdx,
                          cityName:           provider.cityName,
                          notifPrefs:         provider.notifPrefs,
                          masterNotifEnabled: settings.masterNotifEnabled,
                          imsakTime: provider.isRamadanActive
                              ? provider.imsakTime
                              : null,
                          onRefresh: () =>
                              context.read<PrayerProvider>().retryLocation(),
                          onShare: () =>
                              _showShareSheet(context, provider, settings),
                          onToggleNotif: (key) => context
                              .read<PrayerProvider>()
                              .toggleNotification(key),
                        ),
                        // Tomorrow
                        _TomorrowScheduleCard(
                          provider: provider,
                          settings: settings,
                          onRefresh: () =>
                              context.read<PrayerProvider>().retryLocation(),
                          onShare: () =>
                              _showShareSheet(context, provider, settings),
                          onToggleNotif: (key) => context
                              .read<PrayerProvider>()
                              .toggleNotification(key),
                        ),
                      ],
                    ),
                  ),

                  // Page indicator + label
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _schedulePage == 0
                            ? settings.getLabel('today')
                            : settings.getLabel('tomorrow'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.appTextFaded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SmoothPageIndicator(
                        controller: _scheduleController,
                        count: 2,
                        effect: ExpandingDotsEffect(
                          dotHeight: 5,
                          dotWidth: 5,
                          expansionFactor: 3,
                          spacing: 4,
                          activeDotColor: context.appAccent,
                          dotColor: context.appDivider,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (provider.isRamadanActive)
                    _RamadanCountdownCard(
                      prayers:   prayers,
                      imsakTime: provider.imsakTime,
                      isEnglish: settings.isEnglish,
                    ),

                  if (syuruq != null && dhuhr != null && maghrib != null) ...[
                    const SizedBox(height: 8),
                    _SunInfoCard(
                      syuruqTime:  syuruq.time,
                      dhuhrTime:   dhuhr.time,
                      maghribTime: maghrib.time,
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareSheet(
    BuildContext context,
    PrayerProvider provider,
    SettingsProvider settings,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareBottomSheet(
        prayers:       provider.prayerTimes,
        cityName:      provider.cityName,
        gregorianDate: provider.gregorianDate,
        hijriDate:     provider.hijriDate,
        imsakTime:     provider.isRamadanActive ? provider.imsakTime : null,
        language:      settings.language,
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

// ── Tomorrow schedule wrapper ─────────────────────────────────────────────────
//
// Thin wrapper around _PrayerGroupCard that:
//   - Computes tomorrow's prayer times via PrayerProvider.prayerTimesForDate.
//   - Computes tomorrow's imsak (Fajr − 10min) if Ramadan mode is active.
//   - Passes currentIdx: -1 so no prayer is highlighted as "current".
//   - Returns a placeholder if GPS isn't cached yet (first launch).
//
// Notification toggles still call the same provider — toggling on the tomorrow
// page also updates today's schedule (notification prefs are per-prayer, not
// per-day). That's the intended behavior.

class _TomorrowScheduleCard extends StatelessWidget {
  final PrayerProvider provider;
  final SettingsProvider settings;
  final VoidCallback onRefresh;
  final VoidCallback onShare;
  final void Function(String key) onToggleNotif;

  const _TomorrowScheduleCard({
    required this.provider,
    required this.settings,
    required this.onRefresh,
    required this.onShare,
    required this.onToggleNotif,
  });

  @override
  Widget build(BuildContext context) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowPrayers = provider.prayerTimesForDate(tomorrow);

    if (tomorrowPrayers == null || tomorrowPrayers.isEmpty) {
      // No GPS yet — show placeholder so the user understands tomorrow's
      // schedule needs the same location data as today.
      return Container(
        decoration: BoxDecoration(
          color: context.appCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appDivider, width: 1),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              settings.getLabel('city'),
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appTextFaded, fontSize: 13),
            ),
          ),
        ),
      );
    }

    return _PrayerGroupCard(
      prayers:            tomorrowPrayers,
      currentIdx:         -1, // no "current" highlight on a future day
      cityName:           provider.cityName,
      notifPrefs:         provider.notifPrefs,
      masterNotifEnabled: settings.masterNotifEnabled,
      imsakTime: provider.isRamadanActive
          ? provider.imsakTimeFor(tomorrowPrayers)
          : null,
      onRefresh:     onRefresh,
      onShare:       onShare,
      onToggleNotif: onToggleNotif,
    );
  }
}

// ── Prayer group card ─────────────────────────────────────────────────────────

class _PrayerGroupCard extends StatelessWidget {
  final List<PrayerInfo> prayers;
  final int currentIdx;
  final String cityName;
  final Map<String, bool> notifPrefs;
  final bool masterNotifEnabled;
  final DateTime? imsakTime;
  final VoidCallback onRefresh;
  final VoidCallback onShare;
  final void Function(String key) onToggleNotif;

  const _PrayerGroupCard({
    required this.prayers,
    required this.currentIdx,
    required this.cityName,
    required this.notifPrefs,
    required this.masterNotifEnabled,
    this.imsakTime,
    required this.onRefresh,
    required this.onShare,
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
                    onTap: onShare,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.appRefreshBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.share_rounded,
                        size: 14,
                        color: context.appAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
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
              // Imsak row injected before Fajr during Ramadan
              if (prayers[i].key == 'fajr' && imsakTime != null) ...[
                _ImsakRow(time: imsakTime!),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Divider(height: 1, thickness: 0.5, color: context.appDivider),
                ),
              ],
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
            formatPrayerTime(context, prayer.time),
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
                  time:  formatPrayerTime(ctx, syuruqTime),
                ),
                VerticalDivider(
                  width: 1, thickness: 1, indent: 10, endIndent: 10,
                  color: ctx.appSunDivider,
                ),
                _SunSection(
                  icon:  Icons.wb_sunny_rounded,
                  label: s.getLabel('solarNoon'),
                  time:  formatPrayerTime(ctx, dhuhrTime),
                ),
                VerticalDivider(
                  width: 1, thickness: 1, indent: 10, endIndent: 10,
                  color: ctx.appSunDivider,
                ),
                _SunSection(
                  icon:  Icons.brightness_4_rounded,
                  label: s.getLabel('sunSet'),
                  time:  formatPrayerTime(ctx, maghribTime),
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
  final bool showCrescent;

  const _DateHeader({
    required this.hijriDate,
    required this.gregorianDate,
    this.showCrescent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
      child: Column(
        children: [
          if (hijriDate.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showCrescent) ...[
                  const Icon(
                    Icons.nightlight_round,
                    size: 14,
                    color: Color(0xFFD4A057),
                  ),
                  const SizedBox(width: 5),
                ],
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
                if (showCrescent) ...[
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.nightlight_round,
                    size: 14,
                    color: Color(0xFFD4A057),
                  ),
                ],
              ],
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
    final total    = tracking.effectiveTotalTasks;
    final pct      = count / total;

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
                        '$count/$total',
                        style: GoogleFonts.poppins(
                          color: count == total
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

// ── Imsak row ─────────────────────────────────────────────────────────────────

class _ImsakRow extends StatelessWidget {
  final DateTime time;
  const _ImsakRow({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.nightlight_round, size: 16, color: Color(0xFFD4A057)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Imsak',
              style: GoogleFonts.poppins(
                color: context.appTextPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            formatPrayerTime(context, time),
            style: GoogleFonts.poppins(
              color: context.appTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 28), // align with rows that have bell icon
        ],
      ),
    );
  }
}

// ── Ramadan banner ────────────────────────────────────────────────────────────

class _RamadanBanner extends StatelessWidget {
  final bool isEnglish;
  const _RamadanBanner({required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final inRamadan   = RamadanService.isRamadan();
    final day         = RamadanService.currentRamadanDay();
    final daysUntil   = RamadanService.daysUntilRamadan();
    final isQadar     = RamadanService.isLailatulQadarNight();

    // Only show if within 30 days of Ramadan or during Ramadan
    if (!inRamadan && daysUntil > 30) return const SizedBox.shrink();

    String mainText;
    String? subText;

    if (inRamadan && day != null) {
      mainText = isEnglish
          ? '🌙 Ramadan · Day $day of 30'
          : '🌙 Ramadhan · Hari ke-$day dari 30';
      if (isQadar) {
        subText = isEnglish
            ? '✨ Tonight may be Lailatul Qadar — increase your worship!'
            : '✨ Malam ini bisa jadi Lailatul Qadar — perbanyak ibadah!';
      }
    } else {
      mainText = isEnglish
          ? '🌙 $daysUntil days until Ramadan'
          : '🌙 $daysUntil hari lagi menuju Ramadhan';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3A00), Color(0xFFD4A057)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mainText,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subText != null) ...[
            const SizedBox(height: 3),
            Text(
              subText,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Ramadan countdown card ─────────────────────────────────────────────────────

class _RamadanCountdownCard extends StatelessWidget {
  final List<PrayerInfo> prayers;
  final DateTime? imsakTime;
  final bool isEnglish;

  const _RamadanCountdownCard({
    required this.prayers,
    required this.imsakTime,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final fajr    = _find(prayers, 'fajr');
    final maghrib = _find(prayers, 'maghrib');

    String label;
    Duration? diff;

    if (fajr != null && imsakTime != null && now.isBefore(fajr.time)) {
      // Before Fajr — count down to Imsak or Fajr
      if (now.isBefore(imsakTime!)) {
        diff  = imsakTime!.difference(now);
        label = isEnglish ? 'Time to Imsak' : 'Menuju Imsak';
      } else {
        diff  = fajr.time.difference(now);
        label = isEnglish ? 'Time to Fajr (Sahur ends)' : 'Menuju Subuh (Sahur berakhir)';
      }
    } else if (maghrib != null && now.isBefore(maghrib.time)) {
      // After Fajr, before Maghrib — countdown to iftar
      diff  = maghrib.time.difference(now);
      label = isEnglish ? 'Time to Iftar (Maghrib)' : 'Menuju Buka Puasa (Maghrib)';
    } else {
      return const SizedBox.shrink();
    }

    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: context.appCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4A057).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: context.appCardShadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 18, color: Color(0xFFD4A057)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: context.appTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$h:$m:$s',
            style: GoogleFonts.poppins(
              color: const Color(0xFFD4A057),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  static PrayerInfo? _find(List<PrayerInfo> list, String key) {
    try { return list.firstWhere((p) => p.key == key); } catch (_) { return null; }
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
