import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;

import '../providers/murottal_provider.dart';
import '../screens/murottal_screen.dart';
import '../utils/quran_utils.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MurottalProvider>();
    if (mp.currentSurah == null) return const SizedBox.shrink();

    const gold   = Color(0xFFD4A057);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF252840) : const Color(0xFFFFF3E0);

    final surahName = QuranUtils.getSurahDisplayName(mp.currentSurah!);
    final ayah      = mp.currentAyah ?? 1;
    final ayahCount = quran.getVerseCount(mp.currentSurah!);
    final progress  = mp.duration.inMilliseconds > 0
        ? (mp.position.inMilliseconds / mp.duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MurottalScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            top: BorderSide(color: gold.withValues(alpha: 0.3), width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress line
            LinearProgressIndicator(
              value: progress,
              minHeight: 2,
              backgroundColor: gold.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(gold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Music icon
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.music_note_rounded, color: gold, size: 18),
                  ),
                  const SizedBox(width: 12),
                  // Track info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surahName,
                          style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${mp.reciter.displayName.split(' ').first}  •  Ayat $ayah/$ayahCount',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Prev
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: const Icon(Icons.skip_previous_rounded, size: 22),
                    color: gold,
                    onPressed: mp.currentAyah != null && mp.currentAyah! > 1
                        ? mp.prevAyah
                        : null,
                  ),
                  // Play/Pause
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    icon: mp.isLoading
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: gold,
                            ),
                          )
                        : Icon(
                            mp.isPlaying
                                ? Icons.pause_circle_rounded
                                : Icons.play_circle_rounded,
                            size: 32,
                          ),
                    color: gold,
                    onPressed: mp.togglePlayPause,
                  ),
                  // Next
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: const Icon(Icons.skip_next_rounded, size: 22),
                    color: gold,
                    onPressed: (mp.currentAyah != null &&
                            mp.currentAyah! < ayahCount)
                        ? mp.nextAyah
                        : null,
                  ),
                  // Close
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: mp.stop,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
