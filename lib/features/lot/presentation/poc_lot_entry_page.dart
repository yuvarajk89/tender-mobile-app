import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/image_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/persistence/local_store.dart';
import '../../tender/presentation/tender_providers.dart';
import 'lot_providers.dart';

/// ============================================================================
/// FAITHFUL PORT of the client-approved POC — `lot-entry-final.html`.
/// Same palette, fonts (Outfit + JetBrains Mono), data (shape/color/clarity),
/// parse chips, tab-picker sheet with shape SVGs, ".." duplicate, camera buttons,
/// stone cards + stone-detail sheet, and toast. Kept 1:1 on purpose — this is the
/// screen the customer signed off. BRD extensions (pieces/yield/break-even/bid/
/// OR-plans/child stones) are layered on top ONLY after re-confirmation.
/// ============================================================================

// ─── palette — THEME-AWARE ───────────────────────────────────────────
// The terminal keeps the POC's gold "code" character, but its surface/text
// stack now follows the app's light/dark theme. `apply()` is called at the top
// of build() with the active Brightness, so light mode gives a clean light
// terminal and dark mode gives the original near-black POC look.
class _P {
  // Initialised to the dark values; overwritten by apply() each build.
  static Color bg = const Color(0xFF08080A);
  static Color surface = const Color(0xFF0E0E12);
  static Color card = const Color(0xFF141418);
  static Color elevated = const Color(0xFF1A1A20);
  static Color active = const Color(0xFF2A2A32);
  static Color input = const Color(0xFF111116);
  static Color accent = const Color(0xFFD4A853);
  static Color accentB = const Color(0xFFF0C95E);
  static Color accentD = const Color(0xFF9A7A3A);
  static Color accentG = const Color(0x1FD4A853);
  static Color accentGs = const Color(0x40D4A853);
  static Color ok = const Color(0xFF2DD4A0);
  static Color err = const Color(0xFFF87171);
  static Color info = const Color(0xFF60A5FA);
  static Color t1 = const Color(0xFFE8E6E3);
  static Color t2 = const Color(0xFF7A7A80);
  static Color t3 = const Color(0xFF4A4A50);
  static Color t4 = const Color(0xFF333338);
  static Color border = const Color(0xFF222228);
  static Color borderA = const Color(0x4DD4A853);
  static Color onAccent = const Color(0xFF08080A); // ink on the gold buttons

  static void apply(Brightness b) {
    if (b == Brightness.dark) {
      bg = const Color(0xFF08080A);
      surface = const Color(0xFF0E0E12);
      card = const Color(0xFF141418);
      elevated = const Color(0xFF1A1A20);
      active = const Color(0xFF2A2A32);
      input = const Color(0xFF111116);
      accent = const Color(0xFFD4A853);
      accentB = const Color(0xFFF0C95E);
      accentD = const Color(0xFF9A7A3A);
      accentG = const Color(0x1FD4A853);
      accentGs = const Color(0x40D4A853);
      ok = const Color(0xFF2DD4A0);
      err = const Color(0xFFF87171);
      info = const Color(0xFF60A5FA);
      t1 = const Color(0xFFE8E6E3);
      t2 = const Color(0xFF7A7A80);
      t3 = const Color(0xFF4A4A50);
      t4 = const Color(0xFF333338);
      border = const Color(0xFF222228);
      borderA = const Color(0x4DD4A853);
      onAccent = const Color(0xFF08080A);
    } else {
      bg = const Color(0xFFF6F7FB);
      surface = const Color(0xFFFFFFFF);
      card = const Color(0xFFFFFFFF);
      elevated = const Color(0xFFF0F2F8);
      active = const Color(0xFFE2E5EF);
      input = const Color(0xFFF2F4F9);
      accent = const Color(0xFFA9812E); // darker gold reads on white
      accentB = const Color(0xFF8A6A22);
      accentD = const Color(0xFFC9A85E);
      accentG = const Color(0x1FA9812E);
      accentGs = const Color(0x33A9812E);
      ok = const Color(0xFF13A15A);
      err = const Color(0xFFD23B3B);
      info = const Color(0xFF2743B0);
      t1 = const Color(0xFF161A2B);
      t2 = const Color(0xFF5B627A);
      t3 = const Color(0xFF9098AE);
      t4 = const Color(0xFFC4C9D6);
      border = const Color(0xFFE2E5EF);
      borderA = const Color(0x4DA9812E);
      onAccent = const Color(0xFFFFFFFF);
    }
  }

