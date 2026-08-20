import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/valuation.dart';

/// The derived-numbers panel: everything the app works out from the 5 inputs.
/// The BID is the hero — biggest, greenest figure (BRD "five taps and a number").
class ValuationPanel extends StatelessWidget {
  const ValuationPanel({super.key, required this.v, required this.marginPct});
  final Valuation v;
  final double marginPct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.page,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dark('Polish ct', Fmt.carats(v.polishCarats)),
              _dark('Polish size', Fmt.carats(v.polishSize)),
              _dark('Total', Fmt.money(v.totalValue)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(color: Colors.white24, height: 1),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BREAK-EVEN \$/ct', style: _lbl),
                    Text(Fmt.money(v.breakEven),
                        style: AppTypography.h1.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('BID  (−${Fmt.percent(marginPct)})',
                      style: _lbl.copyWith(color: AppColors.accentLight)),
                  Text(Fmt.money(v.bid), style: AppTypography.bidNumber),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const TextStyle _lbl = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: Colors.white60,
  );

  Widget _dark(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: _lbl),
        const SizedBox(height: 2),
        Text(value,
            style: AppTypography.numeric.copyWith(color: Colors.white)),
      ],
    );
  }
}
