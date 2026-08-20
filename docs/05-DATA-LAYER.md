# 05 · Data layer — mock now, live MeghaOS later

## Today: mock mode + local persistence

Seed data comes from **one file**: `lib/data/mock/mock_data.dart` (tenders, lots, plans).
On top of that, a **session store** (mutable fields in `MockData`) holds what the user
creates, and a **local persistence layer** writes those deltas to the device so they
**survive an app restart** — the app behaves like the live ERP within the device.

`lib/data/persistence/local_store.dart` (backed by `shared_preferences`) persists:
- **Created (off-list) lots** — ids starting `new-` (added via Add-lot).
- **Saved stones per lot** — grade/weight/price + **photos** (base64).

Flow: `main()` → `LocalStore.I.init()` + `load()` (merges deltas into `MockData`) →
mutations (`addLot`, save stones) call `persistLots()` / `persistStones()`. Seed lots/tenders
stay in code; only user deltas are stored. When the live API is wired, `LocalStore` is
replaced by MeghaOS calls.

`AppConstants.useMockData == true` while there is no backend.

```
Screen → provider → RepositoryInterface → MockRepository → mock_data.dart
```

Nothing in the UI or domain knows it's mock. That's the point.

## Tomorrow: the live MeghaOS backend

The app is the field client for the MeghaOS diamond platform. The existing tender module
already lives there (tender / tender_lot / sub-lot / pile, PDF import, Will-Bid, media,
allocation). This app **reuses** that and **adds** the buyer's evaluation model on top
(yield %, $/polished ct, break-even, bid, `lot_plan`/`OR`, pure-rough, duty).

### The swap — one implementation + one line per feature

1. Add an HTTP client (e.g. `dio`/`http`) and an `ApiTenderRepository`:

   ```dart
   class ApiTenderRepository implements TenderRepository {
     Future<List<Tender>> getTenders() async {
       final res = await _client.get('/api/v1/data/tender');
       return (res.data['data'] as List).map(Tender.fromJson).toList();
     }
   }
   ```

2. Flip the provider:

   ```dart
   final tenderRepositoryProvider = Provider<TenderRepository>((ref) {
     return AppConstants.useMockData
         ? const MockTenderRepository()
         : ApiTenderRepository(ref.read(apiClientProvider));
   });
   ```

No screen, no widget, no entity changes. Repeat per feature.

### What the live wiring needs (tracked, not built)

- **Auth** — real login against the MeghaOS JWT endpoint; store the token; attach it to
  requests. `AuthController` already models the state; give it a real repository.
- **DTO mapping** — `fromJson`/`toJson` on entities (kept out of the mock deliberately).
- **Envelope** — MeghaOS responses are `{ data, meta }`; errors are
  `{ error: { code, message } }`. Centralise unwrapping in the HTTP client.
- **Offline queue** — media capture must work with no connectivity and sync later
  (BRD TE-027). This is the one piece of genuine client-side state; everything else is
  server-authoritative (TE-037).
- **Writes** — the mock is read-only. Add `save*`/`update*` to the repository interfaces
  when entry needs to persist.

## Rules

- Screens talk to **repository interfaces**, never to `mock_data.dart` or HTTP directly.
- Keep serialization in the `data` layer; entities in `domain` stay pure.
- `AppConstants.apiBaseUrl` holds the live base URL for when `useMockData` is false.
