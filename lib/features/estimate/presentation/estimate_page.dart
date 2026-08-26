import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final grade = MockData.gradeSummary(lot.id);
    final margin = (c['marginPct'] as num?)?.toDouble() ?? 15;
    final estimated = c['status'] == 'estimated';

    // Final = TEAM estimate if entered, else the SPOT rollup from splits.
    final rough = lot.publishedCarats;
    final tY = (c['teamYield'] as num?)?.toDouble() ?? 0;
    final tP = (c['teamPrice'] as num?)?.toDouble() ?? 0;
    double polish, value, rEff;
    if (tY > 0 && tP > 0) {
      rEff = rough;
      polish = rough * tY / 100;
      value = polish * tP;
    } else {
      double sR = 0, sPol = 0, sVal = 0;
      for (final s in MockData.subsOf(lot.id)) {
        final wt = (s['wt'] as num?)?.toDouble() ?? 0;
        final y = (s['yieldPct'] as num?)?.toDouble() ?? 0;
        final p = (s['pricePerCt'] as num?)?.toDouble() ?? 0;
        sR += wt; sPol += wt * y / 100; sVal += (wt * y / 100) * p;
      }
      rEff = sR > 0 ? sR : rough;
      polish = sPol;
      value = sVal;
    }
    final breakEven = rEff > 0 ? value / rEff : 0.0;
    final bid = breakEven * (1 - margin / 100);
    final yieldPct = rEff > 0 ? polish / rEff * 100 : 0;
    final priceCt = polish > 0 ? value / polish : 0;

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
                PillTag(text: 'BID ${Fmt.money2(bid)}', color: AppColors.success, bg: AppColors.accentLight)
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
                _mini('\$/pol ct', Fmt.money2(priceCt)),
                _mini('Break-even', Fmt.money2(breakEven)),
                _mini('Max bid', Fmt.money2(bid), accent: true),
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
  late final _tYield = TextEditingController(
      text: ((_c['teamYield'] as num?)?.toDouble() ?? 0) == 0 ? '' : '${_c['teamYield']}');
  late final _tPrice = TextEditingController(
      text: ((_c['teamPrice'] as num?)?.toDouble() ?? 0) == 0 ? '' : '${_c['teamPrice']}');
  late final _margin = TextEditingController(
      text: '${((_c['marginPct'] as num?)?.toDouble() ?? 15).toStringAsFixed(0)}');

  @override
  void dispose() {
    _tYield.dispose();
    _tPrice.dispose();
    _margin.dispose();
    super.dispose();
  }

  double _d(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final rough = widget.lot.publishedCarats;
    final margin = _d(_margin);

    // SPOT — rolled up from the splits' on-spot yields (only some lots have it).
    final subs = MockData.subsOf(widget.lot.id);
    double sRough = 0, sPolish = 0, sValue = 0;
    for (final s in subs) {
      final wt = (s['wt'] as num?)?.toDouble() ?? 0;
      final y = (s['yieldPct'] as num?)?.toDouble() ?? 0;
      final p = (s['pricePerCt'] as num?)?.toDouble() ?? 0;
      sRough += wt;
      sPolish += wt * y / 100;
      sValue += (wt * y / 100) * p;
    }
    final hasSpot = sValue > 0;
    final spotRough = sRough > 0 ? sRough : rough;
    final spotBreakEven = spotRough > 0 ? sValue / spotRough : 0.0;
    final spotBid = spotBreakEven * (1 - margin / 100);

    // TEAM — the estimate team's own numbers (lot level).
    final tY = _d(_tYield), tP = _d(_tPrice);
    final tPolish = rough * tY / 100;
    final tValue = tPolish * tP;
    final tBreakEven = rough > 0 ? tValue / rough : 0.0;
    final tBid = tBreakEven * (1 - margin / 100);
    final hasTeam = tValue > 0;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(widget.lot.lotRef, style: AppTypography.h2)),
            _field('Margin %', _margin, width: 96),
          ]),
          Text('${widget.lot.lotName} · ${widget.lot.publishedPieces} stns · ${Fmt.carats(rough)}',
              style: AppTypography.caption),
          _capturedPhotos(),
          const SizedBox(height: AppSpacing.md),

          // SPOT estimate (only when present).
          if (hasSpot) ...[
            _estCard(
              title: 'SPOT (buyer at stall)',
              tint: AppColors.accent,
              polish: sPolish, value: sValue, breakEven: spotBreakEven, bid: spotBid,
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // TEAM estimate — always editable, for comparison / final.
          Text('YOUR ESTIMATE', style: AppTypography.label),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            Expanded(child: _field('Yield %', _tYield)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _field('\$ / polished ct', _tPrice)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          _estCard(
            title: 'YOUR CALC',
            tint: AppColors.primary,
            polish: tPolish, value: tValue, breakEven: tBreakEven, bid: tBid,
          ),

          // Comparison (only if both exist).
          if (hasSpot && hasTeam) ...[
            const SizedBox(height: AppSpacing.md),
            _compareBar(spotBid, tBid),
          ],

          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
                _c['teamYield'] = tY;
                _c['teamPrice'] = tP;
                _c['marginPct'] = margin;
                _c['status'] = 'estimated';
                LocalStore.I.persistCaptures();
                widget.ref.invalidate(lotsProvider(widget.tenderId));
                Navigator.pop(context);
              },
              child: const Text('Confirm estimate'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ]),
      ),
    );
  }

  // Compact result card: polish · value · break-even · MAX BID.
  Widget _estCard({
    required String title,
    required Color tint,
    required double polish,
    required double value,
    required double breakEven,
    required double bid,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border(left: BorderSide(color: tint, width: 3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTypography.label.copyWith(color: tint)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _cell('Polish', '${polish.toStringAsFixed(3)} ct')),
          Expanded(child: _cell('Value', Fmt.money2(value))),
          Expanded(child: _cell('Break-even', Fmt.money2(breakEven))),
          Expanded(child: _cell('MAX BID', Fmt.money2(bid), big: true)),
        ]),
      ]),
    );
  }

  Widget _cell(String k, String v, {bool big = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k.toUpperCase(),
              style: AppTypography.caption.copyWith(color: Colors.white54, fontSize: 9)),
          const SizedBox(height: 2),
          Text(v,
              style: (big
                      ? AppTypography.numeric.copyWith(
                          color: AppColors.accentLight, fontWeight: FontWeight.w800)
                      : AppTypography.numeric.copyWith(color: Colors.white))
                  .copyWith(fontSize: big ? 15 : 13)),
        ],
      );

  // Spot vs Your bid, with the difference.
  Widget _compareBar(double spotBid, double teamBid) {
    final diff = teamBid - spotBid;
    final up = diff >= 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: context.scheme.outlineVariant),
      ),
      child: Row(children: [
        Expanded(child: _cmp('Spot bid', Fmt.money2(spotBid), AppColors.accent)),
        Icon(Icons.compare_arrows, color: context.scheme.outline),
        Expanded(child: _cmp('Your bid', Fmt.money2(teamBid), AppColors.primary)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('DIFF', style: AppTypography.caption.copyWith(fontSize: 9)),
          Text('${up ? '+' : ''}${Fmt.money2(diff)}',
              style: AppTypography.numeric.copyWith(
                  color: up ? AppColors.success : AppColors.danger)),
        ]),
      ]),
    );
  }

  Widget _cmp(String k, String v, Color c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k.toUpperCase(), style: AppTypography.caption.copyWith(fontSize: 9)),
          Text(v, style: AppTypography.numeric.copyWith(color: c)),
        ],
      );

  // Captured photos — the estimate team taps to view HQ, zoom & rotate to judge
  // size / shape / colour before estimating.
  Widget _capturedPhotos() {
    final imgs = MockData.allPhotos(widget.lot.id);
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

  Widget _field(String label, TextEditingController c, {double? width}) {
    final f = TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(labelText: label, isDense: true),
      style: AppTypography.numeric,
    );
    return width == null ? f : SizedBox(width: width, child: f);
  }
}
