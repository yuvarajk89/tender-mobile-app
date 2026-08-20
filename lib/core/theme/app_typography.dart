import 'package:flutter/material.dart';
import 'app_colors.dart';

/// UI VISUAL LOCK — type scale.
///
/// System font (no network fetch → works fully offline at the viewing table).
/// Numbers use tabular figures so columns of carats / dollars line up.
///
/// IMPORTANT: the headline styles deliberately carry **no colour**. Text colour
/// is inherited from the active theme (onSurface), which is what makes the same
/// widget legible in BOTH light and dark mode. Only the intentionally-muted
/// styles pin a mid-grey (it reads well on white and on charcoal alike).
class AppTypography {
  AppTypography._();

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  // --- Colour-inheriting headline styles ---
  static const TextStyle display =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.1);
  static const TextStyle h1 =
      TextStyle(fontSize: 22, fontWeight: FontWeight.w700);
  static const TextStyle h2 =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const TextStyle title =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const TextStyle body =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const TextStyle numeric = TextStyle(
      fontSize: 15, fontWeight: FontWeight.w600, fontFeatures: _tabular);

  // --- Intentionally muted (mid-grey, theme-agnostic) ---
  static const TextStyle bodyMuted = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const TextStyle caption = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted);
  static const TextStyle label = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      letterSpacing: 0.4);

  // --- The BID: the biggest, greenest number on the entry screen ---
  static const TextStyle bidNumber = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: AppColors.accent,
      fontFeatures: _tabular);

  // --- Monospace, for the typed shorthand stone codes (the terminal feel) ---
  // Uses the platform monospace family (offline-safe; no network font).
  static const TextStyle code = TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: ['RobotoMono', 'Menlo', 'Consolas'],
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5);
}
