import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Small, reusable building blocks shared across screens. They resolve colours
/// from the active theme (via `context.scheme`), so a single theme toggle
/// restyles every one of them — this is what keeps the visual lock honest.

/// A bordered surface card with standard padding.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? AppSpacing.card,
      decoration: BoxDecoration(
        color: context.scheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: context.scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

/// A KPI tile: label on top, big value under it.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
  });
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: context.scheme.outline),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(label.toUpperCase(),
                  style: AppTypography.label, overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTypography.h1.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}

/// A coloured status dot + optional label.
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color, this.label});
  final Color color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      if (label != null) ...[
        const SizedBox(width: 6),
        Text(label!, style: AppTypography.caption),
      ],
    ]);
  }
}

/// A small pill / tag. Defaults to the brand container colour of the active
/// theme; callers may override for semantic (warning / danger) pills.
class PillTag extends StatelessWidget {
  const PillTag({super.key, required this.text, this.color, this.bg});
  final String text;
  final Color? color;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.scheme.onPrimaryContainer;
    final background = bg ?? context.scheme.primaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(text,
          style: AppTypography.caption
              .copyWith(color: fg, fontWeight: FontWeight.w700)),
    );
  }
}

/// Centred empty / placeholder state.
class EmptyState extends StatelessWidget {
  const EmptyState(
      {super.key, required this.icon, required this.title, this.message});
  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.scheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTypography.h2, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(message!,
                  style: AppTypography.bodyMuted, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

/// Constrains content width on tablet/web so lines don't stretch edge-to-edge.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: child,
      ),
    );
  }
}

/// A labelled key→value row, used in summary / detail panels.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow(
      {super.key,
      required this.label,
      required this.value,
      this.valueStyle});
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMuted),
          Text(value, style: valueStyle ?? AppTypography.numeric),
        ],
      ),
    );
  }
}

/// The light/dark toggle used in app bars and the home header.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, required this.isDark, required this.onTap});
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isDark ? 'Switch to light' : 'Switch to dark',
      onPressed: onTap,
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      color: context.scheme.onSurfaceVariant,
    );
  }
}
