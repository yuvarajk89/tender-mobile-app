import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/valuation.dart';

/// The pure valuation engine — shared everywhere a bid is computed.
final valuationServiceProvider =
    Provider<ValuationService>((ref) => const ValuationService());

/// The margin setting (TE-001). Currently a single app-wide value; the live app
/// will make this per-tender / per-lot. Exposed as state so the "what-if" slider
/// on the entry screen can move it and the bid re-computes live.
final marginPctProvider =
    StateProvider<double>((ref) => AppConstants.defaultMarginPct);
