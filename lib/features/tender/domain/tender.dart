import 'package:equatable/equatable.dart';

/// One auction event at one tender house, identified by a sale code
/// (e.g. BST-2601-A). Header fields mirror the published list (BRD PART B).
class Tender extends Equatable {
  const Tender({
    required this.id,
    required this.saleCode,
    required this.house,
    required this.mine,
    required this.origin,
    required this.viewingsStart,
    required this.closure,
    required this.biddingPlatform,
    required this.declaredCarats,
    required this.lotCount,
    this.willBidCount = 0,
    this.doneCount = 0,
    this.currency = 'USD',
  });

  final String id;
  final String saleCode;
  final String house;
  final String mine;
  final String origin; // e.g. "Ekati, Canada"
  final DateTime viewingsStart;
  final DateTime closure;
  final String biddingPlatform; // e.g. rough.bonasbids.com
  final double declaredCarats;
  final int lotCount;
  final int willBidCount;
  final int doneCount;
  final String currency;

  @override
  List<Object?> get props => [id, saleCode, house, mine, origin, closure];
}
