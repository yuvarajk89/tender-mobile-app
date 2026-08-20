# 02 · Project structure

```
donda-diamond-app/
├── CLAUDE.md                     # AI/dev working context
├── README.md                     # run + demo
├── docs/                         # ← you are here
├── pubspec.yaml                  # deps: riverpod, go_router, equatable, uuid, intl
│
├── lib/
│   ├── main.dart                 # ProviderScope + runApp(DondaDiamondApp)
│   │
│   ├── app/                      # composition root (no business logic)
│   │   ├── app.dart              # MaterialApp.router + light/dark theme wiring
│   │   ├── router/
│   │   │   └── app_router.dart   # go_router: login + StatefulShellRoute (4 tabs)
│   │   └── shell/
│   │       └── app_shell.dart    # bottom NavigationBar / side NavigationRail
│   │
│   ├── core/                     # shared, feature-agnostic
│   │   ├── theme/                # THE VISUAL LOCK
│   │   │   ├── app_colors.dart       # colour tokens (light + dark neutrals)
│   │   │   ├── app_typography.dart   # type scale (colour-inheriting)
│   │   │   ├── app_spacing.dart       # 4-based spacing + radius + breakpoints
│   │   │   ├── app_theme.dart         # builds light & dark ThemeData + context.scheme
│   │   │   └── theme_controller.dart  # ThemeMode state (the light/dark toggle)
│   │   ├── widgets/
│   │   │   └── app_widgets.dart   # SectionCard, StatCard, PillTag, EmptyState, …
│   │   ├── utils/
│   │   │   └── formatters.dart    # money / carats / percent / date
│   │   └── constants/
│   │       └── app_constants.dart # margin default, base currency, useMockData flag
│   │
│   ├── data/
│   │   └── mock/
│   │       └── mock_data.dart     # ALL sample data (tenders, lots, plans, rows)
│   │
│   └── features/
│       ├── auth/
│       │   └── presentation/      # login_page.dart, auth_providers.dart
│       │
│       ├── evaluation/            # SHARED valuation core
│       │   ├── domain/
│       │   │   ├── entities/      # enums.dart, lot_row.dart, lot_plan.dart
│       │   │   ├── valuation.dart         # ValuationService + Valuation (the maths)
│       │   │   └── grade_vocabulary.dart  # colour/clarity/fluor/shape master lists
│       │   └── presentation/
│       │       ├── valuation_providers.dart       # service + margin providers
│       │       └── widgets/                        # valuation_panel, grade_picker_field
│       │
│       ├── tender/
│       │   ├── domain/            # tender.dart, tender_repository.dart
│       │   ├── data/              # mock_tender_repository.dart
│       │   └── presentation/      # tender_list_page.dart (home), tender_providers.dart
│       │
│       ├── lot/
│       │   ├── domain/            # lot.dart, lot_repository.dart
│       │   ├── data/              # mock_lot_repository.dart
│       │   └── presentation/      # lot_list, lot_entry, sublots, children, plans,
│       │                          # work_list pages + lot_providers.dart
│       │
│       ├── media/
│       │   └── presentation/      # camera_page.dart
│       │
│       └── summary/
│           └── presentation/      # summary_page.dart
│
├── test/
│   └── widget_test.dart           # valuation engine tests (BRD worked examples)
│
├── android/ · ios/ · web/         # platform runners (generated)
```

## Where do I put…?

| I'm adding… | It goes in… |
|-------------|-------------|
| A new screen | `features/<feature>/presentation/<name>_page.dart` + a route in `app_router.dart` |
| A new entity | `features/<feature>/domain/` (or `evaluation/domain/entities/` if shared) |
| A calculation | a **pure** service in `domain/` (mirror the `ValuationService` style) |
| A data source | a repository impl in `features/<feature>/data/` + a provider |
| A reused widget | `core/widgets/app_widgets.dart` |
| A colour / text style | `core/theme/` — never a literal in a screen (see [06](06-UI-VISUAL-LOCK.md)) |
| Sample data | `lib/data/mock/mock_data.dart` (only place) |
