import 'entities/enums.dart';
import 'entities/lot_row.dart';

/// The result of valuing a single row (or a rolled-up plan). Every figure here
/// is DERIVED — the app computes it and never asks the buyer for it (TE-003).
class Valuation {
  const Valuation({
    required this.pieces,
    required this.roughCarats,
    required this.polishCarats,
    required this.polishSize,
    required this.totalValue,
    required this.breakEven,
    required this.bid,
    required this.category,
  });

  final int pieces;
  final double roughCarats;
  final double polishCarats;
  final double polishSize; // avg finished stone size = polish ÷ pieces
  final double totalValue; // expected polished value
  final double breakEven; // max $/ct payable on the rough
  final double bid; // break-even less margin — the number

  /// pureRough / rejection values must be kept OUT of yield-based averages.
  final ValuationCategory category;

  bool get contributesToYieldAverages =>
      category == ValuationCategory.yieldBased && polishCarats > 0;

  static const Valuation zero = Valuation(
    pieces: 0,
    roughCarats: 0,
    polishCarats: 0,
    polishSize: 0,
    totalValue: 0,
    breakEven: 0,
    bid: 0,
    category: ValuationCategory.yieldBased,
  );
}

/// The single source of truth for the evaluation maths (BRD PART D).
///
///   rough × yield%        = polish carats
///   polish × $/polished   = polished value
///   polished ÷ rough      = break-even rough $/ct
///   break-even × (1−m)    = BID          (m = margin, default 15% — TE-001)
///
/// This class is pure (no Flutter, no IO) so it is trivially unit-testable and
/// identical whether data comes from the mock or the live API.
class ValuationService {
  const ValuationService();

  /// Value one row. [parentRoughCarats] is supplied for child stones that
  /// borrow the parent's rough weight (TE-004).
  Valuation valueRow(
    LotRow row, {
    required double marginPct,
    double? parentRoughCarats,
  }) {
    final rough = row.usesParentRough
        ? (parentRoughCarats ?? 0)
        : row.roughCarats;
    final margin = marginPct / 100.0;

    switch (row.category) {
      case ValuationCategory.rejection:
        // Zero value, but pieces & carats still count (TE-011).
        return Valuation(
          pieces: row.pieces,
          roughCarats: rough,
          polishCarats: 0,
          polishSize: 0,
          totalValue: 0,
          breakEven: 0,
          bid: 0,
          category: ValuationCategory.rejection,
        );

      case ValuationCategory.pureRough:
        // No polish estimate. Total is either a flat figure or rough×$/ct.
        final total = row.directTotal ??
            (rough * (row.directRoughPerCt ?? 0));
        final breakEven = rough > 0 ? total / rough : 0.0;
        return Valuation(
          pieces: row.pieces,
          roughCarats: rough,
          polishCarats: 0, // never treat rough as 100% polished (TE-009)
          polishSize: 0,
          totalValue: total,
          breakEven: breakEven,
          bid: breakEven * (1 - margin),
          category: ValuationCategory.pureRough,
        );

      case ValuationCategory.yieldBased:
        final polish = rough * (row.yieldPct / 100.0);
        final total = polish * row.pricePerPolishedCt;
        final breakEven = rough > 0 ? total / rough : 0.0;
        final polishSize = row.pieces > 0 ? polish / row.pieces : 0.0;
        return Valuation(
          pieces: row.pieces,
          roughCarats: rough,
          polishCarats: polish,
          polishSize: polishSize,
          totalValue: total,
          breakEven: breakEven,
          bid: breakEven * (1 - margin),
          category: ValuationCategory.yieldBased,
        );
    }
  }

  /// Roll a set of rows (a plan) up into one plan-level valuation.
  ///
  /// Parent rows that only exist to hold children (a cleavage/sub-lot header)
  /// are skipped; their children carry the value. Pure-rough and rejection are
  /// kept out of the yield-based polish/size averages (TE-009).
  Valuation valuePlanRows(
    List<LotRow> rows, {
    required double marginPct,
  }) {
    // Index children by parent so we can pass the parent's rough weight down.
    final byParent = <String, List<LotRow>>{};
    for (final r in rows) {
      if (r.parentRowId != null) {
        byParent.putIfAbsent(r.parentRowId!, () => []).add(r);
      }
    }

    int pieces = 0;
    double rough = 0, polish = 0, total = 0;

    for (final r in rows) {
      final hasChildren = byParent.containsKey(r.id);
      if (hasChildren) {
        // Header row: contributes its rough weight once; value AND piece count
        // come from the children (so polish size averages over real stones).
        rough += r.roughCarats;
        continue;
      }
      final v = valueRow(
        r,
        marginPct: marginPct,
        parentRoughCarats: r.usesParentRough
            ? _findParentRough(rows, r.parentRowId)
            : null,
      );
      pieces += v.pieces;
      // A child that borrows parent rough must not double-count that rough.
      if (!r.usesParentRough) rough += v.roughCarats;
      polish += v.polishCarats;
      total += v.totalValue;
    }

    final breakEven = rough > 0 ? total / rough : 0.0;
    final polishSize = pieces > 0 && polish > 0 ? polish / pieces : 0.0;
    return Valuation(
      pieces: pieces,
      roughCarats: rough,
      polishCarats: polish,
      polishSize: polishSize,
      totalValue: total,
      breakEven: breakEven,
      bid: breakEven * (1 - marginPct / 100.0),
      category: ValuationCategory.yieldBased,
    );
  }

  double? _findParentRough(List<LotRow> rows, String? parentId) {
    if (parentId == null) return null;
    for (final r in rows) {
      if (r.id == parentId) return r.roughCarats;
    }
    return null;
  }
}
