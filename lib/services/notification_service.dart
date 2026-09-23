import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/prayer_model.dart';
import '../providers/settings_provider.dart';
import 'ramadan_service.dart';

class NotificationService {
  NotificationService._();

  // ── Channel keys ───────────────────────────────────────────────────────────
  //
  // Android locks a channel's sound at creation time and never changes it.
  // Solution: one channel per AdzanSound value so each carries its own
  // soundSource.  Key suffix _v3 ensures fresh creation after earlier
  // migrations (v1 = alarm-only, v2 = first sound attempt).
  //
  static String _adzanChannelKey(AdzanSound sound) =>
      'prayer_${sound.name}_v3';

  // Pre-adzan reminder uses its own channel (no custom adzan sound needed).
  static const _preChannelKey  = 'prayer_pre_v3';
  static const _preChannelName = 'Pengingat Adzan';

  static const _qadarChannelKey  = 'lailatul_qadar_v1';
  static const _qadarChannelName = 'Lailatul Qadar';

  // ── Stable notification IDs ────────────────────────────────────────────────
  static const _ids = <String, int>{
    'fajr'   : 0,
    'sunrise': 1,
    'dhuhr'  : 2,
    'asr'    : 3,
    'maghrib': 4,
    'isha'   : 5,
  };

  static const _preAdzanIds = <String, int>{
    'fajr'   : 10,
    'dhuhr'  : 12,
    'asr'    : 13,
    'maghrib': 14,
    'isha'   : 15,
  };

  static bool    _initialized = false;
  static String  _localTz     = 'UTC';

  /// Last init error message, null if initialize() succeeded. Surfaced by
  /// DiagnosticScreen so support tickets show whether tz/local-notif init
  /// failed silently. Reset on each initialize() call.
  static String? lastInitError;

  // ── Init ──────────────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;
    lastInitError = null;

    // Build one channel for every AdzanSound variant.
    // soundSource == null → channel falls back to system alarm ringtone.
    final adzanChannels = AdzanSound.values.map((sound) {
      return NotificationChannel(
        channelKey:          _adzanChannelKey(sound),
        channelName:         'Waktu Shalat · ${sound.displayName}',
        channelDescription:  'Notifikasi pengingat waktu shalat',
        defaultColor:        const Color(0xFFD4A057),
        importance:          NotificationImportance.Max,
        defaultRingtoneType: sound.hasAudio
            ? DefaultRingtoneType.Ringtone
            : DefaultRingtoneType.Alarm,
        soundSource:         sound.soundSource,
        enableVibration:     true,
        playSound:           true,
        criticalAlerts:      true,
        locked:              false,
      );
    }).toList();

    // Pre-adzan soft reminder — no custom adzan sound
    final preChannel = NotificationChannel(
      channelKey:          _preChannelKey,
      channelName:         _preChannelName,
      channelDescription:  'Pengingat sebelum waktu shalat',
      defaultColor:        const Color(0xFFD4A057),
      importance:          NotificationImportance.High,
      defaultRingtoneType: DefaultRingtoneType.Ringtone,
      enableVibration:     true,
      playSound:           true,
      locked:              false,
    );

    // Lailatul Qadar special night reminder
    final qadarChannel = NotificationChannel(
      channelKey:          _qadarChannelKey,
      channelName:         _qadarChannelName,
      channelDescription:  'Pengingat malam Lailatul Qadar',
      defaultColor:        const Color(0xFFD4A057),
      importance:          NotificationImportance.Max,
      defaultRingtoneType: DefaultRingtoneType.Ringtone,
      enableVibration:     true,
      playSound:           true,
      locked:              false,
    );

