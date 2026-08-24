import 'package:flutter/material.dart';

/// UI VISUAL LOCK — colours.
///
/// These are the ONLY colours the app uses. Every screen pulls from here so the
/// look stays consistent and a rebrand is a one-file change. See
/// docs/06-UI-VISUAL-LOCK.md for the rationale and swatches.
class AppColors {
  AppColors._();

  // Brand — deep indigo/blue "night table under neutral light".
  static const Color primary = Color(0xFF2743B0);
  static const Color primaryDark = Color(0xFF1B2E7A);
  static const Color primaryLight = Color(0xFFE8ECFB);

  // Accent — used for the BID number, the single most important figure.
  static const Color accent = Color(0xFF13A15A); // "go / money" green
  static const Color accentLight = Color(0xFFE3F5EC);

  // Semantic
  static const Color success = Color(0xFF13A15A); 
  static const Color warning = Color(0xFFC9820A);
  static const Color danger = Color(0xFFD23B3B);
  static const Color info = Color(0xFF2743B0);

  // Neutrals (light theme surface stack)
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0F2F8);
  static const Color border = Color(0xFFE2E5EF);

  // Text — textSecondary / textMuted are mid-greys chosen to stay legible on
  // BOTH a white card and a charcoal card, so muted styles need no dark variant.
  static const Color textPrimary = Color(0xFF161A2B);
  static const Color textSecondary = Color(0xFF6E7488);
  static const Color textMuted = Color(0xFF9098AE);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Dark-theme neutrals (consumed by AppTheme.dark's ColorScheme).
  static const Color darkBackground = Color(0xFF0E1017);
  static const Color darkSurface = Color(0xFF181B24);
  static const Color darkSurfaceAlt = Color(0xFF212533);
  static const Color darkBorder = Color(0xFF2C3140);
  static const Color darkTextPrimary = Color(0xFFECEEF5);

  // Brand tints that read well on dark surfaces (used by ColorScheme.dark).
  static const Color primaryLightDark = Color(0xFF2A335C);
  static const Color accentLightDark = Color(0xFF16351F);

  // Lot status dots
  static const Color statusDone = success;
  static const Color statusPending = textMuted;
  static const Color willBid = primary;
  static const Color rejection = danger;
  static const Color pureRough = warning;
}
