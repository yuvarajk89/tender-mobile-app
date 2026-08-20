import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_tender_repository.dart';
import '../domain/tender.dart';
import '../domain/tender_repository.dart';

/// The repository provider is the single swap point: change this one line to a
/// live implementation and the whole feature moves to the real API.
final tenderRepositoryProvider = Provider<TenderRepository>((ref) {
  return const MockTenderRepository();
});

/// All tenders for the current trip.
final tendersProvider = FutureProvider<List<Tender>>((ref) {
  return ref.watch(tenderRepositoryProvider).getTenders();
});

/// A single tender by id.
final tenderProvider =
    FutureProvider.family<Tender?, String>((ref, id) {
  return ref.watch(tenderRepositoryProvider).getTender(id);
});
