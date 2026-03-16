import 'package:flutter/material.dart';

/// All colors used in the Waktu Shalat app.
///
/// Copy this file into any Flutter project.
/// Theme-aware colors are defined as extensions on [BuildContext].
/// Static colors are defined as constants on [AppColors].
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────

  /// Primary accent — dark theme (warm gold).
  static const Color goldDark = Color(0xFFD4A057);

  /// Primary accent — light theme (warm orange).
  static const Color goldLight = Color(0xFFCE7E50);

  // ── Scaffold Backgrounds ───────────────────────────────────────────────────

  static const Color scaffoldDark = Color(0xFF1A1C2E);
  static const Color scaffoldLight = Color(0xFFFBF6F0);

  // ── Card / Surface Backgrounds ─────────────────────────────────────────────

  static const Color cardDark = Color(0xFF252840);
  static const Color cardLight = Color(0xFFFAF3EC);

  static const Color sheetDark = Color(0xFF1E2138);
  static const Color sheetLight = Color(0xFFFBF6F0);

  static const Color elevatedDark = Color(0xFF2A2D45);
  static const Color elevatedLight = Color(0xFFF5EDE4);

  static const Color cardWarmDark = Color(0xFF252038);
  static const Color cardWarmLight = Color(0xFFF2D9C4);

  static const Color cardNextDark = Color(0xFF1E2138);
  static const Color cardNextLight = Color(0xFFF8EFE4);

  // ── Dividers / Borders ─────────────────────────────────────────────────────

  static const Color dividerDark = Color(0xFF2E3150);
  static const Color dividerLight = Color(0xFFF0E8DE);

  static const Color sunDividerDark = Color(0xFF2E3150);
  static const Color sunDividerLight = Color(0xFFE8D9C8);

  // ── Text ───────────────────────────────────────────────────────────────────

  static const Color textPrimaryDark = Color(0xFFE8E8F0);
  static const Color textPrimaryLight = Color(0xFF2A1A0E);

  static const Color textSecondaryDark = Color(0xFFB0B3C6);
  static const Color textSecondaryLight = Color(0xFF8B6545);

  static const Color textFadedDark = Color(0xFF6E7090);
  static const Color textFadedLight = Color(0xFFBBA88A);

  // ── Icon / Indicator States ────────────────────────────────────────────────

  static const Color iconPassedBgDark = Color(0xFF2A2D45);
  static const Color iconPassedBgLight = Color(0xFFF3EDE6);

  static const Color iconPassedFgDark = Color(0xFF6E7090);
  static const Color iconPassedFgLight = Color(0xFFCBB89E);

  static const Color bellOffDark = Color(0xFF4A4D65);
  static const Color bellOffLight = Color(0xFFCCC0B5);

  static const Color sheetHandleDark = Color(0xFF4A4D65);
  static const Color sheetHandleLight = Color(0xFFD4C0AE);

  // ── Navigation Bar ─────────────────────────────────────────────────────────

  static const Color navInactiveDark = Color(0xFF6E7090);
  static const Color navInactiveLight = Color(0xFFB09880);

  // ── Prayer Time Icon Colors ─────────────────────────────────────────────────

  // Backgrounds (light tints)
  static const Color fajrBg = Color(0xFFEEF2FF);
  static const Color sunriseBg = Color(0xFFFFFBEB);
  static const Color dhuhrBg = Color(0xFFFFF7ED);
  static const Color asrBg = Color(0xFFECFDF5);
  static const Color maghribBg = Color(0xFFFFF1F2);
  static const Color ishaBg = Color(0xFFF5F3FF);
  static const Color defaultPrayerBg = Color(0xFFF5F5F5);

  // Foregrounds (vivid)
  static const Color fajrFg = Color(0xFF6366F1);    // Indigo 500
  static const Color sunriseFg = Color(0xFFF59E0B); // Amber 500
  static const Color dhuhrFg = Color(0xFFF97316);   // Orange 500
  static const Color asrFg = Color(0xFF10B981);     // Emerald 500
  static const Color maghribFg = Color(0xFFF43F5E); // Rose 500
  static const Color ishaFg = Color(0xFF8B5CF6);    // Violet 500

  // ── Tracking / Category Colors ─────────────────────────────────────────────

  static const Color catMalam = Color(0xFF8B5CF6);    // Violet 500
  static const Color catSubuh = Color(0xFF6366F1);    // Indigo 500
  static const Color catPagi = Color(0xFFF59E0B);     // Amber 500
  static const Color catZuhur = Color(0xFFF97316);    // Orange 500
  static const Color catAshar = Color(0xFF10B981);    // Emerald 500
  static const Color catPetang = Color(0xFFF43F5E);   // Rose 500
  static const Color catMaghrib = Color(0xFFEF4444);  // Red 500
  static const Color catIsya = Color(0xFF7C3AED);     // Violet 600
  static const Color catDefault = Color(0xFF6B7280);  // Gray 500

  // ── Progress / Status ──────────────────────────────────────────────────────

  static const Color progressFull = Color(0xFF16A34A);   // Green 600
  static const Color progressGood = Color(0xFF4ADE80);   // Green 400
  static const Color progressMid = Color(0xFFF97316);    // Orange 500
  static const Color progressLow = Color(0xFF9CA3AF);    // Gray 400
  static const Color taskDone = Color(0xFF22C55E);       // Green 500

  // ── Calendar Event Colors ──────────────────────────────────────────────────

  static const Color calGreen = Color(0xFF4CAF50);        // Idul Fitri, Tahun Baru
  static const Color calBlue = Color(0xFF2196F3);         // Asyura
  static const Color calGold = Color(0xFFD4A057);         // Maulid, Nuzulul, Idul Adha
  static const Color calPurple = Color(0xFF9C27B0);       // Isra Mi'raj
  static const Color calCyan = Color(0xFF00BCD4);         // Nisfu Sha'ban
  static const Color calOrange = Color(0xFFFF9800);       // Ramadhan, Tasyrik
  static const Color calPink = Color(0xFFE91E63);         // Lailatul Qadar
  static const Color calDeepOrange = Color(0xFFFF5722);   // Hari Arafah

  // ── Onboarding ─────────────────────────────────────────────────────────────

  static const Color onboardingLocation = Color(0xFF10B981);     // Emerald 500
  static const Color onboardingNotification = Color(0xFF6366F1); // Indigo 500

  // ── Material3 Dark ColorScheme ─────────────────────────────────────────────

  static ColorScheme get darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: goldDark,
    onPrimary: scaffoldDark,
    primaryContainer: Color(0xFF2E3150),
    onPrimaryContainer: Color(0xFFE8E8F0),
    secondary: goldDark,
    onSecondary: scaffoldDark,
    secondaryContainer: Color(0xFF2E3150),
    onSecondaryContainer: Color(0xFFE8E8F0),
    surface: cardDark,
    onSurface: textPrimaryDark,
    onSurfaceVariant: textSecondaryDark,
    outline: Color(0xFF2E3150),
    error: Color(0xFFCF6679),
    onError: Color(0xFF370B1E),
  );
}