  static TextStyle mono({
    double size = 14,
    FontWeight w = FontWeight.w600,
    Color? color,
    double ls = 0,
  }) =>
      GoogleFonts.jetBrainsMono(
          fontSize: size, fontWeight: w, color: color ?? t1, letterSpacing: ls);

  static TextStyle ui({
    double size = 14,
    FontWeight w = FontWeight.w500,
    Color? color,
    double ls = 0,
  }) =>
      GoogleFonts.outfit(
          fontSize: size, fontWeight: w, color: color ?? t1, letterSpacing: ls);
}

// ─── data (verbatim from the POC) ────────────────────────────────────
const _attrs = ['shape', 'color', 'clarity'];
const _labels = {'shape': 'Shape', 'color': 'Color', 'clarity': 'Clarity'};

const Map<String, Map<String, String>> _codes = {
  'shape': {
    'RD': 'Round', 'OV': 'Oval', 'PR': 'Pear', 'CU': 'Cushion', 'PN': 'Princess',
    'EM': 'Emerald', 'MQ': 'Marquise', 'RN': 'Radiant', 'HT': 'Heart',
    'AS': 'Asscher', 'TR': 'Trillion', 'BG': 'Baguette', 'MC': 'Macle',
    'SW': 'Sawable', 'MKE': 'Makeable', 'IR': 'Irregular',
  },
  'color': {
    'D': 'D', 'E': 'E', 'F': 'F', 'G': 'G', 'H': 'H', 'I': 'I', 'J': 'J',
    'K': 'K', 'L': 'L', 'M': 'M', 'N': 'N', 'O': 'O', 'P': 'P', 'Q': 'Q',
    'R': 'R', 'S': 'S', 'T': 'T', 'U': 'U', 'V': 'V', 'W': 'W', 'X': 'X',
    'Y': 'Y', 'Z': 'Z', 'FY': 'F.Yellow', 'FP': 'F.Pink', 'FB': 'F.Blue',
    'FBR': 'F.Brown', 'FG': 'F.Green', 'FO': 'F.Orange',
  },
  'clarity': {
    'FL': 'FL', 'IF': 'IF', 'VVS1': 'VVS1', 'VVS2': 'VVS2', 'VS1': 'VS1',
    'VS2': 'VS2', 'SI1': 'SI1', 'SI2': 'SI2', 'SI3': 'SI3', 'I1': 'I1',
    'I2': 'I2', 'I3': 'I3',
  },
};

const Map<String, List<Map<String, dynamic>>> _groups = {
  'shape': [
    {'g': 'Popular', 'items': ['RD', 'OV', 'PR', 'CU', 'PN', 'EM']},
    {'g': 'Fancy', 'items': ['MQ', 'RN', 'HT', 'AS', 'TR', 'BG']},
    {'g': 'Rough', 'items': ['MC', 'SW', 'MKE', 'IR']},
  ],
  'color': [
    {'g': 'Colorless', 'items': ['D', 'E', 'F']},
    {'g': 'Near Colorless', 'items': ['G', 'H', 'I', 'J']},
    {'g': 'Faint', 'items': ['K', 'L', 'M']},
    {'g': 'Very Light', 'items': ['N', 'O', 'P', 'Q', 'R']},
    {'g': 'Light', 'items': ['S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']},
    {'g': 'Fancy', 'items': ['FY', 'FP', 'FB', 'FBR', 'FG', 'FO']},
  ],
  'clarity': [
    {'g': 'Flawless', 'items': ['FL', 'IF']},
    {'g': 'VV Slight', 'items': ['VVS1', 'VVS2']},
    {'g': 'V Slight', 'items': ['VS1', 'VS2']},
    {'g': 'Slight', 'items': ['SI1', 'SI2', 'SI3']},
    {'g': 'Included', 'items': ['I1', 'I2', 'I3']},
  ],
};

