# Feature · Lot list

Lots within a tender. Built for the table: **never worked in sequence** (TE-030).

## Screen
- **Lot list** — search/jump to any lot no., filter to *Will bid*, done/not-done status
  dots, `WILL BID` and `OR` pills. Tap → lot entry.

## Files
- `features/lot/domain/lot.dart` — `Lot` entity (published pcs/carats, weighed carats,
  will-bid, work status, plans, post-auction fields).
- `features/lot/presentation/lot_list_page.dart`, `lot_providers.dart`.

## Behaviour
- `lotsProvider(tenderId)` loads lots; `willBidFilterProvider` toggles the filter; local
  search box matches lot ref or name.
- Status dot: done (green) / in-progress (amber) / not-started (grey).

## BRD
TE-030 jump-to-any-lot; TE-031/032 work-list vs full-summary split; the `OR` pill flags
lots with multiple plans (TE-007).

## Going live
`lotRepositoryProvider` → API reading `tender_lot` (which already has `will_bid`,
`bid_amount`, `won_lost`, etc.).
