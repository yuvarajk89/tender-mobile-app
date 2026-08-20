import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] from the visual-lock tokens.
///
/// Screens NEVER build their own ThemeData and rarely hard-code a colour — they
/// read from `Theme.of(context).colorScheme`, which is the single reason the
/// light ⇄ dark switch flows to every pixel. The two themes share one brand
/// hue and one type scale; only the neutral surface/text stack differs.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        scheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          primaryContainer: AppColors.primaryLight,
          onPrimaryContainer: AppColors.primaryDark,
          secondary: AppColors.accent,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.accentLight,
          error: AppColors.danger,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textSecondary,
          outline: AppColors.textMuted,
          outlineVariant: AppColors.border,
        ),
        scaffold: AppColors.background,
        surfaceAlt: AppColors.surfaceAlt,
        codeAccent: const Color(0xFFA9812E), // gold, readable on light
        feedBg: AppColors.background,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scheme: const ColorScheme.dark(
          primary: Color(0xFF8FA2FF), // brighter indigo for contrast on dark
          onPrimary: Color(0xFF10163A),
          primaryContainer: AppColors.primaryLightDark,
          onPrimaryContainer: Color(0xFFDDE3FF),
          secondary: AppColors.accent,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.accentLightDark,
          error: Color(0xFFF3736F),
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          onSurfaceVariant: Color(0xFFA9B0C4),
          outline: Color(0xFF737B92),
          outlineVariant: AppColors.darkBorder,
        ),
        scaffold: AppColors.darkBackground,
        surfaceAlt: AppColors.darkSurfaceAlt,
        codeAccent: const Color(0xFFD4A853), // the POC's signature gold
        feedBg: const Color(0xFF08080A), // the POC's near-black terminal
      );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffold,
    required Color surfaceAlt,
    required Color codeAccent,
    required Color feedBg,
  }) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    // Default text colour follows the theme → headline styles inherit it.
    final textColor = scheme.onSurface;
    final textTheme = base.textTheme.apply(
      bodyColor: textColor,
      displayColor: textColor,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: textTheme,
      extensions: [
        AppSurfaces(surfaceAlt: surfaceAlt, codeAccent: codeAccent, feedBg: feedBg)
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: AppTypography.h2.copyWith(color: scheme.onSurface),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardTheme(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: _inputBorder(scheme.outlineVariant),
        enabledBorder: _inputBorder(scheme.outlineVariant),
        focusedBorder: _inputBorder(scheme.primary, width: 1.6),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.outline),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          textStyle: AppTypography.title,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(AppTypography.caption),
        elevation: 3,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle:
            AppTypography.caption.copyWith(color: scheme.onSurface),
        unselectedLabelTextStyle: AppTypography.caption,
      ),
      dividerTheme: DividerThemeData(
          color: scheme.outlineVariant, thickness: 1, space: 1),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surfaceAlt,
        labelStyle: AppTypography.caption.copyWith(color: scheme.onSurface),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: BorderSide(color: color, width: width),
      );
}

/// One extra surface tone that Material's ColorScheme doesn't cleanly express
/// (our "raised / alt" fill). Exposed as a ThemeExtension so it too flips with
/// the theme. Read it via `Theme.of(context).extension<AppSurfaces>()!`.
class AppSurfaces extends ThemeExtension<AppSurfaces> {
  const AppSurfaces({
    required this.surfaceAlt,
    required this.codeAccent,
    required this.feedBg,
  });

  /// Raised / alt fill.
  final Color surfaceAlt;

  /// Gold used for stone codes and terminal accents (the POC signature).
  final Color codeAccent;

  /// The lot-entry "terminal" feed background (near-black in dark, light in light).
  final Color feedBg;

  @override
  AppSurfaces copyWith({Color? surfaceAlt, Color? codeAccent, Color? feedBg}) =>
      AppSurfaces(
        surfaceAlt: surfaceAlt ?? this.surfaceAlt,
        codeAccent: codeAccent ?? this.codeAccent,
        feedBg: feedBg ?? this.feedBg,
      );

  @override
  AppSurfaces lerp(AppSurfaces? other, double t) => AppSurfaces(
        surfaceAlt: Color.lerp(surfaceAlt, other?.surfaceAlt, t) ?? surfaceAlt,
        codeAccent: Color.lerp(codeAccent, other?.codeAccent, t) ?? codeAccent,
        feedBg: Color.lerp(feedBg, other?.feedBg, t) ?? feedBg,
      );
}

/// Ergonomic accessors so screens read `context.scheme.primary` /
/// `context.surfaceAlt` / `context.codeAccent` without the ceremony.
extension ThemeContextX on BuildContext {
  ColorScheme get scheme => Theme.of(this).colorScheme;
  AppSurfaces get _sfc =>
      Theme.of(this).extension<AppSurfaces>() ??
      AppSurfaces(
          surfaceAlt: scheme.surface,
          codeAccent: scheme.secondary,
          feedBg: scheme.surface);
  Color get surfaceAlt => _sfc.surfaceAlt;
  Color get codeAccent => _sfc.codeAccent;
  Color get feedBg => _sfc.feedBg;
}
