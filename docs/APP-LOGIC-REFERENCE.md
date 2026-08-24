# App Logic Reference — Donda Tender Mobile App

**Locked reference of the current build** (updated 2026-08-24). This is the source of
truth for how the app is structured *now* — screens, tabs, data model, storage, and the
capture → estimate → summary flow. Repo: `github.com/yuvarajk89/tender-mobile-app` (main).

---

## 1. The core idea (two jobs, two people)

```
BUYER  (at the tender table)            ESTIMATE TEAM  (back office)
─────────────────────────────          ────────────────────────────────
CAPTURE a lot, fast:                    ESTIMATE the captured lot:
  • photos / videos                       • yield %  +  $ / polished ct
  • grade: Shape · Colour · Clarity       • → break-even  → MAX BID
  • notes                                 • profit/loss vs a target bid
  → Save & move to Estimate               → Save estimate (status = estimated)
```

- A lot's **stone count + weight come from the PDF** — the buyer does NOT add stones.
- All the **money maths lives ONLY in the Estimate tab**, never on capture.
- **Will-Bid** = the shortlist (~10–15 of 49 worth evaluating).

---

## 2. Navigation & tabs

```
Login (admin / 1234)
  → Home  (pick a tender — 10 tenders, BDM-2604 first with real PDF lots)
      → Tender workspace  (bottom tabs, all per-tender):
          • Lots      — list, search, Will-Bid star, long-press menu, + Add lot
          • Estimate  — queue of captured lots → value them (yield/$ct → bid)
          • Summary   — night-before review, reads saved estimates
        (Lot capture is a full-screen push from Lots → tap a lot)
```

Routes (`lib/app/router/app_router.dart`):
| Path | Screen |
|---|---|
| `/login` | Login |
| `/home` | Tender picker |
| `/tender/:tid` | Tender workspace (Lots/Estimate/Summary tabs) |
| `/tender/:tid/lot/:lid` | **Lot capture** (push) |
| `/tender/:tid/add-lot` | Add off-list lot (push) |

---

## 3. Screens & their logic

### 3.1 Home — `features/tender/presentation/tender_list_page.dart`
- Logo + trip stats + light/dark toggle. Lists 10 tenders (BDM-2604 real). Tap → workspace.

### 3.2 Lots tab — `features/lot/presentation/lot_list_page.dart`
- Row = leading thumbnail (first photo / diamond placeholder + status dot + photo-count badge),
  **full lot ref**, name · size, `carats · pcs · status`, and a **Will-Bid ★** on the far right.
- **Search** (jump to lot no / name), **Will bid filter** (uses `MockData.willBid`).
- **★ tap** = toggle Will-Bid → persists + **UNDO snackbar** (`_toggleWillBid`).
- **Long-press row** = menu (Mark/Remove Will Bid · Open & capture) — home for future actions.
- **+ Add lot** FAB → add off-list lot against the tender.
- Status label from `MockData.captureStatus`: To capture → In estimate → Estimated.

### 3.3 Lot capture — `features/lot/presentation/poc_lot_entry_page.dart`
- **Published card** (read-only from PDF): lot name · stones · weight · size + Will-Bid / status pills.
- **Camera / Gallery** buttons (real capture/pick via `image_picker`, bytes-based).
- **Grade**: Shape · Colour · Clarity — horizontal **tap-chips** per row (select/clear). No typing.
- **Notes** (optional free text).
- **Photo strip** just above Save — small clickable thumbs (tap = zoom, ✕ = delete).
- **Pinned bottom Save bar**: `Save & move to Estimate` (always visible, no scrolling).
  **Draft** in the app bar saves without moving to estimate.
- Writes ONE capture per lot into `MockData.captures[lotId]` (see §4) + `persistCaptures()`.
- NO yield / break-even / bid here (moved to Estimate).

### 3.4 Estimate tab — `features/estimate/presentation/estimate_page.dart`
- Two groups: **Pending** (status=captured) and **Estimated** (status=estimated) + count pills.
- Tap a lot → **estimator sheet**: enter **Yield % + $/polished ct** (+ margin slider) →
  live **Break-even** and **MAX BID**; a **target-bid field** shows **profit/loss** vs break-even.
  **Save estimate** → status=estimated, persists.
- Maths: `polish = rough×yield%`, `total = polish×$ct`, `breakEven = total/rough`,
  `bid = breakEven×(1−margin)`. `rough = lot.publishedCarats`.

