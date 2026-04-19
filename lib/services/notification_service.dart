import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/prayer_model.dart';
import '../providers/settings_provider.dart';

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

  static bool   _initialized = false;
  static String _localTz     = 'UTC';

  // ── Init ──────────────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;

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

    try {
      await AwesomeNotifications().initialize(
        'resource://drawable/ic_notification',
        [...adzanChannels, preChannel],
        debug: false,
      );
      _localTz = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    } catch (e) {
      // Initialization failed (e.g. missing drawable resource); fall back to
      // UTC timezone so scheduling still works on next call.
      _localTz = 'UTC';
    }
    _initialized = true;
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  static Future<void> requestPermission() async {
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

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id:                 id,
        channelKey:         _adzanChannelKey(sound),
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

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id:                 id,
        channelKey:         _preChannelKey,
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

  // ── Test notification ─────────────────────────────────────────────────────

  /// Schedules a one-shot notification 10 seconds from now using [sound].
  static Future<void> scheduleTest({
    AdzanSound sound = AdzanSound.adzan,
  }) async {
    final fireAt = DateTime.now().add(const Duration(seconds: 10));
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
  }
}
