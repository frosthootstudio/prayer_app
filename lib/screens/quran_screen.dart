import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;

import '../providers/murottal_provider.dart';
import '../providers/quran_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/arabic_font_helper.dart';
import '../utils/quran_utils.dart';
import 'murottal_screen.dart';
import 'surah_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      // clear search when switching tabs
      if (_tabCtrl.indexIsChanging && _query.isNotEmpty) {
        _searchCtrl.clear();
        setState(() => _query = '');
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qp      = context.watch<QuranProvider>();
    final isEn    = context.watch<SettingsProvider>().isEnglish;
    const gold    = Color(0xFFD4A057);
    final surface = Theme.of(context).colorScheme.surface;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Title ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Al-Qur\'an',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: gold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${quran.totalSurahCount} ${isEn ? 'Surahs' : 'Surah'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Murottal player button
                  Consumer<MurottalProvider>(
                    builder: (_, mp, _) => IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MurottalScreen()),
                      ),
                      icon: Icon(
                        mp.isPlaying
                            ? Icons.graphic_eq_rounded
                            : Icons.headphones_rounded,
                        color: mp.isPlaying ? gold : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                      tooltip: isEn ? 'Murottal Player' : 'Murottal',
                    ),
                  ),
                ],
              ),
            ),

            // ── Search bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: isEn ? 'Search surah…' : 'Cari surah…',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: gold, width: 1.5),
                  ),
                ),
              ),
            ),

            // ── Tab bar ────────────────────────────────────────────────────
            TabBar(
              controller: _tabCtrl,
              labelColor: gold,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: gold,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: [
                Tab(text: isEn ? 'Surah' : 'Surah'),
                Tab(text: isEn ? 'Juz' : 'Juz'),
                Tab(text: isEn ? 'Bookmark' : 'Bookmark'),
              ],
            ),

            // ── Tab content ────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _SurahTab(query: _query, isEn: isEn, qp: qp),
                  _JuzTab(isEn: isEn),
                  _BookmarkTab(qp: qp, isEn: isEn),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Surah tab ─────────────────────────────────────────────────────────────────

class _SurahTab extends StatelessWidget {
  const _SurahTab({required this.query, required this.isEn, required this.qp});

  final String        query;
  final bool          isEn;
  final QuranProvider qp;

  @override
  Widget build(BuildContext context) {
    final surahs      = qp.filteredSurahs(query);
    final showLastRead = query.isEmpty && qp.lastReadSurah != null;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: surahs.length + (showLastRead ? 1 : 0),
      itemBuilder: (context, index) {
        if (showLastRead && index == 0) {
          return _LastReadCard(qp: qp, isEn: isEn);
        }
        final offset = showLastRead ? 1 : 0;
        return _SurahTile(surahNum: surahs[index - offset], isEn: isEn);
      },
    );
  }
}

// ── Last read card ────────────────────────────────────────────────────────────

class _LastReadCard extends StatelessWidget {
  const _LastReadCard({required this.qp, required this.isEn});

  final QuranProvider qp;
  final bool          isEn;

  @override
  Widget build(BuildContext context) {
    final s    = qp.lastReadSurah!;
    final a    = qp.lastReadAyah!;
    const gold = Color(0xFFD4A057);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: InkWell(
        onTap: () => _openSurah(context, s, a),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF2E3150), const Color(0xFF3A3D5C)]
                  : [const Color(0xFFFFF8EE), const Color(0xFFFFEDD5)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: gold.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book_rounded, color: gold, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Continue Reading' : 'Lanjutkan Membaca',
                      style: const TextStyle(
                        fontSize: 11,
                        color: gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${QuranUtils.getSurahDisplayName(s)}  •  ${isEn ? 'Verse' : 'Ayat'} $a',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: gold, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _openSurah(BuildContext context, int s, int a) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SurahScreen(surahNumber: s, startAyah: a)),
    );
  }
}

// ── Surah list tile ───────────────────────────────────────────────────────────

