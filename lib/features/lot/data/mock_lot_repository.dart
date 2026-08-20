import '../../../data/mock/mock_data.dart';
import '../../evaluation/domain/entities/enums.dart';
import '../domain/lot.dart';
import '../domain/lot_repository.dart';

class MockLotRepository implements LotRepository {
  const MockLotRepository();

  @override
  Future<List<Lot>> getLots(String tenderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.lotsForTender(tenderId);
  }

  @override
  Future<Lot?> getLot(String lotId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    for (final l in MockData.lots) {
      if (l.id == lotId) return l;
    }
    return null;
  }

  @override
  Future<List<Lot>> getWorkList() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.lots
        .where((l) => l.workStatus == LotWorkStatus.inProgress)
        .toList();
  }
}
