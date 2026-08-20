/// App-wide constants and defaults. Values that are "settings" in the real
/// product (margin, base currency) live here as defaults for the mock.
class AppConstants {
  AppConstants._();

  static const String appName = 'Donda Diamond';
  static const String appTagline = 'Rough-Diamond Tender Evaluation';

  /// The BRD's single most important rule (TE-001): bid = break-even × (1 − margin).
  /// Currently 15%. In the live app this becomes a per-tender / per-lot setting.
  static const double defaultMarginPct = 15.0;

  static const String baseCurrency = 'USD';

  /// MOCK MODE. While true, all repositories return in-memory sample data and
  /// no network call is made. Flip to false once the live MeghaOS API is wired.
  /// See docs/05-DATA-LAYER.md.
  static const bool useMockData = true;

  /// Base URL for the live MeghaOS backend (used only when useMockData=false).
  static const String apiBaseUrl = 'https://portal.apps.tekfilo.com/api';
}
