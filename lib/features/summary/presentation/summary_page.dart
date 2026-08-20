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
import '../../evaluation/domain/valuation.dart';
import '../../evaluation/presentation/valuation_providers.dart';
import '../../lot/domain/lot.dart';
import '../../lot/presentation/lot_providers.dart';

/// Summary tab body — everything in THIS tender, one screen, for the
/// night-before review (TE-032, per-tender per client note #2). Pure-rough and
/// rejection are counted in pcs/carats but kept OUT of the yield averages
/// (TE-009). Tap a lot to open it for inline edit (TE-035).
class SummaryBody extends ConsumerWidget {
  const SummaryBody({super.key, required this.tenderId});
  final String tenderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotsAsync = ref.watch(lotsProvider(tenderId));
    final margin = ref.watch(marginPctProvider);
    final service = ref.watch(valuationServiceProvider);

    return lotsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          EmptyState(icon: Icons.error_outline, title: 'Error', message: '$e'),
      data: (lots) {
        if (lots.isEmpty) {
          return const EmptyState(
              icon: Icons.summarize_outlined, title: 'No lots');
        }

        double totalBidValue = 0;
        double yieldRough = 0, yieldPolish = 0;
        int pureRough = 0, rejection = 0;
        final rows = <_Line>[];
        for (final l in lots) {
          final plan = l.activePlan;
          final v = plan == null
              ? Valuation.zero
              : service.valuePlanRows(plan.rows, marginPct: margin);
          final cat = (plan?.rows.isNotEmpty ?? false)
              ? plan!.rows.first.category
              : ValuationCategory.yieldBased;
          if (cat == ValuationCategory.pureRough) pureRough++;
          if (cat == ValuationCategory.rejection) rejection++;
          if (v.contributesToYieldAverages) {
            yieldRough += v.roughCarats;
            yieldPolish += v.polishCarats;
          }
          totalBidValue += v.bid * v.roughCarats;
          rows.add(_Line(l, v, cat));
        }
        final avgYield = yieldRough > 0 ? yieldPolish / yieldRough * 100 : 0.0;

        return ResponsiveContent(
          child: ListView(
            padding: AppSpacing.page,
            children: [
              Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
                PillTag(text: 'Bid value ${Fmt.money(totalBidValue)}'),
                PillTag(
                    text: 'Avg yield ${Fmt.percent(avgYield)}',
                    color: AppColors.success,
                    bg: AppColors.accentLight),
                if (pureRough > 0)
                  PillTag(
                      text: '$pureRough pure-rough',
                      color: AppColors.warning,
                      bg: const Color(0xFFFBF0DC)),
                if (rejection > 0)
                  PillTag(
                      text: '$rejection rejection',
                      color: AppColors.danger,
                      bg: const Color(0xFFFBE5E5)),
              ]),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Column(
                  children: [
                    for (final line in rows) _lotLine(context, line),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _lotLine(BuildContext context, _Line line) {
    final l = line.lot;
    final (color, tag) = switch (line.category) {
      ValuationCategory.pureRough => (AppColors.warning, 'ROUGH'),
      ValuationCategory.rejection => (AppColors.danger, 'REJ'),
      ValuationCategory.yieldBased => (context.scheme.outline, ''),
    };
    return InkWell(
      onTap: () => context.go('/tender/${l.tenderId}/lot/${l.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(children: [
          SizedBox(
              width: 44,
              child: Text(l.lotRef.split('-').last, style: AppTypography.numeric)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(l.lotName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body),
                  ),
                  if (tag.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    PillTag(text: tag, color: color, bg: context.surfaceAlt),
                  ],
                ]),
                Text(
                    '${Fmt.carats(l.workingCarats)} · break-even ${Fmt.money(line.v.breakEven)}',
                    style: AppTypography.caption),
              ],
            ),
          ),
          Text(Fmt.money(line.v.bid),
              style: AppTypography.numeric.copyWith(color: AppColors.accent)),
          const SizedBox(width: 4),
          Icon(Icons.edit_outlined, size: 15, color: context.scheme.outline),
        ]),
      ),
    );
  }
}

class _Line {
  _Line(this.lot, this.v, this.category);
  final Lot lot;
  final Valuation v;
  final ValuationCategory category;
}
