import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/prayer_guide_data.dart';
import '../models/prayer_guide_model.dart';
import '../providers/settings_provider.dart';
import '../utils/arabic_font_helper.dart';
import '../utils/app_theme.dart';

class PrayerRecitationScreen extends StatelessWidget {
  const PrayerRecitationScreen({super.key});

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
          isEn ? 'Prayer Recitations & Steps' : 'Bacaan & Gerakan Shalat',
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
          // ── Info banner ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.appAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.appAccent.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: context.appAccent,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEn
                        ? 'Universal sequence of prayer recitations and movements from Takbiratul Ihram to Salam according to the Shafi\'i school of thought.'
                        : 'Urutan bacaan dan gerakan shalat universal dari Takbiratul Ihram hingga Salam sesuai dengan tuntunan sunnah dan Mazhab Syafi\'i.',
                    style: GoogleFonts.poppins(
                      color: context.appTextPrimary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── 12 Steps ─────────────────────────────────────────────────────
          for (int i = 0; i < PrayerGuideData.commonSteps.length; i++)
            _RecitationStepCard(
              step: PrayerGuideData.commonSteps[i],
              index: i + 1,
              settings: settings,
            ),
        ],
      ),
    );
  }
}

class _RecitationStepCard extends StatelessWidget {
  final PrayerGuideStep step;
  final int index;
  final SettingsProvider settings;

  const _RecitationStepCard({
    required this.step,
    required this.index,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appDivider, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: context.appCardShadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.appAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: GoogleFonts.poppins(
                    color: context.appAccent,
                    fontSize: 13,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Arabic
          if (step.arabic != null && step.arabic!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                step.arabic!,
                textDirection: TextDirection.rtl,
                style: ArabicFontHelper.getStyle(
                  settings.arabicFont,
                  fontSize: 20,
                  color: context.appTextPrimary,
                  height: 1.85,
                ),
              ),
            ),
          ],

          // Latin
          if (step.latin != null && step.latin!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              step.latin!,
              style: GoogleFonts.poppins(
                color: context.appAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ],

          // Translation
          if (step.translation != null && step.translation!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              step.translation!,
              style: GoogleFonts.poppins(
                color: context.appTextSecondary,
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ],

          // Movement Notes
          if (step.notes != null && step.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.appAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: context.appAccent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      step.notes!,
                      style: GoogleFonts.poppins(
                        color: context.appTextPrimary,
                        fontSize: 11,
                        height: 1.35,
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
