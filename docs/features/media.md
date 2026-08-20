# Feature · Camera / media

Capture a photo or pick from the gallery, preview it, and pinch-to-zoom — in both
the **Capture tab** and the **Lot-entry terminal** (BRD PART H).

## What works now (real, not mock)
- **Take a photo** (device camera) or **choose from gallery** — a bottom-sheet chooser
  (`core/widgets/image_utils.dart` → `pickImageBytes`). Uses `image_picker`.
- **Preview** — real thumbnails (`ImageThumb`), rounded, with a delete ✕.
- **Full-screen zoom viewer** — swipe between images, **pinch** or **double-tap** to zoom,
  page counter, dark backdrop (`showImageViewer` / `_ImageViewer`).
- Images are held as **bytes** (`Uint8List`) so it works on **mobile and web** (no `dart:io`).

## Where
- **Capture tab** (`features/media/presentation/camera_page.dart`) — the tray: shoot/upload
  → thumbnails → tap to zoom. Tray held in `MockData.trayImages` (session).
- **Lot entry** (`poc_lot_entry_page.dart`) — 📷 in the input bar adds a photo to the
  next stone; the media strip shows real thumbnails; each saved stone carries its photos
  (`_Stone.images`), shown in the stone-detail sheet with zoom. Photos **persist** with the
  stone (see [../05-DATA-LAYER.md](../05-DATA-LAYER.md)).

## Still to wire (live build)
- Video capture (🎬 is a placeholder toast for now).
- Attaching a tray photo to a specific lot/stone after the fact.
- Upload to the MeghaOS storage API + offline upload queue (TE-027).

## BRD
PART H — TE-024 (shoot first) · TE-025 (attach at lot/sub-lot/bunch) · TE-027 (offline).
