import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/mock/mock_data.dart';
import '../../lot/domain/lot.dart';
import '../../lot/presentation/lot_providers.dart';

/// Summary tab — the night-before review of THIS tender. Reads the locally-saved
/// captures/estimates (MockData.captures), so it reflects exactly what the buyer
/// captured and the estimate team valued. Break-even & bid come from the saved
/// yield% + $/ct; un-estimated lots show as pending.
class SummaryBody extends ConsumerWidget {
  const SummaryBody({super.key, required this.tenderId});
  final String tenderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(lotsProvider(tenderId)); // rebuild when captures change
    final lots = MockData.lotsForTender(tenderId);
    if (lots.isEmpty) {
      return const EmptyState(icon: Icons.summarize_outlined, title: 'No lots');
    }

    int willBid = 0, captured = 0, estimated = 0;
    double totalBidValue = 0, yRough = 0, yPolish = 0;
    final rows = <_Line>[];
    for (final l in lots) {
      if (MockData.willBid(l)) willBid++;
      final st = MockData.captureStatus(l.id);
      if (st == 'captured') captured++;
      if (st == 'estimated') estimated++;

      final c = MockData.capture(l.id);
      final yieldPct = (c?['yieldPct'] as num?)?.toDouble() ?? 0;
      final priceCt = (c?['pricePerCt'] as num?)?.toDouble() ?? 0;
      final margin = (c?['marginPct'] as num?)?.toDouble() ?? 15;
      final rough = l.publishedCarats;
      final polish = rough * yieldPct / 100;
      final total = polish * priceCt;
      final breakEven = rough > 0 ? total / rough : 0.0;
      final bid = breakEven * (1 - margin / 100);
      if (st == 'estimated') {
        totalBidValue += bid * rough;
        yRough += rough;
        yPolish += polish;
      }
      rows.add(_Line(l, st, breakEven, bid));
    }
    final avgYield = yRough > 0 ? yPolish / yRough * 100 : 0.0;

    // Sort: estimated first, then captured, then to-do — most useful on top.
    int rank(String s) => s == 'estimated' ? 0 : (s == 'captured' ? 1 : 2);
    rows.sort((a, b) => rank(a.status).compareTo(rank(b.status)));

    return ResponsiveContent(
      child: ListView(
        padding: AppSpacing.page,
        children: [
          Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
            PillTag(text: '${lots.length} lots', color: context.scheme.onSurfaceVariant, bg: context.surfaceAlt),
            PillTag(text: '$willBid will bid'),
            PillTag(text: '$captured to estimate', color: AppColors.info, bg: context.surfaceAlt),
            PillTag(text: '$estimated estimated', color: AppColors.success, bg: AppColors.accentLight),
          ]),
          const SizedBox(height: AppSpacing.md),
          // headline totals from estimated lots
          Row(children: [
            Expanded(
              child: StatCard(
                  label: 'Total bid value',
                  value: Fmt.money(totalBidValue),
                  valueColor: AppColors.accent,
                  icon: Icons.gavel_outlined),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                  label: 'Avg yield',
                  value: Fmt.percent(avgYield),
                  icon: Icons.percent),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _lotLine(context, rows[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _lotLine(BuildContext context, _Line line) {
    final l = line.lot;
    final (statusColor, statusText) = switch (line.status) {
      'estimated' => (AppColors.success, 'estimated'),
      'captured' => (AppColors.info, 'to estimate'),
      _ => (context.scheme.outline, 'to capture'),
    };
    return InkWell(
      onTap: () => context.go('/tender/${l.tenderId}/lot/${l.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(children: [
          Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.lotRef,
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text('${l.lotName} · ${Fmt.carats(l.publishedCarats)}',
                    style: AppTypography.caption, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (line.status == 'estimated')
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('bid ${Fmt.money(line.bid)}',
                    style: AppTypography.numeric.copyWith(color: AppColors.accent)),
                Text('break-even ${Fmt.money(line.breakEven)}',
                    style: AppTypography.caption),
              ],
            )
          else
            Text(statusText, style: AppTypography.caption.copyWith(color: statusColor)),
        ]),
      ),
    );
  }
}

class _Line {
  _Line(this.lot, this.status, this.breakEven, this.bid);
  final Lot lot;
  final String status;
  final double breakEven;
  final double bid;
}
