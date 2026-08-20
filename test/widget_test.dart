// Smoke tests for the valuation engine — the one piece of pure logic that must
// stay correct as the app grows. UI tests come later; this locks the maths.
import 'package:flutter_test/flutter_test.dart';
import 'package:donda_diamond/features/evaluation/domain/entities/enums.dart';
import 'package:donda_diamond/features/evaluation/domain/entities/lot_row.dart';
import 'package:donda_diamond/features/evaluation/domain/valuation.dart';

void main() {
  const service = ValuationService();

  test('yield-based bid matches the BRD lot-117 worked example', () {
    // 39.39ct rough, cleavage: header holds the rough, two children cut from it
    // — 11% @ \$28,000 + 5% @ \$13,500, 15% margin.
    const header = LotRow(id: 'h', planId: 'p', pieces: 1, roughCarats: 39.39);
    const oval = LotRow(
      id: 'a', planId: 'p', parentRowId: 'h', pieces: 1, usesParentRough: true,
      yieldPct: 11, pricePerPolishedCt: 28000,
    );
    const pear = LotRow(
      id: 'b', planId: 'p', parentRowId: 'h', pieces: 1, usesParentRough: true,
      yieldPct: 5, pricePerPolishedCt: 13500,
    );
    final v = service.valuePlanRows([header, oval, pear], marginPct: 15);

    // Break-even ≈ \$3,755/ct, bid ≈ \$3,191.75/ct.
    expect(v.breakEven, closeTo(3755, 2));
    expect(v.bid, closeTo(3191.75, 2));
  });

  test('pure rough is never treated as 100% polished', () {
    const rough = LotRow(
      id: 'r', planId: 'p', pieces: 1, roughCarats: 86.82,
      category: ValuationCategory.pureRough, directRoughPerCt: 81,
    );
    final v = service.valueRow(rough, marginPct: 15);
    expect(v.polishCarats, 0); // TE-009
    expect(v.breakEven, closeTo(81, 0.01));
  });

  test('rejection has zero value but keeps carats', () {
    const rej = LotRow(
      id: 'x', planId: 'p', pieces: 9, roughCarats: 173.38,
      category: ValuationCategory.rejection,
    );
    final v = service.valueRow(rej, marginPct: 15);
    expect(v.totalValue, 0);
    expect(v.roughCarats, 173.38); // TE-011
  });
}
