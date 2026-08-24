import 'grade_vocabulary.dart';

/// The parsed result of a typed shorthand line, e.g. `RD FVY VS NON`.
class ParsedGrade {
  const ParsedGrade({
    this.colour = '',
    this.clarity = '',
    this.fluor = '',
    this.shape = '',
    this.note = '',
  });

  final String colour;
  final String clarity;
  final String fluor;
  final String shape;
  final String note; // tokens that matched no vocabulary (free notes, TE-019)

  bool get hasAny =>
      colour.isNotEmpty ||
      clarity.isNotEmpty ||
      fluor.isNotEmpty ||
      shape.isNotEmpty;

  String slot(String name) => switch (name) {
        'colour' => colour,
        'clarity' => clarity,
        'fluor' => fluor,
        'shape' => shape,
        _ => '',
      };
}

/// Order-independent slot-filling parser — the heart of the POC's "typed
/// shorthand" entry. Each whitespace token is matched against the managed grade
/// lists; the first empty matching slot claims it. Tokens matching nothing are
/// kept as a free note (so `MU 10MM`, `BHARELO`, cross-refs aren't lost).
///
/// `RD FVY VS NON`  → shape RD? no — RD is a shape; FVY colour; VS clarity;
/// NON fluor. Order doesn't matter: `FVY NON RD VS` yields the same result.
class GradeParser {
  const GradeParser._();

  static ParsedGrade parse(String text) {
    var colour = '', clarity = '', fluor = '', shape = '';
    final notes = <String>[];

    for (final rawTok in text.trim().split(RegExp(r'\s+'))) {
      final tok = GradeVocabulary.normalise(rawTok);
      if (tok.isEmpty) continue;
      if (colour.isEmpty && GradeVocabulary.colours.contains(tok)) {
        colour = tok;
      } else if (clarity.isEmpty && GradeVocabulary.clarities.contains(tok)) {
        clarity = tok;
      } else if (fluor.isEmpty && GradeVocabulary.fluors.contains(tok)) {
        fluor = tok;
      } else if (shape.isEmpty && GradeVocabulary.shapes.contains(tok)) {
        shape = tok;
      } else {
        notes.add(tok);
      }
    }
    return ParsedGrade(
      colour: colour,
      clarity: clarity,
      fluor: fluor,
      shape: shape,
      note: notes.join(' '),
    );
  }
}
