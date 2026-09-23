import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tracks app launches and triggers the in-app rating prompt once after
/// the 5th launch. A manual trigger is also available for the settings screen.
/// Uses Google's official Play In-App Review via MethodChannel on Android,
/// with direct Play Store fallback.
class RatingService {
  static const _launchCountKey = 'app_launch_count';
  static const _ratingShownKey = 'rating_shown';
  static const _minLaunchCount = 5;

  static const _channel = MethodChannel('studio.frosthoot.prayer_app/settings');

  /// Call on every app open (from MainScreen.initState via a 2-second delay).
  /// Shows the system rating prompt exactly once after [_minLaunchCount] launches.
  static Future<void> trackLaunchAndPrompt() async {
    final box = await Hive.openBox('settings');

    final alreadyShown = box.get(_ratingShownKey, defaultValue: false) as bool;
    if (alreadyShown) return;

    final count = (box.get(_launchCountKey, defaultValue: 0) as int) + 1;
    await box.put(_launchCountKey, count);

    if (count >= _minLaunchCount) {
      try {
        final success = await _channel.invokeMethod<bool>('requestReview') ?? false;
        if (success) {
          await box.put(_ratingShownKey, true);
        }
      } catch (e) {
        debugPrint('[Rating] trackLaunchAndPrompt error: $e');
      }
    }
  }

  /// Manual trigger from the settings screen. Falls back to the Play Store
  /// listing if the in-app dialog is unavailable.
  static Future<void> requestRating() async {
    try {
      final success = await _channel.invokeMethod<bool>('requestReview') ?? false;
      if (success) return;
    } catch (e) {
      debugPrint('[Rating] requestReview failed, falling back: $e');
    }
    // Fallback: open the Play Store listing directly. The in-app review
    // dialog is frequently unavailable (Google quota, sideloaded build,
    // emulator), so always have a path that actually opens something.
    await _openPlayStoreListing();
  }

  static Future<void> _openPlayStoreListing() async {
    const package = 'studio.frosthoot.prayer_app';
    // Prefer the Play Store app via market:// , fall back to https:// for
    // devices without the Play Store app.
    final marketUri = Uri.parse('market://details?id=$package');
    final webUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$package',
    );
    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      debugPrint('[Rating] market:// launch failed: $e');
    }
    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[Rating] https Play Store launch failed: $e');
    }
  }
}
