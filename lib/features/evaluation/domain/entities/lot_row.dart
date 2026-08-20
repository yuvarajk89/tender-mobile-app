import 'package:equatable/equatable.dart';
import 'enums.dart';

/// The recursive, self-describing evaluation row (BRD PART K).
///
/// ONE structure covers all four names the docs invented — simple stone,
/// sub-lot, bunch, and child stone. The difference is only:
///   • [pieces]           — a bunch is a row with pieces > 1 (TE-005)
///   • [parentRowId]      — child stones hang off a parent (TE-004)
///   • [usesParentRough]  — child stones borrow the parent's rough weight;
///                          sub-lots carry their own.
///
/// Do NOT split this into four tables. See docs/features/lot-entry.md.
class LotRow extends Equatable {
  const LotRow({
    required this.id,
    required this.planId,
    this.parentRowId,
    this.pieces = 1,
    this.roughCarats = 0,
    this.usesParentRough = false,
    this.colour = '',
    this.clarity = '',
    this.fluor = '',
    this.shape = '',
    this.note = '',
    this.yieldPct = 0,
    this.pricePerPolishedCt = 0,
    this.category = ValuationCategory.yieldBased,
    this.directRoughPerCt, // pure-rough: $/ct on the rough directly
    this.directTotal, // pure-rough: a flat total, bypassing the chain
  });

  final String id;
  final String planId;
  final String? parentRowId;

  final int pieces;
  final double roughCarats;
  final bool usesParentRough;

  // Structured grade fields (TE-019) — replaces the Excel free-text cell.
  final String colour;
  final String clarity;
  final String fluor;
  final String shape;
  final String note;

  // The buyer's core inputs.
  final double yieldPct; // TE-002: stored, not derived from a formula
  final double pricePerPolishedCt;

  final ValuationCategory category;
  final double? directRoughPerCt;
  final double? directTotal;

  bool get isChild => parentRowId != null;
  bool get isBunch => pieces > 1;

  LotRow copyWith({
    int? pieces,
    double? roughCarats,
    bool? usesParentRough,
    String? colour,
    String? clarity,
    String? fluor,
    String? shape,
    String? note,
    double? yieldPct,
    double? pricePerPolishedCt,
    ValuationCategory? category,
    double? directRoughPerCt,
    double? directTotal,
  }) {
    return LotRow(
      id: id,
      planId: planId,
      parentRowId: parentRowId,
      pieces: pieces ?? this.pieces,
      roughCarats: roughCarats ?? this.roughCarats,
      usesParentRough: usesParentRough ?? this.usesParentRough,
      colour: colour ?? this.colour,
      clarity: clarity ?? this.clarity,
      fluor: fluor ?? this.fluor,
      shape: shape ?? this.shape,
      note: note ?? this.note,
      yieldPct: yieldPct ?? this.yieldPct,
      pricePerPolishedCt: pricePerPolishedCt ?? this.pricePerPolishedCt,
      category: category ?? this.category,
      directRoughPerCt: directRoughPerCt ?? this.directRoughPerCt,
      directTotal: directTotal ?? this.directTotal,
    );
  }

  /// A clone with a fresh id (used when duplicating a stone via `..`).
  LotRow copyWithId(String newId) => LotRow(
        id: newId,
        planId: planId,
        parentRowId: parentRowId,
        pieces: pieces,
        roughCarats: roughCarats,
        usesParentRough: usesParentRough,
        colour: colour,
        clarity: clarity,
        fluor: fluor,
        shape: shape,
        note: note,
        yieldPct: yieldPct,
        pricePerPolishedCt: pricePerPolishedCt,
        category: category,
        directRoughPerCt: directRoughPerCt,
        directTotal: directTotal,
      );

  /// A one-line grade summary, e.g. "FVY VS NON OVL".
  String get gradeSummary =>
      [colour, clarity, fluor, shape].where((s) => s.isNotEmpty).join(' ');

  @override
  List<Object?> get props => [
        id,
        planId,
        parentRowId,
        pieces,
        roughCarats,
        usesParentRough,
        colour,
        clarity,
        fluor,
        shape,
        note,
        yieldPct,
        pricePerPolishedCt,
        category,
        directRoughPerCt,
        directTotal,
      ];
}
