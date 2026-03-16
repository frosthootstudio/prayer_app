import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/prayer_model.dart';

class NotificationService {
  NotificationService._();

  // ── Channel config ─────────────────────────────────────────────────────────
  static const _channelKey  = 'prayer_channel';
  static const _channelName = 'Waktu Shalat';
  static const _channelDesc = 'Notifikasi pengingat waktu shalat';

  // ── Stable notification IDs per prayer key ─────────────────────────────────
  static const _ids = <String, int>{
    'fajr'   : 0,
    'sunrise': 1,
    'dhuhr'  : 2,
    'asr'    : 3,
    'maghrib': 4,
    'isha'   : 5,
  };

  // ── Pre-adzan IDs (prayer_id + 10) ─────────────────────────────────────────
  static const _preAdzanIds = <String, int>{
    'fajr'   : 10,
    'dhuhr'  : 12,
    'asr'    : 13,
    'maghrib': 14,
    'isha'   : 15,
  };

  static bool   _initialized = false;
  static String _localTz     = 'UTC';

  // ── Init ──────────────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;

    await AwesomeNotifications().initialize(
      'resource://drawable/ic_notification',
      [
        NotificationChannel(
          channelKey:          _channelKey,
          channelName:         _channelName,
          channelDescription:  _channelDesc,
          defaultColor:        const Color(0xFFD4A057),
          // Max importance ensures heads-up delivery on MIUI/HyperOS
          importance:          NotificationImportance.Max,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          enableVibration:     true,
          playSound:           true,
          // criticalAlerts bypasses Do-Not-Disturb / silent mode
          criticalAlerts:      true,
          locked:              false,
        ),
      ],
      debug: false,
    );

    _localTz = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    _initialized = true;
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  /// Requests notification permission and, on Android 12+, exact alarm permission
  /// (SCHEDULE_EXACT_ALARM → NotificationPermission.PreciseAlarms).
  /// The user is directed to the system "Alarms & Reminders" settings page if needed.
  static Future<void> requestPermission() async {
    await AwesomeNotifications().requestPermissionToSendNotifications(
      permissions: [
        NotificationPermission.Alert,
        NotificationPermission.Sound,
        NotificationPermission.Vibration,
        NotificationPermission.Badge,
        NotificationPermission.CriticalAlert,
        NotificationPermission.PreciseAlarms,  // SCHEDULE_EXACT_ALARM on API 31+
      ],
    );
  }

  // ── Adzan scheduling ──────────────────────────────────────────────────────

  /// Schedules a daily-repeating exact alarm for [prayer].
  /// Sunrise is skipped (no adzan notification).
  static Future<void> scheduleOne(PrayerInfo prayer) async {
    if (prayer.key == 'sunrise') return;
    final id = _ids[prayer.key];
    if (id == null) return;

    final timeStr = DateFormat('HH:mm').format(prayer.time);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id:                 id,
        channelKey:         _channelKey,
        title:              'Waktu ${prayer.name}',
        body:               '${prayer.name} · $timeStr',
        notificationLayout: NotificationLayout.Default,
        category:           NotificationCategory.Reminder,
        wakeUpScreen:       true,
        criticalAlert:      true,
        autoDismissible:    false,
      ),
      schedule: NotificationCalendar(
        hour:           prayer.time.hour,
        minute:         prayer.time.minute,
        second:         0,
        millisecond:    0,
        timeZone:       _localTz,
        repeats:        true,
        preciseAlarm:   true,
        allowWhileIdle: true,
      ),
    );
  }

  /// Cancels the adzan notification for a single [prayerKey].
  static Future<void> cancelOne(String prayerKey) async {
    final id = _ids[prayerKey];
    if (id == null) return;
    await AwesomeNotifications().cancel(id);
  }

  // ── Pre-adzan scheduling ──────────────────────────────────────────────────

  /// Schedules a daily reminder [minutesBefore] minutes before [prayer].
  static Future<void> schedulePreAdzan(
    PrayerInfo prayer,
    int minutesBefore, {
    bool isEnglish = false,
  }) async {
    if (prayer.key == 'sunrise') return;
    final id = _preAdzanIds[prayer.key];
    if (id == null) return;

    // Compute the reminder time
    final preTime = prayer.time.subtract(Duration(minutes: minutesBefore));
    final timeStr = DateFormat('HH:mm').format(prayer.time);

    final title = isEnglish
        ? '⏰ ${prayer.name} in $minutesBefore min'
        : '⏰ ${prayer.name} dalam $minutesBefore menit';
    final body = isEnglish
        ? 'Prepare for ${prayer.name} prayer · $timeStr'
        : 'Bersiaplah untuk shalat ${prayer.name} · $timeStr';

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id:                 id,
        channelKey:         _channelKey,
        title:              title,
        body:               body,
        notificationLayout: NotificationLayout.Default,
        category:           NotificationCategory.Reminder,
        wakeUpScreen:       true,
        criticalAlert:      true,
        autoDismissible:    true,
      ),
      schedule: NotificationCalendar(
        hour:           preTime.hour,
        minute:         preTime.minute,
        second:         0,
        millisecond:    0,
        timeZone:       _localTz,
        repeats:        true,
        preciseAlarm:   true,
        allowWhileIdle: true,
      ),
    );
  }

  /// Cancels the pre-adzan reminder for a single [prayerKey].
  static Future<void> cancelPreAdzan(String prayerKey) async {
    final id = _preAdzanIds[prayerKey];
    if (id == null) return;
    await AwesomeNotifications().cancel(id);
  }

  // ── Batch scheduling ──────────────────────────────────────────────────────

  /// Schedules enabled prayers and their pre-adzan reminders; cancels disabled ones.
  static Future<void> scheduleAll(
    List<PrayerInfo> prayers,
    Map<String, bool> notifPrefs, {
    bool preAdzanEnabled = false,
    int  preAdzanMinutes = 10,
    bool isEnglish       = false,
  }) async {
    for (final prayer in prayers) {
      if (prayer.key == 'sunrise') continue;
      final enabled = notifPrefs[prayer.key] ?? true;
      if (enabled) {
        await scheduleOne(prayer);
        if (preAdzanEnabled) {
          await schedulePreAdzan(prayer, preAdzanMinutes, isEnglish: isEnglish);
        } else {
          await cancelPreAdzan(prayer.key);
        }
      } else {
        await cancelOne(prayer.key);
        await cancelPreAdzan(prayer.key);
      }
    }
  }

  /// Cancels all prayer and pre-adzan notifications.
  static Future<void> cancelAll() => AwesomeNotifications().cancelAll();

  // ── Test notification ──────────────────────────────────────────────────────

  /// Schedules a one-shot test notification 10 seconds from now.
  /// Helps users verify that the notification channel is working correctly.
  static Future<void> scheduleTest() async {
    final fireAt = DateTime.now().add(const Duration(seconds: 10));
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id:                 99,
        channelKey:         _channelKey,
        title:              'Test Notifikasi Adzan',
        body:               'Notifikasi adzan berfungsi dengan baik!',
        notificationLayout: NotificationLayout.Default,
        category:           NotificationCategory.Reminder,
        wakeUpScreen:       true,
        autoDismissible:    true,
      ),
      schedule: NotificationCalendar(
        year:           fireAt.year,
        month:          fireAt.month,
        day:            fireAt.day,
        hour:           fireAt.hour,
        minute:         fireAt.minute,
        second:         fireAt.second,
        millisecond:    0,
        timeZone:       _localTz,
        repeats:        false,
        preciseAlarm:   true,
        allowWhileIdle: true,
      ),
    );
  }
}
