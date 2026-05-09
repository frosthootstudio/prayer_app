import 'dart:async';
import 'dart:math' show cos, pi, sin;

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';

// ── Sensor reliability tracking ─────────────────────────────────────────────
//
// Crashlytics shows recurring `Azimuth.<init>: Degrees must be finite but
// was 'NaN'` from flutter_compass_v2's native side on certain devices with
// miscalibrated magnetometers. The throw happens BEFORE Dart can intercept
// (it's a JVM-level exception), so onError handlers + isFinite filters
// can't fully prevent it.
//
// Defense-in-depth: persist a fail counter across sessions. Once a device
// has racked up N failures, mark Qibla as unavailable on that device so we
// stop re-subscribing the broken stream. User can reset via clearing app
// data — small UX cost, but protects the 18 affected users from repeat
// crashes (currently 76 events / 18 users in Crashlytics).

const String _kSensorBlockedKey   = 'qibla_sensor_blocked';
const String _kSensorFailCountKey = 'qibla_sensor_fail_count';
const int    _kMaxSensorFailures  = 3;

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  // null = still checking, false = unavailable, true = available
  bool? _sensorAvailable;
  bool  _locationReady = false;

  StreamSubscription<QiblahDirection>? _sub;

  // Cumulative angles in degrees to prevent wrap-around jumps
  double _compassAngle  = 0.0;
  double _needleAngle   = 0.0;
  double _offset        = 0.0; // absolute Qibla bearing from North (for display)

  double _prevDirection = 0.0;
  double _prevQiblah    = 0.0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  /// Reads the persisted block flag — true if previous sessions exceeded
  /// the failure threshold. Defaults false on any Hive error.
  bool get _isSensorBlocked {
    try {
      return Hive.box('settings')
              .get(_kSensorBlockedKey, defaultValue: false) as bool;
    } catch (_) {
      return false;
    }
  }

  /// Increments the persisted failure counter. Once threshold is hit, sets
  /// the block flag so subsequent screen opens skip subscribe entirely.
  void _recordSensorFailure() {
    try {
      final box = Hive.box('settings');
      final newCount =
          (box.get(_kSensorFailCountKey, defaultValue: 0) as int) + 1;
      box.put(_kSensorFailCountKey, newCount);
      if (newCount >= _kMaxSensorFailures) {
        box.put(_kSensorBlockedKey, true);
        debugPrint(
          '[Qibla] Sensor blocked after $newCount failures — '
          'will skip subscribe on next open',
        );
      }
      FirebaseCrashlytics.instance.setCustomKey('qibla_fail_count', newCount);
      FirebaseCrashlytics.instance.setCustomKey('qibla_blocked', newCount >= _kMaxSensorFailures);
    } catch (e) {
      debugPrint('[Qibla] Failed to persist sensor failure: $e');
    }
  }

  Future<void> _init() async {
    // Bail early if previous sessions exceeded failure threshold. User
    // sees the "sensor unavailable" UI with no risk of re-triggering the
    // native Azimuth NaN crash.
    if (_isSensorBlocked) {
      debugPrint('[Qibla] Sensor previously marked blocked — skipping init');
      if (!mounted) return;
      setState(() => _sensorAvailable = false);
      return;
    }

    // Wrap entire init in try/catch — flutter_qiblah's native methods can
    // throw on some devices (notably during sensor support check on devices
    // with no magnetometer). Without this wrap, the exception bubbles to
    // PlatformDispatcher and ends up as a fatal crash.
    try {
      // 1. Check sensor
      final supported = await FlutterQiblah.androidDeviceSensorSupport();
      if (!mounted) return;
      setState(() => _sensorAvailable = supported ?? false);
      if (_sensorAvailable == false) return;

      // 2. Check / request location permission
      var status = await FlutterQiblah.checkLocationStatus();
      if (!mounted) return;
      if (status.enabled && status.status == LocationPermission.denied) {
        await FlutterQiblah.requestPermissions();
        status = await FlutterQiblah.checkLocationStatus();
        if (!mounted) return;
      }

      final ready = status.enabled &&
          (status.status == LocationPermission.always ||
              status.status == LocationPermission.whileInUse);
      setState(() => _locationReady = ready);
      if (!ready) return;

      // 3. Subscribe to combined compass + location stream.
      //
      // onError handler increments persistent failure counter — if a device
      // racks up too many errors, future sessions skip subscribe entirely.
      // cancelOnError:false keeps the stream alive after a bad sample so we
      // recover on the next valid reading (some devices recalibrate).
      _sub = FlutterQiblah.qiblahStream.listen(
        _onQiblah,
        onError: (Object error, StackTrace stack) {
          debugPrint('[Qibla] Sensor stream error: $error');
          FirebaseCrashlytics.instance.recordError(error, stack, reason: 'qibla_stream_error', fatal: false);
          _recordSensorFailure();
        },
        cancelOnError: false,
      );
    } catch (e, stack) {
      debugPrint('[Qibla] _init failed: $e\n$stack');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'qibla_init_failed', fatal: false);
      _recordSensorFailure();
      if (!mounted) return;
      setState(() => _sensorAvailable = false);
    }
  }

  void _onQiblah(QiblahDirection q) {
    // Defensive: skip samples where any value is NaN/Infinity. Some
    // devices briefly emit invalid sensor data during calibration; the
    // stream's onError handler catches the package-thrown variant, but
    // this guards the silent NaN-in-double case that would otherwise
    // poison _compassAngle / _needleAngle and break rotation.
    if (!q.direction.isFinite || !q.qiblah.isFinite || !q.offset.isFinite) {
      return;
    }

    // Shortest-path delta to avoid 359° → 0° jumps
    double dDir = q.direction - _prevDirection;
    if (dDir >  180) dDir -= 360;
    if (dDir < -180) dDir += 360;
    _compassAngle += dDir;
    _prevDirection = q.direction;

    double dQ = q.qiblah - _prevQiblah;
    if (dQ >  180) dQ -= 360;
    if (dQ < -180) dQ += 360;
    _needleAngle += dQ;
    _prevQiblah = q.qiblah;

    setState(() => _offset = q.offset);
  }

  @override
  void dispose() {
    _sub?.cancel();
    FlutterQiblah().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (_sensorAvailable == null) {
      return Center(
        child: CircularProgressIndicator(color: context.appAccent),
      );
    }

    if (_sensorAvailable == false) {
      return _InfoCard(
        icon: Icons.sensors_off_outlined,
        message: settings.getLabel('sensorUnavailable'),
      );
    }

    if (!_locationReady) {
      return _InfoCard(
        icon: Icons.location_off_outlined,
        message: settings.getLabel('noLocationQibla'),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            settings.getLabel('qibla'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: context.appAccent,
            ),
          ),
          Expanded(
            child: Center(
              child: _CompassWidget(
                compassAngle: _compassAngle,
                needleAngle: _needleAngle,
                accentColor: context.appAccent,
                isEn: settings.isEnglish,
              ),
            ),
          ),
          Text(
            '${_offset.toStringAsFixed(1)}°  ${_cardinalLabel(_offset, settings.isEnglish)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: context.appTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
            child: Text(
              settings.getLabel('metalWarning'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: context.appTextFaded,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _cardinalLabel(double deg, bool isEn) {
    const en = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    const id = ['U', 'TL', 'T', 'TG', 'S', 'BD', 'B', 'BL'];
    final idx = ((deg + 22.5) / 45).floor() % 8;
    return (isEn ? en : id)[idx];
  }
}

// ── Compass widget (rose + needle) ──────────────────────────────────────────

class _CompassWidget extends StatelessWidget {
  final double compassAngle;
  final double needleAngle;
  final Color  accentColor;
  final bool   isEn;

  const _CompassWidget({
    required this.compassAngle,
    required this.needleAngle,
    required this.accentColor,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    const size = 280.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating compass rose
          AnimatedRotation(
            turns: -compassAngle / 360,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: CustomPaint(
              size: const Size(size, size),
              painter: _RosePainter(isEn: isEn),
            ),
          ),
          // Qibla needle (points toward Mecca)
          AnimatedRotation(
            turns: -needleAngle / 360,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: CustomPaint(
              size: const Size(size, size),
              painter: _NeedlePainter(color: accentColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rose painter ─────────────────────────────────────────────────────────────

class _RosePainter extends CustomPainter {
  final bool isEn;
  const _RosePainter({required this.isEn});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Outer ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x44888888),
    );

    // Inner hub ring
    canvas.drawCircle(
      center,
      radius * 0.10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x44888888),
    );

    // Tick marks (72 × 5° = 360°)
    final tickPaint = Paint()..strokeCap = StrokeCap.round;
    for (int i = 0; i < 72; i++) {
      final angleRad = i * 5.0 * pi / 180 - pi / 2;
      final isCardinal = i % 18 == 0; // 0°, 90°, 180°, 270°
      final isMedium   = i % 6  == 0; // every 30°
      final tickLen    = isCardinal ? 18.0 : (isMedium ? 10.0 : 5.0);
      final sw         = isCardinal ? 2.0  : 1.0;
      final opacity    = isCardinal ? 0.70 : (isMedium ? 0.40 : 0.22);

      tickPaint
        ..color = Color.fromRGBO(136, 136, 136, opacity)
        ..strokeWidth = sw;

      canvas.drawLine(
        Offset(center.dx + (radius - tickLen) * cos(angleRad),
               center.dy + (radius - tickLen) * sin(angleRad)),
        Offset(center.dx + radius * cos(angleRad),
               center.dy + radius * sin(angleRad)),
        tickPaint,
      );
    }

    // Cardinal labels: N/E/S/W (or U/T/S/B in Indonesian)
    final cardinals  = isEn
        ? [('N', true), ('E', false), ('S', false), ('W', false)]
        : [('U', true), ('T', false), ('S', false), ('B', false)];
    final labelAngles = [0.0, pi / 2, pi, 3 * pi / 2];
    final labelR      = radius - 28.0;

    for (int i = 0; i < 4; i++) {
      final angle        = labelAngles[i];
      final (label, isN) = cardinals[i];
      final pos = Offset(
        center.dx + labelR * sin(angle),
        center.dy - labelR * cos(angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: isN ? Colors.red.shade400 : const Color(0xFF888888),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_RosePainter old) => old.isEn != isEn;
}

// ── Needle painter ───────────────────────────────────────────────────────────

class _NeedlePainter extends CustomPainter {
  final Color color;
  const _NeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx  = size.width  / 2;
    final cy  = size.height / 2;
    final tip = size.height * 0.08;   // arrow tip (near top)
    final toe = cy + size.height * 0.28; // arrow tail (below center)

    // Drop shadow
    canvas.drawPath(
      _arrowPath(cx, cy, tip, toe),
      Paint()
        ..color      = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Filled arrow
    canvas.drawPath(
      _arrowPath(cx, cy, tip, toe),
      Paint()..color = color,
    );

    // Small Kaaba diamond at the tip
    canvas.save();
    canvas.translate(cx, tip + 4);
    canvas.rotate(pi / 4);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 9, height: 9),
      Paint()..color = color,
    );
    canvas.restore();

    // Center hub
    canvas.drawCircle(Offset(cx, cy), 8,
        Paint()..color = color);
    canvas.drawCircle(Offset(cx, cy), 4,
        Paint()..color = Colors.white.withValues(alpha: 0.55));
  }

  Path _arrowPath(double cx, double cy, double tip, double toe) => Path()
    ..moveTo(cx,     tip + 16) // just below the diamond
    ..lineTo(cx - 7, cy - 12)
    ..lineTo(cx - 3, toe)
    ..lineTo(cx + 3, toe)
    ..lineTo(cx + 7, cy - 12)
    ..close();

  @override
  bool shouldRepaint(_NeedlePainter old) => old.color != color;
}

// ── Info card (sensor/location errors) ───────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String   message;

  const _InfoCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: context.appTextFaded),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: context.appTextPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
