import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../utils/arabic_font_helper.dart';

import 'package:audioplayers/audioplayers.dart';

import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';
import '../services/rating_service.dart';
import '../services/prayer_calculation_service.dart';
import '../utils/app_theme.dart';
import '../widgets/permission_fix_sheet.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final prayers  = context.watch<PrayerProvider>();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Text(
              settings.getLabel('settings'),
              style: GoogleFonts.poppins(
                color: context.appTextPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // ── Scrollable settings list ───────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [

                // ── LOKASI / LOCATION ────────────────────────────────────────
                _SectionHeader(settings.getLabel('location')),
                _SettingCard(children: [
                  _InfoRow(
                    label: settings.getLabel('city'),
                    value: prayers.cityName.isNotEmpty ? prayers.cityName : '—',
                  ),
                  const _CardDivider(),
                  _ActionRow(
                    label: settings.getLabel('refreshLocation'),
                    icon: Icons.my_location_rounded,
                    onTap: () => context.read<PrayerProvider>().retryLocation(),
                  ),
                  const _CardDivider(),
                  _ToggleRow(
                    label: settings.getLabel('autoLocation'),
                    value: settings.autoLocation,
                    onChanged: (v) =>
                        context.read<SettingsProvider>().setAutoLocation(v),
                  ),
                ]),

                const SizedBox(height: 20),

                // ── METODE KALKULASI / CALCULATION METHOD ────────────────────
                _SectionHeader(settings.getLabel('calcMethod')),
                _SettingCard(children: [
                  _PickerRow(
                    label: settings.getLabel('method'),
                    value: settings.calcMethod.label,
                    onTap: () => _showPicker<CalcMethod>(
                      context,
                      title:    settings.getLabel('calcMethod'),
                      options:  CalcMethod.values,
                      selected: settings.calcMethod,
                      label:    (m) => m.label,
                      onSelect: (m) =>
                          context.read<SettingsProvider>().setCalcMethod(m),
                    ),
                  ),
                  const _CardDivider(),
                  _PickerRow(
                    label: settings.getLabel('madhab'),
                    value: settings.getMadhabLabel(settings.madhab),
                    onTap: () => _showPicker<MadhabSetting>(
                      context,
                      title:    settings.getLabel('madhab'),
                      options:  MadhabSetting.values,
                      selected: settings.madhab,
                      label:    (m) => settings.getMadhabLabel(m),
                      onSelect: (m) =>
                          context.read<SettingsProvider>().setMadhab(m),
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // ── KOREKSI WAKTU / TIME CORRECTION ─────────────────────────
                _SectionHeader(settings.getLabel('timeCorrection')),
                _PrayerOffsetCard(settings: settings),

                const SizedBox(height: 20),

                // ── NOTIFIKASI / NOTIFICATIONS ───────────────────────────────
                _SectionHeader(settings.getLabel('notifications')),
                _SettingCard(children: [
                  _ToggleRow(
                    label: settings.getLabel('enableAllNotif'),
                    value: settings.masterNotifEnabled,
                    onChanged: (v) =>
                        context.read<SettingsProvider>().setMasterNotif(v),
                  ),
                  const _CardDivider(),
                  _ToggleRow(
                    label: settings.getLabel('preAdzan'),
                    value: settings.preAdzanEnabled,
                    onChanged: (v) =>
                        context.read<SettingsProvider>().setPreAdzanEnabled(v),
                  ),
                  if (settings.preAdzanEnabled) ...[
                    const _CardDivider(),
                    _PickerRow(
                      label: settings.getLabel('preAdzanMinutes'),
                      value: '${settings.preAdzanMinutes}'
                          ' ${settings.isEnglish ? "min" : "menit"}',
                      onTap: () =>
                          _showPreAdzanPicker(context, settings),
                    ),
                  ],
                  const _CardDivider(),
                  _ActionRow(
                    label: settings.getLabel('testNotif'),
                    icon:  Icons.notifications_active_rounded,
                    onTap: () async {
                      await NotificationService.scheduleTest(
                        sound: settings.adzanSound,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(settings.getLabel('testNotifSent')),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  ),
                ]),

                const SizedBox(height: 20),

                // ── ADZAN AUDIO ──────────────────────────────────────────────
                _SectionHeader(settings.getLabel('adzanAudio')),
                _AdzanCard(settings: settings),

                const SizedBox(height: 20),

                // ── DEVICE OPTIMIZATION (non-stock Android) ──────────────────
                if (PermissionService.needsOptimizationGuidance) ...[
                  _SectionHeader(settings.getLabel('miuiSection')),
                  _ManufacturerOptCard(
                    settings:    settings,
                    manufacturer: PermissionService.deviceManufacturer,
                    onFixTap:    () => _showPermissionSheet(context),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── TAMPILAN ARAB / ARABIC DISPLAY ───────────────────────────
                _SectionHeader(settings.getLabel('arabicDisplay')),
                _ArabicDisplayCard(settings: settings),

                const SizedBox(height: 20),

                // ── RAMADAN ───────────────────────────────────────────────────
                _SectionHeader(settings.getLabel('ramadanMode')),
                _SettingCard(children: [
                  _ToggleRow(
                    label: settings.getLabel('ramadanMode'),
                    value: settings.ramadanMode,
                    onChanged: (v) =>
                        context.read<SettingsProvider>().setRamadanMode(v),
                  ),
                  const _CardDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Text(
                      settings.getLabel('ramadanModeDesc'),
                      style: GoogleFonts.poppins(
                        color: context.appTextSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // ── TAMPILAN / APPEARANCE ────────────────────────────────────
                _SectionHeader(settings.getLabel('appearance')),
                _SettingCard(children: [
                  _PickerRow(
                    label: settings.getLabel('theme'),
                    value: settings.themeModeLabel,
                    onTap: () => _showThemePicker(context, settings),
                  ),
                  const _CardDivider(),
                  _PickerRow(
                    label: settings.getLabel('language'),
                    value: settings.language.label,
                    onTap: () => _showPicker<AppLanguage>(
                      context,
                      title:    settings.getLabel('language'),
                      options:  AppLanguage.values,
                      selected: settings.language,
                      label:    (l) => l.label,
                      onSelect: (l) =>
                          context.read<SettingsProvider>().setLanguage(l),
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // ── TENTANG / ABOUT ──────────────────────────────────────────
                _SectionHeader(settings.getLabel('about')),
                _SettingCard(children: [
                  _ActionRow(
                    label: settings.getLabel('rateApp'),
                    icon:  Icons.star_outline_rounded,
                    onTap: () => RatingService.requestRating(),
                  ),
                  const _CardDivider(),
                  _InfoRow(label: settings.getLabel('version'),     value: '1.1.1 (build 11)'),
                  const _CardDivider(),
                  _InfoRow(label: settings.getLabel('developedBy'), value: 'Frosthoot Studio'),
                  const _CardDivider(),
                  _DzikirDisclaimerRow(settings: settings),
                ]),

              ],
            ),
          ),
        ],
      ),
    );
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
        onDone: () => Navigator.pop(ctx),
      ),
    );
  }

  // ── Generic picker bottom sheet ─────────────────────────────────────────────

  void _showPicker<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required T selected,
    required String Function(T) label,
    required void Function(T) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appSheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickerSheet<T>(
        title:    title,
        options:  options,
        selected: selected,
        label:    label,
        onSelect: (v) {
          onSelect(v);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showPreAdzanPicker(BuildContext context, SettingsProvider settings) {
    const options = [5, 10, 15, 20, 30];
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appSheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickerSheet<int>(
        title:    settings.getLabel('preAdzanMinutes'),
        options:  options,
        selected: settings.preAdzanMinutes,
        label:    (m) => settings.isEnglish
            ? '$m min before adhan'
            : '$m menit sebelum adzan',
        onSelect: (v) {
          context.read<SettingsProvider>().setPreAdzanMinutes(v);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showThemePicker(BuildContext context, SettingsProvider settings) {
    final options = [
      (ThemeMode.system, settings.getLabel('followSystem'), Icons.brightness_auto_rounded),
      (ThemeMode.light,  settings.getLabel('light'),        Icons.wb_sunny_rounded),
      (ThemeMode.dark,   settings.getLabel('dark'),         Icons.nights_stay_rounded),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appSheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _SheetWrapper(
        title: settings.getLabel('theme'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final opt in options)
              ListTile(
                leading: Icon(opt.$3, color: sheetCtx.appAccent, size: 20),
                title: Text(
                  opt.$2,
                  style: GoogleFonts.poppins(
                    color: sheetCtx.appTextPrimary,
                    fontSize: 14,
                  ),
                ),
                trailing: opt.$1 == settings.themeMode
                    ? Icon(Icons.check_rounded,
                        color: sheetCtx.appAccent, size: 20)
                    : null,
                onTap: () {
                  settings.setThemeMode(opt.$1);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Sheet helpers ─────────────────────────────────────────────────────────────

class _SheetWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  const _SheetWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: context.appSheetHandle,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: context.appTextPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
        // Prevent content from being hidden behind the system navigation bar
        // (3-button nav). viewPadding is the raw window inset — always correct
        // regardless of how SafeArea may have transformed MediaQuery.padding.
        SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
      ],
    );
  }
}

class _PickerSheet<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final T selected;
  final String Function(T) label;
  final void Function(T) onSelect;

  const _PickerSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.label,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetWrapper(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(
                label(option),
                style: GoogleFonts.poppins(
                  color: context.appTextPrimary,
                  fontSize: 14,
                ),
              ),
              trailing: option == selected
                  ? Icon(Icons.check_rounded,
                      color: context.appAccent, size: 20)
                  : null,
              onTap: () => onSelect(option),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Setting card layout helpers ───────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          color: context.appTextSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appDivider, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.appCardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Divider(
        height: 1, thickness: 0.5, color: context.appDivider,
      ),
    );
  }
}

// ── Row types ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: context.appTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: context.appTextSecondary,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionRow({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: context.appAccent, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: context.appAccent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: context.appTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: context.appAccent,
            activeTrackColor: context.appAccent.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _PickerRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: context.appTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: context.appTextSecondary,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.appTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dzikir reference disclaimer row ──────────────────────────────────────────

class _DzikirDisclaimerRow extends StatelessWidget {
  final SettingsProvider settings;
  const _DzikirDisclaimerRow({required this.settings});

  @override
  Widget build(BuildContext context) {
    final isEn = settings.isEnglish;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_outlined, size: 14, color: context.appAccent),
              const SizedBox(width: 6),
              Text(
                isEn ? 'Dzikir References' : 'Sumber Referensi',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.appTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isEn
                ? 'All dzikir and doa in this app are sourced from authentic hadith in the Kutub as-Sittah (Bukhari, Muslim, Abu Dawud, Tirmidzi, Nasai, Ibn Majah) and Hisnul Muslim. If you find an error, please report it to frosthoot.studio@gmail.com'
                : 'Seluruh dzikir dan doa dalam aplikasi ini bersumber dari hadits-hadits shahih yang termaktub dalam Kutub as-Sittah (Bukhari, Muslim, Abu Dawud, Tirmidzi, Nasa\'i, Ibnu Majah) serta kitab Hisnul Muslim. Jika menemukan kesalahan, mohon laporkan ke frosthoot.studio@gmail.com',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: context.appTextSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Per-prayer time correction card ──────────────────────────────────────────

class _PrayerOffsetCard extends StatelessWidget {
  final SettingsProvider settings;
  const _PrayerOffsetCard({required this.settings});

  static const _keys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

  @override
  Widget build(BuildContext context) {
    return _SettingCard(
      children: [
        for (int i = 0; i < _keys.length; i++) ...[
          if (i > 0) const _CardDivider(),
          _PrayerOffsetRow(prayerKey: _keys[i], settings: settings),
        ],
      ],
    );
  }
}

class _PrayerOffsetRow extends StatelessWidget {
  final String prayerKey;
  final SettingsProvider settings;
  const _PrayerOffsetRow({required this.prayerKey, required this.settings});

  static String _fmt(int v, bool isEn) {
    if (v == 0) return isEn ? '0 min' : '0 mnt';
    final sign = v > 0 ? '+' : '';
    return '$sign$v m';
  }

  @override
  Widget build(BuildContext context) {
    const gold   = Color(0xFFD4A057);
    final offset = settings.prayerTimeOffsets[prayerKey] ?? 0;
    final name   = settings.getPrayerName(prayerKey);
    final isEn   = settings.isEnglish;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                color: context.appTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _OffsetButton(
            icon: Icons.remove,
            onTap: offset > -10
                ? () => context.read<SettingsProvider>().setPrayerOffset(prayerKey, offset - 1)
                : null,
          ),
          SizedBox(
            width: 54,
            child: Text(
              _fmt(offset, isEn),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: offset != 0 ? gold : context.appTextSecondary,
                fontSize: 13,
                fontWeight: offset != 0 ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          _OffsetButton(
            icon: Icons.add,
            onTap: offset < 10
                ? () => context.read<SettingsProvider>().setPrayerOffset(prayerKey, offset + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _OffsetButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _OffsetButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap != null
              ? context.appAccent.withValues(alpha: 0.12)
              : context.appDivider,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? context.appAccent : context.appTextFaded,
        ),
      ),
    );
  }
}

// ── Adzan audio card ──────────────────────────────────────────────────────────

class _AdzanCard extends StatefulWidget {
  final SettingsProvider settings;
  const _AdzanCard({required this.settings});

  @override
  State<_AdzanCard> createState() => _AdzanCardState();
}

class _AdzanCardState extends State<_AdzanCard> {
  final _player = AudioPlayer();
  bool  _previewing = false;

  SettingsProvider get s => widget.settings;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _preview() async {
    if (!s.adzanSound.hasAudio) return;
    if (_previewing) {
      await _player.stop();
      setState(() => _previewing = false);
      return;
    }
    setState(() => _previewing = true);
    try {
      await _player.setVolume(s.adzanVolume);
      await _player.play(AssetSource(s.adzanSound.assetPath!));
      _player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _previewing = false);
      });
    } catch (_) {
      if (mounted) setState(() => _previewing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4A057);

    return _SettingCard(children: [
      _PickerRow(
        label: s.getLabel('adzanSound'),
        value: s.adzanSound.displayName,
        onTap: () => showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _PickerSheet<AdzanSound>(
            title:    s.getLabel('adzanSound'),
            options:  AdzanSound.values,
            selected: s.adzanSound,
            label:    (v) => v.displayName,
            onSelect: (v) => context.read<SettingsProvider>().setAdzanSound(v),
          ),
        ),
      ),
      const _CardDivider(),
      _PickerRow(
        label: s.getLabel('adzanSoundFajr'),
        value: s.adzanSoundFajr.displayName,
        onTap: () => showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _PickerSheet<AdzanSound>(
            title:    s.getLabel('adzanSoundFajr'),
            options:  AdzanSound.values,
            selected: s.adzanSoundFajr,
            label:    (v) => v.displayName,
            onSelect: (v) => context.read<SettingsProvider>().setAdzanSoundFajr(v),
          ),
        ),
      ),
      const _CardDivider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.getLabel('adzanVolume'),
                      style: const TextStyle(fontSize: 14)),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: gold,
                      thumbColor: gold,
                      overlayColor: gold.withValues(alpha: 0.15),
                      inactiveTrackColor: gold.withValues(alpha: 0.2),
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: s.adzanVolume,
                      min: 0, max: 1, divisions: 10,
                      onChanged: (v) =>
                          context.read<SettingsProvider>().setAdzanVolume(v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (s.adzanSound.hasAudio)
              TextButton.icon(
                onPressed: _preview,
                icon: Icon(
                  _previewing
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline_rounded,
                  size: 18,
                  color: gold,
                ),
                label: Text(
                  s.getLabel('previewAdzan'),
                  style: const TextStyle(color: gold, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    ]);
  }
}

// ── Manufacturer-specific optimization guidance card ──────────────────────────

class _ManufacturerOptCard extends StatelessWidget {
  final SettingsProvider  settings;
  final DeviceManufacturer manufacturer;
  final VoidCallback?     onFixTap;
  const _ManufacturerOptCard({
    required this.settings,
    required this.manufacturer,
    this.onFixTap,
  });

  List<String> _stepKeys() => switch (manufacturer) {
    DeviceManufacturer.xiaomi   => ['miuiInfo',    'miuiStep1',    'miuiStep2',    'miuiStep3',    'miuiStep4'],
    DeviceManufacturer.samsung  => ['samsungInfo', 'samsungStep1', 'samsungStep2', 'samsungStep3'],
    DeviceManufacturer.oppo     => ['oppoInfo',    'oppoStep1',    'oppoStep2',    'oppoStep3'],
    DeviceManufacturer.vivo     => ['vivoInfo',    'vivoStep1',    'vivoStep2',    'vivoStep3'],
    DeviceManufacturer.huawei   => ['huaweiInfo',  'huaweiStep1',  'huaweiStep2',  'huaweiStep3'],
    DeviceManufacturer.realme   => ['realmeInfo',  'realmeStep1',  'realmeStep2',  'realmeStep3'],
    DeviceManufacturer.stock    => ['genericOptInfo', 'genericOptStep1', 'genericOptStep2'],
  };

  @override
  Widget build(BuildContext context) {
    final keys = _stepKeys();
    return _SettingCard(children: [
      if (onFixTap != null) ...[
        _ActionRow(
          label: settings.getLabel('fixAuto'),
          icon:  Icons.auto_fix_high_rounded,
          onTap: onFixTap!,
        ),
        const _CardDivider(),
      ],
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First key is the info/description paragraph
            Text(
              settings.getLabel(keys.first),
              style: GoogleFonts.poppins(
                color: context.appTextSecondary,
                fontSize: 12.5,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 10),
            // Remaining keys are numbered steps
            for (final key in keys.skip(1))
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  settings.getLabel(key),
                  style: GoogleFonts.poppins(
                    color: context.appTextPrimary,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
      const _CardDivider(),
      _ActionRow(
        label: settings.getLabel('openBatterySettings'),
        icon:  Icons.battery_saver_rounded,
        onTap: PermissionService.openBatterySettings,
      ),
    ]);
  }
}

// ── Arabic display card ───────────────────────────────────────────────────────

class _ArabicDisplayCard extends StatelessWidget {
  final SettingsProvider settings;
  const _ArabicDisplayCard({required this.settings});

  static const _gold = Color(0xFFD4A057);

  @override
  Widget build(BuildContext context) {
    final fontName = ArabicFontHelper.displayName(settings.arabicFont);
    return _SettingCard(children: [
      _PickerRow(
        label: settings.getLabel('arabicFont'),
        value: fontName,
        onTap: () => _showFontPicker(context),
      ),
      const _CardDivider(),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    settings.getLabel('arabicFontSize'),
                    style: GoogleFonts.poppins(
                      color: context.appTextPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${settings.arabicFontSize.toInt()}',
                  style: GoogleFonts.poppins(
                    color: _gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _gold,
                thumbColor: _gold,
                overlayColor: _gold.withValues(alpha: 0.15),
                inactiveTrackColor: _gold.withValues(alpha: 0.2),
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                value: settings.arabicFontSize,
                min: 16, max: 40, divisions: 12,
                onChanged: (v) =>
                    context.read<SettingsProvider>().setArabicFontSize(v),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  void _showFontPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appSheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ArabicFontPickerSheet(settings: settings),
    );
  }
}

class _ArabicFontPickerSheet extends StatelessWidget {
  final SettingsProvider settings;
  const _ArabicFontPickerSheet({required this.settings});

  @override
  Widget build(BuildContext context) {
    return _SheetWrapper(
      title: settings.getLabel('arabicFont'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final font in ArabicFontHelper.availableFonts)
              _FontOptionCard(
                font: font,
                isSelected: settings.arabicFont == font['key'],
                isEn: settings.isEnglish,
                onTap: () {
                  context.read<SettingsProvider>().setArabicFont(font['key']!);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _FontOptionCard extends StatelessWidget {
  final Map<String, String> font;
  final bool isSelected;
  final bool isEn;
  final VoidCallback onTap;
  const _FontOptionCard({
    required this.font,
    required this.isSelected,
    required this.isEn,
    required this.onTap,
  });

  static const _gold = Color(0xFFD4A057);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.appCardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _gold : context.appDivider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + style badge + check
              Row(
                children: [
                  Text(
                    font['name']!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.appTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      font['style']!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: _gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded,
                        color: _gold, size: 20),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                isEn ? font['descEn']! : font['descId']!,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: context.appTextSecondary,
                ),
              ),
              const SizedBox(height: 10),
              // Arabic preview
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                  textDirection: TextDirection.rtl,
                  style: ArabicFontHelper.getStyle(
                    font['key']!,
                    fontSize: 22,
                    color: context.appTextPrimary,
                    height: 1.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
