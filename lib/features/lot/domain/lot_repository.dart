import 'lot.dart';

abstract interface class LotRepository {
  Future<List<Lot>> getLots(String tenderId);
  Future<Lot?> getLot(String lotId);

  /// Lots the buyer is actively working right now (the work list, TE-031).
  Future<List<Lot>> getWorkList();
}
