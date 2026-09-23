import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/prayer_guide_data.dart';
import '../models/prayer_guide_model.dart';
import '../providers/settings_provider.dart';
import '../utils/arabic_font_helper.dart';
import '../utils/app_theme.dart';
import 'prayer_guide_detail_screen.dart';

class PrayerGuideScreen extends StatefulWidget {
  const PrayerGuideScreen({super.key});

  @override
  State<PrayerGuideScreen> createState() => _PrayerGuideScreenState();
}

class _PrayerGuideScreenState extends State<PrayerGuideScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isEn = settings.isEnglish;

    final fardhuList = PrayerGuideData.prayers
        .where((p) => p.category == 'fardhu')
        .where(
          (p) =>
              _searchQuery.isEmpty ||
              p.title.toLowerCase().contains(_searchQuery) ||
              p.arabicTitle.contains(_searchQuery) ||
              p.recommendedSurahs.any(
                (s) =>
                    s.surahName.toLowerCase().contains(_searchQuery) ||
                    s.virtue.toLowerCase().contains(_searchQuery),
              ),
        )
        .toList();

    final sunnahList = PrayerGuideData.prayers
        .where((p) => p.category == 'sunnah')
        .where(
          (p) =>
              _searchQuery.isEmpty ||
              p.title.toLowerCase().contains(_searchQuery) ||
              p.arabicTitle.contains(_searchQuery) ||
              p.recommendedSurahs.any(
                (s) =>
                    s.surahName.toLowerCase().contains(_searchQuery) ||
                    s.virtue.toLowerCase().contains(_searchQuery),
              ),
        )
        .toList();

    final recitationSteps = PrayerGuideData.commonSteps
        .where(
          (s) =>
              _searchQuery.isEmpty ||
              s.title.toLowerCase().contains(_searchQuery) ||
              (s.latin != null &&
                  s.latin!.toLowerCase().contains(_searchQuery)) ||
              (s.translation != null &&
                  s.translation!.toLowerCase().contains(_searchQuery)) ||
              (s.notes != null &&
                  s.notes!.toLowerCase().contains(_searchQuery)),
        )
        .toList();

    final rulesList = PrayerGuideData.rules
        .where(
          (r) =>
              _searchQuery.isEmpty ||
              r.title.toLowerCase().contains(_searchQuery) ||
              r.description.toLowerCase().contains(_searchQuery) ||
              r.points.any((pt) => pt.toLowerCase().contains(_searchQuery)),
        )
        .toList();

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
          isEn ? 'Prayer Guide' : 'Panduan Shalat',
          style: GoogleFonts.poppins(
            color: context.appTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: context.appCardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.appDivider, width: 0.8),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(
                  color: context.appTextPrimary,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: isEn
                      ? 'Search prayer, surah, or step...'
                      : 'Cari shalat, surah pendek, bacaan...',
                  hintStyle: GoogleFonts.poppins(
                    color: context.appTextSecondary,
                    fontSize: 12,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: context.appTextSecondary,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: context.appTextSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // ── Tab Bar ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: context.appCardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.appDivider, width: 0.8),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.appAccent.withValues(alpha: 0.18),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: context.appAccent,
                unselectedLabelColor: context.appTextSecondary,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: isEn ? 'Obligatory' : 'Wajib'),
                  Tab(text: isEn ? 'Sunnah' : 'Sunnah'),
                  Tab(text: isEn ? 'Recitations' : 'Bacaan Shalat'),
                  Tab(text: isEn ? 'Rules' : 'Rukun & Syarat'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Tab Views ────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PrayerListView(items: fardhuList, isEn: isEn),
                _PrayerListView(items: sunnahList, isEn: isEn),
                _RecitationListView(
                  steps: recitationSteps,
                  settings: settings,
                  isEn: isEn,
                ),
                _RuleListView(rules: rulesList),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Prayer List View ─────────────────────────────────────────────────────────

class _PrayerListView extends StatelessWidget {
  final List<PrayerGuideItem> items;
  final bool isEn;

  const _PrayerListView({required this.items, required this.isEn});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: context.appTextSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              isEn ? 'No prayer found' : 'Shalat tidak ditemukan',
              style: GoogleFonts.poppins(
                color: context.appTextSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final prayer = items[index];
        return _PrayerCard(prayer: prayer);
      },
    );
  }
}

// ── Prayer Card ──────────────────────────────────────────────────────────────

class _PrayerCard extends StatelessWidget {
  final PrayerGuideItem prayer;

  const _PrayerCard({required this.prayer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrayerGuideDetailScreen(item: prayer),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              prayer.title,
                              style: GoogleFonts.poppins(
                                color: context.appTextPrimary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            prayer.arabicTitle,
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.amiri(
                              color: context.appAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.appAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              prayer.rakaatNote,
                              style: GoogleFonts.poppins(
                                color: context.appAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              prayer.time,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: context.appTextSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (prayer.recommendedSurahs.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 13,
                              color: context.appAccent,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                prayer.recommendedSurahs
                                    .map(
                                      (s) =>
                                          s.surahName.replaceAll('Surah ', ''),
                                    )
                                    .join(', '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: context.appTextSecondary,
                                  fontSize: 10.5,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.appTextSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Recitation List View (Tab 3) ─────────────────────────────────────────────

class _RecitationListView extends StatelessWidget {
  final List<PrayerGuideStep> steps;
  final SettingsProvider settings;
  final bool isEn;

  const _RecitationListView({
    required this.steps,
    required this.settings,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Center(
        child: Text(
          isEn ? 'No step found' : 'Bacaan tidak ditemukan',
          style: GoogleFonts.poppins(
            color: context.appTextSecondary,
            fontSize: 13,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
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
              Text(
                step.title,
                style: GoogleFonts.poppins(
                  color: context.appTextPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
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
                      height: 1.85,
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
                    height: 1.45,
                  ),
                ),
              ],
              if (step.translation != null && step.translation!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  step.translation!,
                  style: GoogleFonts.poppins(
                    color: context.appTextSecondary,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
              if (step.notes != null && step.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
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
      },
    );
  }
}

// ── Rule List View (Tab 4) ───────────────────────────────────────────────────

class _RuleListView extends StatelessWidget {
  final List<PrayerRuleItem> rules;

  const _RuleListView({required this.rules});

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      return Center(
        child: Text(
          'Tidak ditemukan',
          style: GoogleFonts.poppins(
            color: context.appTextSecondary,
            fontSize: 13,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        final rule = rules[index];
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
              Text(
                rule.title,
                style: GoogleFonts.poppins(
                  color: context.appAccent,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                rule.description,
                style: GoogleFonts.poppins(
                  color: context.appTextSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              for (final pt in rule.points)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 8),
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: context.appAccent,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          pt,
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
            ],
          ),
        );
      },
    );
  }
}