/// Theme-aware color extension. Usage: `context.appAccent`, `context.appCardBg`, etc.
extension AppColorsX on BuildContext {
  bool get _dark => Theme.of(this).brightness == Brightness.dark;

  // ── Accent ─────────────────────────────────────────────────────────────────
  Color get appAccent => _dark ? AppColors.goldDark : AppColors.goldLight;

  // ── Text ───────────────────────────────────────────────────────────────────
  Color get appTextPrimary => _dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get appTextSecondary => _dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get appTextFaded => _dark ? AppColors.textFadedDark : AppColors.textFadedLight;

  // ── Backgrounds ────────────────────────────────────────────────────────────
  Color get appCardBg => _dark ? AppColors.cardDark : AppColors.cardLight;
  Color get appSheetBg => _dark ? AppColors.sheetDark : AppColors.sheetLight;
  Color get appChevronBg => _dark ? AppColors.cardDark : AppColors.elevatedLight;
  Color get appRefreshBg => _dark ? AppColors.elevatedDark : AppColors.elevatedLight;
  Color get appCardWarm => _dark ? AppColors.cardWarmDark : AppColors.cardWarmLight;
  Color get appCardLight => _dark ? AppColors.cardNextDark : AppColors.cardNextLight;
  Color get appIconPassedBg => _dark ? AppColors.iconPassedBgDark : AppColors.iconPassedBgLight;

  // ── Dividers / Handles ─────────────────────────────────────────────────────
  Color get appDivider => _dark ? AppColors.dividerDark : AppColors.dividerLight;
  Color get appSunDivider => _dark ? AppColors.sunDividerDark : AppColors.sunDividerLight;
  Color get appSheetHandle => _dark ? AppColors.sheetHandleDark : AppColors.sheetHandleLight;

  // ── Icon States ────────────────────────────────────────────────────────────
  Color get appIconPassedFg => _dark ? AppColors.iconPassedFgDark : AppColors.iconPassedFgLight;
  Color get appBellOff => _dark ? AppColors.bellOffDark : AppColors.bellOffLight;

  // ── Overlays ───────────────────────────────────────────────────────────────
  Color get appCardShadow =>
      _dark ? Colors.black.withValues(alpha: 0.30) : const Color(0xFF2A1A0E).withValues(alpha: 0.07);
  Color get appRowHighlight =>
      _dark ? AppColors.goldDark.withValues(alpha: 0.12) : const Color(0xFFFFF6F0);
  Color get appMosqueOverlayWarm =>
      _dark ? AppColors.goldDark.withValues(alpha: 0.06) : AppColors.goldLight.withValues(alpha: 0.12);
  Color get appMosqueOverlayLight =>
      _dark ? AppColors.goldDark.withValues(alpha: 0.04) : AppColors.goldLight.withValues(alpha: 0.09);
}
