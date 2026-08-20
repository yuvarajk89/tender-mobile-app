/// Master lists for the structured grade fields (BRD TE-019, PART G).
///
/// Seeded from the "observed vocabulary" in the BRD. In the live app these come
/// from the org's Hong Kong list via the MeghaOS master-data API and are
/// editable from the phone mid-evaluation (TE-021). Here they are constants so
/// the pickers work offline in the mock.
class GradeVocabulary {
  GradeVocabulary._();

  static const List<String> colours = [
    'FVOY', 'FVY', 'FIY', 'FSVY', 'FDOY', 'FBY', 'FY+', 'FY', 'FLY', 'FLY+',
    'YZ', 'WX', 'UV', 'FIPP', 'FPP', 'LPP', 'LBPP', 'FAINT PINK',
  ];

  static const List<String> clarities = [
    'VVS', 'VS', 'VS2', 'SI', 'SI1', 'SI2', 'I1', 'I3',
  ];

  static const List<String> fluors = [
    'NON', 'N', 'FB', 'MB', 'MB+', 'MY', 'SSB', 'CBLK', 'BLK',
  ];

  static const List<String> shapes = [
    'RAD', 'SQ RAD', 'OVL', 'PEAR', 'EM', 'SQ EM', 'LONG EM', 'HEART',
    'CUSHION', 'CU', 'LONG CU', 'ROUND',
  ];

  /// Normalise a typed value on entry (TE-022): trim, collapse inner spaces,
  /// upper-case — so `IJ+`, `IJ +`, `ij+` all resolve to one value.
  static String normalise(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
}