    try {
      await AwesomeNotifications().initialize(
        'resource://drawable/ic_notification',
        [...adzanChannels, preChannel, qadarChannel],
        debug: false,
      );
      _localTz = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    } catch (e) {
      // Initialization failed (e.g. missing drawable resource); fall back to
      // UTC timezone so scheduling still works on next call.
      FirebaseCrashlytics.instance.recordError(
        e, StackTrace.current,
        reason: 'notif_init_failed', fatal: false,
      );
      lastInitError = e.toString();
      _localTz = 'UTC';
    }
    _initialized = true;
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  /// Requests notification permissions. Skips the dialog entirely if
  /// permission is already granted (avoids re-prompting on every boot).
  /// Wrapped in try/catch — requestPermissionToSendNotifications can throw
  /// PlatformException on aggressive OEMs (same class as the Tecno
  /// INSUFFICIENT_PERMISSIONS crash fixed in 1.5.3).
  static Future<void> requestPermission() async {
    try {
      final allowed = await AwesomeNotifications().isNotificationAllowed();
      if (allowed) return;
      await AwesomeNotifications().requestPermissionToSendNotifications(
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Vibration,
          NotificationPermission.Badge,
          NotificationPermission.CriticalAlert,
          NotificationPermission.PreciseAlarms,
        ],
      );
    } catch (e, stack) {
      debugPrint('[Notif] requestPermission failed: $e');
      FirebaseCrashlytics.instance.recordError(
        e, stack, reason: 'notif_request_permission_failed', fatal: false,
      );
    }
  }

  /// Returns true if notifications are currently allowed. Wraps the plugin
  /// call in try/catch — on some OEMs the check itself can throw if the
  /// notification subsystem is in a bad state.
  static Future<bool> isAllowed() async {
    try {
      return await AwesomeNotifications().isNotificationAllowed();
    } catch (e) {
      debugPrint('[Notif] isNotificationAllowed check failed: $e');
      return false;
    }
  }

  // ── Adzan scheduling ──────────────────────────────────────────────────────

  /// Schedules a daily-repeating exact alarm for [prayer] using the channel
  /// that matches [sound].  Sunrise is always skipped.
  static Future<void> scheduleOne(
    PrayerInfo prayer, {
    AdzanSound sound = AdzanSound.adzan,
  }) async {
    if (prayer.key == 'sunrise') return;
    final id = _ids[prayer.key];
    if (id == null) return;

    final timeStr = DateFormat('HH:mm').format(prayer.time);

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id:                 id,
          channelKey:         _adzanChannelKey(sound),
          title:              'Waktu ${prayer.name}',
          body:               '${prayer.name} · $timeStr',
          notificationLayout: NotificationLayout.Default,
          category:           NotificationCategory.Reminder,
          wakeUpScreen:       true,
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
    } catch (e, stack) {
      debugPrint('[Notif] scheduleOne(${prayer.key}) failed: $e');
      FirebaseCrashlytics.instance.recordError(
        e, stack, reason: 'notif_schedule_one_failed', fatal: false,
      );
    }
  }

  /// Cancels the adzan notification for [prayerKey].
  static Future<void> cancelOne(String prayerKey) async {
    final id = _ids[prayerKey];
    if (id == null) return;
    await AwesomeNotifications().cancel(id);
  }

  // ── Pre-adzan scheduling ──────────────────────────────────────────────────

  static Future<void> schedulePreAdzan(
    PrayerInfo prayer,
    int minutesBefore, {
    bool isEnglish = false,
  }) async {
    if (prayer.key == 'sunrise') return;
    final id = _preAdzanIds[prayer.key];
    if (id == null) return;

    final preTime = prayer.time.subtract(Duration(minutes: minutesBefore));
    final timeStr = DateFormat('HH:mm').format(prayer.time);
    final title   = isEnglish
        ? '⏰ ${prayer.name} in $minutesBefore min'
        : '⏰ ${prayer.name} dalam $minutesBefore menit';
    final body    = isEnglish
        ? 'Prepare for ${prayer.name} prayer · $timeStr'
        : 'Bersiaplah untuk shalat ${prayer.name} · $timeStr';

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id:                 id,
          channelKey:         _preChannelKey,
          title:              title,
          body:               body,
          notificationLayout: NotificationLayout.Default,
          category:           NotificationCategory.Reminder,
          wakeUpScreen:       true,
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
    } catch (e, stack) {
      debugPrint('[Notif] schedulePreAdzan(${prayer.key}) failed: $e');
      FirebaseCrashlytics.instance.recordError(
        e, stack, reason: 'notif_schedule_pre_failed', fatal: false,
      );
    }
  }

  static Future<void> cancelPreAdzan(String prayerKey) async {
    final id = _preAdzanIds[prayerKey];
    if (id == null) return;
    await AwesomeNotifications().cancel(id);
  }

  // ── Batch scheduling ──────────────────────────────────────────────────────

  static Future<void> scheduleAll(
    List<PrayerInfo>  prayers,
    Map<String, bool> notifPrefs, {
    AdzanSound adzanSound       = AdzanSound.adzan,
    AdzanSound adzanSoundFajr   = AdzanSound.adzanFajr,
    bool       preAdzanEnabled  = false,
    int        preAdzanMinutes  = 10,
    bool       isEnglish        = false,
  }) async {
    // Bail early if notifications are disabled — common on aggressive OEMs
    // (Tecno HiOS, Xiaomi) that revoke permission while backgrounded. Calling
    // createNotification() without permission throws INSUFFICIENT_PERMISSIONS,
    // which previously bubbled up as a fatal crash (Crashlytics 1.5.2).
    if (!await isAllowed()) {
      debugPrint('[Notif] scheduleAll skipped — notifications not allowed');
      return;
    }
    for (final prayer in prayers) {
      if (prayer.key == 'sunrise') continue;
      final enabled = notifPrefs[prayer.key] ?? true;
      final sound   = prayer.key == 'fajr' ? adzanSoundFajr : adzanSound;
      if (enabled) {
        await scheduleOne(prayer, sound: sound);
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

  static Future<void> cancelAll() => AwesomeNotifications().cancelAll();

  // ── Lailatul Qadar notifications ──────────────────────────────────────────

  /// Schedules one-shot notifications at 23:00 on Ramadan nights 21,23,25,27,29.
  static Future<void> scheduleLailatulQadar({bool isEnglish = false}) async {
    final dates = RamadanService.lailatulQadarDates();
    final now   = DateTime.now();
    for (final (day, date) in dates) {
      final fireAt = DateTime(date.year, date.month, date.day, 23, 0, 0);
      if (fireAt.isBefore(now)) continue; // skip past nights
      final title = isEnglish
          ? '✨ Lailatul Qadar Night (Night $day)'
          : '✨ Malam Lailatul Qadar (Malam ke-$day)';
      final body = isEnglish
          ? 'This may be the Night of Power. Increase your worship!'
          : 'Ini bisa jadi malam penuh kemuliaan. Perbanyak ibadah!';
      try {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id:                 day, // 21, 23, 25, 27, or 29
            channelKey:         _qadarChannelKey,
            title:              title,
            body:               body,
            notificationLayout: NotificationLayout.Default,
            category:           NotificationCategory.Reminder,
            wakeUpScreen:       true,
            autoDismissible:    false,
          ),
          schedule: NotificationCalendar(
            year:           fireAt.year,
            month:          fireAt.month,
            day:            fireAt.day,
            hour:           23,
            minute:         0,
            second:         0,
            millisecond:    0,
            timeZone:       _localTz,
            repeats:        false,
            preciseAlarm:   true,
            allowWhileIdle: true,
          ),
        );
      } catch (e, stack) {
        debugPrint('[Notif] scheduleLailatulQadar(night $day) failed: $e');
        FirebaseCrashlytics.instance.recordError(
          e, stack, reason: 'notif_schedule_qadar_failed', fatal: false,
        );
      }
    }
  }

  static Future<void> cancelLailatulQadar() async {
    for (final day in const [21, 23, 25, 27, 29]) {
      await AwesomeNotifications().cancel(day);
    }
  }

  // ── Test notification ─────────────────────────────────────────────────────

  /// Schedules a one-shot test notification 10s from now. Returns false if
  /// notifications aren't allowed (caller should guide the user to enable
  /// them) — previously this scheduled silently and the user saw nothing.
  static Future<bool> scheduleTest({
    AdzanSound sound = AdzanSound.adzan,
  }) async {
    if (!await isAllowed()) {
      debugPrint('[Notif] scheduleTest skipped — notifications not allowed');
      return false;
    }
    final fireAt = DateTime.now().add(const Duration(seconds: 10));
    debugPrint('[Notif] scheduleTest: tz=$_localTz, fireAt=$fireAt, '
        'now=${DateTime.now()}');
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id:                 99,
          channelKey:         _adzanChannelKey(sound),
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
      final pending = await AwesomeNotifications().listScheduledNotifications();
      debugPrint('[Notif] pending count=${pending.length}');
      for (final n in pending) {
        debugPrint('[Notif] pending id=${n.content?.id} '
            'schedule=${n.schedule?.toMap()}');
      }
      return true;
    } catch (e, stack) {
      debugPrint('[Notif] scheduleTest failed: $e');
      FirebaseCrashlytics.instance.recordError(
        e, stack, reason: 'notif_schedule_test_failed', fatal: false,
      );
      return false;
    }
  }
}

