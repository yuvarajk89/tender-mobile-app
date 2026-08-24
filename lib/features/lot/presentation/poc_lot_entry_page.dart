import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/image_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/persistence/local_store.dart';
import '../../evaluation/domain/entities/lot_row.dart';
import '../../evaluation/domain/grade_parser.dart';
import '../../evaluation/domain/grade_vocabulary.dart';
import '../../evaluation/domain/valuation.dart';
import '../../evaluation/presentation/valuation_providers.dart';
import '../../tender/presentation/tender_providers.dart';
import '../domain/lot.dart';
import 'lot_providers.dart';

/// ============================================================================
/// Lot entry — the approved POC chat-feed interaction, with the BRD extensions
/// layered on (BRD PART J):
///   • the 5 inputs: pieces · rough ct · grade · yield % · $/polished ct
///   • live BREAK-EVEN & BID in the header (BRD PART D)
///   • OR-plan tabs (TE-007) · sub-lot/bunch/child stones as feed rows (TE-004/5)
///   • the fancy-colour vocabulary (Colour/Clarity/Fluor/Shape) (TE-019)
///   • weight-mismatch warning (TE-033)
/// Interaction kept faithful to lot-entry-final.html: typed shorthand into a
/// feed, tap-picker fallback, ".." duplicates, camera in the input bar.
/// ============================================================================

const _uuid = Uuid();

// ─── theme-aware palette (gold "terminal" that follows the app theme) ──
class _P {
  static Color bg = const Color(0xFF08080A);
  static Color surface = const Color(0xFF0E0E12);
  static Color card = const Color(0xFF141418);
  static Color elevated = const Color(0xFF1A1A20);
  static Color input = const Color(0xFF111116);
  static Color accent = const Color(0xFFD4A853);
  static Color accentB = const Color(0xFFF0C95E);
  static Color accentGs = const Color(0x40D4A853);
  static Color ok = const Color(0xFF2DD4A0);
  static Color err = const Color(0xFFF87171);
  static Color info = const Color(0xFF60A5FA);
  static Color warn = const Color(0xFFFBBF24);
  static Color t1 = const Color(0xFFE8E6E3);
  static Color t2 = const Color(0xFF7A7A80);
  static Color t3 = const Color(0xFF4A4A50);
  static Color border = const Color(0xFF222228);
  static Color borderA = const Color(0x4DD4A853);
  static Color onAccent = const Color(0xFF08080A);

  static void apply(Brightness b) {
    if (b == Brightness.dark) {
      bg = const Color(0xFF08080A);
      surface = const Color(0xFF0E0E12);
      card = const Color(0xFF141418);
      elevated = const Color(0xFF1A1A20);
      input = const Color(0xFF111116);
      accent = const Color(0xFFD4A853);
      accentB = const Color(0xFFF0C95E);
      accentGs = const Color(0x40D4A853);
      ok = const Color(0xFF2DD4A0);
      err = const Color(0xFFF87171);
      info = const Color(0xFF60A5FA);
      warn = const Color(0xFFFBBF24);
      t1 = const Color(0xFFE8E6E3);
      t2 = const Color(0xFF7A7A80);
      t3 = const Color(0xFF4A4A50);
      border = const Color(0xFF222228);
      borderA = const Color(0x4DD4A853);
      onAccent = const Color(0xFF08080A);
    } else {
      bg = const Color(0xFFF6F7FB);
      surface = const Color(0xFFFFFFFF);
      card = const Color(0xFFFFFFFF);
      elevated = const Color(0xFFF0F2F8);
      input = const Color(0xFFF2F4F9);
      accent = const Color(0xFFA9812E);
      accentB = const Color(0xFF8A6A22);
      accentGs = const Color(0x33A9812E);
      ok = const Color(0xFF13A15A);
      err = const Color(0xFFD23B3B);
      info = const Color(0xFF2743B0);
      warn = const Color(0xFFC9820A);
      t1 = const Color(0xFF161A2B);
      t2 = const Color(0xFF5B627A);
      t3 = const Color(0xFF9098AE);
      border = const Color(0xFFE2E5EF);
      borderA = const Color(0x4DA9812E);
      onAccent = const Color(0xFFFFFFFF);
    }
  }

