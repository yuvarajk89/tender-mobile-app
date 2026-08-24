import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../estimate/presentation/estimate_page.dart';
import '../../lot/presentation/lot_list_page.dart';
import '../../summary/presentation/summary_page.dart';
import 'tender_providers.dart';

/// The per-tender workspace. Once a tender is picked, the buyer lives here; the
/// bottom tabs are all scoped to THIS tender (Work list & Summary are per-tender,
/// so they can't be global — client note #2).
class TenderShellPage extends ConsumerStatefulWidget {
  const TenderShellPage({super.key, required this.tenderId});
  final String tenderId;

  @override
  ConsumerState<TenderShellPage> createState() => _TenderShellPageState();
}

class _TenderShellPageState extends ConsumerState<TenderShellPage> {
  int _index = 0;

  static const _tabs = [
    _Tab('Lots', Icons.grid_view_outlined, Icons.grid_view),
    _Tab('Estimate', Icons.calculate_outlined, Icons.calculate),
    _Tab('Summary', Icons.summarize_outlined, Icons.summarize),
  ];

  @override
  Widget build(BuildContext context) {
    final tid = widget.tenderId;
    final tender = ref.watch(tenderProvider(tid)).valueOrNull;
    final bodies = [
      LotListBody(tenderId: tid),
      EstimateBody(tenderId: tid),
      SummaryBody(tenderId: tid),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tender?.house ?? 'Tender', style: AppTypography.h2),
            if (tender != null)
              Text(tender.saleCode, style: AppTypography.caption),
          ],
        ),
        actions: [
          const _OfflineChip(),
          ThemeToggleButton(
            isDark: ref.watch(themeControllerProvider) == ThemeMode.dark,
            onTap: () => ref.read(themeControllerProvider.notifier).toggle(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: bodies),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/tender/$tid/add-lot'),
              icon: const Icon(Icons.add),
              label: const Text('Add lot'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon),
              label: t.label,
            ),
        ],
      ),
    );
  }
}

/// A small offline/sync indicator (mock). Tap for detail.
class _OfflineChip extends StatelessWidget {
  const _OfflineChip();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Offline — 3 items queued, will sync when online')),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF0DC),
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 13, color: AppColors.warning),
            const SizedBox(width: 4),
            Text('3',
                style: AppTypography.caption
                    .copyWith(color: AppColors.warning, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
