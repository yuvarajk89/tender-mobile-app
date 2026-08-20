import 'package:equatable/equatable.dart';
import 'lot_row.dart';

/// A competing cutting scenario for a lot — the "OR" container (BRD TE-007).
///
/// In Excel this is literally the word "OR" typed between two blocks of rows.
/// Here it is a real object: a lot holds several plans, exactly one is
/// [isActive] (the one the bid is based on); the rest are kept for comparison.
class LotPlan extends Equatable {
  const LotPlan({
    required this.id,
    required this.lotId,
    required this.label,
    this.isActive = false,
    this.rows = const [],
  });

  final String id;
  final String lotId;
  final String label; // e.g. "Plan A — two stones"
  final bool isActive;
  final List<LotRow> rows;

  /// Top-level rows (sub-lots / simple stones); children are nested under them.
  List<LotRow> get topRows => rows.where((r) => r.parentRowId == null).toList();

  List<LotRow> childrenOf(String rowId) =>
      rows.where((r) => r.parentRowId == rowId).toList();

  LotPlan copyWith({String? label, bool? isActive, List<LotRow>? rows}) {
    return LotPlan(
      id: id,
      lotId: lotId,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
      rows: rows ?? this.rows,
    );
  }

  @override
  List<Object?> get props => [id, lotId, label, isActive, rows];
}
