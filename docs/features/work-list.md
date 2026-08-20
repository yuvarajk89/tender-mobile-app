# Feature · Work list

Only the lots being processed **right now** — the view for the table, not the whole tender
(TE-031).

## Screen
- **Work list** — in-progress lots with an amber status dot; tap → lot entry.

## Files
- `features/lot/presentation/work_list_page.dart`
- `workListProvider` in `lot_providers.dart` (filters lots to `LotWorkStatus.inProgress`).

## BRD
TE-031. Pairs with the full **[summary](summary.md)** (TE-032) — two views for two moments
(at the table vs the night before).
