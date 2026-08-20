# 03 · Navigation flow

## The map

```
┌────────┐   any creds
│ LOGIN  │ ─────────────►  /home
└────────┘

┌─────────────────────────────┐
│  HOME  — pick a tender       │   /home   (standalone screen, NOT a tab)
└──────────────┬──────────────┘
               │ tap a tender
               ▼
╔═════════ TENDER WORKSPACE  /tender/:tid  (TenderShellPage) ═════════╗
║  bottom tabs — ALL scoped to this tender:                          ║
║                                                                    ║
║  [ Lots ]        [ Capture ]     [ Work list ]     [ Summary ]     ║
║     │               │                                              ║
║     │ tap a lot     │ media tray (shoot first, attach later)       ║
║     ▼                                                              ║
║  LOT ENTRY  /tender/:tid/lot/:lid   (full-screen push)            ║
║   • OR plans = tabs across the top                                 ║
║   • chat FEED of stones (sub-lot / bunch / child = rows)           ║
║   • typed shorthand + tap-picker + ".." dup + camera in bar        ║
║   • live break-even & bid in the header                            ║
║                                                                    ║
║  [+ Add lot]  /tender/:tid/add-lot   (off-list lot, TE-034)        ║
╚════════════════════════════════════════════════════════════════════╝
```

Work list and Summary are **per-tender** (client note #2) — that's why they're tabs
*inside* the tender, not global.

## Routes (`lib/app/router/app_router.dart`)

| Path | Screen |
|------|--------|
| `/login` | Login |
| `/home` | Tender picker (home) |
| `/tender/:tid` | Tender workspace (Lots / Capture / Work list / Summary tabs) |
| `/tender/:tid/lot/:lid` | Lot entry (terminal feed) |
| `/tender/:tid/add-lot` | Add off-list lot |

## How it's built

- **Home is a plain route**, not a tab. Selecting a tender enters the workspace.
- **`TenderShellPage`** is a `Scaffold` with a bottom `NavigationBar` and an `IndexedStack`
  of four **body-only** widgets (`LotListBody`, `CameraBody`, `WorkListBody`, `SummaryBody`)
  — each takes the `tenderId`, so every tab is tender-scoped. It carries the app bar (tender
  name), the **offline/sync chip**, and the light/dark toggle.
- **Lot entry & add-lot** are full-screen routes pushed over the workspace.

## Responsive

Phone: bottom `NavigationBar`. Content is width-capped by `ResponsiveContent` on
tablet/web. (A side-rail variant can be reintroduced at the shell if desired.)

## Adding a screen

- A new **tab** → add a body-only widget + a slot in `TenderShellPage`'s `IndexedStack`.
- A new **pushed screen** → add a `GoRoute` under `/tender/:tid` and `context.go(...)` to it.
