# Feature · Tender summary

Everything, one screen, for the night-before review (TE-032).

## Screen
- **Tender summary** — per tender: total bid value, average yield, pure-rough / rejection
  counts, then every lot with its break-even and bid. Tap a lot to jump into it.

## Files
- `features/summary/presentation/summary_page.dart`

## Behaviour — the important rule
- Yield-based lots contribute to the **average yield**; **pure-rough and rejection are
  counted in pcs/carats but kept OUT of the yield averages** (TE-009). This is enforced via
  `Valuation.contributesToYieldAverages`.
- Each lot's bid comes from `valuePlanRows` on its active plan.

## BRD
TE-032 (full summary), TE-009 (separate categories in the maths). Open question PART N-1:
is average polish size a simple mean or piece-weighted? — resolve with the client before
finalising.
