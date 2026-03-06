import 'package:flutter/material.dart';

/// Theme-aware color getters via BuildContext extension.
/// Use `context.appAccent`, `context.appCardBg`, etc. inside build() methods.
extension AppColorsX on BuildContext {
  bool get _dark => Theme.of(this).brightness == Brightness.dark;

  // ── Accent / brand ──────────────────────────────────────────────────────────
  Color get appAccent => _dark ? const Color(0xFFD4A057) : const Color(0xFFCE7E50);

  // ── Text ────────────────────────────────────────────────────────────────────
  Color get appTextPrimary   => _dark ? const Color(0xFFE8E8F0) : const Color(0xFF2A1A0E);
  Color get appTextSecondary => _dark ? const Color(0xFFB0B3C6) : const Color(0xFF8B6545);
  Color get appTextFaded     => _dark ? const Color(0xFF6E7090) : const Color(0xFFBBA88A);

  // ── Surfaces ────────────────────────────────────────────────────────────────
  Color get appCardBg    => _dark ? const Color(0xFF252840) : const Color(0xFFFAF3EC);
  Color get appDivider   => _dark ? const Color(0xFF2E3150) : const Color(0xFFF0E8DE);
  Color get appCardShadow => _dark
      ? const Color(0xFF000000).withValues(alpha: 0.30)
      : const Color(0xFF2A1A0E).withValues(alpha: 0.07);

  // ── Prayer list ─────────────────────────────────────────────────────────────
  Color get appRowHighlight  => _dark
      ? const Color(0xFFD4A057).withValues(alpha: 0.12)
      : const Color(0xFFFFF6F0);
  Color get appIconPassedBg  => _dark ? const Color(0xFF2A2D45) : const Color(0xFFF3EDE6);
  Color get appIconPassedFg  => _dark ? const Color(0xFF6E7090) : const Color(0xFFCBB89E);
  Color get appBellOff       => _dark ? const Color(0xFF4A4D65) : const Color(0xFFCCC0B5);

  // ── Next prayer cards ───────────────────────────────────────────────────────
  Color get appCardWarm  => _dark ? const Color(0xFF252038) : const Color(0xFFF2D9C4);
  Color get appCardLight => _dark ? const Color(0xFF1E2138) : const Color(0xFFF8EFE4);
  Color get appMosqueOverlayWarm => _dark
      ? const Color(0xFFD4A057).withValues(alpha: 0.06)
      : const Color(0xFFCE7E50).withValues(alpha: 0.12);
  Color get appMosqueOverlayLight => _dark
      ? const Color(0xFFD4A057).withValues(alpha: 0.04)
      : const Color(0xFFCE7E50).withValues(alpha: 0.09);

  // ── UI chrome ───────────────────────────────────────────────────────────────
  Color get appChevronBg  => _dark ? const Color(0xFF252840) : const Color(0xFFF5EDE4);
  Color get appSunDivider => _dark ? const Color(0xFF2E3150) : const Color(0xFFE8D9C8);
  Color get appRefreshBg  => _dark ? const Color(0xFF2A2D45) : const Color(0xFFF5EDE4);

  // ── Bottom sheets ────────────────────────────────────────────────────────────
  Color get appSheetBg     => _dark ? const Color(0xFF1E2138) : const Color(0xFFFBF6F0);
  Color get appSheetHandle => _dark ? const Color(0xFF4A4D65) : const Color(0xFFD4C0AE);
}
