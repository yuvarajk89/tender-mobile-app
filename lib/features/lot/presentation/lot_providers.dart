import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_lot_repository.dart';
import '../domain/lot.dart';
import '../domain/lot_repository.dart';

final lotRepositoryProvider = Provider<LotRepository>((ref) {
  return const MockLotRepository();
});

/// Lots for a tender.
final lotsProvider =
    FutureProvider.family<List<Lot>, String>((ref, tenderId) {
  return ref.watch(lotRepositoryProvider).getLots(tenderId);
});

/// A single lot.
final lotProvider = FutureProvider.family<Lot?, String>((ref, lotId) {
  return ref.watch(lotRepositoryProvider).getLot(lotId);
});

/// The work list (lots in progress).
final workListProvider = FutureProvider<List<Lot>>((ref) {
  return ref.watch(lotRepositoryProvider).getWorkList();
});

/// Filter toggle on the lot list: show only Will-Bid lots (TE-030).
final willBidFilterProvider = StateProvider<bool>((ref) => false);
