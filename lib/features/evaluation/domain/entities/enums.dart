/// The six lot shapes from the BRD (PART E). A single [LotRow] can express all
/// of them; this enum records which one a row/plan represents so the maths and
/// the UI can treat pure-rough and rejection specially (TE-008, TE-009, TE-011).
enum ValuationCategory {
  /// Normal: yield% × $/polished-ct drives the bid.
  yieldBased,

  /// Pure rough (TE-008): no polish estimate. A direct rough $/ct or total.
  /// MUST NOT be folded into yield-based averages (TE-009).
  pureRough,

  /// Rejection (TE-010/011): zero value. Still counts in pcs/carats totals.
  rejection,
}

extension ValuationCategoryX on ValuationCategory {
  String get label => switch (this) {
        ValuationCategory.yieldBased => 'Yield',
        ValuationCategory.pureRough => 'Pure rough',
        ValuationCategory.rejection => 'Rejection',
      };
}

/// Won / lost / no-bid outcome captured after the auction (TE-028).
enum LotOutcome { pending, won, lost, noBid }

extension LotOutcomeX on LotOutcome {
  String get label => switch (this) {
        LotOutcome.pending => 'Pending',
        LotOutcome.won => 'Won',
        LotOutcome.lost => 'Lost',
        LotOutcome.noBid => 'No bid',
      };
}

/// Where a lot is in the buyer's own workflow (drives the done/not-done dot).
enum LotWorkStatus { notStarted, inProgress, done }
