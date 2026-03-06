import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/prayer_provider.dart';
import '../utils/app_theme.dart';

class CountdownTimer extends StatelessWidget {
  const CountdownTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final countdown = context.select<PrayerProvider, String>(
      (p) => p.countdown,
    );

    return Text(
      countdown,
      style: TextStyle(
        color: context.appTextPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
