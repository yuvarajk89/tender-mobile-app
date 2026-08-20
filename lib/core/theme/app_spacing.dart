import 'package:flutter/widgets.dart';

/// UI VISUAL LOCK — spacing & radius scale.
///
/// A single 4-based scale. Never hard-code padding numbers in a screen; use
/// these so density stays uniform across phone / tablet / web.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusPill = 999;

  // Common EdgeInsets shortcuts.
  static const EdgeInsets pageH = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets page = EdgeInsets.all(lg);
  static const EdgeInsets card = EdgeInsets.all(lg);

  /// Above this width we treat the device as a tablet/desktop and switch to
  /// multi-pane / wider layouts. See docs/03-NAVIGATION-FLOW.md.
  static const double tabletBreakpoint = 720;
  static const double maxContentWidth = 1100;
}
