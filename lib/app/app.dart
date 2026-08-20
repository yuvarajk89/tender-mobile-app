import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import 'router/app_router.dart';

/// The application root. Owns nothing but composition: it hands the router and
/// both themes to [MaterialApp.router] and lets [themeControllerProvider] pick
/// which theme is live. Everything else is a feature.
class DondaDiamondApp extends ConsumerWidget {
  const DondaDiamondApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode, // light by default; the header toggle flips it
      routerConfig: router,
    );
  }
}