  static TextStyle mono(
          {double size = 14, FontWeight w = FontWeight.w600, Color? color, double ls = 0}) =>
      GoogleFonts.jetBrainsMono(
          fontSize: size, fontWeight: w, color: color ?? t1, letterSpacing: ls);
  static TextStyle ui(
          {double size = 14, FontWeight w = FontWeight.w500, Color? color, double ls = 0}) =>
      GoogleFonts.outfit(
          fontSize: size, fontWeight: w, color: color ?? t1, letterSpacing: ls);
}

// ─── grade slots (the BRD fancy vocabulary) ───────────────────────────
// Capture grade slots: Shape · Colour · Clarity (as confirmed — no Cut/Fluor).
const _slots = ['shape', 'colour', 'clarity'];
const _slotLabels = {
  'shape': 'Shape',
  'colour': 'Colour',
  'clarity': 'Clarity',
};
List<String> _optionsFor(String slot) => switch (slot) {
      'colour' => GradeVocabulary.colours,
      'clarity' => GradeVocabulary.clarities,
      'shape' => GradeVocabulary.shapes,
      _ => const [],
    };
// Grouped vocabulary for the tap-picker (from the BRD's observed lists).
const Map<String, List<Map<String, dynamic>>> _groups = {
  'colour': [
    {'g': 'Fancy yellow', 'items': ['FVOY', 'FVY', 'FIY', 'FSVY', 'FDOY', 'FBY', 'FY+', 'FY', 'FLY', 'FLY+']},
    {'g': 'Off-white', 'items': ['YZ', 'WX', 'UV']},
    {'g': 'Pink', 'items': ['FIPP', 'FPP', 'LPP', 'LBPP', 'FAINT PINK']},
  ],
  'clarity': [
    {'g': 'Very slight', 'items': ['VVS', 'VS', 'VS2']},
    {'g': 'Slight', 'items': ['SI', 'SI1', 'SI2']},
    {'g': 'Included', 'items': ['I1', 'I3']},
  ],
  'shape': [
    {'g': 'Common', 'items': ['RAD', 'SQ RAD', 'OVL', 'PEAR', 'ROUND']},
    {'g': 'Emerald / cushion', 'items': ['EM', 'SQ EM', 'LONG EM', 'CUSHION', 'CU', 'LONG CU']},
    {'g': 'Other', 'items': ['HEART']},
  ],
};

// ─── stone (a feed row = simple / bunch(pieces>1) / child) ─────────────
class _Stone {
  _Stone({
    required this.id,
    this.parentId,
    this.seq = 0,
    this.pieces = 1,
    this.roughCarats = 0,
    this.usesParentRough = false,
    this.colour = '',
    this.clarity = '',
    this.fluor = '',
    this.shape = '',
    this.note = '',
    this.yieldPct = 0,
    this.pricePerPolishedCt = 0,
    List<Uint8List>? images,
    this.videos = 0,
    this.raw = '',
  }) : images = images ?? [];

  String id;
  String? parentId;
  int seq;
  int pieces;
  double roughCarats;
  bool usesParentRough;
  String colour, clarity, fluor, shape, note;
  double yieldPct;
  double pricePerPolishedCt;
  List<Uint8List> images;
  int videos;
  String raw;

  bool get isBunch => pieces > 1;
  String get grade =>
      [colour, clarity, fluor, shape].where((s) => s.isNotEmpty).join(' ');

  LotRow toRow() => LotRow(
        id: id,
        planId: 'p',
        parentRowId: parentId,
        pieces: pieces,
        roughCarats: usesParentRough ? 0 : roughCarats,
        usesParentRough: usesParentRough,
        colour: colour,
        clarity: clarity,
        fluor: fluor,
        shape: shape,
        note: note,
        yieldPct: yieldPct,
        pricePerPolishedCt: pricePerPolishedCt,
      );

  _Stone clone(String newId, int n) => _Stone(
        id: newId,
        parentId: parentId,
        seq: n,
        pieces: pieces,
        roughCarats: roughCarats,
        usesParentRough: usesParentRough,
        colour: colour,
        clarity: clarity,
        fluor: fluor,
        shape: shape,
        note: note,
        yieldPct: yieldPct,
        pricePerPolishedCt: pricePerPolishedCt,
        images: List.of(images),
        videos: videos,
        raw: raw,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'parentId': parentId,
        'seq': seq,
        'pieces': pieces,
        'roughCarats': roughCarats,
        'usesParentRough': usesParentRough,
        'colour': colour,
        'clarity': clarity,
        'fluor': fluor,
        'shape': shape,
        'note': note,
        'yieldPct': yieldPct,
        'pricePerPolishedCt': pricePerPolishedCt,
        'images': images,
        'videos': videos,
        'raw': raw,
      };

