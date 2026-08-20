# 08 · Roadmap

The app is being built to grow from a viewing-table tool into the front end of a full
diamond ERP. Phased so each stage is demoable.

## Phase 0 — UI simulation ✅ (this build)

Clickable, cross-platform, mock-data walkthrough of the whole flow, for client sign-off.

- ✅ Clean architecture + feature scaffolding
- ✅ Login → Home → tabs → drill-down navigation
- ✅ **Live valuation** (5 inputs → break-even & bid) with margin what-if
- ✅ Six lot shapes modelled (simple / child / sub-lot / bunch / OR / pure-rough / rejection)
- ✅ Light + dark theme with a global switch
- ✅ Valuation engine unit-tested against BRD examples
- ✅ Mock screens: tenders, lot list, lot entry, sub-lot, child, plans, camera, work list, summary

## Phase 1 — Live data (after client approves the mock)

- Auth against MeghaOS JWT; token storage + interceptor
- `Api*Repository` implementations + entity `fromJson`/`toJson`; flip `useMockData`
- Wire to the existing tender module (tender / lot / Will-Bid / import / media)
- Persist evaluation writes (new `lot_plan` / `lot_row` schema on the backend)

## Phase 2 — Field-readiness

- Offline media capture + deferred upload queue (TE-027)
- Weight-vs-published validation (TE-033)
- Copy-previous & `..` duplicate on the sub-lot grid (TE-006, from the approved POC)
- Master-data add-from-phone + normalise/near-duplicate (TE-021/022/023)

## Phase 3 — The learning loop

- Post-auction result capture per lot (opening / bid / result / won-lost) (TE-028)
- Price chart refreshed from actual sales, joined on the structured grade (TE-014)
- Country-of-origin duty into landed cost (TE-017)

## Phase 4 — ERP expansion

- Hand-off of won lots into the invoice / stock / sales suite (separate BRD)
- Reporting & management views
- Multi-user, roles, sync hardening

## Blocking questions to close first (BRD PART N)

Average polish-size method · margin scope · pure-rough vs rejection · parent/child
reconciliation under partial rejection · phone-vs-tablet gap list. See
[07-VALUATION-MODEL.md](07-VALUATION-MODEL.md).
