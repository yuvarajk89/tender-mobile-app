# Donda Diamond App — Claude Context

Flutter app (Android · iOS · Web · Tablet) for **rough-diamond tender evaluation** — the
tool a buyer uses at the viewing table to turn five inputs into one bid. It is the front
of the funnel for the MeghaOS diamond ERP; won lots flow downstream into the invoice/stock
suite (a separate system).

> **Status: UI SIMULATION (mock mode).** Every repository returns in-memory sample data
> (`lib/data/mock/`). No backend is wired yet. The goal of this phase is a clickable,
> client-approvable walkthrough. The seam to swap mock → live MeghaOS API is a single
> provider per feature — see `docs/05-DATA-LAYER.md`.

## The one idea to understand first

The whole business is one calculation (`docs/07-VALUATION-MODEL.md`):

```
rough ct × yield%        = polish ct
polish ct × $/polished   = polished value
polished value ÷ rough   = break-even rough $/ct
break-even × (1 − margin)= BID          (margin default 15%)
```

Buyer enters **5 things** — pieces, rough ct, grade, yield %, $/polished ct — the app
derives the rest. This lives in `lib/features/evaluation/domain/valuation.dart` as a
**pure, unit-tested** service. If you touch the maths, keep `test/widget_test.dart` green
(it pins the BRD's worked examples).

## Tech stack

- **Flutter 3.22 / Dart 3.4**, Material 3.
- **flutter_riverpod** — state & dependency injection (the mock→live swap point).
- **go_router** — declarative navigation, `StatefulShellRoute` for the bottom tabs.
- **equatable / uuid / intl** — value objects, ids, formatting.
- No network font (system font) so it works offline at the viewing table.

## Architecture (clean, feature-first)

Three layers per feature — `presentation` → `domain` ← `data`. Dependencies point INWARD:
presentation and data both depend on domain; domain depends on nothing. Full explanation in
`docs/01-ARCHITECTURE.md`; folder map in `docs/02-PROJECT-STRUCTURE.md`.

```
lib/
├── main.dart                 # ProviderScope + runApp
├── app/                      # composition root: app widget, router, shell
├── core/                     # theme (visual lock), widgets, utils, constants
├── data/mock/                # ALL mock data (one file)
└── features/<name>/
    ├── domain/               # entities + pure services + repository interfaces
    ├── data/                 # repository implementations (mock now, http later)
    └── presentation/         # pages + providers + widgets
```

Features: `auth`, `tender`, `lot`, `evaluation` (the shared valuation core + grade
vocabulary + panels), `media`, `summary`.

## Theming — light default + dark, switch on every screen

Colours are resolved from `Theme.of(context).colorScheme` (never hard-coded), so the
header toggle flips the whole app. Light and dark `ThemeData` are built in
`lib/core/theme/app_theme.dart` from one brand hue + one type scale. The tokens (the
"visual lock") are in `app_colors.dart` / `app_typography.dart` / `app_spacing.dart` —
documented in `docs/06-UI-VISUAL-LOCK.md`. **Rule: a widget states its colour via the
theme, not a literal.**

## Navigation

`Login → Home (pick tender) → per-tender workspace`. The workspace (`TenderShellPage`) has
bottom tabs **scoped to the tender**: Lots · Capture · Work list · Summary (Work list &
Summary are per-tender, not global). Lot entry and Add-lot push over it. Map in
`docs/03-NAVIGATION-FLOW.md`; router is `lib/app/router/app_router.dart`.

## Lot entry = the approved POC (not a form)

`lib/features/lot/presentation/lot_entry_page.dart` reproduces
`diamond-lot-entry-poc/lot-entry-final.html`: a chat **feed** of stones added by **typed
shorthand** (`RD FVY VS NON`, order-independent parser in `grade_parser.dart`), **parse
chips** + **tap-picker** fallback, **`..`** to duplicate, **camera in the input bar**, **OR
plans as top tabs**, and sub-lot/bunch/child stones as **rows in the feed** (never separate
screens). Live break-even & bid + weight-mismatch in the header. Open the POC before
changing this screen.

## Conventions

- **One structure for sub-lot / bunch / child stone** — `LotRow` is recursive
  (`parentRowId`, `pieces`, `usesParentRough`). Do NOT add parallel tables/classes.
- **Derived values are never stored** — compute them through `ValuationService`.
- **Mock data lives only in `lib/data/mock/mock_data.dart`.** Pages read repositories,
  never the mock directly.
- **New feature** = new folder under `features/` with the three layers + a providers file.
- Run `flutter analyze` and `flutter test` before calling anything done.

## BRD traceability

Requirement IDs (TE-nnn) from `BRD-Rough-Diamond-Tender-Evaluation.md` are cited in code
comments where they're implemented (e.g. TE-005 sub-lot=bunch, TE-007 OR plans, TE-009
pure-rough isolation). Grep `TE-0` to find them.
