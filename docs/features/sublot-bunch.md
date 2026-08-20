# Feature · Sub-lot & bunch

**One structure, not two** (TE-005). A bunch is a sub-lot row with `pieces > 1`. The doc's
"sub-lot" and "bunch" are the same `LotRow`.

> **Now lives inside Lot entry** (client note #4): sub-lots and bunches are just **rows in
> the feed** — not a separate screen. A bunch shows an `N STN` pill.

## Where
- `features/lot/presentation/lot_entry_page.dart` (feed + `_StoneCard`).
- Entity: `evaluation/domain/entities/lot_row.dart`.

## Behaviour
- Each top row values independently (its **own** rough), summing to the lot.
- **`..` duplicates** the last stone (`..3` = three) so the buyer changes only what differs
  — the biggest time-saver at the table (TE-006).

## BRD
TE-005 (sub-lot = bunch), TE-006 (copy-previous). The workbook proves they're one row with
a piece count; we follow the workbook, not the docx.
