# Feature · Child stones (cleavage)

One rough → several polished stones, each with its **own yield** pointing back at the
parent's rough weight (TE-004).

> **Now lives inside Lot entry** (client note #4): child stones are **indented rows** under
> their parent rough in the feed. The **`+ child of last rough`** toggle in the input bar
> adds the next stone as a child (it shares the previous rough, `usesParentRough = true`).

## Where
- `features/lot/presentation/lot_entry_page.dart` (`_StoneCard` renders children indented;
  the `_childMode` toggle adds them).
- Engine: `evaluation/domain/valuation.dart` (`valueRow` accepts `parentRoughCarats`;
  `valuePlanRows` counts the parent rough once).

## Behaviour
- Children have `usesParentRough = true` and no rough of their own.
- Yields need **not** sum to 100 % — 11 % + 5 % = 16 % is normal; the rest is lost in
  cutting.

## BRD
TE-004. Contrast with sub-lots (which carry their own rough and sum to the parent). The
recursive `LotRow` expresses both with the same fields.
