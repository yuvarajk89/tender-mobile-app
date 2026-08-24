import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../auth/presentation/auth_providers.dart';
import 'prefs_providers.dart';

/// Settings — theme, grade master data (Shape/Colour/Clarity lists), account.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final user = ref.watch(authControllerProvider).userName;
    final gradeStyle = ref.watch(gradeStyleProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home')),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _sectionHeader(context, 'APPEARANCE'),
          _card(context, [
            _themeRow(context, ref, mode, ThemeMode.light, 'Light', Icons.light_mode_outlined),
            const Divider(height: 1),
            _themeRow(context, ref, mode, ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
            const Divider(height: 1),
            _themeRow(context, ref, mode, ThemeMode.system, 'System default', Icons.brightness_auto_outlined),
          ]),

          _sectionHeader(context, 'GRADE SELECTION STYLE'),
          _card(context, [
            _styleRow(context, ref, gradeStyle, GradeStyle.inline, 'Inline chips',
                'Chips shown directly on the screen (today)', Icons.view_agenda_outlined),
            const Divider(height: 1),
            _styleRow(context, ref, gradeStyle, GradeStyle.tabbed, 'Tabbed picker',
                'Tap a field → tabbed sheet with a list (yesterday)', Icons.list_alt_outlined),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 4, AppSpacing.lg, 0),
            child: Text('How Shape / Colour / Clarity are picked when capturing a lot. Values come from the backend.',
                style: AppTypography.caption),
          ),

          _sectionHeader(context, 'ACCOUNT'),
          _card(context, [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Signed in as'),
              subtitle: Text(user.isEmpty ? 'Buyer' : user),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('Log out', style: TextStyle(color: AppColors.danger)),
              onTap: () => _confirmLogout(context, ref),
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text('Donda Export · Tender Mobile · v0.2.9',
                style: AppTypography.caption),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String t) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
        child: Text(t, style: AppTypography.label),
      );

  Widget _card(BuildContext context, List<Widget> children) => Container(
        margin: AppSpacing.pageH,
        decoration: BoxDecoration(
          color: context.scheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: context.scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      );

  Widget _themeRow(BuildContext context, WidgetRef ref, ThemeMode current,
      ThemeMode mode, String label, IconData icon) {
    final selected = current == mode;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle, color: context.scheme.primary)
          : const Icon(Icons.circle_outlined, color: Color(0xFFC4C9D6)),
      onTap: () => ref.read(themeControllerProvider.notifier).set(mode),
    );
  }

  Widget _styleRow(BuildContext context, WidgetRef ref, String current,
      String value, String label, String subtitle, IconData icon) {
    final selected = current == value;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(Icons.check_circle, color: context.scheme.primary)
          : const Icon(Icons.circle_outlined, color: Color(0xFFC4C9D6)),
      onTap: () => ref.read(gradeStyleProvider.notifier).set(value),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will return to the sign-in screen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

