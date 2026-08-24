import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/image_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/persistence/local_store.dart';
import '../../lot/domain/lot.dart';
import '../../lot/presentation/lot_providers.dart';

/// ESTIMATE tab — the estimate team's screen.
///
/// A queue of lots the buyer CAPTURED (photos + grade). The team opens each,
/// enters yield % and $/polished-ct, and the app computes break-even and the
/// MAX BID — showing whether bidding at a target price is profit or loss.
/// This is where the money maths lives (not on the capture screen).
class EstimateBody extends ConsumerWidget {
  const EstimateBody({super.key, required this.tenderId});
  final String tenderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(lotsProvider(tenderId)); // rebuild when captures change
    final all = MockData.lotsForTender(tenderId);
    final pending = all.where((l) => MockData.captureStatus(l.id) == 'captured').toList();
    final done = all.where((l) => MockData.captureStatus(l.id) == 'estimated').toList();

    if (pending.isEmpty && done.isEmpty) {
      return const EmptyState(
          icon: Icons.calculate_outlined,
          title: 'Nothing to estimate yet',
          message: 'Captured lots from the buyer appear here for the estimate team.');
    }
    return ResponsiveContent(
      child: ListView(
        padding: AppSpacing.page,
        children: [
          Row(children: [
            PillTag(text: '${pending.length} pending', color: AppColors.info, bg: context.surfaceAlt),
            const SizedBox(width: 8),
            PillTag(text: '${done.length} estimated', color: AppColors.success, bg: AppColors.accentLight),
          ]),
          const SizedBox(height: AppSpacing.lg),
          if (pending.isNotEmpty) ...[
            Text('PENDING', style: AppTypography.label),
            const SizedBox(height: AppSpacing.sm),
            for (final l in pending) _EstimateTile(lot: l, tenderId: tenderId),
          ],
          if (done.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('ESTIMATED', style: AppTypography.label),
            const SizedBox(height: AppSpacing.sm),
            for (final l in done) _EstimateTile(lot: l, tenderId: tenderId),
          ],
        ],
      ),
    );
  }
}

class _EstimateTile extends ConsumerWidget {
  const _EstimateTile({required this.lot, required this.tenderId});
  final Lot lot;
  final String tenderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MockData.capture(lot.id)!;
    final grade = [c['shape'], c['colour'], c['clarity']]
        .where((s) => (s as String).isNotEmpty)
        .join(' ');
    final yieldPct = (c['yieldPct'] as num?)?.toDouble() ?? 0;
    final priceCt = (c['pricePerCt'] as num?)?.toDouble() ?? 0;
    final margin = (c['marginPct'] as num?)?.toDouble() ?? 15;
    final estimated = c['status'] == 'estimated';

    // rough → polish → value → break-even → bid
    final rough = lot.publishedCarats;
    final polish = rough * yieldPct / 100;
    final total = polish * priceCt;
    final breakEven = rough > 0 ? total / rough : 0;
    final bid = breakEven * (1 - margin / 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => _openEstimator(context, ref),
        child: SectionCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(lot.lotRef,
                    style: AppTypography.title, overflow: TextOverflow.ellipsis),
              ),
              if (estimated)
                PillTag(text: 'BID ${Fmt.money(bid)}', color: AppColors.success, bg: AppColors.accentLight)
              else
                PillTag(text: 'estimate', color: AppColors.info, bg: context.surfaceAlt),
            ]),
            const SizedBox(height: 2),
            Text('${lot.lotName} · ${lot.publishedPieces} stns · ${Fmt.carats(rough)}'
                '${grade.isNotEmpty ? '  ·  $grade' : ''}',
                style: AppTypography.caption, overflow: TextOverflow.ellipsis),
            if (estimated) ...[
              const Divider(height: AppSpacing.lg),
              Row(children: [
                _mini('Yield', Fmt.percent(yieldPct)),
                _mini('\$/pol ct', Fmt.money(priceCt)),
                _mini('Break-even', Fmt.money(breakEven)),
                _mini('Max bid', Fmt.money(bid), accent: true),
              ]),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _mini(String k, String v, {bool accent = false}) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k.toUpperCase(), style: AppTypography.label),
          const SizedBox(height: 2),
          Text(v,
              style: AppTypography.numeric
                  .copyWith(color: accent ? AppColors.accent : null)),
        ]),
      );

  void _openEstimator(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.scheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg))),
      builder: (_) => _EstimatorSheet(lot: lot, tenderId: tenderId, ref: ref),
    );
  }
}

/// The valuation sheet: enter yield % + $/ct (+ margin), see break-even & max
/// bid live, plus a profit/loss check against a target bid.
class _EstimatorSheet extends StatefulWidget {
  const _EstimatorSheet({required this.lot, required this.tenderId, required this.ref});
  final Lot lot;
  final String tenderId;
  final WidgetRef ref;

