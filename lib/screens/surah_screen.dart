import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;

import '../data/transliteration_data.dart';
import '../providers/murottal_provider.dart';
import '../providers/quran_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/arabic_font_helper.dart';
import '../utils/quran_utils.dart';

class SurahScreen extends StatefulWidget {
  const SurahScreen({
    super.key,
    required this.surahNumber,
    this.startAyah = 1,
  });

  final int surahNumber;
  final int startAyah;

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  late ScrollController _scrollCtrl;
  late int _surah;
  List<String>? _fetchedTranslit; // null = loading; non-null = done (may be empty on error)
  bool _translitFailed = false;
  List<String>? _uthmaniText;

  @override
  void initState() {
    super.initState();
    _surah    = widget.surahNumber;
    _scrollCtrl = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Save last read
      context.read<QuranProvider>().setLastRead(_surah, widget.startAyah);
      _loadTransliteration(_surah);
      _loadUthmaniText(_surah);
      // Scroll to approximate position of startAyah
      if (widget.startAyah > 1 && _scrollCtrl.hasClients) {
        final offset = _estimateOffset(widget.startAyah);
        _scrollCtrl.jumpTo(
          offset.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  double _estimateOffset(int ayah) {
    final hasBismillah = _surah != 1 && _surah != 9;
    return 140.0 + (hasBismillah ? 60.0 : 0) + (ayah - 1) * 160.0;
  }

  void _loadTransliteration(int surahNumber) {
    if (TransliterationData.hasSurah(surahNumber)) return; // local data sufficient
    setState(() => _translitFailed = false);
    context
        .read<QuranProvider>()
        .fetchTransliteration(surahNumber)
        .then((list) {
      if (mounted) {
        setState(() {
          _fetchedTranslit = list ?? [];
          _translitFailed  = list == null;
        });
      }
    });
  }

  void _loadUthmaniText(int surahNumber) {
    context
        .read<QuranProvider>()
        .fetchUthmaniText(surahNumber)
        .then((list) {
      if (mounted && list != null) {
        setState(() => _uthmaniText = list);
      }
    });
  }

  void _navigateSurah(int delta) {
    final next = _surah + delta;
    if (next < 1 || next > quran.totalSurahCount) return;
    setState(() {
      _surah           = next;
      _fetchedTranslit = null;
      _translitFailed  = false;
      _uthmaniText     = null;
      _scrollCtrl.jumpTo(0);
    });
    context.read<QuranProvider>().setLastRead(next, 1);
    _loadTransliteration(next);
    _loadUthmaniText(next);
  }

  void _showReadingPrefs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Consumer<QuranProvider>(
        builder: (ctx, qp, _) {
          final sp   = ctx.watch<SettingsProvider>();
          final isEn = sp.isEnglish;
          const gold = Color(0xFFD4A057);
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.75,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.viewPaddingOf(ctx).bottom + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Handle
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.outline.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isEn ? 'Reading Settings' : 'Pengaturan Baca',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Font size
                Row(
                  children: [
                    const Icon(Icons.text_fields_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(isEn ? 'Arabic Font Size' : 'Ukuran Font Arab'),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${sp.arabicFontSize.round()}',
                        style: const TextStyle(
                          color: gold, fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: sp.arabicFontSize,
                  min: 18, max: 36, divisions: 18,
                  activeColor: gold,
                  onChanged: (v) => ctx.read<SettingsProvider>().setArabicFontSize(v),
                ),
                // Font family
                const SizedBox(height: 4),
                Text(
                  isEn ? 'Arabic Font' : 'Font Arab',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ArabicFontHelper.availableFonts.map((f) {
                    final key      = f['key']!;
                    final selected = sp.arabicFont == key;
                    return GestureDetector(
                      onTap: () => ctx.read<SettingsProvider>().setArabicFont(key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? gold.withValues(alpha: 0.15) : Colors.transparent,
                          border: Border.all(
                            color: selected ? gold : Theme.of(ctx).colorScheme.outline.withValues(alpha: 0.4),
                            width: selected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f['name']!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                color: selected ? gold : null,
                              ),
                            ),
                            Text(
                              isEn ? f['descEn']! : f['descId']!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Show transliteration
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(isEn ? 'Show Transliteration' : 'Tampilkan Transliterasi'),
                  value: qp.showTranslit,
                  activeThumbColor: gold,
                  onChanged: (_) => qp.toggleTranslit(),
                ),
                // Show translation
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(isEn ? 'Show Translation' : 'Tampilkan Terjemahan'),
                  value: qp.showTranslation,
                  activeThumbColor: gold,
                  onChanged: (_) => qp.toggleTranslation(),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qp     = context.watch<QuranProvider>();
    final mp     = context.watch<MurottalProvider>();
    final sp     = context.watch<SettingsProvider>();
    final isEn   = sp.isEnglish;
    const gold   = Color(0xFFD4A057);
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    final ayahCount    = quran.getVerseCount(_surah);
    final surahName    = QuranUtils.getSurahDisplayName(_surah);
    final surahArabic  = quran.getSurahNameArabic(_surah);
    final place        = quran.getPlaceOfRevelation(_surah);
    final hasBismillah = _surah != 1 && _surah != 9;
    final headerCount  = hasBismillah ? 2 : 1;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(surahName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(
              '$place  •  $ayahCount ${isEn ? 'verses' : 'ayat'}',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Text(surahArabic, style: ArabicFontHelper.getStyle(sp.arabicFont, fontSize: 18, color: gold, height: 1.5)),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 22),
            onPressed: () => _showReadingPrefs(context),
          ),
        ],
      ),

      // ── Bottom prev/next bar ───────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                // Prev surah
                Expanded(
                  child: TextButton.icon(
                    onPressed: _surah > 1 ? () => _navigateSurah(-1) : null,
                    icon: const Icon(Icons.chevron_left_rounded, size: 20),
                    label: Text(
                      _surah > 1
                          ? QuranUtils.getSurahDisplayName(_surah - 1)
                          : (isEn ? 'First Surah' : 'Surah Pertama'),
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: _surah > 1
                          ? gold
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  width: 1, height: 24,
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
                // Next surah
                Expanded(
                  child: TextButton.icon(
                    onPressed: _surah < quran.totalSurahCount
                        ? () => _navigateSurah(1)
                        : null,
                    icon: Text(
                      _surah < quran.totalSurahCount
                          ? QuranUtils.getSurahDisplayName(_surah + 1)
                          : (isEn ? 'Last Surah' : 'Surah Terakhir'),
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    label: const Icon(Icons.chevron_right_rounded, size: 20),
                    style: TextButton.styleFrom(
                      foregroundColor: _surah < quran.totalSurahCount
                          ? gold
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: headerCount + ayahCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _SurahHeader(
              surah: _surah,
              surahArabic: surahArabic,
              surahName: surahName,
              place: place,
              ayahCount: ayahCount,
            );
          }
          if (hasBismillah && index == 1) {
            return _Bismillah();
          }
          final ayah = index - headerCount + 1;
          return _AyahTile(
            surah:          _surah,
            ayah:           ayah,
            qp:             qp,
            mp:             mp,
            isEn:           isEn,
            isHighlighted:  ayah == widget.startAyah && widget.startAyah > 1,
            fetchedTranslit: _fetchedTranslit,
            translitFailed: _translitFailed,
            uthmaniText:    _uthmaniText,
          );
        },
      ),
    );
  }
}

// ── Surah header ──────────────────────────────────────────────────────────────

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({
    required this.surah,
    required this.surahArabic,
    required this.surahName,
    required this.place,
    required this.ayahCount,
  });

  final int    surah;
  final String surahArabic;
  final String surahName;
  final String place;
  final int    ayahCount;

  @override
  Widget build(BuildContext context) {
    const gold      = Color(0xFFD4A057);
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final arabicFont = context.watch<SettingsProvider>().arabicFont;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2E3150), const Color(0xFF252840)]
              : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            surahArabic,
            style: ArabicFontHelper.getStyle(arabicFont, fontSize: 32, color: gold),
          ),
          const SizedBox(height: 4),
          Text(
            surahName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$place  •  Surah $surah',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bismillah ─────────────────────────────────────────────────────────────────

class _Bismillah extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4A057);
    final sp   = context.watch<SettingsProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        quran.basmala,
        textAlign: TextAlign.center,
        style: ArabicFontHelper.getStyle(
          sp.arabicFont,
          fontSize: sp.arabicFontSize,
          color: gold,
        ),
      ),
    );
  }
}

// ── Ayah tile ─────────────────────────────────────────────────────────────────

class _AyahTile extends StatelessWidget {
  const _AyahTile({
    required this.surah,
    required this.ayah,
    required this.qp,
    required this.mp,
    required this.isEn,
    this.isHighlighted = false,
    this.fetchedTranslit,
    this.translitFailed = false,
    this.uthmaniText,
  });

  final int              surah;
  final int              ayah;
  final QuranProvider    qp;
  final MurottalProvider mp;
  final bool             isEn;
  final bool             isHighlighted;
  final List<String>?    fetchedTranslit;
  final bool             translitFailed;
  final List<String>?    uthmaniText;

  @override
  Widget build(BuildContext context) {
    const gold         = Color(0xFFD4A057);
    final arabicText   = (uthmaniText != null && ayah - 1 < uthmaniText!.length)
        ? uthmaniText![ayah - 1]
        : quran.getVerse(surah, ayah);
    final translation  = quran.getVerseTranslation(
      surah, ayah, translation: quran.Translation.indonesian,
    );
    final translit = TransliterationData.hasSurah(surah)
        ? TransliterationData.get(surah, ayah)
        : (fetchedTranslit != null && ayah <= fetchedTranslit!.length
            ? fetchedTranslit![ayah - 1]
            : null);
    final isBookmarked  = qp.isBookmarked(surah, ayah);
    final isPlayingThis = mp.isPlayingAyah(surah, ayah);
    final isDark        = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () => _showActions(context, arabicText, translation),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: (isHighlighted || isPlayingThis)
            ? BoxDecoration(
                color: gold.withValues(alpha: isDark ? 0.08 : 0.06),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Action bar ──────────────────────────────────────────────
              Row(
                children: [
                  // Ayah number badge
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: isPlayingThis ? gold : gold.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$ayah',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Bookmark
                  GestureDetector(
                    onTap: () => qp.toggleBookmark(surah, ayah),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        color: isBookmarked
                            ? gold
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Play / pause
                  GestureDetector(
                    onTap: () => mp.playAyah(surah, ayah),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: isPlayingThis && mp.isLoading
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: gold,
                              ),
                            )
                          : Icon(
                              isPlayingThis && mp.isPlaying
                                  ? Icons.pause_circle_outline_rounded
                                  : Icons.play_circle_outline_rounded,
                              color: isPlayingThis
                                  ? gold
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              size: 22,
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Arabic text ─────────────────────────────────────────────
              Selector<SettingsProvider, ({String font, double size})>(
                selector: (_, s) => (font: s.arabicFont, size: s.arabicFontSize),
                builder: (ctx, cfg, _) => Text(
                  arabicText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: ArabicFontHelper.getStyle(
                    cfg.font,
                    fontSize: cfg.size,
                    height: 2.0,
                    color: Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
              ),

              // ── Transliteration ─────────────────────────────────────────
              if (qp.showTranslit) ...[
                if (translit != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    translit,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                      color: Theme.of(context).colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ] else if (translitFailed && ayah == 1 &&
                    !TransliterationData.hasSurah(surah)) ...[
                  const SizedBox(height: 6),
                  Text(
                    isEn
                        ? 'Transliteration unavailable — tap refresh'
                        : 'Latin tidak tersedia, coba refresh',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],

              // ── Translation ─────────────────────────────────────────────
              if (qp.showTranslation) ...[
                const SizedBox(height: 8),
                Text(
                  translation,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],

              const SizedBox(height: 4),
              Divider(
                height: 20, thickness: 0.5,
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActions(BuildContext context, String arabicText, String translation) {
    const gold = Color(0xFFD4A057);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isEnLocal = ctx.read<SettingsProvider>().isEnglish;
        return Padding(
          padding: EdgeInsets.fromLTRB(8, 12, 8, MediaQuery.viewPaddingOf(ctx).bottom + 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  qp.isBookmarked(surah, ayah)
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: gold,
                ),
                title: Text(
                  qp.isBookmarked(surah, ayah)
                      ? (isEnLocal ? 'Remove Bookmark' : 'Hapus Bookmark')
                      : (isEnLocal ? 'Add Bookmark' : 'Tambah Bookmark'),
                ),
                onTap: () {
                  qp.toggleBookmark(surah, ayah);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: Text(isEnLocal ? 'Copy Arabic Text' : 'Salin Teks Arab'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: arabicText));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEnLocal ? 'Copied' : 'Disalin'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.translate_rounded),
                title: Text(isEnLocal ? 'Copy Translation' : 'Salin Terjemahan'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: translation));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEnLocal ? 'Copied' : 'Disalin'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.play_circle_outline_rounded),
                title: Text(isEnLocal ? 'Play Audio' : 'Putar Audio'),
                onTap: () {
                  Navigator.pop(ctx);
                  mp.playAyah(surah, ayah);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
