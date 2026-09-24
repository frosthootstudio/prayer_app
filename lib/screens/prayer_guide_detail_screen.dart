import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/prayer_guide_model.dart';
import '../providers/settings_provider.dart';
import '../utils/arabic_font_helper.dart';
import '../utils/app_theme.dart';
import 'prayer_recitation_screen.dart';

class PrayerGuideDetailScreen extends StatelessWidget {
  final PrayerGuideItem item;

  const PrayerGuideDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isEn = settings.isEnglish;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.appTextPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          item.title,
          style: GoogleFonts.poppins(
            color: context.appTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Header Card ───────────────────────────────────────────────────
          _HeaderCard(item: item, settings: settings),

          const SizedBox(height: 16),

          // ── Niat Card ─────────────────────────────────────────────────────
          _NiatCard(item: item, settings: settings, isEn: isEn),

          const SizedBox(height: 16),

          // ── Rekomendasi Surah Pendek & Keutamaannya ───────────────────────
          if (item.recommendedSurahs.isNotEmpty) ...[
            _RecommendedSurahsCard(surahs: item.recommendedSurahs, isEn: isEn),
            const SizedBox(height: 16),
          ],

          // ── Special Dua (if available) ────────────────────────────────────
          if (item.specialDuaArabic != null) ...[
            _SpecialDuaCard(item: item, settings: settings, isEn: isEn),
            const SizedBox(height: 16),
          ],

          // ── Tata Cara Khusus (misal Shalat Jenazah 4 takbir) ──────────────
          if (item.specialSteps != null && item.specialSteps!.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: context.appAccent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isEn ? 'Step-by-Step Procedure' : 'Tata Cara Pelaksanaan',
                  style: GoogleFonts.poppins(
                    color: context.appTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < item.specialSteps!.length; i++)
              _SpecialStepItem(
                step: item.specialSteps![i],
                stepIndex: i + 1,
                settings: settings,
              ),
            const SizedBox(height: 16),
          ],

          // ── Banner Akses Bacaan Shalat Lengkap (Takbir s/d Salam) ─────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.appAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.appAccent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.appAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: context.appAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn
                                ? 'Universal Prayer Recitations'
                                : 'Bacaan & Gerakan Shalat Lengkap',
                            style: GoogleFonts.poppins(
                              color: context.appTextPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            isEn
                                ? 'Full guide from Takbiratul Ihram to Salam'
                                : 'Panduan dari Takbiratul Ihram hingga Salam',
                            style: GoogleFonts.poppins(
                              color: context.appTextSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrayerRecitationScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isEn
                              ? 'Open Full Recitations'
                              : 'Buka Panduan Bacaan Lengkap',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header Card ──────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final PrayerGuideItem item;
  final SettingsProvider settings;

  const _HeaderCard({required this.item, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appDivider, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: context.appCardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            item.arabicTitle,
            textDirection: TextDirection.rtl,
            style: ArabicFontHelper.getStyle(
              settings.arabicFont,
              fontSize: 26,
              color: context.appAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.appAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.rakaatNote,
              style: GoogleFonts.poppins(
                color: context.appAccent,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: context.appTextSecondary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  item.time,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: context.appTextSecondary,
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          if (item.virtue.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.appCardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.appAccent.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: context.appAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.virtue,
                      style: GoogleFonts.poppins(
                        color: context.appTextPrimary,
                        fontSize: 11.5,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Niat Card ────────────────────────────────────────────────────────────────

class _NiatCard extends StatelessWidget {
  final PrayerGuideItem item;
  final SettingsProvider settings;
  final bool isEn;

  const _NiatCard({
    required this.item,
    required this.settings,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appDivider, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: context.appCardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEn ? 'Intention (Niat)' : 'Lafal Niat',
                style: GoogleFonts.poppins(
                  color: context.appAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: context.appTextSecondary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: isEn ? 'Copy' : 'Salin',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text:
                          '${item.niatArabic}\n\n${item.niatLatin}\n\n${item.niatTranslation}',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEn
                            ? 'Niat copied to clipboard'
                            : 'Niat disalin ke clipboard',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              item.niatArabic,
              textDirection: TextDirection.rtl,
              style: ArabicFontHelper.getStyle(
                settings.arabicFont,
                fontSize: 22,
                color: context.appTextPrimary,
                height: 1.9,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.niatLatin,
            style: GoogleFonts.poppins(
              color: context.appAccent,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.niatTranslation,
            style: GoogleFonts.poppins(
              color: context.appTextSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rekomendasi Surah Pendek & Keutamaannya ──────────────────────────────────

class _RecommendedSurahsCard extends StatelessWidget {
  final List<RecommendedSurah> surahs;
  final bool isEn;

  const _RecommendedSurahsCard({required this.surahs, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.appAccent.withValues(alpha: 0.3),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: context.appCardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_outlined,
                color: context.appAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn
                      ? 'Recommended Surahs & Virtues'
                      : 'Rekomendasi Surah Pendek & Keutamaannya',
                  style: GoogleFonts.poppins(
                    color: context.appAccent,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < surahs.length; i++) ...[
            if (i > 0)
              Divider(
                color: context.appDivider,
                height: 22,
                thickness: 0.6,
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: context.appAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    surahs[i].rakaat,
                    style: GoogleFonts.poppins(
                      color: context.appAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        surahs[i].surahName,
                        style: GoogleFonts.poppins(
                          color: context.appTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (surahs[i].arabicSurahName != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        surahs[i].arabicSurahName!,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          color: context.appAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 6),
                      child: Icon(
                        Icons.stars_rounded,
                        size: 15,
                        color: const Color(0xFFD4A057),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        surahs[i].virtue,
                        style: GoogleFonts.poppins(
                          color: context.appTextSecondary,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Special Dua Card ─────────────────────────────────────────────────────────

class _SpecialDuaCard extends StatelessWidget {
  final PrayerGuideItem item;
  final SettingsProvider settings;
  final bool isEn;

  const _SpecialDuaCard({
    required this.item,
    required this.settings,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.appAccent.withValues(alpha: 0.3),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: context.appCardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.specialDuaTitle ??
                    (isEn ? 'Special Prayer Dua' : 'Doa Khusus Shalat'),
                style: GoogleFonts.poppins(
                  color: context.appAccent,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: context.appTextSecondary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: isEn ? 'Copy' : 'Salin',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text:
                          '${item.specialDuaArabic}\n\n${item.specialDuaLatin}\n\n${item.specialDuaTranslation}',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEn ? 'Dua copied' : 'Doa disalin ke clipboard',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              item.specialDuaArabic ?? '',
              textDirection: TextDirection.rtl,
              style: ArabicFontHelper.getStyle(
                settings.arabicFont,
                fontSize: 20,
                color: context.appTextPrimary,
                height: 1.9,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.specialDuaLatin ?? '',
            style: GoogleFonts.poppins(
              color: context.appAccent,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.specialDuaTranslation ?? '',
            style: GoogleFonts.poppins(
              color: context.appTextSecondary,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Special Step Item (e.g. for Janazah) ──────────────────────────────────────

class _SpecialStepItem extends StatelessWidget {
  final PrayerGuideStep step;
  final int stepIndex;
  final SettingsProvider settings;

  const _SpecialStepItem({
    required this.step,
    required this.stepIndex,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appDivider, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.appAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$stepIndex',
                  style: GoogleFonts.poppins(
                    color: context.appAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.title,
                  style: GoogleFonts.poppins(
                    color: context.appTextPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (step.arabic != null && step.arabic!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                step.arabic!,
                textDirection: TextDirection.rtl,
                style: ArabicFontHelper.getStyle(
                  settings.arabicFont,
                  fontSize: 19,
                  color: context.appTextPrimary,
                  height: 1.8,
                ),
              ),
            ),
          ],
          if (step.latin != null && step.latin!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              step.latin!,
              style: GoogleFonts.poppins(
                color: context.appAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
          if (step.translation != null && step.translation!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              step.translation!,
              style: GoogleFonts.poppins(
                color: context.appTextSecondary,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
