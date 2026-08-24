import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/image_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/persistence/local_store.dart';
import '../domain/lot.dart';
import 'lot_providers.dart';

/// ============================================================================
/// LOT CAPTURE — split a lot into SUBS.
///
/// A lot has published pieces + weight (from the PDF). The buyer splits it into
/// one or more subs — each with a grade (Shape/Colour/Clarity + free "shade"
/// note), its own pieces, weight, and photos. The split pcs/wt must reconcile to
/// the published totals (a warning shows if not; save is still allowed).
/// Save → the lot moves to the Estimate team.
/// ============================================================================

const _uuid = Uuid();

class _P {
  static late Color bg, surface, card, input, accent, accentB, accentGs, ok,
      err, info, t1, t2, t3, border, borderA, onAccent;
  static void apply(Brightness b) {
    final d = b == Brightness.dark;
    bg = d ? const Color(0xFF0E1017) : const Color(0xFFF6F7FB);
    surface = d ? const Color(0xFF181B24) : const Color(0xFFFFFFFF);
    card = d ? const Color(0xFF1E2230) : const Color(0xFFFFFFFF);
    input = d ? const Color(0xFF14171F) : const Color(0xFFF2F4F9);
    accent = d ? const Color(0xFFD4A853) : const Color(0xFFA9812E);
    accentB = d ? const Color(0xFFF0C95E) : const Color(0xFF8A6A22);
    accentGs = d ? const Color(0x40D4A853) : const Color(0x33A9812E);
    ok = d ? const Color(0xFF2DD4A0) : const Color(0xFF13A15A);
    err = d ? const Color(0xFFF87171) : const Color(0xFFD23B3B);
    info = d ? const Color(0xFF60A5FA) : const Color(0xFF2743B0);
    t1 = d ? const Color(0xFFE8E6E3) : const Color(0xFF161A2B);
    t2 = d ? const Color(0xFF9AA0B4) : const Color(0xFF5B627A);
    t3 = d ? const Color(0xFF5A6072) : const Color(0xFF9098AE);
    border = d ? const Color(0xFF2C3140) : const Color(0xFFE2E5EF);
    borderA = d ? const Color(0x4DD4A853) : const Color(0x4DA9812E);
    onAccent = d ? const Color(0xFF0E1017) : const Color(0xFFFFFFFF);
  }

  static TextStyle mono({double size = 14, FontWeight w = FontWeight.w600, Color? c, double ls = 0}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: w, color: c ?? t1, letterSpacing: ls);
  static TextStyle ui({double size = 14, FontWeight w = FontWeight.w500, Color? c, double ls = 0}) =>
      GoogleFonts.outfit(fontSize: size, fontWeight: w, color: c ?? t1, letterSpacing: ls);
}

const _slots = ['shape', 'colour', 'clarity'];
const _slotLabels = {'shape': 'Shape', 'colour': 'Colour', 'clarity': 'Clarity'};
List<String> _optionsFor(String s) => MockData.masterList(s);

/// A split sub (mutable, in-memory while editing).
class _Sub {
  _Sub({
    String? id,
    this.shape = '',
    this.colour = '',
    this.clarity = '',
    this.shade = '',
    this.pcs = 0,
    this.wt = 0,
    this.yieldPct = 0,
    this.pricePerCt = 0,
    List<Uint8List>? images,
  })  : id = id ?? _uuid.v4(),
        images = images ?? [];

  final String id;
  String shape, colour, clarity, shade;
  int pcs;
  double wt;
  double yieldPct;    // on-spot expert estimate (optional)
  double pricePerCt;  // $/polished ct (optional)
  List<Uint8List> images;

  String get grade =>
      [shape, colour, clarity].where((s) => s.isNotEmpty).join(' ');

