import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../utils/app_theme.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  // Location page state
  bool   _locLoading   = false;
  bool   _locRequested = false;
  bool   _locGranted   = false;
  String _cityName     = '';

  // Notification page state
  bool   _notifLoading   = false;
  bool   _notifRequested = false;
  bool   _notifGranted   = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Permission requests ───────────────────────────────────────────────────

  Future<void> _requestLocation() async {
    if (_locLoading) return;
    setState(() => _locLoading = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      final granted = perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse;
      String city = '';
      if (granted) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
            ),
          ).timeout(const Duration(seconds: 15));
          final marks = await placemarkFromCoordinates(
            pos.latitude, pos.longitude,
          );
          city = marks.first.locality ??
              marks.first.subAdministrativeArea ??
              marks.first.administrativeArea ?? '';
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _locRequested = true;
          _locGranted   = granted;
          _cityName     = city;
          _locLoading   = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _locLoading = false);
    }
  }

  Future<void> _requestNotif() async {
    if (_notifLoading) return;
    setState(() => _notifLoading = true);
    try {
      bool allowed = await AwesomeNotifications().isNotificationAllowed();
      if (!allowed) {
        allowed = await AwesomeNotifications()
            .requestPermissionToSendNotifications();
      }
      if (mounted) {
        setState(() {
          _notifRequested = true;
          _notifGranted   = allowed;
          _notifLoading   = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _notifLoading = false);
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _next() {
    if (_page < 2) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await Hive.box('settings').put('onboarding_done', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLast    = _page == 2;
    final safeTop   = MediaQuery.of(context).padding.top;
    final safeBot   = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Page content ─────────────────────────────────────────────────
          PageView(
            controller: _ctrl,
            onPageChanged: (p) => setState(() => _page = p),
            children: [
              _WelcomePage(topPad: safeTop + 56, botPad: safeBot + 140),
              _LocationPage(
                topPad:    safeTop + 56,
                botPad:    safeBot + 140,
                loading:   _locLoading,
                requested: _locRequested,
                granted:   _locGranted,
                cityName:  _cityName,
                onRequest: _requestLocation,
              ),
              _NotifPage(
                topPad:    safeTop + 56,
                botPad:    safeBot + 140,
                loading:   _notifLoading,
                requested: _notifRequested,
                granted:   _notifGranted,
                onRequest: _requestNotif,
              ),
            ],
          ),

          // ── Skip button (top-right) ───────────────────────────────────────
          Positioned(
            top: safeTop + 8,
            right: 16,
            child: AnimatedOpacity(
              opacity: isLast ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: TextButton(
                onPressed: isLast ? null : _finish,
                child: Text(
                  'Lewati',
                  style: GoogleFonts.poppins(
                    color: context.appTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom: indicator + buttons ──────────────────────────────────
          Positioned(
            bottom: 0,
            left:   0,
            right:  0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, safeBot + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmoothPageIndicator(
                    controller:    _ctrl,
                    count:         3,
                    effect: ExpandingDotsEffect(
                      dotColor:       context.appDivider,
                      activeDotColor: context.appAccent,
                      dotHeight:      8,
                      dotWidth:       8,
                      expansionFactor: 3,
                      spacing:        6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      // Back button — invisible on first page (keeps layout stable)
                      AnimatedOpacity(
                        opacity:  _page > 0 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _page > 0
                                ? () => _ctrl.previousPage(
                                      duration: const Duration(milliseconds: 350),
                                      curve: Curves.easeInOut,
                                    )
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.appTextSecondary,
                              side: BorderSide(color: context.appDivider),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Kembali',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Next / Mulai button
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.appAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLast ? 'Mulai' : 'Lanjut',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                isLast
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page scaffold (shared layout) ─────────────────────────────────────────────

class _PageScaffold extends StatelessWidget {
  final double  topPad;
  final double  botPad;
  final Widget  illustration;
  final String  title;
  final String  subtitle;
  final Widget? extra; // optional action widget below subtitle

  const _PageScaffold({
    required this.topPad,
    required this.botPad,
    required this.illustration,
    required this.title,
    required this.subtitle,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPad, bottom: botPad),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Center(child: illustration),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: context.appTextPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: context.appTextSecondary,
                    height: 1.65,
                  ),
                ),
                if (extra != null) ...[
                  const SizedBox(height: 28),
                  extra!,
                ],
              ],
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

// ── Illustration bubble ───────────────────────────────────────────────────────

class _IllustrationBubble extends StatelessWidget {
  final IconData icon;
  final Color    color;

  const _IllustrationBubble({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer decorative ring
          Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              color:  color.withValues(alpha: 0.06),
              shape:  BoxShape.circle,
            ),
          ),
          // Middle ring
          Container(
            width: 188, height: 188,
            decoration: BoxDecoration(
              color:  color.withValues(alpha: 0.10),
              shape:  BoxShape.circle,
            ),
          ),
          // Inner filled circle with icon
          Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              color:  context.appCardBg,
              shape:  BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:       color.withValues(alpha: 0.22),
                  blurRadius:  24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(icon, size: 62, color: color),
          ),
          // Small accent dot (top-right of inner circle)
          Positioned(
            top:   40,
            right: 46,
            child: Container(
              width:  15, height: 15,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Permission button widget ──────────────────────────────────────────────────

/// Three visual states: initial button → loading → granted / denied.
class _PermissionTile extends StatelessWidget {
  final bool       loading;
  final bool       requested;
  final bool       granted;
  final String     label;
  final String     grantedLabel;
  final String     deniedLabel;
  final VoidCallback onPressed;
  final Color      color;

  const _PermissionTile({
    required this.loading,
    required this.requested,
    required this.granted,
    required this.label,
    required this.grantedLabel,
    required this.deniedLabel,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (loading) {
      return SizedBox(
        height: 48,
        child: Center(
          child: SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: color,
            ),
          ),
        ),
      );
    }

    // Granted state
    if (requested && granted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color:        color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Row(
          mainAxisSize:       MainAxisSize.min,
          mainAxisAlignment:  MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 18, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                grantedLabel,
                style: GoogleFonts.poppins(
                  color:      color,
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Denied state
    if (requested && !granted) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded, size: 14, color: context.appTextFaded),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                deniedLabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color:    context.appTextFaded,
                  fontSize: 12,
                  height:   1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default: request button
    return SizedBox(
      width:  double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation:       0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize:   14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Page 1: Welcome ───────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final double topPad;
  final double botPad;
  const _WelcomePage({required this.topPad, required this.botPad});

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      topPad: topPad,
      botPad: botPad,
      illustration: _IllustrationBubble(
        icon:  Icons.mosque_rounded,
        color: context.appAccent,
      ),
      title:    "Assalamu'alaikum 👋",
      subtitle: 'Selamat datang di Waktu Shalat\nAplikasi jadwal shalat & ibadah harianmu',
    );
  }
}

// ── Page 2: Location ──────────────────────────────────────────────────────────

class _LocationPage extends StatelessWidget {
  final double     topPad;
  final double     botPad;
  final bool       loading;
  final bool       requested;
  final bool       granted;
  final String     cityName;
  final VoidCallback onRequest;

  const _LocationPage({
    required this.topPad,
    required this.botPad,
    required this.loading,
    required this.requested,
    required this.granted,
    required this.cityName,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      topPad: topPad,
      botPad: botPad,
      illustration: const _IllustrationBubble(
        icon:  Icons.location_on_rounded,
        color: Color(0xFF10B981),
      ),
      title:    'Izinkan Akses Lokasi',
      subtitle: 'Kami membutuhkan lokasi kamu untuk menghitung waktu shalat yang akurat sesuai kotamu',
      extra: _PermissionTile(
        loading:      loading,
        requested:    requested,
        granted:      granted,
        label:        'Izinkan Lokasi',
        grantedLabel: cityName.isNotEmpty ? '✓  $cityName' : '✓  Lokasi terdeteksi',
        deniedLabel:  'Akses ditolak — bisa diubah di Pengaturan HP',
        onPressed:    onRequest,
        color:        const Color(0xFF10B981),
      ),
    );
  }
}

// ── Page 3: Notifications ─────────────────────────────────────────────────────

class _NotifPage extends StatelessWidget {
  final double     topPad;
  final double     botPad;
  final bool       loading;
  final bool       requested;
  final bool       granted;
  final VoidCallback onRequest;

  const _NotifPage({
    required this.topPad,
    required this.botPad,
    required this.loading,
    required this.requested,
    required this.granted,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      topPad: topPad,
      botPad: botPad,
      illustration: const _IllustrationBubble(
        icon:  Icons.notifications_rounded,
        color: Color(0xFF6366F1),
      ),
      title:    'Aktifkan Pengingat Adzan',
      subtitle: 'Dapatkan notifikasi tepat waktu untuk setiap waktu shalat agar tidak terlewat',
      extra: _PermissionTile(
        loading:      loading,
        requested:    requested,
        granted:      granted,
        label:        'Aktifkan Notifikasi',
        grantedLabel: '✓  Notifikasi diaktifkan',
        deniedLabel:  'Bisa diaktifkan nanti di Pengaturan',
        onPressed:    onRequest,
        color:        const Color(0xFF6366F1),
      ),
    );
  }
}
