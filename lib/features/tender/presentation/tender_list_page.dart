import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/tender.dart';
import 'tender_providers.dart';

/// Tab 0 — the home/dashboard. Shows the current trip and its tenders; tap one
/// to drill into its lots.
class TenderListPage extends ConsumerWidget {
  const TenderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tendersAsync = ref.watch(tendersProvider);
    final user = ref.watch(authControllerProvider).userName;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: tendersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState(
                icon: Icons.error_outline, title: 'Could not load', message: '$e'),
            data: (tenders) => CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    user: user,
                    tenders: tenders,
                    isDark:
                        ref.watch(themeControllerProvider) == ThemeMode.dark,
                    onToggleTheme: () =>
                        ref.read(themeControllerProvider.notifier).toggle(),
                  ),
                ),
                SliverPadding(
                  padding: AppSpacing.pageH,
                  sliver: SliverList.separated(
                    itemCount: tenders.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) => _TenderCard(tender: tenders[i]),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.user,
    required this.tenders,
    required this.isDark,
    required this.onToggleTheme,
  });
  final String user;
  final List<Tender> tenders;
  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final totalLots = tenders.fold<int>(0, (s, t) => s + t.lotCount);
    final willBid = tenders.fold<int>(0, (s, t) => s + t.willBidCount);
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'
    ];
    final trip = '${months[DateTime.now().month - 1]} trip · Belgium';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BrandLogo(size: 38),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DONDA EXPORT',
                        style: AppTypography.label
                            .copyWith(color: context.scheme.primary)),
                    Text(trip, style: AppTypography.caption),
                  ],
                ),
              ),
              ThemeToggleButton(isDark: isDark, onTap: onToggleTheme),
            ],
          ),
          const SizedBox(height: 2),
          Text('Hello, $user', style: AppTypography.display),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            Expanded(
                child: StatCard(
                    label: 'Tenders',
                    value: '${tenders.length}',
                    icon: Icons.inventory_2_outlined)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: StatCard(
                    label: 'Lots',
                    value: '$totalLots',
                    icon: Icons.grid_view_outlined)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: StatCard(
                    label: 'Will bid',
                    value: '$willBid',
                    valueColor: AppColors.primary,
                    icon: Icons.gavel_outlined)),
          ]),
          const SizedBox(height: AppSpacing.lg),
          Text('Tenders', style: AppTypography.h2),
        ],
      ),
    );
  }
}

class _TenderCard extends StatelessWidget {
  const _TenderCard({required this.tender});
  final Tender tender;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: () => context.go('/tender/${tender.id}'),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tender.house, style: AppTypography.h2),
                      const SizedBox(height: 2),
                      Text(tender.saleCode, style: AppTypography.bodyMuted),
                    ],
                  ),
                ),
                PillTag(text: '${tender.willBidCount} will bid'),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Row(children: [
              _mini(Icons.place_outlined, tender.origin),
              const SizedBox(width: AppSpacing.lg),
              _mini(Icons.scale_outlined, Fmt.carats(tender.declaredCarats)),
            ]),
            const SizedBox(height: AppSpacing.sm),
            Row(children: [
              _mini(Icons.event_outlined,
                  'Closes ${Fmt.dateTime(tender.closure)}'),
              const Spacer(),
              Text('${tender.doneCount}/${tender.lotCount} done',
                  style: AppTypography.caption),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _mini(IconData icon, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 15, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Text(text, style: AppTypography.caption),
    ]);
  }
}
