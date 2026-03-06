import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/murottal_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/mini_player.dart';
import 'calendar_screen.dart';
import 'dzikir_screen.dart';
import 'home_screen.dart';
import 'qibla_screen.dart';
import 'quran_screen.dart';
import 'settings_screen.dart';
import 'tracking_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bgColor  = Theme.of(context).scaffoldBackgroundColor;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                HomeScreen(
                  onNavigateToTracking: () => setState(() => _selectedIndex = 4),
                ),
                const QiblaScreen(),
                const CalendarScreen(),
                const QuranScreen(),
                const TrackingScreen(),
                const DzikirScreen(),
                const SettingsScreen(),
              ],
            ),
          ),
          // Mini player — visible only when MurottalProvider has an active track
          Consumer<MurottalProvider>(
            builder: (_, mp, _) => mp.currentSurah != null
                ? const MiniPlayer()
                : const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onSelect: (i) => setState(() => _selectedIndex = i),
        bgColor: bgColor,
        items: [
          _NavItemData(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: settings.getLabel('home'),
          ),
          _NavItemData(
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore_rounded,
            label: settings.getLabel('qibla'),
          ),
          _NavItemData(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month_rounded,
            label: settings.getLabel('kalender'),
          ),
          _NavItemData(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book_rounded,
            label: settings.getLabel('quran'),
          ),
          _NavItemData(
            icon: Icons.checklist_outlined,
            activeIcon: Icons.checklist_rounded,
            label: settings.getLabel('ibadah'),
          ),
          _NavItemData(
            icon: Icons.auto_stories_outlined,
            activeIcon: Icons.auto_stories_rounded,
            label: settings.getLabel('dzikir'),
          ),
          _NavItemData(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            label: settings.getLabel('settings'),
          ),
        ],
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ── Container ─────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int                selectedIndex;
  final ValueChanged<int>  onSelect;
  final Color              bgColor;
  final List<_NavItemData> items;

  const _BottomNav({
    required this.selectedIndex,
    required this.onSelect,
    required this.bgColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                _NavButton(
                  data: items[i],
                  isSelected: selectedIndex == i,
                  onTap: () => onSelect(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Item ──────────────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final _NavItemData data;
  final bool         isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4A057);
    final grey = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF6E7090)
        : const Color(0xFFB09880);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor:    gold.withValues(alpha: 0.12),
        highlightColor: gold.withValues(alpha: 0.07),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon — swaps between outlined and filled
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                isSelected ? data.activeIcon : data.icon,
                key:   ValueKey(isSelected),
                color: isSelected ? gold : grey,
                size:  24,
              ),
            ),
            // Label — slides in/out below icon
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        data.label,
                        style: const TextStyle(
                          color: gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
