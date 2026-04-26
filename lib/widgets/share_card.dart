import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/prayer_model.dart';
import '../services/prayer_calculation_service.dart';

/// Off-screen 1080×1080 card rendered for sharing.
class ShareCard extends StatelessWidget {
  final List<PrayerInfo> prayers;
  final String cityName;
  final String gregorianDate;
  final String hijriDate;
  final DateTime? imsakTime;
  final AppLanguage language;

  const ShareCard({
    super.key,
    required this.prayers,
    required this.cityName,
    required this.gregorianDate,
    required this.hijriDate,
    this.imsakTime,
    this.language = AppLanguage.id,
  });

  static const _gold   = Color(0xFFD4A057);
  static const _gold2  = Color(0xFFB8893F);
  static const _white  = Colors.white;
  static const _white70 = Color(0xB3FFFFFF);

  static const double _kWidth = 1080;

  static String _t(AppLanguage l,
      {required String ar, required String en, required String id}) =>
      l == AppLanguage.ar ? ar : l == AppLanguage.en ? en : id;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kWidth,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1C2E), Color(0xFF252840)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 36),
            _buildDateSection(),
            const SizedBox(height: 28),
            _buildGoldDivider(),
            const SizedBox(height: 28),
            _buildPrayerList(),
            const SizedBox(height: 28),
            _buildGoldDivider(),
            const SizedBox(height: 32),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_gold, _gold2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.mosque_rounded, color: _white, size: 40),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Waktu Shalat',
              style: GoogleFonts.poppins(
                color: _white,
                fontSize: 36,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            if (cityName.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: _gold, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    cityName,
                    style: GoogleFonts.poppins(
                      color: _gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      children: [
        if (hijriDate.isNotEmpty)
          Text(
            hijriDate,
            style: GoogleFonts.poppins(
              color: _gold,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          gregorianDate,
          style: GoogleFonts.poppins(
            color: _white70,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildGoldDivider() {
    return Container(
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _gold.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerList() {
    final fmt = DateFormat('HH:mm');
    final rows = <Widget>[];

    // Imsak row (Ramadan only)
    if (imsakTime != null) {
      rows.add(_PrayerRowCard(
        icon: Icons.nightlight_round,
        iconColor: _gold,
        name: _t(language, ar: 'إمساك', en: 'Imsak', id: 'Imsak'),
        time: fmt.format(imsakTime!),
        isBold: false,
      ));
      rows.add(const SizedBox(height: 12));
    }

    for (final prayer in prayers) {
      if (prayer.key == 'sunrise') continue;
      rows.add(_PrayerRowCard(
        icon: _prayerIcon(prayer.key),
        iconColor: _prayerColor(prayer.key),
        name: prayer.name,
        time: fmt.format(prayer.time),
        isBold: prayer.isNext,
      ));
      if (prayer != prayers.last) rows.add(const SizedBox(height: 12));
    }

    return Column(children: rows);
  }

  Widget _buildFooter() {
    return Text(
      _t(language,
        ar: 'شارك وانشر الخير 🕌',
        en: 'Shared via Waktu Shalat app 🕌',
        id: 'Dibagikan via aplikasi Waktu Shalat 🕌',
      ),
      style: GoogleFonts.poppins(
        color: _white70,
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static IconData _prayerIcon(String key) => switch (key) {
        'fajr'    => Icons.nights_stay_rounded,
        'dhuhr'   => Icons.wb_sunny_rounded,
        'asr'     => Icons.brightness_5_rounded,
        'maghrib' => Icons.brightness_4_rounded,
        'isha'    => Icons.nights_stay_rounded,
        _         => Icons.circle_outlined,
      };

  static Color _prayerColor(String key) => switch (key) {
        'fajr'    => const Color(0xFF6366F1),
        'dhuhr'   => const Color(0xFFF97316),
        'asr'     => const Color(0xFF10B981),
        'maghrib' => const Color(0xFFF43F5E),
        'isha'    => const Color(0xFF8B5CF6),
        _         => _gold,
      };
}

class _PrayerRowCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String time;
  final bool isBold;

  const _PrayerRowCard({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.time,
    required this.isBold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        color: isBold
            ? const Color(0xFFD4A057).withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBold
              ? const Color(0xFFD4A057).withValues(alpha: 0.40)
              : Colors.white.withValues(alpha: 0.06),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 26, color: iconColor),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                color: isBold
                    ? const Color(0xFFD4A057)
                    : Colors.white,
                fontSize: 26,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              color: isBold
                  ? const Color(0xFFD4A057)
                  : Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