  double get polishWt => wt * yieldPct / 100;
  double get value => polishWt * pricePerCt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'shape': shape,
        'colour': colour,
        'clarity': clarity,
        'shade': shade,
        'pcs': pcs,
        'wt': wt,
        'yieldPct': yieldPct,
        'pricePerCt': pricePerCt,
        'images': images,
      };

  factory _Sub.fromMap(Map<String, dynamic> m) => _Sub(
        id: m['id'] as String?,
        shape: m['shape'] as String? ?? '',
        colour: m['colour'] as String? ?? '',
        clarity: m['clarity'] as String? ?? '',
        shade: m['shade'] as String? ?? '',
        pcs: (m['pcs'] as num?)?.toInt() ?? 0,
        wt: (m['wt'] as num?)?.toDouble() ?? 0,
        yieldPct: (m['yieldPct'] as num?)?.toDouble() ?? 0,
        pricePerCt: (m['pricePerCt'] as num?)?.toDouble() ?? 0,
        images: (m['images'] as List?)?.cast<Uint8List>() ?? [],
      );
}

class PocLotEntryPage extends ConsumerStatefulWidget {
  const PocLotEntryPage({super.key, required this.tenderId, required this.lotId});
  final String tenderId;
  final String lotId;

  @override
  ConsumerState<PocLotEntryPage> createState() => _PocLotEntryPageState();
}

class _PocLotEntryPageState extends ConsumerState<PocLotEntryPage> {
  final List<_Sub> _subs = [];
  bool _seeded = false;

  void _seed() {
    if (_seeded) return;
    _seeded = true;
    for (final s in MockData.subsOf(widget.lotId)) {
      _subs.add(_Sub.fromMap(s));
    }
  }

  int get _usedPcs => _subs.fold(0, (n, s) => n + s.pcs);
  double get _usedWt => _subs.fold(0.0, (w, s) => w + s.wt);