  factory _Stone.fromMap(Map<String, dynamic> m) => _Stone(
        id: m['id'] as String? ?? _uuid.v4(),
        parentId: m['parentId'] as String?,
        seq: m['seq'] as int? ?? 0,
        pieces: m['pieces'] as int? ?? 1,
        roughCarats: (m['roughCarats'] as num?)?.toDouble() ?? 0,
        usesParentRough: m['usesParentRough'] as bool? ?? false,
        colour: m['colour'] as String? ?? '',
        clarity: m['clarity'] as String? ?? '',
        fluor: m['fluor'] as String? ?? '',
        shape: m['shape'] as String? ?? '',
        note: m['note'] as String? ?? '',
        yieldPct: (m['yieldPct'] as num?)?.toDouble() ?? 0,
        pricePerPolishedCt: (m['pricePerPolishedCt'] as num?)?.toDouble() ?? 0,
        images: (m['images'] as List?)?.cast<Uint8List>() ?? [],
        videos: m['videos'] as int? ?? 0,
        raw: m['raw'] as String? ?? '',
      );
}

class _Plan {
  _Plan(this.label, {this.isActive = false, List<_Stone>? stones})
      : stones = stones ?? [];
  String label;
  bool isActive;
  List<_Stone> stones;
}

// ─── page ──────────────────────────────────────────────────────────────
class PocLotEntryPage extends ConsumerStatefulWidget {
  const PocLotEntryPage({super.key, required this.tenderId, required this.lotId});
  final String tenderId;
  final String lotId;

  @override
  ConsumerState<PocLotEntryPage> createState() => _PocLotEntryPageState();
}

class _PocLotEntryPageState extends ConsumerState<PocLotEntryPage> {
  final _pcs = TextEditingController(text: '1');
  final _rough = TextEditingController();
  final _yield = TextEditingController();
  final _price = TextEditingController();
  final _code = TextEditingController();
  final _scroll = ScrollController();

  List<_Plan> _plans = [_Plan('Plan A', isActive: true)];
  int _active = 0;
  bool _seeded = false;
  ParsedGrade _parsed = const ParsedGrade();
  final List<Uint8List> _pendingImages = [];
  bool _childMode = false;
  String _time = '';
  Timer? _timer;
  OverlayEntry? _toast;