  @override
  State<_EstimatorSheet> createState() => _EstimatorSheetState();
}

class _EstimatorSheetState extends State<_EstimatorSheet> {
  late final Map<String, dynamic> _c = MockData.capture(widget.lot.id)!;
  late final _yield = TextEditingController(
      text: ((_c['yieldPct'] as num?)?.toDouble() ?? 0) == 0 ? '' : '${_c['yieldPct']}');
  late final _price = TextEditingController(
      text: ((_c['pricePerCt'] as num?)?.toDouble() ?? 0) == 0 ? '' : '${_c['pricePerCt']}');
  late final _target = TextEditingController();
  late final _margin = TextEditingController(
      text: '${((_c['marginPct'] as num?)?.toDouble() ?? 15).toStringAsFixed(0)}');

  @override
  void dispose() {
    _yield.dispose();
    _price.dispose();
    _target.dispose();
    _margin.dispose();
    super.dispose();
  }

  double _d(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final rough = widget.lot.publishedCarats;
    final polish = rough * _d(_yield) / 100;
    final total = polish * _d(_price);
    final breakEven = rough > 0 ? total / rough : 0.0;
    final margin = _d(_margin);
    final bid = breakEven * (1 - margin / 100);
    final target = _d(_target);
    final showPL = target > 0;
    final profit = (breakEven - target) * rough; // vs break-even, per lot
    final profitPos = profit >= 0;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.lot.lotRef, style: AppTypography.h2),
          Text('${widget.lot.lotName} · ${widget.lot.publishedPieces} stns · ${Fmt.carats(rough)}',
              style: AppTypography.caption),
          _capturedPhotos(),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            Expanded(child: _field('Yield %', _yield)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _field('\$ / polished ct', _price)),
          ]),
          const SizedBox(height: AppSpacing.md),
          // Margin — a simple typed field (default 15%).
          _field('Margin %', _margin),
          const SizedBox(height: AppSpacing.md),
          // results
          Container(
            padding: AppSpacing.card,
            decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            child: Column(children: [
              _resRow('Polish carats', Fmt.carats(polish)),
              _resRow('Polished value', Fmt.money(total)),
              _resRow('Break-even \$/ct', Fmt.money(breakEven)),
              const Divider(color: Colors.white24, height: AppSpacing.lg),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('MAX BID \$/ct', style: AppTypography.label.copyWith(color: AppColors.accentLight)),
                Text(Fmt.money(bid), style: AppTypography.bidNumber),
              ]),
            ]),
          ),
          const SizedBox(height: AppSpacing.md),
          // profit / loss check
          _field('If we bid \$/ct (check profit)', _target),
          if (showPL)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Container(
                width: double.infinity,
                padding: AppSpacing.card,
                decoration: BoxDecoration(
                  color: (profitPos ? AppColors.success : AppColors.danger).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(children: [
                  Icon(profitPos ? Icons.trending_up : Icons.trending_down,
                      color: profitPos ? AppColors.success : AppColors.danger),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      profitPos
                          ? 'Profit ${Fmt.money(profit)} vs break-even'
                          : 'Loss ${Fmt.money(profit.abs())} — above break-even',
                      style: AppTypography.body.copyWith(
                          color: profitPos ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
                _c['yieldPct'] = _d(_yield);
                _c['pricePerCt'] = _d(_price);
                _c['marginPct'] = _d(_margin);
                _c['status'] = 'estimated';
                LocalStore.I.persistCaptures();
                widget.ref.invalidate(lotsProvider(widget.tenderId));
                Navigator.pop(context);
              },
              child: const Text('Save estimate'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ]),
      ),
    );
  }

  Widget _resRow(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: AppTypography.caption.copyWith(color: Colors.white70)),
          Text(v, style: AppTypography.numeric.copyWith(color: Colors.white)),
        ]),
      );

  // Captured photos — the estimate team taps to view HQ, zoom & rotate to judge
  // size / shape / colour before estimating.
  Widget _capturedPhotos() {
    final imgs = (_c['images'] as List?)?.cast<Uint8List>() ?? const [];
    if (imgs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Row(children: [
          Icon(Icons.image_not_supported_outlined,
              size: 16, color: context.scheme.outline),
          const SizedBox(width: 6),
          Text('No photos captured', style: AppTypography.caption),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${imgs.length} PHOTO${imgs.length == 1 ? '' : 'S'} — tap to zoom & rotate',
            style: AppTypography.label),
        const SizedBox(height: 8),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imgs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ImageThumb(images: imgs, index: i, size: 84),
          ),
        ),
      ]),
    );
  }

  Widget _field(String label, TextEditingController c) => TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        textAlign: label.isEmpty ? TextAlign.center : TextAlign.start,
        decoration: InputDecoration(
            labelText: label.isEmpty ? null : label,
            hintText: label.isEmpty ? '%' : null,
            isDense: true),
        style: AppTypography.numeric,
      );
}
