# 01 · Architecture

**Clean architecture, feature-first.** The app is a set of self-contained *features*; each
feature has three layers, and dependencies point **inward**.

```
        ┌─────────────────────────────────────────────┐
        │                PRESENTATION                  │  Flutter pages, widgets,
        │        (pages · widgets · providers)         │  Riverpod providers
        └───────────────────┬─────────────────────────┘
                            │ depends on ↓
        ┌───────────────────▼─────────────────────────┐
        │                   DOMAIN                     │  Pure Dart. No Flutter,
        │  entities · pure services · repo interfaces  │  no IO. Unit-testable.
        └───────────────────▲─────────────────────────┘
                            │ implements ↑
        ┌───────────────────┴─────────────────────────┐
        │                    DATA                      │  Repository implementations
        │     mock repositories → (later) HTTP ones    │  (mock now, live later)
        └─────────────────────────────────────────────┘
```

## Why this shape

- **The domain never changes when the backend does.** Entities and the `ValuationService`
  know nothing about mock vs HTTP. Swapping data sources touches only the `data` layer and
  one provider line.
- **The maths is testable in isolation.** `ValuationService` is pure Dart — no widget, no
  network — so `flutter test` locks the BRD's worked examples forever.
- **Features don't bleed into each other.** A screen imports its own feature's domain +
  shared `core`; it does not reach into another feature's `data`.

## The three layers, concretely

### domain/ — the rules
- **entities** — immutable value objects (`Tender`, `Lot`, `LotPlan`, `LotRow`), built with
  `equatable`. No JSON, no Flutter.
- **services** — pure logic. The big one is `evaluation/domain/valuation.dart`.
- **repository interfaces** — `abstract interface class TenderRepository { … }`. The
  contract the presentation layer depends on.

### data/ — the wiring
- **repository implementations** — `MockTenderRepository implements TenderRepository`.
  Today they read `lib/data/mock/mock_data.dart`; tomorrow an `ApiTenderRepository` calls
  MeghaOS. Presentation cannot tell the difference.

### presentation/ — the screen
- **pages** — one widget per screen.
- **providers** — Riverpod providers exposing repositories and async data to the UI.
- **widgets** — feature-local widgets (shared ones live in `core/widgets`).

## The dependency rule in one sentence

> `presentation` and `data` may import `domain`; `domain` imports nothing from them, and no
> feature imports another feature's `data`.

## Shared vs feature code

- **`core/`** — cross-cutting, feature-agnostic: theme (the visual lock), shared widgets,
  formatters, constants. Anything used by ≥2 features.
- **`features/evaluation/`** — a *shared domain* feature: the valuation engine, grade
  vocabulary, and the reusable valuation panel / grade pickers. `tender` and `lot` both
  build on it.

See [02-PROJECT-STRUCTURE.md](02-PROJECT-STRUCTURE.md) for the exact file tree.
