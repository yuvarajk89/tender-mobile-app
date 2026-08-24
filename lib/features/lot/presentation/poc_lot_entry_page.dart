import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/image_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/persistence/local_store.dart';
import '../../evaluation/domain/grade_vocabulary.dart';
import '../domain/lot.dart';
import 'lot_providers.dart';

/// ============================================================================
/// LOT CAPTURE — the buyer's fast at-the-table screen.
///
/// The lot already has its stone count + weight from the PDF, so the buyer does
/// NOT add stones. They just record what they see:
///   • photos / videos
///   • grade: Shape · Colour · Clarity  (tap to pick)
///   • optional notes
/// Save → the lot is marked "captured" and handed to the ESTIMATE team, who do
/// the yield / break-even / bid maths on the Estimate tab. No bid maths here.
/// ============================================================================

// theme-aware palette
class _P {
  static late Color bg, surface, card, input, accent, accentB,
      accentGs, ok, info, t1, t2, t3, border, borderA, onAccent;
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
List<String> _optionsFor(String s) => switch (s) {
      'colour' => GradeVocabulary.colours,
      'clarity' => GradeVocabulary.clarities,
      'shape' => GradeVocabulary.shapes,
      _ => const [],
    };

class PocLotEntryPage extends ConsumerStatefulWidget {
  const PocLotEntryPage({super.key, required this.tenderId, required this.lotId});
  final String tenderId;
  final String lotId;

  @override
  ConsumerState<PocLotEntryPage> createState() => _PocLotEntryPageState();
}

class _PocLotEntryPageState extends ConsumerState<PocLotEntryPage> {
  String _shape = '', _colour = '', _clarity = '';
  final _notes = TextEditingController();
  final List<Uint8List> _images = [];
  bool _seeded = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _seed() {
    if (_seeded) return;
    _seeded = true;
    final c = MockData.capture(widget.lotId);
    if (c != null) {
      _shape = c['shape'] ?? '';
      _colour = c['colour'] ?? '';
      _clarity = c['clarity'] ?? '';
      _notes.text = c['notes'] ?? '';
      final imgs = c['images'] as List?;
      if (imgs != null) _images.addAll(imgs.cast<Uint8List>());
    }
  }

  String _slotVal(String s) =>
      switch (s) { 'shape' => _shape, 'colour' => _colour, 'clarity' => _clarity, _ => '' };
  void _setSlot(String s, String v) => setState(() {
        if (s == 'shape') _shape = v;
        if (s == 'colour') _colour = v;
        if (s == 'clarity') _clarity = v;
      });

  Future<void> _addPhoto() async {
    final b = await pickImageBytes(context);
    if (b == null) return;
    setState(() => _images.add(b));
  }

