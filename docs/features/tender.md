# Feature · Tenders (Home)

The landing dashboard: the current trip and its tenders. Tap a tender to drill into its
lots.

## Screen
- **Tender list / Home** — greeting + trip KPIs (tenders / lots / will-bid) + tender cards.
  Header carries the light/dark toggle.

## Files
- `features/tender/domain/tender.dart` — `Tender` entity (sale code, house, mine, origin,
  viewings, closure, bidding platform, declared carats, counts).
- `features/tender/domain/tender_repository.dart` — interface.
- `features/tender/data/mock_tender_repository.dart` — mock impl.
- `features/tender/presentation/tender_list_page.dart`, `tender_providers.dart`.

## Behaviour
- `tendersProvider` (FutureProvider) loads the list; cards show origin, declared carats,
  closure, done/total.
- Tapping a card → `/home/tender/:id`.

## BRD
One trip covers many tenders at many houses (PART A). Header fields mirror the published
list (PART B). Mock tenders mirror the Feb-2026 Belgium houses.

## Going live
Swap `tenderRepositoryProvider` to an `ApiTenderRepository` reading the MeghaOS `tender`
object. Header auto-detect already exists server-side (PDF import).
