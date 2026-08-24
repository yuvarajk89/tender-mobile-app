import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/persistence/local_store.dart';
import '../../auth/presentation/auth_providers.dart';

/// Settings — theme, grade master data (Shape/Colour/Clarity lists), account.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final user = ref.watch(authControllerProvider).userName;

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

          _sectionHeader(context, 'GRADE MASTER DATA'),
          _card(context, [
            _masterRow(context, 'shape', 'Shapes', Icons.category_outlined),
            const Divider(height: 1),
            _masterRow(context, 'colour', 'Colours', Icons.palette_outlined),
            const Divider(height: 1),
            _masterRow(context, 'clarity', 'Clarities', Icons.blur_on_outlined),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 4, AppSpacing.lg, 0),
            child: Text('Edit the Shape / Colour / Clarity options shown on the capture screen.',
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

  Widget _masterRow(BuildContext context, String key, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text('${MockData.masterList(key).length} values'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _MasterEditor(keyName: key, title: label))),
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

/// Editor for one grade list — add/remove values (persisted).
class _MasterEditor extends StatefulWidget {
  const _MasterEditor({required this.keyName, required this.title});
  final String keyName;
  final String title;

  @override
  State<_MasterEditor> createState() => _MasterEditorState();
}

class _MasterEditorState extends State<_MasterEditor> {
  final _add = TextEditingController();
  List<String> get _list => MockData.masterList(widget.keyName);

  @override
  void dispose() {
    _add.dispose();
    super.dispose();
  }

  void _persist() => LocalStore.I.persistMaster();

  void _addValue() {
    final v = _add.text.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
    if (v.isEmpty) return;
    if (!_list.contains(v)) {
      setState(() => _list.add(v));
      _persist();
    }
    _add.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(children: [
        Padding(
          padding: AppSpacing.page,
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _add,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _addValue(),
                decoration: InputDecoration(
                  hintText: 'Add a ${widget.title.toLowerCase().replaceAll('s', '')} value…',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(
                onPressed: _addValue,
                style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
                child: const Text('Add')),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            padding: AppSpacing.pageH,
            itemCount: _list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => ListTile(
              title: Text(_list[i], style: AppTypography.numeric),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                onPressed: () {
                  setState(() => _list.removeAt(i));
                  _persist();
                },
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
