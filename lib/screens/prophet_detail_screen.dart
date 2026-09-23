import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/prophet_data.dart';
import '../models/prophet_model.dart';
import '../providers/settings_provider.dart';
import '../utils/arabic_font_helper.dart';
import '../utils/app_theme.dart';

class ProphetDetailScreen extends StatelessWidget {
  final ProphetModel prophet;

  const ProphetDetailScreen({super.key, required this.prophet});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isEn = settings.isEnglish;

    final prevProphet = prophet.id > 1
        ? ProphetData.prophets.firstWhere((p) => p.id == prophet.id - 1)
        : null;

    final nextProphet = prophet.id < ProphetData.prophets.length
        ? ProphetData.prophets.firstWhere((p) => p.id == prophet.id + 1)
        : null;

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
          prophet.name,
          style: GoogleFonts.poppins(
            color: context.appTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.copy_rounded,
              size: 20,
              color: context.appTextSecondary,
            ),
            tooltip: isEn ? 'Copy Story' : 'Salin Kisah',
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: '${prophet.name} (${prophet.arabicName})\n\n'
                    '${prophet.story}\n\n'
                    'Hikmah:\n${prophet.moralLessons.map((l) => '- $l').join('\n')}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEn ? 'Story copied to clipboard' : 'Kisah disalin ke clipboard',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Header Card ───────────────────────────────────────────────────
          _HeaderCard(prophet: prophet, settings: settings, isEn: isEn),

          const SizedBox(height: 16),

          // ── Kisah Utama (Story) ───────────────────────────────────────────
          _SectionTitle(title: isEn ? 'Story & Mission' : 'Kisah & Perjuangan Dakwah'),
          const SizedBox(height: 8),
          Container(
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
            child: Text(
              prophet.story,
              style: GoogleFonts.poppins(
                color: context.appTextPrimary,
                fontSize: 13,
                height: 1.7,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Mukjizat (Miracles) ───────────────────────────────────────────
          _SectionTitle(title: isEn ? 'Miracles Granted' : 'Mukjizat yang Diberikan'),
          const SizedBox(height: 8),
          Container(
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
              children: [
                for (final miracle in prophet.miracles)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3, right: 10),
                          child: Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: context.appAccent,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            miracle,
                            style: GoogleFonts.poppins(
                              color: context.appTextPrimary,
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Hikmah & Pelajaran Hidup (Moral Lessons) ──────────────────────
          _SectionTitle(title: isEn ? 'Moral Lessons' : 'Hikmah & Teladan Hidup'),
          const SizedBox(height: 8),
          Container(
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
              children: [
                for (final lesson in prophet.moralLessons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3, right: 10),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: context.appAccent,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            lesson,
                            style: GoogleFonts.poppins(
                              color: context.appTextPrimary,
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Previous / Next Navigation ────────────────────────────────────
          Row(
            children: [
              if (prevProphet != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProphetDetailScreen(prophet: prevProphet),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: context.appAccent,
                    ),
                    label: Text(
                      prevProphet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: context.appTextPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.appDivider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                )
              else
                const Spacer(),

              const SizedBox(width: 12),

              if (nextProphet != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProphetDetailScreen(prophet: nextProphet),
                        ),
                      );
                    },
                    icon: Text(
                      nextProphet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    label: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Header Card ──────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final ProphetModel prophet;
  final SettingsProvider settings;
  final bool isEn;

  const _HeaderCard({
    required this.prophet,
    required this.settings,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.appAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isEn ? 'Prophet #${prophet.id}' : 'Nabi ke-${prophet.id}',
                  style: GoogleFonts.poppins(
                    color: context.appAccent,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (prophet.isUlulAzmi) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A057).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD4A057).withValues(alpha: 0.5),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFD4A057),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ulul Azmi',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFD4A057),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            prophet.arabicName,
            textDirection: TextDirection.rtl,
            style: ArabicFontHelper.getStyle(
              settings.arabicFont,
              fontSize: 26,
              color: context.appAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prophet.name,
            style: GoogleFonts.poppins(
              color: context.appTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: context.appDivider, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.history_edu_rounded, size: 15, color: context.appTextSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  prophet.era,
                  style: GoogleFonts.poppins(
                    color: context.appTextSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.place_outlined, size: 15, color: context.appTextSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  prophet.place,
                  style: GoogleFonts.poppins(
                    color: context.appTextSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          title,
          style: GoogleFonts.poppins(
            color: context.appTextPrimary,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
