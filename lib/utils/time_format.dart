import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Formats a prayer time following the device's system 12h/24h preference.
///
/// - 24-hour device → "05:12"
/// - 12-hour device → "5:12 AM"
///
/// Reads MediaQuery.alwaysUse24HourFormatOf(context), so it updates live if
/// the user changes their system setting and returns to the app.
String formatPrayerTime(BuildContext context, DateTime time) {
  final use24h = MediaQuery.alwaysUse24HourFormatOf(context);
  final pattern = use24h ? 'HH:mm' : 'h:mm a';
  return DateFormat(pattern).format(time);
}