const Map<String, String> _svgs = {
  'RD': '<circle cx="14" cy="14" r="11"/>',
  'OV': '<ellipse cx="14" cy="14" rx="8" ry="11"/>',
  'PR': '<path d="M14 3C14 3 5 11 5 17c0 4 4 7 9 7s9-3 9-7C23 11 14 3 14 3z"/>',
  'CU': '<rect x="3" y="3" width="22" height="22" rx="7"/>',
  'PN': '<rect x="3" y="3" width="22" height="22" rx="1"/>',
  'EM': '<rect x="2" y="5" width="24" height="18" rx="3"/>',
  'MQ': '<ellipse cx="14" cy="14" rx="7" ry="12"/>',
  'RN': '<rect x="3" y="3" width="22" height="22" rx="3"/>',
  'HT': '<path d="M14 24C14 24 3 17 3 10c0-3.5 2.5-6 5.5-6C11 4 14 7 14 7s3-3 5.5-3C22.5 4 25 6.5 25 10c0 7-11 14-11 14z"/>',
  'AS': '<rect x="4" y="4" width="20" height="20" rx="2"/>',
  'TR': '<polygon points="14,3 25,25 3,25"/>',
  'BG': '<rect x="4" y="7" width="20" height="14" rx="1"/>',
  'MC': '<polygon points="14,2 26,14 14,26 2,14"/>',
  'SW': '<polygon points="14,3 24,10 20,24 8,24 4,10"/>',
  'MKE': '<polygon points="14,4 22,10 22,22 6,22 6,10"/>',
  'IR': '<polygon points="8,4 20,6 24,16 16,26 4,20"/>',
};

String _shapeSvg(String code, Color stroke) {
  final path = _svgs[code] ?? '';
  final hex = '#${(stroke.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 28 28" '
      'fill="none" stroke="$hex" stroke-width="1.5">$path</svg>';
}

// ─── stone model ─────────────────────────────────────────────────────
class _Stone {
  _Stone({
    required this.num,
    required this.attrs,
    required this.weight,
    required this.price,
    required this.raw,
    List<Uint8List>? images,
    this.videos = 0,
  }) : images = images ?? [];
  int num;
  Map<String, String> attrs;
  String weight;
  String price;
  String raw;
  List<Uint8List> images; // real photos (bytes)
  int videos; // mock count (video capture is live-build only)

  String get codeStr => _attrs.map((a) => attrs[a] ?? '—').join(' ');
  _Stone clone(int n) => _Stone(
      num: n,
      attrs: Map.of(attrs),
      weight: weight,
      price: price,
      raw: raw,
      images: List.of(images),
      videos: videos);

  Map<String, dynamic> toMap() => {
        'num': num,
        'attrs': attrs,
        'weight': weight,
        'price': price,
        'raw': raw,
        'images': images,
        'videos': videos,
      };

  factory _Stone.fromMap(Map<String, dynamic> m) => _Stone(
        num: m['num'] as int,
        attrs: Map<String, String>.from(m['attrs'] as Map),
        weight: m['weight'] as String? ?? '',
        price: m['price'] as String? ?? '',
        raw: m['raw'] as String? ?? '',
        images: (m['images'] as List?)?.cast<Uint8List>() ?? [],
        videos: m['videos'] as int? ?? 0,
      );
}

