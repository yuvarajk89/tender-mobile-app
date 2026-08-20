import '../../../data/mock/mock_data.dart';
import '../domain/tender.dart';
import '../domain/tender_repository.dart';

/// Reads the in-memory sample set. A small artificial delay makes the mock feel
/// like a real network call (spinners show, so the UI is exercised honestly).
class MockTenderRepository implements TenderRepository {
  const MockTenderRepository();

  @override
  Future<List<Tender>> getTenders() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return MockData.tenders;
  }

  @override
  Future<Tender?> getTender(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    for (final t in MockData.tenders) {
      if (t.id == id) return t;
    }
    return null;
  }
}
