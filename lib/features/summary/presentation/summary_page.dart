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

/// Summary tab — the night-before review of THIS tender. The count pills at the
/// top are TAPPABLE FILTERS (All / Will bid / To estimate / Estimated). Reads
/// the locally-saved captures/estimates so break-even & bid reflect real data.
class SummaryBody extends ConsumerStatefulWidget {
  const SummaryBody({super.key, required this.tenderId});
  final String tenderId;

  @override
  ConsumerState<SummaryBody> createState() => _SummaryBodyState();
}

class _SummaryBodyState extends ConsumerState<SummaryBody> {
  String _filter = 'all'; // all | willbid | capture | estimated

  @override
  Widget build(BuildContext context) {
    ref.watch(lotsProvider(widget.tenderId)); // rebuild on change
    final lots = MockData.lotsForTender(widget.tenderId);
    if (lots.isEmpty) {
      return const EmptyState(icon: Icons.summarize_outlined, title: 'No lots');
    }

    int willBid = 0, captured = 0, estimated = 0;
    double totalBidValue = 0, yRough = 0, yPolish = 0;
    final rows = <_Line>[];
    for (final l in lots) {
      final wb = MockData.willBid(l);
      if (wb) willBid++;
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
      rows.add(_Line(l, st, wb, breakEven, bid));
    }
    final avgYield = yRough > 0 ? yPolish / yRough * 100 : 0.0;

    // Apply the tapped filter.
    var shown = switch (_filter) {
      'willbid' => rows.where((r) => r.willBid).toList(),
      'capture' => rows.where((r) => r.status == 'captured').toList(),
      'estimated' => rows.where((r) => r.status == 'estimated').toList(),
      _ => rows,
    };
    int rank(String s) => s == 'estimated' ? 0 : (s == 'captured' ? 1 : 2);
    shown.sort((a, b) => rank(a.status).compareTo(rank(b.status)));

    return ResponsiveContent(
      child: ListView(
        padding: AppSpacing.page,
        children: [
          // tappable filter pills
          Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
            _filterPill('all', '${lots.length} lots', context.scheme.primary),
            _filterPill('willbid', '$willBid will bid', AppColors.accent),
            _filterPill('capture', '$captured to estimate', AppColors.info),
            _filterPill('estimated', '$estimated estimated', AppColors.success),
          ]),
          const SizedBox(height: AppSpacing.md),
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
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                  child: Text('No lots in this filter',
                      style: AppTypography.bodyMuted)),
            )
          else
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < shown.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    _lotLine(context, shown[i]),
                  ],
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _filterPill(String key, String label, Color accent) {
    final selected = _filter == key;
    return GestureDetector(
      onTap: () => setState(() => _filter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent : context.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
              color: selected ? accent : context.scheme.outlineVariant),
        ),
        child: Text(label,
            style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : context.scheme.onSurfaceVariant)),
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
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: statusColor, shape: BoxShape.circle)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(l.lotRef,
                        style: AppTypography.body
                            .copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (line.willBid) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.accent),
                  ],
                ]),
                Text('${l.lotName} · ${Fmt.carats(l.publishedCarats)}',
                    style: AppTypography.caption,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (line.status == 'estimated')
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('bid ${Fmt.money(line.bid)}',
                    style: AppTypography.numeric
                        .copyWith(color: AppColors.accent)),
                Text('break-even ${Fmt.money(line.breakEven)}',
                    style: AppTypography.caption),
              ],
            )
          else
            Text(statusText,
                style: AppTypography.caption.copyWith(color: statusColor)),
        ]),
      ),
    );
  }
}

class _Line {
  _Line(this.lot, this.status, this.willBid, this.breakEven, this.bid);
  final Lot lot;
  final String status;
  final bool willBid;
  final double breakEven;
  final double bid;
}