// ─── page ────────────────────────────────────────────────────────────
class PocLotEntryPage extends ConsumerStatefulWidget {
  const PocLotEntryPage({super.key, required this.tenderId, required this.lotId});
  final String tenderId;
  final String lotId;

  @override
  ConsumerState<PocLotEntryPage> createState() => _PocLotEntryPageState();
}

class _PocLotEntryPageState extends ConsumerState<PocLotEntryPage> {
  final _weight = TextEditingController();
  final _price = TextEditingController();
  final _code = TextEditingController();
  final _scroll = ScrollController();

  final List<_Stone> _stones = [];
  Map<String, String> _parsed = {};
  final List<Uint8List> _pendingImages = []; // real photos for the next stone
  String _time = '';
  Timer? _timer;
  OverlayEntry? _toast;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _tick());
    // Reload any stones already saved on this lot (session store) so reopening
    // a lot shows what you entered before.
    final saved = MockData.savedStones[widget.lotId];
    if (saved != null) {
      _stones.addAll(saved.map(_Stone.fromMap));
    }
  }

  void _tick() {
    final n = DateTime.now();
    final hh = n.hour.toString().padLeft(2, '0');
    final mm = n.minute.toString().padLeft(2, '0');
    if (mounted) setState(() => _time = '$hh:$mm');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _toast?.remove();
    for (final c in [_weight, _price, _code]) {
      c.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  // ─── parse (order-independent slot fill) ───────────────────────────
  Map<String, String> _parseCode(String text) {
    final res = <String, String>{};
    final slots = List<String>.from(_attrs);
    for (final tok in text.trim().toUpperCase().split(RegExp(r'\s+'))) {
      if (tok.isEmpty) continue;
      for (var i = 0; i < slots.length; i++) {
        if (_codes[slots[i]]!.containsKey(tok)) {
          res[slots[i]] = tok;
          slots.removeAt(i);
          break;
        }
      }
    }
    return res;
  }

  String? _nextAttr() {
    for (final a in _attrs) {
      if (_parsed[a] == null) return a;
    }
    return null;
  }

  void _onInput(String t) => setState(() => _parsed = _parseCode(t));

  // ─── send / duplicate ──────────────────────────────────────────────
  void _sendStone() {
    final text = _code.text.trim();
    if (text.startsWith('..') && _stones.isNotEmpty) {
      final n = int.tryParse(text.substring(2)) ?? 1;
      setState(() {
        for (var i = 0; i < n; i++) {
          _stones.add(_stones.last.clone(_stones.length + 1));
        }
        _clear();
      });
      _showToast('Duplicated $n stone${n > 1 ? 's' : ''}');
      _scrollDown();
      return;
    }
    final attrs = _parseCode(text);
    if (attrs['shape'] == null) {
      _showToast('Enter at least Shape');
      return;
    }
    setState(() {
      _stones.add(_Stone(
        num: _stones.length + 1,
        attrs: attrs,
        weight: _weight.text.trim(),
        price: _price.text.trim(),
        raw: text,
        images: List.of(_pendingImages),
      ));
      _clear();
    });
    _showToast('Stone #${_stones.length} added');
    _scrollDown();
  }

  void _clear() {
    _code.clear();
    _weight.clear();
    _price.clear();
    _parsed = {};
    _pendingImages.clear();
  }

  void _scrollDown() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut);
        }
      });

  void _insertSug(String code) {
    _code.text = '${_code.text.trim()} $code '.replaceAll(RegExp(r'\s+'), ' ');
    _onInput(_code.text);
  }

  Future<void> _addPhoto() async {
    final bytes = await pickImageBytes(context);
    if (bytes == null) return;
    setState(() => _pendingImages.add(bytes));
  }

  // ─── toast (top-centre pill, like the POC) ─────────────────────────
  void _showToast(String msg) {
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
                border: Border.all(color: _P.borderA),
              ),
              child: Text(msg, style: _P.mono(size: 12, color: _P.accent)),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
    _toast = entry;
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (_toast == entry) {
        entry.remove();
        _toast = null;
      }
    });
  }

  // ─── build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    _P.apply(Theme.of(context).brightness); // terminal follows the app theme
    final lot = ref.watch(lotProvider(widget.lotId)).valueOrNull;
    final tender = ref.watch(tenderProvider(widget.tenderId)).valueOrNull;
    return Scaffold(
      backgroundColor: _P.bg,
      body: SafeArea(
        child: Column(
          children: [
            _statusBar(tender?.house ?? '—'),
            Expanded(child: _feed(lot?.lotName ?? 'Lot', lot?.lotRef ?? '')),
            _inputArea(),
          ],
        ),
      ),
    );
  }

  Widget _statusBar(String tenderName) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _P.surface,
        border: Border(bottom: BorderSide(color: _P.border)),
      ),
      child: Row(children: [
        _iconBtn('‹', () => context.go('/tender/${widget.tenderId}')),
        const SizedBox(width: 8),
        Expanded(
          child: Text(tenderName,
              style: _P.ui(size: 13, w: FontWeight.w600, color: _P.accent)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
              color: _P.elevated, borderRadius: BorderRadius.circular(20)),
          child: Text('${_stones.length} Stones',
              style: _P.mono(size: 11, w: FontWeight.w500, color: _P.t2)),
        ),
        const SizedBox(width: 8),
        Text(_time, style: _P.mono(size: 11, w: FontWeight.w500, color: _P.t3)),
      ]),
    );
  }

  Widget _iconBtn(String glyph, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _P.elevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _P.border),
        ),
        child: Text(glyph, style: _P.ui(size: 15, color: _P.t2)),
      ),
    );
  }

  // ─── feed ──────────────────────────────────────────────────────────
  Widget _feed(String lotName, String lotRef) {
    final now = TimeOfDay.now().format(context);
    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      children: [
        Center(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
          child: Text('— $now —', style: _P.mono(size: 11, color: _P.t3)),
        )),
        // lot banner (gold)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _P.accentG,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _P.borderA),
          ),
          child: Row(children: [
            Expanded(
              child: Text(lotName,
                  style: _P.mono(size: 14, w: FontWeight.w700, color: _P.accentB)),
            ),
            Text(lotRef, style: _P.ui(size: 11, color: _P.t2)),
          ]),
        ),
        for (final s in _stones) _stoneCard(s),
      ],
    );
  }

  Widget _stoneCard(_Stone s) {
    return GestureDetector(
      onTap: () => _openStoneDetail(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _P.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _P.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: _P.ok, width: 3)),
              ),
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('Stone ${s.num}',
                        style: _P.mono(size: 10, color: _P.ok)),
                    const Spacer(),
                    if (s.weight.isNotEmpty)
                      Text('${s.weight} ct',
                          style: _P.mono(size: 12, color: _P.t1)),
                  ]),
                  const SizedBox(height: 3),
                  Text(s.codeStr, style: _P.mono(size: 14, color: _P.t1, ls: 1.5)),
                  const SizedBox(height: 3),
                  Row(children: [
                    if (s.price.isNotEmpty)
                      Text('\$${s.price}/ct',
                          style: _P.mono(size: 10, color: _P.accent)),
                    if (s.images.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text('📷 ${s.images.length}',
                          style: _P.mono(size: 10, color: _P.info)),
                    ],
                    if (s.videos > 0) ...[
                      const SizedBox(width: 8),
                      Text('🎬 ${s.videos}',
                          style: _P.mono(size: 10, color: _P.info)),
                    ],
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── input area ────────────────────────────────────────────────────
  Widget _inputArea() {
    final ready = _attrs.every((a) => _parsed[a] != null);
    return Container(
      decoration: BoxDecoration(
        color: _P.surface,
        border: Border(top: BorderSide(color: _P.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _parseChips(),
            // mini fields: Weight (ct) / Price ($/ct)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 2),
              child: Row(children: [
                _mini('Weight (ct)', _weight, '0.00'),
                const SizedBox(width: 6),
                _mini('Price (\$/ct)', _price, '0'),
              ]),
            ),
            if (_pendingImages.isNotEmpty) _mediaStrip(),
            _inputBar(ready),
            _sugStrip(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    if (_stones.isEmpty) {
                      _showToast('Add at least one stone');
                      return;
                    }
                    // Persist to the session store, then refresh the Lots tab
                    // so the count + done status show up.
                    MockData.savedStones[widget.lotId] =
                        _stones.map((s) => s.toMap()).toList();
                    LocalStore.I.persistStones(); // survives restart
                    ref.invalidate(lotsProvider(widget.tenderId));
                    _showToast('Lot saved — ${_stones.length} stones');
                    context.go('/tender/${widget.tenderId}');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: _P.elevated,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: _P.border)),
                    padding: const EdgeInsets.all(10),
                  ),
                  child: Text('✓ Save Lot & Start Next',
                      style: _P.ui(size: 12, w: FontWeight.w700, color: _P.t2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _parseChips() {
    final next = _nextAttr();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      child: Row(
        children: _attrs.map((a) {
          final v = _parsed[a];
          final Color bg, fg, bd;
          if (v != null) {
            bg = _P.accentGs;
            fg = _P.accentB;
            bd = _P.accentD;
          } else if (a == next) {
            bg = _P.active;
            fg = _P.t2;
            bd = _P.t3;
          } else {
            bg = _P.elevated;
            fg = _P.t3;
            bd = _P.border;
          }
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => _openTabPicker(a),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: bd),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('${_labels[a]!.toUpperCase()} ',
                      style: _P.mono(size: 7, color: fg.withOpacity(0.6))),
                  Text(v ?? '?', style: _P.mono(size: 10, color: fg)),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _mini(String label, TextEditingController c, String hint) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            child: Text(label.toUpperCase(),
                style: _P.ui(size: 8, w: FontWeight.w600, color: _P.t3)),
          ),
          TextField(
            controller: c,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            style: _P.mono(size: 13, w: FontWeight.w500, color: _P.t1),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: _P.input,
              hintText: hint,
              hintStyle: _P.mono(size: 13, color: _P.t3),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _P.border, width: 1.5)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _P.border, width: 1.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _P.accent, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediaStrip() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
        child: Row(
          children: List.generate(_pendingImages.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ImageThumb(
                images: _pendingImages,
                index: i,
                size: 54,
                onDelete: () => setState(() => _pendingImages.removeAt(i)),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _inputBar(bool ready) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      child: Row(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _P.input,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: _P.border, width: 2),
            ),
            padding: const EdgeInsets.only(left: 12, right: 4),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _code,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  enableSuggestions: false,
                  onChanged: _onInput,
                  onSubmitted: (_) => _sendStone(),
                  cursorColor: _P.accent,
                  style: _P.mono(size: 14, w: FontWeight.w500, color: _P.t1, ls: 1),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false, // the dark code-wrap provides the fill
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'RD G VS1',
                    hintStyle: _P.mono(size: 14, w: FontWeight.w400, color: _P.t3),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              _camBtn('📷', _addPhoto),
              const SizedBox(width: 4),
              _camBtn('🎬', () => _showToast('Video capture — live build'),
                  small: true),
            ]),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: _sendStone,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _P.accent,
              shape: BoxShape.circle,
              boxShadow: ready
                  ? [BoxShadow(color: _P.accentGs, blurRadius: 6, spreadRadius: 2)]
                  : null,
            ),
            child: Icon(Icons.arrow_upward, color: _P.onAccent, size: 18),
          ),
        ),
      ]),
    );
  }

  Widget _camBtn(String glyph, VoidCallback onTap, {bool small = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _P.elevated,
          shape: BoxShape.circle,
          border: Border.all(color: _P.border),
        ),
        child: Text(glyph, style: TextStyle(fontSize: small ? 12 : 14)),
      ),
    );
  }

  Widget _sugStrip() {
    final next = _nextAttr();
    final children = <Widget>[];
    if (next == null) {
      children.add(GestureDetector(
        onTap: _sendStone,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
              color: _P.accentGs,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: _P.accent)),
          child: Text('✓ Add Stone', style: _P.mono(size: 12, color: _P.accentB)),
        ),
      ));
    } else {
      children.add(GestureDetector(
        onTap: () => _openTabPicker(next),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Text('${_labels[next]} ▾', style: _P.mono(size: 8, color: _P.t3)),
        ),
      ));
      for (final c in _codes[next]!.keys.take(7)) {
        children.add(Padding(
          padding: const EdgeInsets.only(left: 5),
          child: GestureDetector(
            onTap: () => _insertSug(c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              constraints: const BoxConstraints(minHeight: 36),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _P.elevated,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: _P.border)),
              child: Text(c, style: _P.mono(size: 12, color: _P.t1)),
            ),
          ),
        ));
      }
    }
    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
        child: Row(children: children),
      ),
    );
  }

  // ─── tab picker bottom sheet ───────────────────────────────────────
  void _openTabPicker(String startTab) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _P.surface,
      barrierColor: Colors.black.withOpacity(0.6),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        var tab = startTab;
        return StatefulBuilder(builder: (ctx, setSheet) {
          void pick(String code) {
            final old = _parsed[tab];
            var text = _code.text;
            if (old != null) {
              text = text.replaceAll(RegExp('\\b$old\\b'), '');
            }
            text = '${text.trim()} $code '.replaceAll(RegExp(r'\s+'), ' ');
            _code.text = text;
            _onInput(text);
            final nextUnfilled =
                _attrs.where((a) => _parsed[a] == null && a != tab).toList();
            if (nextUnfilled.isNotEmpty) {
              setSheet(() => tab = nextUnfilled.first);
            } else {
              Navigator.pop(ctx);
            }
          }

          return ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: _P.active,
                        borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                  child: Row(children: [
                    Text('Select Attribute',
                        style: _P.ui(size: 16, w: FontWeight.w700, color: _P.t1)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: _P.elevated, shape: BoxShape.circle),
                        child: Text('✕', style: _P.ui(size: 14, color: _P.t2)),
                      ),
                    ),
                  ]),
                ),
                // tabs
                Container(
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: _P.border))),
                  child: Row(
                    children: _attrs.map((a) {
                      final active = tab == a;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setSheet(() => tab = a),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: active ? _P.accent : Colors.transparent,
                                      width: 2)),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_labels[a]!,
                                      style: _P.ui(
                                          size: 10,
                                          w: FontWeight.w600,
                                          color: active ? _P.accentB : _P.t3)),
                                  if (_parsed[a] != null) ...[
                                    const SizedBox(width: 3),
                                    Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                            color: _P.ok, shape: BoxShape.circle)),
                                  ],
                                ]),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final grp in _groups[tab]!) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
                            child: Text((grp['g'] as String).toUpperCase(),
                                style: _P.ui(
                                    size: 9, w: FontWeight.w700, color: _P.t3)),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final code in grp['items'] as List)
                                _sheetChip(tab, code as String, pick),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _sheetChip(String cat, String code, void Function(String) pick) {
    final selected = _parsed[cat] == code;
    final border = selected ? _P.accent : _P.border;
    final fg = selected ? _P.accentB : _P.t1;
    if (cat == 'shape' && _svgs.containsKey(code)) {
      return GestureDetector(
        onTap: () => pick(code),
        child: Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? _P.accentGs : _P.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SvgPicture.string(_shapeSvg(code, selected ? _P.accentB : _P.t2),
                width: 22, height: 22),
            const SizedBox(height: 3),
            Text(code, style: _P.ui(size: 9, w: FontWeight.w500, color: fg)),
          ]),
        ),
      );
    }
    return GestureDetector(
      onTap: () => pick(code),
      child: Container(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 46),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _P.accentGs : _P.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Text(code, style: _P.mono(size: 14, color: fg)),
      ),
    );
  }

  // ─── stone detail sheet ────────────────────────────────────────────
  void _openStoneDetail(_Stone s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _P.surface,
      barrierColor: Colors.black.withOpacity(0.6),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                          color: _P.active,
                          borderRadius: BorderRadius.circular(2)))),
              Text('Stone ${s.num}',
                  style: _P.ui(size: 16, w: FontWeight.w700, color: _P.t1)),
              const SizedBox(height: 12),
              for (final a in _attrs)
                _detailRow(_labels[a]!,
                    s.attrs[a] != null ? '${s.attrs[a]} · ${_codes[a]![s.attrs[a]]}' : '—'),
              _detailRow('Weight', s.weight.isNotEmpty ? '${s.weight} ct' : '—'),
              _detailRow('Price', s.price.isNotEmpty ? '\$${s.price}/ct' : '—'),
              const SizedBox(height: 14),
              Text('PHOTOS & VIDEOS',
                  style: _P.ui(size: 11, w: FontWeight.w600, color: _P.t2)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (var i = 0; i < s.images.length; i++)
                  ImageThumb(images: s.images, index: i, size: 92),
                _addThumb('📷', 'Add', () async {
                  final bytes = await pickImageBytes(context);
                  if (bytes == null) return;
                  setState(() => s.images.add(bytes));
                  if (ctx.mounted) Navigator.pop(ctx);
                  _openStoneDetail(s);
                }),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _detailAction('Edit', _P.accent, _P.borderA, () {
                  Navigator.pop(ctx);
                  _editStone(s);
                }),
                const SizedBox(width: 8),
                _detailAction('Close', _P.t2, _P.border, () => Navigator.pop(ctx)),
                const SizedBox(width: 8),
                _detailAction('Delete', _P.err, const Color(0x4DF87171), () {
                  setState(() {
                    _stones.removeWhere((x) => x.num == s.num);
                    for (var i = 0; i < _stones.length; i++) {
                      _stones[i].num = i + 1;
                    }
                  });
                  Navigator.pop(ctx);
                  _showToast('Stone deleted');
                }),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 90,
              child: Text(label.toUpperCase(),
                  style: _P.ui(size: 10, color: _P.t3))),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: _P.mono(size: 13, w: FontWeight.w500, color: _P.t1)),
          ),
        ],
      ),
    );
  }

  Widget _thumb(String badge, String glyph) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: _P.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _P.borderA),
      ),
      child: Stack(children: [
        Center(child: Text(glyph, style: const TextStyle(fontSize: 20))),
        Positioned(
            top: 4,
            left: 4,
            child: Text(badge, style: _P.mono(size: 8, color: _P.accent))),
      ]),
    );
  }

  Widget _addThumb(String glyph, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          color: _P.elevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _P.t4, style: BorderStyle.solid),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(glyph, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: _P.ui(size: 9, color: _P.t3)),
        ]),
      ),
    );
  }

  Widget _detailAction(String label, Color fg, Color border, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _P.elevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border),
          ),
          child: Text(label, style: _P.ui(size: 13, w: FontWeight.w600, color: fg)),
        ),
      ),
    );
  }

  void _editStone(_Stone s) {
    setState(() {
      _code.text = s.raw;
      _weight.text = s.weight;
      _price.text = s.price;
      _parsed = _parseCode(s.raw);
      _stones.removeWhere((x) => x.num == s.num);
      for (var i = 0; i < _stones.length; i++) {
        _stones[i].num = i + 1;
      }
    });
    _showToast('Editing — modify and send');
  }
}
