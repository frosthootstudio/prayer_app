import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../services/permission_service.dart';
import '../utils/app_theme.dart';

// ── Warning banner shown on the home screen ───────────────────────────────────

class NotifWarningBanner extends StatelessWidget {
  final VoidCallback onTap;
  const NotifWarningBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.orange.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.read<SettingsProvider>().getLabel('notifWarning'),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.orange,
                  height: 1.3,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.orange,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Permission fix bottom sheet ───────────────────────────────────────────────

class PermissionFixSheet extends StatefulWidget {
  final bool isXiaomi;
  final VoidCallback onDone;

  const PermissionFixSheet({
    super.key,
    required this.isXiaomi,
    required this.onDone,
  });

  @override
  State<PermissionFixSheet> createState() => _PermissionFixSheetState();
}

class _PermissionFixSheetState extends State<PermissionFixSheet> {
  bool _notifGranted      = false;
  bool _batteryGranted    = false;
  bool _exactAlarmGranted = false;

  @override
  void initState() {
    super.initState();
    _checkAll();
  }

  Future<void> _checkAll() async {
    final n = await PermissionService.hasNotification();
    final b = await PermissionService.hasBatteryOptimization();
    final e = await PermissionService.hasExactAlarm();
    if (mounted) {
      setState(() {
        _notifGranted      = n;
        _batteryGranted    = b;
        _exactAlarmGranted = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final isEn     = settings.isEnglish;
    const orange   = Color(0xFFD4A057);
    final safe     = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, safe + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.appDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            isEn ? 'Fix Prayer Notifications 🔔' : 'Perbaiki Notifikasi Adzan 🔔',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.appTextPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Row 1 – Notification permission
          _PermissionRow(
            label:    settings.getLabel('permNotif'),
            granted:  _notifGranted,
            fixLabel: isEn ? 'Enable' : 'Aktifkan',
            onFix: () async {
              await PermissionService.requestNotification();
              await _checkAll();
            },
          ),
          const SizedBox(height: 12),

          // Row 2 – Battery unrestricted
          _PermissionRow(
            label:    settings.getLabel('permBattery'),
            granted:  _batteryGranted,
            fixLabel: isEn ? 'Allow' : 'Izinkan',
            onFix: () async {
              await PermissionService.requestBatteryOptimization();
              await _checkAll();
            },
          ),
          const SizedBox(height: 12),

          // Row 3 – Exact alarm (Android 12+)
          _PermissionRow(
            label:    settings.getLabel('permExactAlarm'),
            granted:  _exactAlarmGranted,
            fixLabel: isEn ? 'Allow' : 'Izinkan',
            onFix: () async {
              await PermissionService.openExactAlarmSettings();
              await _checkAll();
            },
          ),

          // Row 4 – Autostart manager (Xiaomi only) — opens MIUI autostart page
          if (widget.isXiaomi) ...[
            const SizedBox(height: 12),
            _AutostartRow(
              isEn: isEn,
              onOpen: PermissionService.openAutostartSettings,
            ),
            const SizedBox(height: 12),
            // Row 5 – MIUI manual step (cannot be automated)
            _MiuiLockRow(isEn: isEn),
          ],

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _checkAll,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.appTextSecondary,
                    side: BorderSide(color: context.appDivider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text(
                    settings.getLabel('recheckAll'),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text(
                    isEn ? 'Done' : 'Selesai',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Single permission status row ──────────────────────────────────────────────

class _PermissionRow extends StatelessWidget {
  final String       label;
  final bool         granted;
  final String       fixLabel;
  final VoidCallback onFix;

  const _PermissionRow({
    required this.label,
    required this.granted,
    required this.fixLabel,
    required this.onFix,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFD4A057);
    const green  = Color(0xFF22C55E);

    return Row(
      children: [
        Icon(
          granted ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: granted ? green : Colors.red.shade300,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: context.appTextPrimary,
            ),
          ),
        ),
        if (!granted)
          TextButton(
            onPressed: onFix,
            style: TextButton.styleFrom(
              foregroundColor: orange,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              fixLabel,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              context.read<SettingsProvider>().getLabel('permActive'),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ── MIUI autostart action row (opens the autostart manager) ──────────────────

class _AutostartRow extends StatelessWidget {
  final bool isEn;
  final Future<void> Function() onOpen;
  const _AutostartRow({required this.isEn, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFD4A057);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.rocket_launch_outlined, color: orange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Autostart (MIUI)' : 'Autostart (MIUI)',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.appTextPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isEn
                      ? 'Allow the app to start automatically so adzan reminders keep firing.'
                      : 'Izinkan app berjalan otomatis agar pengingat adzan tetap muncul.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: context.appTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onOpen,
            style: TextButton.styleFrom(
              foregroundColor: orange,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              isEn ? 'Open' : 'Buka',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── MIUI "pin in recent apps" manual instruction row ─────────────────────────

class _MiuiLockRow extends StatelessWidget {
  final bool isEn;
  const _MiuiLockRow({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline_rounded, color: Colors.orange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Pin in Recent Apps (MIUI)' : 'Kunci di Recent Apps',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.appTextPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isEn
                      ? 'Open recent apps → hold the app → tap the 🔒 lock icon'
                      : 'Buka recent apps → tahan app → tap ikon 🔒',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: context.appTextSecondary,
                    height: 1.4,
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
