import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;

import '../providers/murottal_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/quran_utils.dart';

class MurottalScreen extends StatelessWidget {
  const MurottalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mp     = context.watch<MurottalProvider>();
    final isEn   = context.watch<SettingsProvider>().isEnglish;
    const gold   = Color(0xFFD4A057);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    final surah      = mp.currentSurah;
    final ayah       = mp.currentAyah;
    final ayahCount  = surah != null ? quran.getVerseCount(surah) : 0;
    final surahArabic = surah != null ? quran.getSurahNameArabic(surah) : '';
    final surahName   = surah != null ? QuranUtils.getSurahDisplayName(surah) : (isEn ? 'No track' : 'Belum diputar');

    final pos = mp.position;
    final dur = mp.duration;
    final progress = (dur.inMilliseconds > 0)
        ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEn ? 'Murottal Player' : 'Murottal',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Reciter picker
          TextButton.icon(
            onPressed: () => _showReciterPicker(context, mp, isEn),
            icon: const Icon(Icons.person_rounded, size: 18, color: gold),
            label: Text(
              mp.reciter.displayName.split(' ').first,
              style: const TextStyle(color: gold, fontSize: 12),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Now playing card ───────────────────────────────────────────
          Flexible(
            flex: 9,
            fit: FlexFit.tight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Surah display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF2E3150), const Color(0xFF252840)]
                            : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: gold.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        if (surahArabic.isNotEmpty)
                          Text(
                            surahArabic,
                            style: GoogleFonts.amiri(fontSize: 36, color: gold),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          surahName,
                          style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ayah != null
                              ? '${isEn ? 'Ayah' : 'Ayat'} $ayah / $ayahCount'
                              : mp.reciter.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Progress bar ─────────────────────────────────────────
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: gold,
                      inactiveTrackColor: gold.withValues(alpha: 0.2),
                      thumbColor: gold,
                      overlayColor: gold.withValues(alpha: 0.15),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: progress,
                      onChanged: dur.inMilliseconds > 0
                          ? (v) => mp.seek(
                                Duration(
                                  milliseconds: (v * dur.inMilliseconds).round(),
                                ),
                              )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmt(pos), style: const TextStyle(fontSize: 11)),
                        Text(_fmt(dur), style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Main controls ─────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Prev ayah
                      IconButton(
                        onPressed: mp.currentAyah != null && mp.currentAyah! > 1
                            ? mp.prevAyah
                            : null,
                        icon: const Icon(Icons.skip_previous_rounded),
                        iconSize: 32,
                        color: gold,
                      ),
                      // Rewind 10s
                      IconButton(
                        onPressed: mp.currentSurah != null ? mp.rewind : null,
                        icon: const Icon(Icons.replay_10_rounded),
                        iconSize: 28,
                        color: gold,
                      ),
                      // Play / Pause
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: mp.currentSurah != null ? mp.togglePlayPause : null,
                        child: Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            color: mp.currentSurah != null
                                ? gold
                                : gold.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: gold.withValues(alpha: 0.4),
                                blurRadius: 12, offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: mp.isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(18),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  mp.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Forward 10s
                      IconButton(
                        onPressed: mp.currentSurah != null ? mp.forward : null,
                        icon: const Icon(Icons.forward_10_rounded),
                        iconSize: 28,
                        color: gold,
                      ),
                      // Next ayah
                      IconButton(
                        onPressed: (mp.currentSurah != null &&
                                mp.currentAyah != null &&
                                mp.currentAyah! < mp.currentAyahCount)
                            ? mp.nextAyah
                            : null,
                        icon: const Icon(Icons.skip_next_rounded),
                        iconSize: 32,
                        color: gold,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Repeat + Speed ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Repeat toggle
                      _RepeatButton(mp: mp, isEn: isEn),
                      const SizedBox(width: 24),
                      // Speed selector
                      _SpeedButton(mp: mp),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Surah selector ─────────────────────────────────────────────
          Flexible(
            flex: 11,
            fit: FlexFit.tight,
            child: SafeArea(
            top: false,
            child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2038) : const Color(0xFFF5EFE8),
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    isEn ? 'Select Surah' : 'Pilih Surah',
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: gold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: quran.totalSurahCount,
                    itemBuilder: (context, i) {
                      final s = i + 1;
                      final isActive = s == mp.currentSurah;
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        leading: Text(
                          '$s',
                          style: TextStyle(
                            color: isActive ? gold : null,
                            fontWeight: isActive ? FontWeight.bold : null,
                            fontSize: 12,
                          ),
                        ),
                        title: Text(
                          QuranUtils.getSurahDisplayName(s),
                          style: TextStyle(
                            fontSize: 13,
                            color: isActive ? gold : null,
                            fontWeight: isActive ? FontWeight.bold : null,
                          ),
                        ),
                        trailing: isActive
                            ? const Icon(Icons.graphic_eq_rounded, color: gold, size: 16)
                            : null,
                        onTap: () => mp.playSurahFromStart(s),
                      );
                    },
                  ),
                ),
              ],
            ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showReciterPicker(BuildContext context, MurottalProvider mp, bool isEn) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(8, 16, 8, MediaQuery.viewPaddingOf(ctx).bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isEn ? 'Select Reciter' : 'Pilih Qari',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...Reciter.values.map(
              (r) => ListTile(
                leading: Icon(
                  Icons.mic_rounded,
                  color: r == mp.reciter
                      ? const Color(0xFFD4A057)
                      : null,
                ),
                title: Text(r.displayName),
                trailing: r == mp.reciter
                    ? const Icon(Icons.check_rounded, color: Color(0xFFD4A057))
                    : null,
                onTap: () {
                  mp.setReciter(r);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Repeat button ─────────────────────────────────────────────────────────────

class _RepeatButton extends StatelessWidget {
  const _RepeatButton({required this.mp, required this.isEn});
  final MurottalProvider mp;
  final bool             isEn;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4A057);

    final (icon, label) = switch (mp.repeatMode) {
      MurottalRepeat.off   => (Icons.repeat_rounded,      isEn ? 'Off'   : 'Mati'),
      MurottalRepeat.ayah  => (Icons.repeat_one_rounded,  isEn ? 'Ayah'  : 'Ayat'),
      MurottalRepeat.surah => (Icons.repeat_rounded,      isEn ? 'Surah' : 'Surah'),
    };
    final isActive = mp.repeatMode != MurottalRepeat.off;

    return GestureDetector(
      onTap: () => mp.setMurottalRepeat(
        switch (mp.repeatMode) {
          MurottalRepeat.off   => MurottalRepeat.ayah,
          MurottalRepeat.ayah  => MurottalRepeat.surah,
          MurottalRepeat.surah => MurottalRepeat.off,
        },
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? gold.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? gold : Theme.of(context).colorScheme.outline,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? gold : null),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? gold : null,
                fontWeight: isActive ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Speed button ──────────────────────────────────────────────────────────────

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.mp});
  final MurottalProvider mp;

  static const _speeds = [0.75, 1.0, 1.25, 1.5];

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4A057);

    return GestureDetector(
      onTap: () {
        final idx   = _speeds.indexOf(mp.speed);
        final next  = _speeds[(idx + 1) % _speeds.length];
        mp.setSpeed(next);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: mp.speed != 1.0 ? gold.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: mp.speed != 1.0 ? gold : Theme.of(context).colorScheme.outline,
            width: mp.speed != 1.0 ? 1.5 : 1,
          ),
        ),
        child: Text(
          '${mp.speed}x',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: mp.speed != 1.0 ? gold : null,
          ),
        ),
      ),
    );
  }
}