  void _save({required bool toEstimate}) {
    final existing = MockData.captures[widget.lotId];
    MockData.captures[widget.lotId] = {
      'subs': _subs.map((s) => s.toMap()).toList(),
      'status': toEstimate ? 'captured' : (existing?['status'] ?? 'captured'),
      'yieldPct': existing?['yieldPct'] ?? 0.0,
      'pricePerCt': existing?['pricePerCt'] ?? 0.0,
      'marginPct': existing?['marginPct'] ?? 15.0,
    };
    LocalStore.I.persistCaptures();
    ref.invalidate(lotsProvider(widget.tenderId));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(toEstimate ? 'Saved — moved to Estimate' : 'Draft saved'),
      duration: const Duration(milliseconds: 1200),
    ));
    context.go('/tender/${widget.tenderId}');
  }

  Future<void> _editSub(Lot lot, {_Sub? existing}) async {
    // suggest remaining pcs/wt for a new sub
    final sub = existing ??
        _Sub(
          pcs: (lot.publishedPieces - _usedPcs).clamp(0, lot.publishedPieces),
          wt: (lot.publishedCarats - _usedWt).clamp(0, lot.publishedCarats).toDouble(),
        );
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _P.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SubEditor(sub: sub),
    );
    if (saved == true) {
      setState(() {
        if (existing == null) _subs.add(sub);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _P.apply(Theme.of(context).brightness);
    _seed();
    final lot = ref.watch(lotProvider(widget.lotId)).valueOrNull;
    final hasAny = _subs.isNotEmpty;

    return Scaffold(
      backgroundColor: _P.bg,
      appBar: AppBar(
        backgroundColor: _P.surface,
        foregroundColor: _P.t1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/tender/${widget.tenderId}'),
        ),
        title: Text(lot?.lotRef ?? 'Lot',
            style: _P.mono(size: 15, w: FontWeight.w700, c: _P.accent)),
        actions: [
          if (lot != null)
            TextButton(
              onPressed: hasAny ? () => _save(toEstimate: false) : null,
              child: Text('Draft', style: _P.ui(size: 13, w: FontWeight.w600, c: _P.t2)),
            ),
        ],
      ),
      body: lot == null
          ? const Center(child: Text('Lot not found'))
          : Column(children: [
              _compactHeader(lot),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  children: [
                    Row(children: [
                      _sectionLabel('SPLITS  (${_subs.length})'),
                      const Spacer(),
                      if (_subs.any((s) => s.value > 0))
                        Text('Value ${Fmt.money(_totalValue)}',
                            style: _P.mono(size: 11, w: FontWeight.w700, c: _P.ok)),
                    ]),
                    const SizedBox(height: 8),
                    if (_subs.isEmpty)
                      _emptyHint()
                    else
                      for (var i = 0; i < _subs.length; i++) _subCard(lot, i),
                    const SizedBox(height: 10),
                    _addSplitButton(lot),
                  ],
                ),
              ),
              _bottomSaveBar(lot, hasAny),
            ]),
    );
  }

  Widget _sectionLabel(String t) =>
      Text(t, style: _P.mono(size: 10, w: FontWeight.w700, c: _P.t3));

  double get _totalValue => _subs.fold(0.0, (v, s) => v + s.value);
  int leftPcs(Lot lot) => lot.publishedPieces - _usedPcs;
  double leftWt(Lot lot) => lot.publishedCarats - _usedWt;

  // Compact sticky header: published totals + live allocation/remaining.
  Widget _compactHeader(Lot lot) {
    final lp = leftPcs(lot);
    final lw = leftWt(lot);
    final matched = _subs.isNotEmpty && lp == 0 && lw.abs() < 0.005;
    final over = lp < 0 || lw < -0.005;
    final Color barC = matched ? _P.ok : (over ? _P.err : _P.accent);
    final pcsFrac =
        lot.publishedPieces > 0 ? (_usedPcs / lot.publishedPieces).clamp(0.0, 1.0) : 0.0;
    final wtFrac =
        lot.publishedCarats > 0 ? (_usedWt / lot.publishedCarats).clamp(0.0, 1.0) : 0.0;
    return Container(
      color: _P.surface,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(lot.lotName,
                style: _P.mono(size: 13, w: FontWeight.w700, c: _P.accentB),
                overflow: TextOverflow.ellipsis),
          ),
          if (lot.willBid) _pill('WILL BID', _P.accent),
        ]),
        const SizedBox(height: 8),
        // two compact allocation meters
        Row(children: [
          Expanded(child: _meter('PCS', _usedPcs.toString(), '${lot.publishedPieces}', pcsFrac, barC)),
          const SizedBox(width: 12),
          Expanded(child: _meter('WT', _fmt2(_usedWt), _fmt2(lot.publishedCarats), wtFrac, barC)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Icon(matched ? Icons.check_circle : (over ? Icons.error_outline : Icons.pie_chart_outline),
              size: 15, color: barC),
          const SizedBox(width: 5),
          Text(
            matched
                ? 'Fully allocated'
                : over
                    ? 'Over by ${lp < 0 ? '${-lp} pc ' : ''}${lw < -0.005 ? '${_fmt2(-lw)} ct' : ''}'
                    : 'Remaining  ${lp} pc · ${_fmt2(lw)} ct',
            style: _P.mono(size: 11, w: FontWeight.w700, c: barC),
          ),
          const Spacer(),
          if (!matched && !over && (lp > 0 || lw > 0.005))
            GestureDetector(
              onTap: () => _addRemainderSplit(lot),
              child: Text('+ add remaining',
                  style: _P.mono(size: 11, w: FontWeight.w700, c: _P.accent)),
            ),
        ]),
      ]),
    );
  }

  Widget _meter(String label, String used, String total, double frac, Color c) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: _P.mono(size: 9, w: FontWeight.w700, c: _P.t3)),
        const Spacer(),
        Text('$used / $total', style: _P.mono(size: 11, w: FontWeight.w700, c: c)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: LinearProgressIndicator(
            value: frac, minHeight: 6, backgroundColor: _P.input,
            valueColor: AlwaysStoppedAnimation(c)),
      ),
    ]);
  }

  String _fmt2(num n) => n.toStringAsFixed(2);

  // Add a split that auto-takes the exact remaining pcs + wt.
  void _addRemainderSplit(Lot lot) => _editSub(lot);

  Widget _subCard(Lot lot, int i) {
    final s = _subs[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _editSub(lot, existing: s),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: _P.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _P.border)),
          child: Row(children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: _P.accentGs,
              child: Text('${i + 1}', style: _P.mono(size: 11, c: _P.accent)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.grade.isEmpty ? '(no grade)' : s.grade,
                    style: _P.mono(size: 14, w: FontWeight.w700, c: _P.accentB)),
                const SizedBox(height: 2),
                Row(children: [
                  Text('${s.pcs} pc · ${Fmt.carats(s.wt)}',
                      style: _P.mono(size: 11, c: _P.t2)),
                  if (s.shade.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text('· ${s.shade}', style: _P.ui(size: 11, c: _P.t3)),
                  ],
                  if (s.images.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text('· 📷${s.images.length}', style: _P.mono(size: 11, c: _P.info)),
                  ],
                ]),
                if (s.yieldPct > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                        '${Fmt.percent(s.yieldPct)} @ ${Fmt.money(s.pricePerCt)} · ${Fmt.money(s.value)}',
                        style: _P.mono(size: 10, c: _P.ok)),
                  ),
              ]),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: _P.err, size: 20),
              onPressed: () => setState(() => _subs.removeAt(i)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _emptyHint() => Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text('No splits yet — add one below.',
            style: _P.ui(size: 13, c: _P.t3)),
      );

  Widget _addSplitButton(Lot lot) => GestureDetector(
        onTap: () => _editSub(lot),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _P.accentGs,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _P.borderA),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add, color: _P.accent, size: 20),
            const SizedBox(width: 6),
            Text('Add split', style: _P.ui(size: 14, w: FontWeight.w700, c: _P.accent)),
          ]),
        ),
      );

  Widget _bottomSaveBar(Lot lot, bool hasAny) {
    return Container(
      decoration: BoxDecoration(
        color: _P.surface,
        border: Border(top: BorderSide(color: _P.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: hasAny ? () => _save(toEstimate: true) : null,
              style: FilledButton.styleFrom(
                backgroundColor: _P.accent,
                foregroundColor: _P.onAccent,
                disabledBackgroundColor: _P.border,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.check),
              label: Text('Save & move to Estimate',
                  style: _P.ui(size: 14, w: FontWeight.w700, c: _P.onAccent)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: c.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.withOpacity(0.5))),
        child: Text(t, style: _P.mono(size: 9, w: FontWeight.w700, c: c)),
      );

}

/// Editor sheet for one split sub: grade chips + shade + pcs/wt + photos.
class _SubEditor extends StatefulWidget {
  const _SubEditor({required this.sub});
  final _Sub sub;

  @override
  State<_SubEditor> createState() => _SubEditorState();
}

class _SubEditorState extends State<_SubEditor> {
  late final _pcs = TextEditingController(text: widget.sub.pcs == 0 ? '' : '${widget.sub.pcs}');
  late final _wt = TextEditingController(
      text: widget.sub.wt == 0 ? '' : widget.sub.wt.toStringAsFixed(2));
  late final _shade = TextEditingController(text: widget.sub.shade);
  late final _yield = TextEditingController(text: widget.sub.yieldPct == 0 ? '' : '${widget.sub.yieldPct}');
  late final _price = TextEditingController(text: widget.sub.pricePerCt == 0 ? '' : '${widget.sub.pricePerCt}');

  @override
  void dispose() {
    _pcs.dispose();
    _wt.dispose();
    _shade.dispose();
    _yield.dispose();
    _price.dispose();
    super.dispose();
  }

  String _val(String s) => switch (s) {
        'shape' => widget.sub.shape,
        'colour' => widget.sub.colour,
        'clarity' => widget.sub.clarity,
        _ => '',
      };
  void _set(String s, String v) => setState(() {
        if (s == 'shape') widget.sub.shape = v;
        if (s == 'colour') widget.sub.colour = v;
        if (s == 'clarity') widget.sub.clarity = v;
      });

  Future<void> _camera() async {
    final b = await captureFromCamera(context);
    if (b != null) setState(() => widget.sub.images.add(b));
  }

  Future<void> _gallery() async {
    final list = await pickMultiFromGallery(context);
    if (list.isNotEmpty) setState(() => widget.sub.images.addAll(list));
  }

  void _commit() {
    widget.sub.pcs = int.tryParse(_pcs.text.trim()) ?? 0;
    widget.sub.wt = double.tryParse(_wt.text.trim()) ?? 0;
    widget.sub.shade = _shade.text.trim();
    widget.sub.yieldPct = double.tryParse(_yield.text.trim()) ?? 0;
    widget.sub.pricePerCt = double.tryParse(_price.text.trim()) ?? 0;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: _P.border, borderRadius: BorderRadius.circular(2))),
          ),
          Text('Split', style: _P.ui(size: 16, w: FontWeight.w700, c: _P.t1)),
          const SizedBox(height: 12),
          for (final s in _slots) _gradeRow(s),
          const SizedBox(height: 4),
          Text('SHADE (optional)', style: _P.mono(size: 10, w: FontWeight.w700, c: _P.t3)),
          const SizedBox(height: 6),
          TextField(
            controller: _shade,
            style: _P.ui(size: 14, c: _P.t1),
            decoration: _dec('e.g. MB, light, coated'),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _numField('Pieces', _pcs, whole: true)),
            const SizedBox(width: 12),
            Expanded(child: _numField('Rough wt (ct)', _wt)),
          ]),
          const SizedBox(height: 12),
          Text('ON-SPOT ESTIMATE (optional)',
              style: _P.mono(size: 10, w: FontWeight.w700, c: _P.t3)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _numField('Yield %', _yield)),
            const SizedBox(width: 12),
            Expanded(child: _numField('\$ / polished ct', _price)),
          ]),
          const SizedBox(height: 14),
          Text('PHOTOS', style: _P.mono(size: 10, w: FontWeight.w700, c: _P.t3)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _mediaBtn(Icons.photo_camera_outlined, 'Camera', _camera)),
            const SizedBox(width: 10),
            Expanded(child: _mediaBtn(Icons.photo_library_outlined, 'Gallery', _gallery)),
          ]),
          if (widget.sub.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.sub.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ImageThumb(
                    images: widget.sub.images, index: i, size: 60,
                    onDelete: () => setState(() => widget.sub.images.removeAt(i))),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _commit,
              style: FilledButton.styleFrom(
                  backgroundColor: _P.accent, foregroundColor: _P.onAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Add split', style: _P.ui(size: 14, w: FontWeight.w700, c: _P.onAccent)),
            ),
          ),
          const SizedBox(height: 6),
        ]),
      ),
    );
  }

  Widget _gradeRow(String s) {
    final val = _val(s);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(_slotLabels[s]!, style: _P.ui(size: 13, w: FontWeight.w600, c: _P.t2)),
          if (val.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(val, style: _P.mono(size: 13, w: FontWeight.w700, c: _P.accent)),
          ],
        ]),
        const SizedBox(height: 6),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _optionsFor(s).length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final code = _optionsFor(s)[i];
              final sel = val == code;
              return GestureDetector(
                onTap: () => _set(s, sel ? '' : code),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: sel ? _P.accentGs : _P.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? _P.accent : _P.border, width: sel ? 1.5 : 1),
                  ),
                  child: Text(code,
                      style: _P.mono(size: 14, w: FontWeight.w600, c: sel ? _P.accentB : _P.t1)),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _numField(String label, TextEditingController c, {bool whole = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: _P.mono(size: 9, w: FontWeight.w700, c: _P.t3)),
      const SizedBox(height: 4),
      TextField(
        controller: c,
        keyboardType: TextInputType.numberWithOptions(decimal: !whole),
        style: _P.mono(size: 15, c: _P.t1),
        decoration: _dec(whole ? '0' : '0.00'),
      ),
    ]);
  }

  Widget _mediaBtn(IconData ic, String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: _P.card, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _P.border)),
          child: Column(children: [
            Icon(ic, color: _P.accent, size: 22),
            const SizedBox(height: 4),
            Text(label, style: _P.ui(size: 11, w: FontWeight.w600, c: _P.t2)),
          ]),
        ),
      );

  InputDecoration _dec(String hint) => InputDecoration(
        isDense: true,
        filled: true,
        fillColor: _P.input,
        hintText: hint,
        hintStyle: _P.ui(size: 13, c: _P.t3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _P.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _P.accent)),
      );
}