### 3.5 Summary tab — `features/summary/presentation/summary_page.dart`
- Reads the **same saved captures** (not the old plans model). Pills:
  `N lots · N will bid · N to estimate · N estimated`.
- Headline cards: **Total bid value** (Σ estimated) + **Avg yield**.
- Per-lot list sorted estimated → captured → to-do; estimated rows show bid + break-even.

### 3.6 Add lot — `features/lot/presentation/add_lot_page.dart`
- Create an off-list lot (ref/name/pcs/carats) → added to tender (id `new-…`), persists,
  drops into capture.

### 3.7 Login — `features/auth/presentation/login_page.dart`
- Hardcoded **admin / 1234** (internal preview). Gold-glow logo, gradient, show/hide password.

---

## 4. Data model & local storage

**Seed data** — `lib/data/mock/mock_data.dart`
- `tenders` (10; BDM-2604 real, parsed from the Bonas PDF — 49 lots) + `lots` (184 total).
- Dates computed relative to today via `_at(days, hour)`.

**Mutable session stores (all persisted):**
| Store | Shape | Meaning |
|---|---|---|
| `captures` | `Map<lotId, Map>` | ONE capture per lot: `shape,colour,clarity,notes,images[],status,yieldPct,pricePerCt,marginPct` |
| `willBidOverride` | `Map<lotId,bool>` | phone Will-Bid toggle (falls back to lot.willBid) |
| `lots` (id `new-…`) | created off-list lots |
| `trayImages` | — | (removed with the old media tray) |

Helpers: `capture(id)`, `captureStatus(id)` (todo/captured/estimated), `willBid(lot)`,
`toggleWillBid(lot)`, `firstPhoto(id)`, `photoCount(id)`, `lotsForTender(id)`.

**Persistence** — `lib/data/persistence/local_store.dart` (shared_preferences, JSON;
images as base64). Keys: `created_lots_v1`, `lot_captures_v1`, `willbid_override_v1`.
Loaded at startup in `main()` (`LocalStore.I.init()` + `load()`). Persist calls:
`persistLots()`, `persistCaptures()`, `persistWillBid()`. **Everything survives an app restart.**

**When live:** replace `MockData` + `LocalStore` with the MeghaOS API (see `docs/05-DATA-LAYER.md`).

---

## 5. Theme, media, shared

- **Theme**: light default + dark toggle, applied app-wide. Capture screen has a theme-aware
  gold "terminal" palette (`_P` in poc_lot_entry_page).
- **Images**: `core/widgets/image_utils.dart` — `pickImageBytes` (Camera/Gallery sheet),
  `ImageThumb` (thumbnail + delete + tap-to-zoom), full-screen pinch/zoom viewer. Bytes → web+mobile.
- **Logo**: `core/widgets/brand_logo.dart` + launcher icons (flutter_launcher_icons).

---

## 6. Build / run / install

```bash
flutter pub get
flutter analyze          # 0 errors/warnings
flutter test             # valuation engine tests
flutter build apk --release   # ~22 MB
# Device (USB most reliable; Wi-Fi has AP-isolation on some networks):
adb -s <serial> install -r build/app/outputs/flutter-apk/app-release.apk
```
Android build pinned to **JDK 17** (`android/gradle.properties`), Gradle 8.7 / AGP 8.3.2 /
Kotlin 1.9.24, `ndkVersion 25.1.8937393`. Login: **admin / 1234**.

Current version: **v0.2.5** (pinned bottom Save bar).

---

## 7. Change log (today, 2026-08-24)

- Mock: 10 tenders, **BDM-2604 real from PDF** (49 lots), lot thumbnails.
- Lot ref shown in full (`BDM-2604-017`).
- Removed confusing "Margin -15%" duplicate; clearer margin control.
- **Redesign**: simple Lot Capture (no stones feed / no 0-2 stones counter / no bid here) +
  new **Estimate tab** (yield → break-even → max bid + profit/loss).
- Grade = **Shape · Colour · Clarity** only (removed Cut/Fluor); inline chip selection.
- Will-Bid moved to a **far-right ★** (frees the lot name) + **long-press menu** + **UNDO**.
- **Summary** rewritten to read saved captures/estimates (was stuck at $0).
- Capture: photo **strip above Save** + **pinned bottom Save bar** (no scroll needed).
- Repo created & pushed to `github.com/yuvarajk89/tender-mobile-app` (main).
