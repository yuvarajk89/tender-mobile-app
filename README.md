# Donda Diamond App

A cross-platform **Flutter** app (Android · iOS · Web · Tablet) for **rough-diamond tender
& lot evaluation** — the field tool a buyer uses at the viewing table to turn five inputs
into one bid.

> **This build is a UI simulation (mock mode).** It runs entirely on in-memory sample data
> so the client can walk the full app and flow before the live backend is connected.

---

## Quick start

```bash
flutter pub get

# Web (fastest to demo)
flutter run -d chrome

# Android / iOS
flutter run -d <device-id>

# Checks
flutter analyze
flutter test          # valuation engine tests (BRD worked examples)
```

Login accepts **any credentials** (it's a mock). Use the ☀️/🌙 button in the header to
switch light/dark.

---

## What you can click through

`Login → Home → bottom tabs`:

| Tab | Screen | What to try |
|-----|--------|-------------|
| **Tenders** | Home dashboard | Tap a tender → lot list → tap a lot |
| | Lot list | Filter *Will bid*, search a lot no., see done/not-done dots |
| | **Lot entry** | Edit the 5 inputs → watch **break-even & bid** update live; drag the margin slider |
| | Sub-lot / Child / Plans | Open from the lot-entry action row |
| **Work list** | In-progress lots | |
| **Camera** | Capture mock (offline state) | |
| **Summary** | Night-before review | Bids per lot; pure-rough & rejection kept out of averages |

Sample lots mirror the BRD's real Feb-2026 Belgium workbook — including the fancy-yellow
cleavage (lot 117), the `OR` two-plan lot (47), the sub-lot+bunch lot (36), a pure-rough
parcel (197) and a rejection (9).

---

## Documentation

Everything is in [`docs/`](docs/) — start at [`docs/00-INDEX.md`](docs/00-INDEX.md).
For the AI/dev working context see [`CLAUDE.md`](CLAUDE.md).

| Doc | About |
|-----|-------|
| [01 Architecture](docs/01-ARCHITECTURE.md) | Clean, feature-first layering |
| [02 Project structure](docs/02-PROJECT-STRUCTURE.md) | Every folder explained |
| [03 Navigation flow](docs/03-NAVIGATION-FLOW.md) | Screens & routes |
| [04 State management](docs/04-STATE-MANAGEMENT.md) | Riverpod patterns |
| [05 Data layer](docs/05-DATA-LAYER.md) | Mock now → live MeghaOS API later |
| [06 UI visual lock](docs/06-UI-VISUAL-LOCK.md) | Colours, type, spacing, theming |
| [07 Valuation model](docs/07-VALUATION-MODEL.md) | The five-inputs → one-bid maths |
| [08 Roadmap](docs/08-ROADMAP.md) | Mock → live → ERP phases |
| [features/](docs/features/) | One file per feature |

---

## Tech

Flutter 3.22 · Dart 3.4 · Material 3 · Riverpod · go_router. Offline-friendly (system font,
no network assets). See `CLAUDE.md` for conventions.
