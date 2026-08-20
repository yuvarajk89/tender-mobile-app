import 'package:equatable/equatable.dart';
import '../../evaluation/domain/entities/enums.dart';
import '../../evaluation/domain/entities/lot_plan.dart';

/// A tender item as published by the house — the top-level unit the buyer
/// evaluates. Holds one or more [LotPlan]s (the "OR" scenarios, TE-007).
class Lot extends Equatable {
  const Lot({
    required this.id,
    required this.tenderId,
    required this.lotRef,
    required this.sizeRange,
    required this.lotName,
    required this.publishedPieces,
    required this.publishedCarats,
    this.weighedCarats,
    this.willBid = false,
    this.workStatus = LotWorkStatus.notStarted,
    this.plans = const [],
    // Post-auction capture (TE-028).
    this.openingPrice,
    this.ourBidPerCt,
    this.resultPerCt,
    this.outcome = LotOutcome.pending,
  });

  final String id;
  final String tenderId;
  final String lotRef; // BST-2601-A-117
  final String sizeRange; // "+10.80CT"
  final String lotName; // "SINGLE COLOURED GEM"
  final int publishedPieces;
  final double publishedCarats;
  final double? weighedCarats; // buyer's own weight (TE-033)

  final bool willBid;
  final LotWorkStatus workStatus;
  final List<LotPlan> plans;

  final double? openingPrice;
  final double? ourBidPerCt;
  final double? resultPerCt;
  final LotOutcome outcome;

  LotPlan? get activePlan {
    for (final p in plans) {
      if (p.isActive) return p;
    }
    return plans.isNotEmpty ? plans.first : null;
  }

  bool get hasMultiplePlans => plans.length > 1;

  /// The weight the buyer works from — their own if weighed, else published.
  double get workingCarats => weighedCarats ?? publishedCarats;

  @override
  List<Object?> get props => [id, tenderId, lotRef, willBid, workStatus, plans];
}