  _Plan get _plan => _plans[_active];
  double get _margin => ref.read(marginPctProvider);
  ValuationService get _svc => ref.read(valuationServiceProvider);

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _tick());
    final saved = MockData.savedStones[widget.lotId];
    if (saved != null && saved.isNotEmpty) {
      _plan.stones.addAll(saved.map(_Stone.fromMap));
    }
  }

  void _tick() {
    final n = DateTime.now();
    if (mounted) {
      setState(() => _time =
          '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _toast?.remove();
    for (final c in [_pcs, _rough, _yield, _price, _code]) {
      c.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  double _d(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
  int _i(TextEditingController c) => int.tryParse(c.text.trim()) ?? 1;

  _Stone? get _lastTop {
    for (var i = _plan.stones.length - 1; i >= 0; i--) {
      if (_plan.stones[i].parentId == null) return _plan.stones[i];
    }
    return null;
  }

  List<LotRow> get _activeRows => _plan.stones.map((s) => s.toRow()).toList();

  // ── add / duplicate ────────────────────────────────────────────────
  void _send() {
    final text = _code.text.trim();
    if (text.startsWith('..') && _plan.stones.isNotEmpty) {
      final n = int.tryParse(text.substring(2)) ?? 1;
      setState(() {
        final last = _plan.stones.last;
        for (var i = 0; i < n; i++) {
          _plan.stones.add(last.clone(_uuid.v4(), _plan.stones.length + 1));
        }
        _clear();
      });
      _toastMsg('Duplicated $n stone${n > 1 ? 's' : ''}');
      _scrollDown();
      return;
    }
    final g = GradeParser.parse(text);
    final rough = _d(_rough);
    if (!g.hasAny && rough == 0) {
      _toastMsg('Type a grade (e.g. FVY VS NON OVL) or a rough weight');
      return;
    }
    final child = _childMode && _lastTop != null;
    setState(() {
      _plan.stones.add(_Stone(
        id: _uuid.v4(),
        parentId: child ? _lastTop!.id : null,
        seq: _plan.stones.length + 1,
        pieces: _i(_pcs),
        roughCarats: child ? 0 : rough,
        usesParentRough: child,
        colour: g.colour,
        clarity: g.clarity,
        fluor: g.fluor,
        shape: g.shape,
        note: g.note,
        yieldPct: _d(_yield),
        pricePerPolishedCt: _d(_price),
        images: List.of(_pendingImages),
        raw: text,
      ));
      _clear();
    });
    _toastMsg(child ? 'Child stone added' : 'Stone #${_plan.stones.length} added');
    _scrollDown();
  }

  void _clear() {
    _code.clear();
    _rough.clear();
    _yield.clear();
    _price.clear();
    _pcs.text = '1';
    _parsed = const ParsedGrade();
    _pendingImages.clear();
  }

  void _scrollDown() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
        }
      });

  Future<void> _addPhoto() async {
    final bytes = await pickImageBytes(context);
    if (bytes == null) return;
    setState(() => _pendingImages.add(bytes));
  }

  /// Set one grade slot (colour/clarity/fluor/shape) into the typed line.
  void _setSlot(String slot, String code) {
    final current = _parsed.slot(slot);
    var text = _code.text;
    if (current.isNotEmpty) {
      text = text.replaceAll(RegExp('\\b$current\\b'), '');
    }
    text = '${text.trim()} $code'.trim().replaceAll(RegExp(r'\s+'), ' ');
    _code.text = text;
    setState(() => _parsed = GradeParser.parse(text));
  }

  /// The POC tab-picker: ONE sheet with Colour/Clarity/Fluor/Shape tabs,
  /// grouped selectable chips, a filled-dot per tab, and auto-advance to the
  /// next empty slot after a pick.
  void _openGradePicker(String startSlot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _P.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String tab = startSlot;
        final customCtl = TextEditingController();
        return StatefulBuilder(builder: (ctx, setSheet) {
          void pick(String code) {
            _setSlot(tab, code);
            final next =
                _slots.where((s) => _parsed.slot(s).isEmpty && s != tab).toList();
            if (next.isNotEmpty) {
              setSheet(() => tab = next.first);
            } else {
              Navigator.pop(ctx);
            }
          }

          return ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.72),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      color: _P.border, borderRadius: BorderRadius.circular(2))),
              // tabs
              Row(
                children: _slots.map((s) {
                  final activeTab = tab == s;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setSheet(() => tab = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: activeTab ? _P.accent : _P.border,
                                  width: activeTab ? 2 : 1)),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_slotLabels[s]!,
                                  style: _P.ui(
                                      size: 11,
                                      w: FontWeight.w600,
                                      color: activeTab ? _P.accentB : _P.t3)),
                              if (_parsed.slot(s).isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                        color: _P.ok, shape: BoxShape.circle)),
                              ],
                            ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
              // grouped chips
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final grp in _groups[tab]!) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
                            child: Text((grp['g'] as String).toUpperCase(),
                                style: _P.mono(
                                    size: 9, w: FontWeight.w700, color: _P.t3)),
                          ),
                          Wrap(spacing: 8, runSpacing: 8, children: [
                            for (final code in grp['items'] as List<String>)
                              _pickChip(code, _parsed.slot(tab) == code, pick),
                          ]),
                        ],
                      ]),
                ),
              ),
              // add-new
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: customCtl,
                      textCapitalization: TextCapitalization.characters,
                      style: _P.mono(size: 13, color: _P.t1),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: _P.input,
                        hintText: 'Add a new ${_slotLabels[tab]!.toLowerCase()}…',
                        hintStyle: _P.mono(size: 12, color: _P.t3),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _P.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _P.accent)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final v = GradeVocabulary.normalise(customCtl.text);
                      if (v.isNotEmpty) pick(v);
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          color: _P.accent,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('Add',
                          style: _P.ui(w: FontWeight.w700, color: _P.onAccent)),
                    ),
                  ),
                ]),
              ),
            ]),
          );
        });
      },
    );
  }

  Widget _pickChip(String code, bool selected, void Function(String) pick) =>
      GestureDetector(
        onTap: () => pick(code),
        child: Container(
          constraints: const BoxConstraints(minWidth: 52, minHeight: 46),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _P.accentGs : _P.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? _P.accent : _P.border, width: 1.5),
          ),
          child: Text(code,
              style: _P.mono(size: 14, color: selected ? _P.accentB : _P.t1)),
        ),
      );

  void _addPlan() => setState(() {
        for (final p in _plans) {
          p.isActive = false;
        }
        _plans.add(_Plan('Plan ${String.fromCharCode(65 + _plans.length)}',
            isActive: true));
        _active = _plans.length - 1;
      });

  void _save() {
    if (_plan.stones.isEmpty) {
      _toastMsg('Add at least one stone');
      return;
    }
    MockData.savedStones[widget.lotId] =
        _plan.stones.map((s) => s.toMap()).toList();
    LocalStore.I.persistStones();
    ref.invalidate(lotsProvider(widget.tenderId));
    _toastMsg('Lot saved — ${_plan.stones.length} stones');
    context.go('/tender/${widget.tenderId}');
  }

  void _toastMsg(String msg) {
    _toast?.remove();
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 54,
        left: 0,
        right: 0,
        child: IgnorePointer(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                  color: _P.elevated,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: _P.borderA)),
              child: Text(msg, style: _P.mono(size: 12, color: _P.accent)),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
    _toast = entry;
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (_toast == entry) {
        entry.remove();
        _toast = null;
      }
    });
  }

  // ── build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    _P.apply(Theme.of(context).brightness);
    final lot = ref.watch(lotProvider(widget.lotId)).valueOrNull;
    final tender = ref.watch(tenderProvider(widget.tenderId)).valueOrNull;
    final margin = ref.watch(marginPctProvider);
    final v = _svc.valuePlanRows(_activeRows, marginPct: margin);
    if (!_seeded && lot != null) _seeded = true;

    return Scaffold(
      backgroundColor: _P.bg,
      body: SafeArea(
        child: Column(
          children: [
            _statusBar(tender?.house ?? '—'),
            _header(lot, v, margin),
            _planTabs(),
            Expanded(child: _feed(lot)),
            _inputArea(),
          ],
        ),
      ),
    );
  }

  Widget _statusBar(String tenderName) => Container(
        constraints: const BoxConstraints(minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: _P.surface,
            border: Border(bottom: BorderSide(color: _P.border))),
        child: Row(children: [
          GestureDetector(
            onTap: () => context.go('/tender/${widget.tenderId}'),
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _P.elevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _P.border)),
              child: Text('‹', style: _P.ui(size: 15, color: _P.t2)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(tenderName,
                  style: _P.ui(size: 13, w: FontWeight.w600, color: _P.accent))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: _P.elevated, borderRadius: BorderRadius.circular(20)),
            child: Text('${_plan.stones.length} Stones',
                style: _P.mono(size: 11, w: FontWeight.w500, color: _P.t2)),
          ),
          const SizedBox(width: 8),
          Text(_time, style: _P.mono(size: 11, w: FontWeight.w500, color: _P.t3)),
        ]),
      );

  // Live BREAK-EVEN & BID header + weight mismatch (TE-033) + margin menu.
  Widget _header(Lot? lot, Valuation v, double margin) {
    final published = lot?.publishedCarats ?? 0;
    final weighed = lot?.weighedCarats;
    final mismatch = weighed != null &&
        published > 0 &&
        (weighed - published).abs() / published > 0.01;
    return Container(
      width: double.infinity,
      color: _P.surface,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('${lot?.lotName ?? 'Lot'} · ${lot?.sizeRange ?? ''}',
                style: _P.mono(size: 11, color: _P.t2),
                overflow: TextOverflow.ellipsis),
          ),
          _marginMenu(margin),
        ]),
        if (mismatch)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded, size: 14, color: _P.warn),
              const SizedBox(width: 4),
              Text(
                  'Weighed ${Fmt.carats(weighed)} vs published ${Fmt.carats(published)}',
                  style: _P.mono(size: 10, color: _P.warn)),
            ]),
          ),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BREAK-EVEN \$/ct',
                  style: _P.mono(size: 9, w: FontWeight.w700, color: _P.t3)),
              Text(Fmt.money(v.breakEven),
                  style: _P.mono(size: 20, w: FontWeight.w700, color: _P.t1)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('BID',
                style: _P.mono(size: 9, w: FontWeight.w700, color: _P.accent)),
            Text(Fmt.money(v.bid),
                style: _P.mono(size: 26, w: FontWeight.w800, color: _P.accent)),
          ]),
        ]),
      ]),
    );
  }

  Widget _marginMenu(double margin) => PopupMenuButton<double>(
        tooltip: 'Margin',
        color: _P.surface,
        onSelected: (m) => ref.read(marginPctProvider.notifier).state = m,
        itemBuilder: (_) => [
          for (final m in [10.0, 12.0, 15.0, 18.0, 20.0])
            PopupMenuItem(
                value: m,
                child: Text('${Fmt.percent(m)} margin',
                    style: _P.ui(color: _P.t1))),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: _P.elevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _P.border)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Margin ${Fmt.percent(margin)}',
                style: _P.mono(size: 10, w: FontWeight.w700, color: _P.t2)),
            Icon(Icons.expand_more, size: 14, color: _P.t2),
          ]),
        ),
      );

  // OR-plan tabs (TE-007).
  Widget _planTabs() => Container(
        color: _P.bg,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (var i = 0; i < _plans.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _active = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: i == _active ? _P.accentGs : _P.elevated,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: i == _active ? _P.accent : _P.border),
                      ),
                      child: Text(_plans[i].label,
                          style: _P.mono(
                              size: 11,
                              color: i == _active ? _P.accentB : _P.t2)),
                    ),
                  ),
              ]),
            ),
          ),
          GestureDetector(
            onTap: _addPlan,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.add, size: 20, color: _P.accent),
            ),
          ),
        ]),
      );

  // ── feed ────────────────────────────────────────────────────────────
  Widget _feed(Lot? lot) {
    final tops = _plan.stones.where((s) => s.parentId == null).toList();
    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
              color: _P.accentGs.withOpacity(_P.bg.computeLuminance() > 0.5 ? 0.4 : 1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _P.borderA)),
          child: Row(children: [
            Expanded(
                child: Text(lot?.lotName ?? 'Lot',
                    style: _P.mono(size: 14, w: FontWeight.w700, color: _P.accentB))),
            Text(lot?.lotRef ?? '', style: _P.ui(size: 11, color: _P.t2)),
          ]),
        ),
        if (tops.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
                child: Text('No stones yet — type a grade below.',
                    style: _P.ui(size: 13, color: _P.t2))),
          ),
        for (var i = 0; i < tops.length; i++)
          _stoneCard(tops[i], i + 1,
              _plan.stones.where((s) => s.parentId == tops[i].id).toList()),
      ],
    );
  }

  Widget _stoneCard(_Stone s, int index, List<_Stone> children) {
    final margin = _margin;
    final self = _svc.valueRow(s.toRow(), marginPct: margin);
    final rollup = children.isEmpty
        ? self
        : _svc.valuePlanRows(
            [s.toRow(), ...children.map((c) => c.toRow())],
            marginPct: margin);
    return GestureDetector(
      onTap: () => _openDetail(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: _P.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _P.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('#$index', style: _P.mono(size: 10, color: _P.t3)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(s.grade.isEmpty ? '(rough)' : s.grade,
                    style: _P.mono(size: 14, color: _P.accentB, ls: 1))),
            if (s.isBunch)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: _P.elevated, borderRadius: BorderRadius.circular(6)),
                child: Text('${s.pieces} STN',
                    style: _P.mono(size: 9, color: _P.warn)),
              ),
            Text(Fmt.carats(s.roughCarats), style: _P.mono(size: 12, color: _P.t1)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            if (s.yieldPct > 0)
              Text('${Fmt.percent(s.yieldPct)} @ ${Fmt.money(s.pricePerPolishedCt)}',
                  style: _P.mono(size: 10, color: _P.t2)),
            if (s.images.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text('📷 ${s.images.length}', style: _P.mono(size: 10, color: _P.info)),
            ],
            const Spacer(),
            Text('bid ${Fmt.money(rollup.bid)}',
                style: _P.mono(size: 11, color: _P.ok)),
          ]),
          for (final c in children)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 6),
              child: Row(children: [
                Icon(Icons.subdirectory_arrow_right, size: 14, color: _P.t3),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(c.grade,
                        style: _P.mono(size: 11, color: _P.t2))),
                Text('${Fmt.percent(c.yieldPct)} @ ${Fmt.money(c.pricePerPolishedCt)}',
                    style: _P.mono(size: 10, color: _P.t3)),
              ]),
            ),
          if (s.note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(s.note, style: _P.mono(size: 10, color: _P.t3)),
            ),
        ]),
      ),
    );
  }

  // ── input area ──────────────────────────────────────────────────────
  Widget _inputArea() {
    return Container(
      decoration: BoxDecoration(
          color: _P.surface,
          border: Border(top: BorderSide(color: _P.border))),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // parse chips (4 grade slots)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
            child: Row(children: [
              for (final slot in _slots) _chip(slot),
            ]),
          ),
          // 5 inputs: pcs · rough · yield · $/pol-ct  (+ grade typed below)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Row(children: [
              _mini('Pcs', _pcs, whole: true),
              const SizedBox(width: 6),
              _mini('Rough ct', _rough, enabled: !_childMode),
              const SizedBox(width: 6),
              _mini('Yield %', _yield),
              const SizedBox(width: 6),
              _mini('\$/pol ct', _price),
            ]),
          ),
          if (_pendingImages.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                child: Row(children: [
                  for (var i = 0; i < _pendingImages.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ImageThumb(
                          images: _pendingImages,
                          index: i,
                          size: 52,
                          onDelete: () =>
                              setState(() => _pendingImages.removeAt(i))),
                    ),
                ]),
              ),
            ),
          // code bar + camera + send
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
            child: Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: _P.input,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: _P.border, width: 2)),
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _code,
                        textCapitalization: TextCapitalization.characters,
                        autocorrect: false,
                        enableSuggestions: false,
                        onChanged: (t) =>
                            setState(() => _parsed = GradeParser.parse(t)),
                        onSubmitted: (_) => _send(),
                        cursorColor: _P.accent,
                        style: _P.mono(size: 14, w: FontWeight.w500, color: _P.t1, ls: 1),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'OVL FVY VS  ·  ..2 dup',
                          hintStyle:
                              _P.mono(size: 13, w: FontWeight.w400, color: _P.t3),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _addPhoto,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: _P.elevated,
                            shape: BoxShape.circle,
                            border: Border.all(color: _P.border)),
                        child: const Text('📷', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: _P.accent, shape: BoxShape.circle),
                  child: Icon(Icons.arrow_upward, color: _P.onAccent, size: 20),
                ),
              ),
            ]),
          ),
          // inline suggestion strip (POC style): chips for the next empty slot
          _suggestionStrip(),
          // child toggle + save
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: Row(children: [
              GestureDetector(
                onTap: _lastTop == null
                    ? null
                    : () => setState(() => _childMode = !_childMode),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _childMode ? _P.accentGs : _P.elevated,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: _childMode ? _P.accent : _P.border),
                  ),
                  child: Text('+ child of last rough',
                      style: _P.mono(
                          size: 10,
                          color: _lastTop == null
                              ? _P.t3
                              : (_childMode ? _P.accentB : _P.t2))),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: _P.elevated,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: _P.border)),
                  child: Text('✓ Save Lot',
                      style: _P.ui(size: 12, w: FontWeight.w700, color: _P.t2)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  /// Inline suggestion strip — the POC's fast chooser. Shows a label + a
  /// horizontal row of round chips for the FIRST empty grade slot (Shape →
  /// Colour → Clarity). Tap a chip → fills it → auto-advances to the next slot.
  /// Tapping the label opens the full grouped picker. When all slots are filled
  /// it shows a "✓ ready" hint.
  Widget _suggestionStrip() {
    final next = _slots.firstWhere((s) => _parsed.slot(s).isEmpty, orElse: () => '');
    return SizedBox(
      height: 46,
      child: next.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('✓ grade set — add weight & press ↑',
                    style: _P.mono(size: 11, color: _P.ok)),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
              child: Row(children: [
                GestureDetector(
                  onTap: () => _openGradePicker(next),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('${_slotLabels[next]!} ▾',
                        style: _P.mono(size: 9, color: _P.t3)),
                  ),
                ),
                for (final code in _optionsFor(next))
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => _setSlot(next, code),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 40),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _P.elevated,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: _P.border),
                        ),
                        child: Text(code, style: _P.mono(size: 12, color: _P.t1)),
                      ),
                    ),
                  ),
              ]),
            ),
    );
  }

  Widget _chip(String slot) {
    final v = _parsed.slot(slot);
    final on = v.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: GestureDetector(
        onTap: () => _openGradePicker(slot),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: on ? _P.accentGs : _P.elevated,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: on ? _P.accent : _P.border),
          ),
          child: Text(on ? v : _slotLabels[slot]!,
              style: _P.mono(size: 10, color: on ? _P.accentB : _P.t3)),
        ),
      ),
    );
  }

  Widget _mini(String label, TextEditingController c,
      {bool whole = false, bool enabled = true}) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 2),
          child: Text(label.toUpperCase(),
              style: _P.mono(size: 8, w: FontWeight.w600, color: _P.t3)),
        ),
        TextField(
          controller: c,
          enabled: enabled,
          keyboardType: TextInputType.numberWithOptions(decimal: !whole),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(whole ? r'[0-9]' : r'[0-9.]'))
          ],
          onChanged: (_) => setState(() {}),
          style: _P.mono(size: 13, w: FontWeight.w500, color: _P.t1),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: enabled ? _P.input : _P.bg,
            hintText: whole ? '1' : '0',
            hintStyle: _P.mono(size: 13, color: _P.t3),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _P.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _P.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _P.accent)),
          ),
        ),
      ]),
    );
  }

  // ── stone detail ────────────────────────────────────────────────────
  void _openDetail(_Stone s) {
    final v = _svc.valueRow(s.toRow(),
        marginPct: _margin,
        parentRoughCarats:
            s.usesParentRough ? _lastTop?.roughCarats : null);
    showModalBottomSheet(
      context: context,
      backgroundColor: _P.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.grade.isEmpty ? 'Stone' : s.grade,
                    style: _P.mono(size: 18, color: _P.accentB)),
                const SizedBox(height: 12),
                _row('Pieces', '${s.pieces}'),
                _row('Rough', Fmt.carats(s.roughCarats)),
                _row('Yield', Fmt.percent(s.yieldPct)),
                _row('\$ / polished ct', Fmt.money(s.pricePerPolishedCt)),
                if (s.note.isNotEmpty) _row('Note', s.note),
                Divider(color: _P.border, height: 24),
                _row('Break-even', Fmt.money(v.breakEven)),
                _row('Bid', Fmt.money(v.bid), accent: true),
                if (s.images.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('PHOTOS',
                      style: _P.ui(size: 11, w: FontWeight.w600, color: _P.t2)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (var i = 0; i < s.images.length; i++)
                      ImageThumb(images: s.images, index: i, size: 88),
                  ]),
                ],
                const SizedBox(height: 16),
                Row(children: [
                  _action('Edit', _P.accent, () {
                    Navigator.pop(ctx);
                    _edit(s);
                  }),
                  const SizedBox(width: 8),
                  _action('Add photo', _P.info, () async {
                    final b = await pickImageBytes(context);
                    if (b == null) return;
                    setState(() => s.images.add(b));
                    if (ctx.mounted) Navigator.pop(ctx);
                    _openDetail(s);
                  }),
                  const SizedBox(width: 8),
                  _action('Delete', _P.err, () {
                    setState(() {
                      _plan.stones
                          .removeWhere((x) => x.id == s.id || x.parentId == s.id);
                      for (var i = 0; i < _plan.stones.length; i++) {
                        _plan.stones[i].seq = i + 1;
                      }
                    });
                    Navigator.pop(ctx);
                    _toastMsg('Stone deleted');
                  }),
                ]),
              ]),
        ),
      ),
    );
  }

  void _edit(_Stone s) {
    setState(() {
      _code.text = s.grade;
      _pcs.text = '${s.pieces}';
      _rough.text = s.roughCarats == 0 ? '' : '${s.roughCarats}';
      _yield.text = s.yieldPct == 0 ? '' : '${s.yieldPct}';
      _price.text = s.pricePerPolishedCt == 0
          ? ''
          : s.pricePerPolishedCt.toStringAsFixed(0);
      _parsed = GradeParser.parse(_code.text);
      _plan.stones.removeWhere((x) => x.id == s.id);
      for (var i = 0; i < _plan.stones.length; i++) {
        _plan.stones[i].seq = i + 1;
      }
    });
    _toastMsg('Editing — modify and send');
  }

  Widget _row(String k, String val, {bool accent = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: _P.ui(size: 13, color: _P.t2)),
          Text(val,
              style: _P.mono(
                  size: 14,
                  w: FontWeight.w600,
                  color: accent ? _P.accent : _P.t1)),
        ]),
      );

  Widget _action(String label, Color fg, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _P.elevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _P.border)),
            child: Text(label, style: _P.ui(size: 12, w: FontWeight.w600, color: fg)),
          ),
        ),
      );
}

// ─── grade attribute picker sheet (text chips + add-new) ───────────────
