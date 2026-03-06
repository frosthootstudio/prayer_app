import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/dzikir_data.dart';
import '../models/dzikir_model.dart';
import '../providers/dzikir_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';

class DzikirScreen extends StatelessWidget {
  const DzikirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isEn = settings.isEnglish;
    final accent = context.appAccent;
    final faded = context.appTextFaded;

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text(settings.getLabel('dzikir')),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              tooltip: isEn ? 'Reset All' : 'Reset Semua',
              onPressed: () => _showResetDialog(context, isEn),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: accent,
            unselectedLabelColor: faded,
            indicatorColor: accent,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: isEn ? '⭐ Favorites' : '⭐ Favorit'),
              Tab(text: isEn ? '🌅 Morning' : '🌅 Pagi'),
              Tab(text: isEn ? '🌆 Evening' : '🌆 Petang'),
              Tab(text: isEn ? '🕌 After Prayer' : '🕌 Setelah Shalat'),
              Tab(text: isEn ? '🌙 Bedtime' : '🌙 Tidur'),
              const Tab(text: '🤲 Doa'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CategoryTabView(category: 'favorit', isEn: isEn),
            _CategoryTabView(category: 'pagi', isEn: isEn),
            _CategoryTabView(category: 'petang', isEn: isEn),
            _CategoryTabView(category: 'setelah_shalat', isEn: isEn),
            _CategoryTabView(category: 'tidur', isEn: isEn),
            _CategoryTabView(category: 'doa', isEn: isEn),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, bool isEn) {
    final provider = context.read<DzikirProvider>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEn ? 'Reset All Counters?' : 'Reset Semua?'),
        content: Text(
          isEn
              ? 'All dzikir counters will be reset to zero.'
              : 'Semua hitungan dzikir akan direset ke nol.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEn ? 'Cancel' : 'Batal'),
          ),
          TextButton(
            onPressed: () {
              provider.resetAll();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ── Category Tab View ──────────────────────────────────────────────────────

class _CategoryTabView extends StatelessWidget {
  const _CategoryTabView({required this.category, required this.isEn});
  final String category;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DzikirProvider>();
    final items = category == 'favorit'
        ? DzikirData.all.where((i) => provider.isFavorite(i.id)).toList()
        : DzikirData.all.where((i) => i.category == category).toList();

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border_rounded, size: 52, color: context.appTextFaded),
            const SizedBox(height: 14),
            Text(
              isEn ? 'No favorites yet' : 'Belum ada favorit',
              style: TextStyle(color: context.appTextFaded, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              isEn ? 'Tap ♡ on any dzikir to add it here' : 'Tap ♡ pada dzikir untuk menambahkan di sini',
              style: TextStyle(color: context.appTextFaded, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: items.length,
      itemBuilder: (context, index) => _DzikirItemCard(
        item: items[index],
        provider: provider,
        isEn: isEn,
      ),
    );
  }
}

// ── Dzikir Item Card ───────────────────────────────────────────────────────

class _DzikirItemCard extends StatelessWidget {
  const _DzikirItemCard({
    required this.item,
    required this.provider,
    required this.isEn,
  });
  final DzikirItem item;
  final DzikirProvider provider;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final current = provider.getCount(item.id);
    final isFav = provider.isFavorite(item.id);
    final done = current >= item.count;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: context.appCardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.appDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.appTextPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.count == 1
                            ? (isEn ? 'Read once' : '1x')
                            : '${item.count}x',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.appTextFaded,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => provider.toggleFavorite(item.id),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? Colors.red.shade400 : context.appTextFaded,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Arabic text
            Text(
              item.arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 22,
                height: 2.0,
                color: context.appTextPrimary,
              ),
            ),

            const SizedBox(height: 10),

            // ── Latin transliteration
            Text(
              item.latin,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: context.appTextSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 6),

            // ── Translation
            Text(
              item.translation,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: context.appTextFaded,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 14),
            Divider(color: context.appDivider, height: 1),
            const SizedBox(height: 12),

            // ── Counter / toggle section
            _CounterSection(
              item: item,
              current: current,
              done: done,
              provider: provider,
              isEn: isEn,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Counter Section ────────────────────────────────────────────────────────

class _CounterSection extends StatelessWidget {
  const _CounterSection({
    required this.item,
    required this.current,
    required this.done,
    required this.provider,
    required this.isEn,
  });
  final DzikirItem item;
  final int current;
  final bool done;
  final DzikirProvider provider;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final accent = context.appAccent;

    // ── Single-read items (count == 1): toggle style
    if (item.count == 1) {
      return Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: done ? Colors.green.shade600 : context.appTextFaded,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              done
                  ? (isEn ? 'Done' : 'Selesai')
                  : (isEn ? 'Not read yet' : 'Belum dibaca'),
              style: TextStyle(
                color: done ? Colors.green.shade600 : context.appTextFaded,
                fontSize: 13,
                fontWeight: done ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (done)
            TextButton(
              onPressed: () => provider.reset(item.id),
              style: TextButton.styleFrom(
                foregroundColor: context.appTextFaded,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(
                isEn ? 'Read Again' : 'Baca Lagi',
                style: const TextStyle(fontSize: 12),
              ),
            )
          else
            FilledButton(
              onPressed: () => provider.increment(item.id),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              ),
              child: Text(
                isEn ? 'Done' : 'Selesai',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      );
    }

    // ── Counter items (count > 1)
    final progress = current / item.count;
    final progressColor = done ? Colors.green.shade600 : accent;

    return Row(
      children: [
        // Reset button
        SizedBox(
          width: 36,
          height: 36,
          child: IconButton(
            icon: Icon(Icons.refresh_rounded, size: 18, color: context.appTextFaded),
            onPressed: current > 0 ? () => provider.reset(item.id) : null,
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            tooltip: 'Reset',
          ),
        ),

        const SizedBox(width: 8),

        // Count + progress bar
        Expanded(
          child: Column(
            children: [
              Text(
                '$current / ${item.count}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: done ? Colors.green.shade600 : context.appTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: context.appDivider,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // +/check button
        GestureDetector(
          onTap: done ? null : () => provider.increment(item.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: done ? Colors.green.shade600 : accent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              done ? Icons.check_rounded : Icons.add_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
