import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/evaluation/domain/entities/enums.dart';
import '../../features/lot/domain/lot.dart';
import '../mock/mock_data.dart';

/// Local, on-device persistence so the app behaves like the live ERP within the
/// device: lots you CREATE and stones you SAVE survive an app restart.
///
/// It stores only the *deltas* on top of the seed data:
///   • created (off-list) lots  — ids start with "new-"
///   • saved stones per lot     — incl. photos (base64)
///
/// Backed by shared_preferences (JSON). Small and dependency-light; when the
/// real MeghaOS backend is wired this whole class is replaced by API calls.
class LocalStore {
  LocalStore._();
  static final LocalStore I = LocalStore._();

  static const _kLots = 'created_lots_v1';
  static const _kCaptures = 'lot_captures_v1';
  static const _kWillBid = 'willbid_override_v1';
  static const _kMaster = 'grade_master_v1';

  SharedPreferences? _p;

  Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  /// Load persisted deltas into the in-memory store at startup.
  void load() {
    final lotsJson = _p?.getString(_kLots);
    if (lotsJson != null) {
      for (final m in jsonDecode(lotsJson) as List) {
        final lot = _lotFromMap(m as Map<String, dynamic>);
        if (!MockData.lots.any((l) => l.id == lot.id)) MockData.lots.add(lot);
      }
    }
    final capJson = _p?.getString(_kCaptures);
    if (capJson != null) {
      (jsonDecode(capJson) as Map<String, dynamic>).forEach((lotId, c) {
        MockData.captures[lotId] = _captureFromJson(c as Map<String, dynamic>);
      });
    }
    final wbJson = _p?.getString(_kWillBid);
    if (wbJson != null) {
      (jsonDecode(wbJson) as Map<String, dynamic>)
          .forEach((lotId, v) => MockData.willBidOverride[lotId] = v as bool);
    }
    final mJson = _p?.getString(_kMaster);
    if (mJson != null) {
      final m = jsonDecode(mJson) as Map<String, dynamic>;
      void apply(String k, List<String> target) {
        final v = (m[k] as List?)?.cast<String>();
        if (v != null) {
          target
            ..clear()
            ..addAll(v);
        }
      }
      apply('shape', MockData.shapes);
      apply('colour', MockData.colours);
      apply('clarity', MockData.clarities);
    }
  }

  Future<void> persistWillBid() async =>
      _p?.setString(_kWillBid, jsonEncode(MockData.willBidOverride));

  Future<void> persistMaster() async => _p?.setString(
      _kMaster,
      jsonEncode({
        'shape': MockData.shapes,
        'colour': MockData.colours,
        'clarity': MockData.clarities,
      }));

  Future<void> persistLots() async {
    final created =
        MockData.lots.where((l) => l.id.startsWith('new-')).map(_lotToMap).toList();
    await _p?.setString(_kLots, jsonEncode(created));
  }

  Future<void> persistCaptures() async {
    final out = <String, dynamic>{};
    MockData.captures.forEach((lotId, c) => out[lotId] = _captureToJson(c));
    await _p?.setString(_kCaptures, jsonEncode(out));
  }

  // ── Capture (de)serialization — images as base64, rest passes through ──
  Map<String, dynamic> _captureToJson(Map<String, dynamic> c) => {
        ...c,
        'images': (c['images'] as List? ?? [])
            .map((b) => base64Encode(b as Uint8List))
            .toList(),
      };

  Map<String, dynamic> _captureFromJson(Map<String, dynamic> c) => {
        ...c,
        'images': (c['images'] as List? ?? [])
            .map((e) => base64Decode(e as String))
            .toList(),
      };

  // ── Lot (de)serialization ──────────────────────────────────────────
  Map<String, dynamic> _lotToMap(Lot l) => {
        'id': l.id,
        'tenderId': l.tenderId,
        'lotRef': l.lotRef,
        'sizeRange': l.sizeRange,
        'lotName': l.lotName,
        'publishedPieces': l.publishedPieces,
        'publishedCarats': l.publishedCarats,
        'weighedCarats': l.weighedCarats,
        'willBid': l.willBid,
        'workStatus': l.workStatus.index,
      };

  Lot _lotFromMap(Map<String, dynamic> m) => Lot(
        id: m['id'] as String,
        tenderId: m['tenderId'] as String,
        lotRef: m['lotRef'] as String,
        sizeRange: m['sizeRange'] as String? ?? '',
        lotName: m['lotName'] as String? ?? 'Lot',
        publishedPieces: m['publishedPieces'] as int? ?? 1,
        publishedCarats: (m['publishedCarats'] as num?)?.toDouble() ?? 0,
        weighedCarats: (m['weighedCarats'] as num?)?.toDouble(),
        willBid: m['willBid'] as bool? ?? false,
        workStatus: LotWorkStatus.values[(m['workStatus'] as int?) ?? 0],
      );
}