  void _save({required bool toEstimate}) {
    final existing = MockData.captures[widget.lotId];
    MockData.captures[widget.lotId] = {
      'shape': _shape,
      'colour': _colour,
      'clarity': _clarity,
      'notes': _notes.text.trim(),
      'images': List<Uint8List>.of(_images),
      'status': toEstimate ? 'captured' : (existing?['status'] ?? 'captured'),
      'yieldPct': existing?['yieldPct'] ?? 0.0,
      'pricePerCt': existing?['pricePerCt'] ?? 0.0,
      'marginPct': existing?['marginPct'] ?? 15.0,
    };
    LocalStore.I.persistCaptures();
    ref.invalidate(lotsProvider(widget.tenderId));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(toEstimate
          ? 'Saved — moved to Estimate team'
          : 'Saved'),
      duration: const Duration(milliseconds: 1200),
    ));
    context.go('/tender/${widget.tenderId}');
  }

  @override
  Widget build(BuildContext context) {
    _P.apply(Theme.of(context).brightness);
    _seed();
    final lot = ref.watch(lotProvider(widget.lotId)).valueOrNull;

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
              onPressed: (_shape.isNotEmpty ||
                      _colour.isNotEmpty ||
                      _clarity.isNotEmpty ||
                      _images.isNotEmpty)
                  ? () => _save(toEstimate: false)
                  : null,
              child: Text('Draft', style: _P.ui(size: 13, w: FontWeight.w600, c: _P.t2)),
            ),
        ],
      ),
      body: lot == null
          ? const Center(child: Text('Lot not found'))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(14),
                    children: [
                      _publishedCard(lot),
                      const SizedBox(height: 14),
                      _sectionLabel('PHOTOS / VIDEOS'),
                      const SizedBox(height: 8),
                      _mediaSection(),
                      const SizedBox(height: 18),
                      _sectionLabel('GRADE'),
                      const SizedBox(height: 8),
                      for (final s in _slots) _gradeRow(s),
                      const SizedBox(height: 14),
                      _sectionLabel('NOTES (optional)'),
                      const SizedBox(height: 8),
                      _notesField(),
                      if (_images.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _photoStrip(),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                _bottomSaveBar(),
              ],
            ),
    );
  }

  Widget _sectionLabel(String t) =>
      Text(t, style: _P.mono(size: 10, w: FontWeight.w700, c: _P.t3));

  // Read-only reference from the PDF (stone count is already known).
  Widget _publishedCard(Lot lot) {
    final status = MockData.captureStatus(lot.id);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _P.accentGs,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _P.borderA),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(lot.lotName,
                style: _P.mono(size: 15, w: FontWeight.w700, c: _P.accentB)),
          ),
          if (lot.willBid) _pill('WILL BID', _P.accent),
          if (status != 'todo') ...[
            const SizedBox(width: 6),
            _pill(status == 'estimated' ? 'ESTIMATED' : 'IN ESTIMATE',
                status == 'estimated' ? _P.ok : _P.info),
          ],
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _fact('STONES', '${lot.publishedPieces}'),
          _fact('WEIGHT', Fmt.carats(lot.publishedCarats)),
          _fact('SIZE', lot.sizeRange),
        ]),
      ]),
    );
  }

  Widget _fact(String k, String v) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k, style: _P.mono(size: 8, w: FontWeight.w700, c: _P.t3)),
          const SizedBox(height: 2),
          Text(v, style: _P.mono(size: 14, w: FontWeight.w700, c: _P.t1)),
        ]),
      );

  Widget _pill(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: c.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.withOpacity(0.5))),
        child: Text(t, style: _P.mono(size: 9, w: FontWeight.w700, c: c)),
      );

  Widget _mediaSection() {
    return Row(children: [
      Expanded(child: _bigBtn(Icons.photo_camera_outlined, 'Camera', _addPhoto)),
      const SizedBox(width: 10),
      Expanded(child: _bigBtn(Icons.photo_library_outlined, 'Gallery', _addPhoto)),
    ]);
  }

  /// Compact clickable thumbnail strip shown just above Save — tap a thumb to
  /// preview (zoom), ✕ to remove.
  Widget _photoStrip() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('${_images.length} PHOTO${_images.length == 1 ? '' : 'S'} — tap to preview'),
      const SizedBox(height: 8),
      SizedBox(
        height: 64,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _images.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => ImageThumb(
              images: _images,
              index: i,
              size: 60,
              onDelete: () => setState(() => _images.removeAt(i))),
        ),
      ),
    ]);
  }

  Widget _bigBtn(IconData ic, String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: _P.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _P.border)),
          child: Column(children: [
            Icon(ic, color: _P.accent, size: 26),
            const SizedBox(height: 6),
            Text(label, style: _P.ui(size: 12, w: FontWeight.w600, c: _P.t2)),
          ]),
        ),
      );

  // A grade row: label + horizontal chips (tap to select). Fast, no typing.
  Widget _gradeRow(String slot) {
    final sel = _slotVal(slot);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(_slotLabels[slot]!, style: _P.ui(size: 13, w: FontWeight.w600, c: _P.t2)),
          const SizedBox(width: 8),
          if (sel.isNotEmpty)
            Text(sel, style: _P.mono(size: 13, w: FontWeight.w700, c: _P.accent)),
          const Spacer(),
          if (sel.isNotEmpty)
            GestureDetector(
              onTap: () => _setSlot(slot, ''),
              child: Text('clear', style: _P.ui(size: 11, c: _P.t3)),
            ),
        ]),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final code in _optionsFor(slot))
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _setSlot(slot, sel == code ? '' : code),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: sel == code ? _P.accentGs : _P.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: sel == code ? _P.accent : _P.border,
                            width: sel == code ? 1.5 : 1),
                      ),
                      child: Text(code,
                          style: _P.mono(
                              size: 14,
                              w: FontWeight.w600,
                              c: sel == code ? _P.accentB : _P.t1)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _notesField() => TextField(
        controller: _notes,
        maxLines: 2,
        style: _P.ui(size: 14, c: _P.t1),
        decoration: InputDecoration(
          hintText: 'e.g. coating, inclusion, "as our 6.72 vivid"…',
          hintStyle: _P.ui(size: 13, c: _P.t3),
          filled: true,
          fillColor: _P.input,
          contentPadding: const EdgeInsets.all(12),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _P.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _P.accent)),
        ),
      );

  /// Pinned bottom bar so Save is ALWAYS reachable without scrolling (fast work).
  Widget _bottomSaveBar() {
    final hasAny =
        _shape.isNotEmpty || _colour.isNotEmpty || _clarity.isNotEmpty || _images.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: _P.surface,
        border: Border(top: BorderSide(color: _P.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
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
}
