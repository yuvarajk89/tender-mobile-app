import 'tender.dart';

/// Contract the presentation layer depends on. The mock implementation reads
/// [MockData]; the future live implementation calls the MeghaOS tender API.
/// Presentation never knows which one it got.
abstract interface class TenderRepository {
  Future<List<Tender>> getTenders();
  Future<Tender?> getTender(String id);
}
