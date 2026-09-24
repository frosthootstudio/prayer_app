import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/prophet_data.dart';
import '../models/prophet_model.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';
import '../utils/arabic_font_helper.dart';
import 'prophet_detail_screen.dart';

class ProphetListScreen extends StatefulWidget {
  const ProphetListScreen({super.key});

  @override
  State<ProphetListScreen> createState() => _ProphetListScreenState();
}

class _ProphetListScreenState extends State<ProphetListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _onlyUlulAzmi = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isEn = settings.isEnglish;

    final filteredProphets = ProphetData.prophets.where((p) {
      if (_onlyUlulAzmi && !p.isUlulAzmi) return false;
      if (_searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery) ||
          p.arabicName.contains(_searchQuery) ||
          p.era.toLowerCase().contains(_searchQuery) ||
          p.place.toLowerCase().contains(_searchQuery);
    }).toList();

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
          isEn ? '25 Prophets in Islam' : 'Kisah 25 Nabi & Rasul',
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
                      ? 'Search prophet (Ibrahim, Musa, Isa...)'
                      : 'Cari nabi (Ibrahim, Musa, Isa, Muhammad...)',
                  hintStyle: GoogleFonts.poppins(
                    color: context.appTextSecondary,
                    fontSize: 12.5,
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

          // ── Filter Chips ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: isEn ? 'All (25)' : 'Semua (25)',
                  isSelected: !_onlyUlulAzmi,
                  onTap: () => setState(() => _onlyUlulAzmi = false),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '⭐ Ulul Azmi (5)',
                  isSelected: _onlyUlulAzmi,
                  onTap: () => setState(() => _onlyUlulAzmi = true),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Prophet List ─────────────────────────────────────────────────
          Expanded(
            child: filteredProphets.isEmpty
                ? Center(
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
                          isEn ? 'No prophet found' : 'Nabi tidak ditemukan',
                          style: GoogleFonts.poppins(
                            color: context.appTextSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filteredProphets.length,
                    itemBuilder: (context, index) {
                      final prophet = filteredProphets[index];
                      return _ProphetCard(prophet: prophet, isEn: isEn);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? context.appAccent.withValues(alpha: 0.18)
              : context.appCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? context.appAccent : context.appDivider,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? context.appAccent : context.appTextSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Prophet Card ─────────────────────────────────────────────────────────────

class _ProphetCard extends StatelessWidget {
  final ProphetModel prophet;
  final bool isEn;

  const _ProphetCard({required this.prophet, required this.isEn});

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
                builder: (_) => ProphetDetailScreen(prophet: prophet),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Number Circle
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.appAccent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.appAccent.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${prophet.id}',
                    style: GoogleFonts.poppins(
                      color: context.appAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name and details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              prophet.name,
                              style: GoogleFonts.poppins(
                                color: context.appTextPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            prophet.arabicName,
                            textDirection: TextDirection.rtl,
                            style: ArabicFontHelper.getStyle(
                              'amiri_quran',
                              color: context.appAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (prophet.isUlulAzmi) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4A057).withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Ulul Azmi',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFD4A057),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              prophet.era,
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