class _SurahTile extends StatelessWidget {
  const _SurahTile({required this.surahNum, required this.isEn});

  final int  surahNum;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    const gold       = Color(0xFFD4A057);
    final arabicFont = context.watch<SettingsProvider>().arabicFont;
    final name    = QuranUtils.getSurahDisplayName(surahNum);
    final meaning = QuranUtils.getSurahMeaning(surahNum, isEn: isEn);
    final arabic  = quran.getSurahNameArabic(surahNum);
    final place   = quran.getPlaceOfRevelation(surahNum);
    final count   = quran.getVerseCount(surahNum);
    final isMakki = place == 'Makkah';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: gold.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: gold.withValues(alpha: 0.4)),
        ),
        alignment: Alignment.center,
        child: Text(
          '$surahNum',
          style: const TextStyle(
            color: Color(0xFFD4A057),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        children: [
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: (isMakki ? Colors.orange : Colors.teal).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isMakki
                  ? (isEn ? 'Makki' : 'Makkiyah')
                  : (isEn ? 'Madani' : 'Madaniyah'),
              style: TextStyle(
                fontSize: 9,
                color: isMakki ? Colors.orange : Colors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        '$meaning  •  ${isEn ? '$count verses' : '$count ayat'}',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(arabic, style: ArabicFontHelper.getStyle(arabicFont, fontSize: 18, color: gold, height: 1.5)),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SurahScreen(surahNumber: surahNum)),
      ),
    );
  }
}

// ── Juz tab ───────────────────────────────────────────────────────────────────

class _JuzTab extends StatelessWidget {
  const _JuzTab({required this.isEn});
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4A057);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: quran.totalJuzCount,
      itemBuilder: (context, index) {
        final juz         = index + 1;
        final surahsInJuz = quran.getSurahAndVersesFromJuz(juz);
        final firstSurah  = surahsInJuz.keys.first;
        final lastSurah   = surahsInJuz.keys.last;
        final firstAyah   = surahsInJuz[firstSurah]!.first;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              '$juz',
              style: const TextStyle(
                color: gold,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          title: Text(
            'Juz $juz',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            firstSurah == lastSurah
                ? QuranUtils.getSurahDisplayName(firstSurah)
                : '${QuranUtils.getSurahDisplayName(firstSurah)} – ${QuranUtils.getSurahDisplayName(lastSurah)}',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahScreen(surahNumber: firstSurah, startAyah: firstAyah),
            ),
          ),
        );
      },
    );
  }
}

// ── Bookmark tab ──────────────────────────────────────────────────────────────

class _BookmarkTab extends StatelessWidget {
  const _BookmarkTab({required this.qp, required this.isEn});

  final QuranProvider qp;
  final bool          isEn;

  @override
  Widget build(BuildContext context) {
    if (qp.bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_outline_rounded,
              size: 52,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              isEn ? 'No bookmarks yet' : 'Belum ada bookmark',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              isEn ? 'Long press any verse to bookmark' : 'Tekan lama ayat untuk menandainya',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: qp.bookmarks.length,
      itemBuilder: (context, index) {
        final bm = qp.bookmarks[index];
        final arabic = quran.getVerse(bm.surah, bm.ayah);

        return Dismissible(
          key: Key(bm.toKey()),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => qp.toggleBookmark(bm.surah, bm.ayah),
          background: Container(
            color: Colors.red.shade800,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: const Icon(Icons.bookmark_rounded, color: Color(0xFFD4A057)),
            title: Text(
              '${QuranUtils.getSurahDisplayName(bm.surah)}  :  ${isEn ? 'Verse' : 'Ayat'} ${bm.ayah}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              arabic,
              style: ArabicFontHelper.getStyle(context.watch<SettingsProvider>().arabicFont, fontSize: 13, height: 1.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SurahScreen(surahNumber: bm.surah, startAyah: bm.ayah),
              ),
            ),
          ),
        );
      },
    );
  }
}
