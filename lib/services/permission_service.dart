import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Centralised helper for the three permissions that affect prayer notification
/// reliability, plus device-manufacturer detection for Xiaomi/MIUI guidance.
class PermissionService {
  PermissionService._();

  static const _channel =
      MethodChannel('studio.frosthoot.prayer_app/settings');

  // Cached synchronously after [getManufacturer] is first awaited (in main.dart)
  static String? _cachedManufacturer;

  // ── Status checks ──────────────────────────────────────────────────────────

  static Future<bool> hasNotification() async {
    if (!Platform.isAndroid) return true;
    return Permission.notification.isGranted;
  }

  static Future<bool> hasBatteryOptimization() async {
    if (!Platform.isAndroid) return true;
    return Permission.ignoreBatteryOptimizations.isGranted;
  }

  static Future<bool> hasExactAlarm() async {
    if (!Platform.isAndroid) return true;
    try {
      return Permission.scheduleExactAlarm.isGranted;
    } catch (_) {
      return true; // not supported on this API level → no restriction
    }
  }

  /// Returns true only when all three are granted.
  static Future<bool> allGranted() async {
    final results = await Future.wait([
      hasNotification(),
      hasBatteryOptimization(),
      hasExactAlarm(),
    ]);
    return results.every((v) => v);
  }

  // ── Requests ───────────────────────────────────────────────────────────────

  static Future<void> requestNotification() async {
    if (!Platform.isAndroid) return;
    await Permission.notification.request();
  }

  static Future<void> requestBatteryOptimization() async {
    if (!Platform.isAndroid) return;
    await Permission.ignoreBatteryOptimizations.request();
  }

  /// On Android 12+ opens the system "Alarms & reminders" settings page.
  /// Falls back to app info page if the intent fails.
  static Future<void> openExactAlarmSettings() async {
    try {
      await _channel.invokeMethod<void>('openAlarmSettings');
    } catch (_) {
      await openAppSettings();
    }
  }

  // ── Device info ────────────────────────────────────────────────────────────

  /// Fetches and caches the device manufacturer string.
  /// Call once at startup (main.dart) so [isXiaomiDevice] is synchronously available.
  static Future<String> getManufacturer() async {
    if (_cachedManufacturer != null) return _cachedManufacturer!;
    try {
      _cachedManufacturer =
          await _channel.invokeMethod<String>('getManufacturer') ?? '';
    } catch (_) {
      _cachedManufacturer = '';
    }
    return _cachedManufacturer!;
  }

  /// Synchronous check — valid only after [getManufacturer] has been awaited.
  static bool get isXiaomiDevice =>
      (_cachedManufacturer ?? '').toLowerCase() == 'xiaomi';
}
