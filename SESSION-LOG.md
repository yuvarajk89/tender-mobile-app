# Session Log — Donda Diamond mobile app

**Saved:** 2026-08-20 · **Local only** (no remote, no push).
**Project:** `/home/yuvaraj/Desktop/office/meghaos-platform/donda-diamond-app`
**Git snapshot:** commit `348a066` (local) · **Backup:** `~/Downloads/donda-diamond-app-backup-20260820-1622.tar.gz`

This is a record of what was decided and built in the session, so it can be picked up or
restored later. (Code is the source of truth; this is the narrative.)

---

## 1. What this project is
A cross-platform **Flutter** app (Android · iOS · Web · tablet) for **rough-diamond tender &
lot evaluation** — the buyer's viewing-table tool. It's the front of the MeghaOS diamond ERP;
won lots later feed the invoice/stock suite (separate system).

- BRD: `~/Downloads/WhatSie/BRD-Rough-Diamond-Tender-Evaluation.md` (requirement IDs TE-nnn).
- Approved UX POC: `~/Desktop/office/meghaos-platform/diamond-lot-entry-poc-main/lot-entry-final.html`.
- Logo source: `diamond-lot-entry-poc-main/img/donda_export.webp`.
- **Status:** UI simulation (mock) + **local persistence**. No live backend yet.

## 2. Stack & architecture
- Flutter 3.22 / Dart 3.4, Material 3.
- **flutter_riverpod** (state/DI), **go_router** (nav), **equatable/uuid/intl**.
- **google_fonts** (Outfit + JetBrains Mono), **flutter_svg** (POC shape icons).
- **image_picker** (camera/gallery), **shared_preferences** (local save).
- Clean architecture, feature-first: `domain` / `data` / `presentation`. Full docs in `docs/`.

## 3. Key decisions made (in order)
1. **Nav:** Login → Home (pick tender) → per-tender workspace with bottom tabs
   **Lots · Capture · Work list · Summary** (Work list & Summary are per-tender). Lot entry &
   Add-lot push over it. (`TenderShellPage`, `app_router.dart`.)
2. **Lot entry = faithful 1:1 port of the approved POC** (`poc_lot_entry_page.dart`): chat feed
   of stones, typed shorthand (`RD G VS1`, order-independent parser), parse chips, tap-picker
   sheet with shape SVGs, `..` duplicate, 📷 in the input bar, stone cards + detail sheet, toast.
   Data = POC's shape/color/clarity + Weight/Price. **Open the POC before changing this screen.**
3. **Theme:** light default + **dark toggle**, applied to EVERY screen. The terminal was made
   **theme-aware** (light in light mode, near-black+gold in dark) per user request.
4. **Login:** hardcoded **admin / 1234** for internal preview; later **redesigned** (gold glow
   logo, gradient, white card, show/hide password).
5. **Logo:** `donda_export.webp` enhanced (1024, sharpened) → in-app logo (`BrandLogo`) +
   launcher icons (Android/iOS/web via `flutter_launcher_icons`).
6. **Local persistence** (`data/persistence/local_store.dart`, shared_preferences): created lots
   + saved stones (incl. photos as base64) survive an app restart.
7. **Images:** real capture / gallery pick / preview / **pinch-zoom viewer**
   (`core/widgets/image_utils.dart`), in Capture tray + Lot entry + stone detail. Bytes-based
   (web+mobile safe).
8. **Dates:** made valid/relative to "today" (no more stale February); header shows current month.

## 4. Android build fixes (important for future runs)
- System had **two Android Studios**, one bundling **Java 25** (no Gradle supports it yet).
- Pinned the build to **JDK 17** via `android/gradle.properties` →
  `org.gradle.java.home=/usr/lib/jvm/java-17-openjdk-amd64` (works for CLI AND Android Studio).
- Upgraded **Gradle 8.7 / AGP 8.3.2 / Kotlin 1.9.24**; Java+Kotlin JVM target **17**.
- Silenced NDK warning: `ndkVersion "25.1.8937393"` in `android/app/build.gradle` (no native code).

## 5. Build / run / install
```bash
cd ~/Desktop/office/meghaos-platform/donda-diamond-app
flutter pub get
flutter analyze                 # expect 0 errors/warnings
flutter test                    # valuation engine tests (3 pass)
flutter run -d chrome           # web
# Device (Pixel 8a, wireless adb 192.168.1.57:5555):
flutter build apk --debug
adb -s 192.168.1.57:5555 install -r build/app/outputs/flutter-apk/app-debug.apk
```
- Debug APK is ~166 MB → wireless install is slow (one-time). Use **USB** or
  `--target-platform android-arm64` to speed the first install.
- New native plugins need a full **run/rebuild** (hot reload won't pick them up).
- Fast iteration after first install: **hot reload** (`r` / ⚡) — no reinstall.

## 6. App flow (test walkthrough)
1. Login `admin` / `1234`.
2. Home → stats + theme toggle (☀️/🌙) → tap a tender.
3. Tender tabs: **Lots / Capture / Work list / Summary**.
4. Lots: jump-to-lot search + Will-bid filter; status dot (green = has stones); **+ Add lot**.
5. Lot entry (terminal): type `RD G VS1` → ↑ to add; chips/tap-picker; Weight/Price; `..2`
   duplicate; 📷 camera/gallery; tap a stone → detail (zoom photos, edit, delete).
6. **✓ Save Lot & Start Next** → stones saved (persist on device) → Lots shows green + count.
7. Add lot → created in that tender (persists) → drop into terminal.
8. Capture tab → shoot/upload → tap to zoom.
9. Work list → in-progress lots. Summary → break-even + bid per lot.

## 7. Restore
- **Git:** `git reset --hard 348a066` (from the project dir).
- **Archive:** extract `~/Downloads/donda-diamond-app-backup-20260820-1622.tar.gz`, then
  `flutter pub get`.

## 8. Next up (not built yet) — the "full lifecycle like the web ERP"
- **Estimate/Bid** fields on a lot (yield % → break-even → bid, the BRD valuation).
- **Close / outcome**: Won / Lost, opening price, result price.
- **Split lot** (sub-lots / piles) like the ERP.
- **Status lifecycle**: Draft → Estimated → Bid → Won/Lost.
- Make the offline "3 items" indicator real (or hide it).
- Wire the live MeghaOS API (replace mock/LocalStore) — see `docs/05-DATA-LAYER.md`.

## 9. Preferences noted this session
- Build in local, test, no auto-PR/push; keep everything local.
- Simple, point-wise explanations.
- Keep the approved POC exact; the rest follows the app theme.
