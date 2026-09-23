import 'dart:async';
import 'dart:math' show cos, pi, sin;

import 'package:adhan/adhan.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';

// ── Sensor reliability tracking ─────────────────────────────────────────────
//
// Defense-in-depth: persist a fail counter across sessions. Once a device
// has racked up N failures, mark Qibla as unavailable on that device so we
// stop re-subscribing a broken stream. User can reset via the "Coba Lagi"
// button after recalibrating with a figure-8 motion.
//
// With the decoupled architecture (pure Dart adhan math + flutter_compass),
// NaN/uncalibrated sensor readings are intercepted safely on the Dart side
// before any calculation, preventing native crashes entirely.

const String _kSensorBlockedKey = 'qibla_sensor_blocked';
const String _kSensorFailCountKey = 'qibla_sensor_fail_count';
const int _kMaxSensorFailures = 3;

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  // null = still checking, false = unavailable, true = available
  bool? _sensorAvailable;
  bool _locationReady = false;

  // Tracks whether `_sensorAvailable == false` was reached via the
  // persistent block flag (true = recoverable, show reset button) vs
  // via genuine hardware unsupported (false = no point retrying).
  bool _wasBlocked = false;

  StreamSubscription<CompassEvent>? _sub;

  // Cumulative angles in degrees to prevent wrap-around jumps
  double _compassAngle = 0.0;
  double _needleAngle = 0.0;
  double _offset = 0.0; // absolute Qibla bearing from North (for display)

  double _prevDirection = 0.0;
  double _prevQiblah = 0.0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  /// Reads the persisted block flag — true if previous sessions exceeded
  /// the failure threshold. Defaults false on any Hive error.
  bool get _isSensorBlocked {
    try {
      return Hive.box('settings').get(_kSensorBlockedKey, defaultValue: false)
          as bool;
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
      FirebaseCrashlytics.instance.setCustomKey(
        'qibla_blocked',
        newCount >= _kMaxSensorFailures,
      );
    } catch (e) {
      debugPrint('[Qibla] Failed to persist sensor failure: $e');
    }
  }

  Future<void> _init() async {
    // Bail early if previous sessions exceeded failure threshold. User
    // sees the "sensor unavailable" UI with no risk of re-triggering issues.
    if (_isSensorBlocked) {
      debugPrint('[Qibla] Sensor previously marked blocked — skipping init');
      if (!mounted) return;
      setState(() {
        _sensorAvailable = false;
        _wasBlocked = true;
      });
      return;
    }

    try {
      // 1. Check hardware compass sensor
      final compassEvents = FlutterCompass.events;
      if (compassEvents == null) {
        if (!mounted) return;
        setState(() => _sensorAvailable = false);
        return;
      }
      if (!mounted) return;
      setState(() => _sensorAvailable = true);

      // 2. Check / request location permission
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationReady = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final ready =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!ready) {
        if (!mounted) return;
        setState(() {
          _locationReady = false;
        });
        return;
      }

      // 3. Obtain coordinates (live GPS with fallback to cached prayer coords)
      double? lat;
      double? lng;

      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (_) {
        try {
          final lastPos = await Geolocator.getLastKnownPosition();
          if (lastPos != null) {
            lat = lastPos.latitude;
            lng = lastPos.longitude;
          }
        } catch (_) {}
      }

      if (lat == null || lng == null) {
        try {
          final prayerBox = Hive.box('prayer');
          final dynamic cLat = prayerBox.get('lastLat');
          final dynamic cLng = prayerBox.get('lastLng');
          if (cLat is num && cLng is num) {
            lat = cLat.toDouble();
            lng = cLng.toDouble();
          }
        } catch (_) {}
      }

      if (lat == null || lng == null) {
        if (!mounted) return;
        setState(() {
          _locationReady = false;
        });
        return;
      }

      // 4. Pure Dart Kaaba bearing calculation (via adhan)
      final qiblaBearing = Qibla(Coordinates(lat, lng)).direction;

      if (!mounted) return;
      setState(() {
        _locationReady = true;
        _offset = qiblaBearing;
      });

      // 5. Subscribe to compass events with safety guards
      _sub = compassEvents.listen(
        (CompassEvent event) {
          final heading = event.heading;
          // Guard against null, NaN, or infinite sensor readings safely in Dart
          if (heading == null || !heading.isFinite) return;

          // Normalized heading 0..360 (0 = North, 90 = East, 180 = South, 270 = West)
          final dir = (heading % 360 + 360) % 360;

          // Relative Qibla angle from device heading
          final qiblah = (dir + (360 - qiblaBearing)) % 360;

          _onQiblaUpdate(dir, qiblah, qiblaBearing);
        },
        onError: (Object error, StackTrace stack) {
          debugPrint('[Qibla] Sensor stream error: $error');
          FirebaseCrashlytics.instance.recordError(
            error,
            stack,
            reason: 'qibla_stream_error',
            fatal: false,
          );
          _recordSensorFailure();
        },
        cancelOnError: false,
      );
    } catch (e, stack) {
      debugPrint('[Qibla] _init failed: $e\n$stack');
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'qibla_init_failed',
        fatal: false,
      );
      _recordSensorFailure();
      if (!mounted) return;
      setState(() => _sensorAvailable = false);
    }
  }

  /// Clears the persistent block flags and re-runs sensor init. Wired to
  /// the "Coba Lagi" button shown when _wasBlocked is true.
  Future<void> _resetSensor() async {
    try {
      final box = Hive.box('settings');
      await box.put(_kSensorBlockedKey, false);
      await box.put(_kSensorFailCountKey, 0);
      debugPrint('[Qibla] Sensor reset by user — re-running init');
    } catch (e) {
      debugPrint('[Qibla] Sensor reset failed: $e');
    }
    await _sub?.cancel();
    _sub = null;
    if (!mounted) return;
    setState(() {
      _sensorAvailable = null;
      _wasBlocked = false;
      _locationReady = false;
    });
    await _init();
  }

  void _onQiblaUpdate(double dir, double qiblah, double offset) {
    if (!dir.isFinite || !qiblah.isFinite || !offset.isFinite) return;

    // Shortest-path delta to avoid 359° → 0° jumps
    double dDir = dir - _prevDirection;
    if (dDir > 180) dDir -= 360;
    if (dDir < -180) dDir += 360;
    _compassAngle += dDir;
    _prevDirection = dir;

    double dQ = qiblah - _prevQiblah;
    if (dQ > 180) dQ -= 360;
    if (dQ < -180) dQ += 360;
    _needleAngle += dQ;
    _prevQiblah = qiblah;

    setState(() => _offset = offset);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (_sensorAvailable == null) {
      return Center(child: CircularProgressIndicator(color: context.appAccent));
    }

    if (_sensorAvailable == false) {
      if (_wasBlocked) {
        return _InfoCard(
          icon: Icons.compass_calibration_outlined,
          message: settings.getLabel('qiblaSensorBlocked'),
          hint: settings.getLabel('qiblaCalibrateHint'),
          actionLabel: settings.getLabel('qiblaResetSensor'),
          onAction: _resetSensor,
        );
      }
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
              style: TextStyle(fontSize: 12, color: context.appTextFaded),
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
  final Color accentColor;
  final bool isEn;

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

// ── Rose painter ────────────────────────────────────────────────────────────

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
      final isMedium = i % 6 == 0; // every 30°
      final tickLen = isCardinal ? 18.0 : (isMedium ? 10.0 : 5.0);
      final sw = isCardinal ? 2.0 : 1.0;
      final opacity = isCardinal ? 0.70 : (isMedium ? 0.40 : 0.22);

      tickPaint
        ..color = Color.fromRGBO(136, 136, 136, opacity)
        ..strokeWidth = sw;

      canvas.drawLine(
        Offset(
          center.dx + (radius - tickLen) * cos(angleRad),
          center.dy + (radius - tickLen) * sin(angleRad),
        ),
        Offset(
          center.dx + radius * cos(angleRad),
          center.dy + radius * sin(angleRad),
        ),
        tickPaint,
      );
    }

    // Cardinal labels: N/E/S/W (or U/T/S/B in Indonesian)
    final cardinals = isEn
        ? [('N', true), ('E', false), ('S', false), ('W', false)]
        : [('U', true), ('T', false), ('S', false), ('B', false)];
    final labelAngles = [0.0, pi / 2, pi, 3 * pi / 2];
    final labelR = radius - 28.0;

    for (int i = 0; i < 4; i++) {
      final angle = labelAngles[i];
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

// ── Needle painter ──────────────────────────────────────────────────────────

class _NeedlePainter extends CustomPainter {
  final Color color;
  const _NeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final tip = size.height * 0.08; // arrow tip (near top)
    final toe = cy + size.height * 0.28; // arrow tail (below center)

    // Drop shadow
    canvas.drawPath(
      _arrowPath(cx, cy, tip, toe),
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Filled arrow
    canvas.drawPath(_arrowPath(cx, cy, tip, toe), Paint()..color = color);

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
    canvas.drawCircle(Offset(cx, cy), 8, Paint()..color = color);
    canvas.drawCircle(
      Offset(cx, cy),
      4,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  Path _arrowPath(double cx, double cy, double tip, double toe) => Path()
    ..moveTo(cx, tip + 16) // just below the diamond
    ..lineTo(cx - 7, cy - 12)
    ..lineTo(cx - 3, toe)
    ..lineTo(cx + 3, toe)
    ..lineTo(cx + 7, cy - 12)
    ..close();

  @override
  bool shouldRepaint(_NeedlePainter old) => old.color != color;
}

// ── Info card (sensor/location errors) ──────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? hint;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _InfoCard({
    required this.icon,
    required this.message,
    this.hint,
    this.actionLabel,
    this.onAction,
  });

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
            if (hint != null) ...[
              const SizedBox(height: 12),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: context.appTextFaded,
                  height: 1.5,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: context.appAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
