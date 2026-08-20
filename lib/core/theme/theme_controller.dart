import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the active [ThemeMode]. Defaults to LIGHT (the client's request); the
/// header toggle cycles light ⇄ dark and every screen follows because all
/// colours are resolved from [Theme.of(context)] rather than hard-coded.
///
/// In the live build this value is persisted (shared_preferences); for the mock
/// it lives in memory, which is enough to demo the switch.
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light);

  void toggle() =>
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

  void set(ThemeMode mode) => state = mode;

  bool get isDark => state == ThemeMode.dark;
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController();
});
