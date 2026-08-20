import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../evaluation/domain/entities/enums.dart';
import 'lot_providers.dart';

/// Work-list tab body — the lots being worked **right now** in THIS tender
/// (per-tender, client note #2). TE-031.
class WorkListBody extends ConsumerWidget {
  const WorkListBody({super.key, required this.tenderId});
  final String tenderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotsAsync = ref.watch(lotsProvider(tenderId));
    return ResponsiveContent(
      child: lotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            EmptyState(icon: Icons.error_outline, title: 'Error', message: '$e'),
        data: (all) {
          final lots = all
              .where((l) => l.workStatus == LotWorkStatus.inProgress)
              .toList();
          if (lots.isEmpty) {
            return const EmptyState(
                icon: Icons.checklist,
                title: 'Nothing in progress',
                message: 'Lots you start appear here.');
          }
          return ListView.separated(
            padding: AppSpacing.page,
            itemCount: lots.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) {
              final l = lots[i];
              return InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                onTap: () =>
                    context.go('/tender/${l.tenderId}/lot/${l.id}'),
                child: SectionCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(children: [
                    const StatusDot(color: AppColors.warning),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Lot ${l.lotRef.split('-').last} · ${l.lotName}',
                              style: AppTypography.title),
                          Text(
                              '${l.publishedPieces} pc · ${Fmt.carats(l.workingCarats)}',
                              style: AppTypography.caption),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: context.scheme.outline),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
