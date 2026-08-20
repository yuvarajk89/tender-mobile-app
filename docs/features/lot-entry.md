# Feature · Lot entry (the core screen)

**Faithful 1:1 port** of the client-approved POC (`diamond-lot-entry-poc/lot-entry-final.html`)
in `lib/features/lot/presentation/poc_lot_entry_page.dart`. This is **not a form** — it's the
POC's chat/terminal **feed**, reproduced exactly: same palette (near-black + gold), same fonts
(Outfit + JetBrains Mono via `google_fonts`), same data (shape / color / clarity + Weight ct /
Price $/ct), parse chips, tab-picker sheet with **shape SVGs** (`flutter_svg`), `..` duplicate,
📷/🎬 in the input bar, suggestion strip, stone cards, stone-detail sheet, and top toast.

> **Fidelity rule:** this screen is kept 1:1 with the signed-off POC. Open the POC and match it
> before changing anything. The BRD extensions (pieces · yield · live break-even/bid · OR-plan
> tabs · child stones) are **new scope to layer on top only after the client re-confirms** — the
> BRD itself calls them "missing scope, not a defect in the POC" (PART J). The pure
> `ValuationService` is ready in the domain for that step.

## Interaction model (binding — from the POC)

- **Typed shorthand into a feed:** type `RD FVY VS NON` in the input bar → a stone card
  appears in the feed. Order-independent **slot-filling parser**
  (`evaluation/domain/grade_parser.dart`) fills colour / clarity / fluor / shape; unmatched
  tokens become a free **note** (TE-019).
- **Parse chips** show the four grade slots live; tap one for the **tap-picker** bottom
  sheet fallback (never a blocker), which also lets you add a new code (TE-021).
- **`..` duplicates** the last stone (`..3` = three copies) — TE-006.
- **Camera inside the input bar** — shoot without leaving the screen (client note #3).
- **OR plans are tabs across the top** (client note #4) — value the lot two ways, compare,
  switch the active plan. `+` adds a plan.
- **Sub-lot / bunch / child stones are rows in the same feed** (client note #4) — a bunch is
  a row with pieces > 1; a child stone (`+ child of last rough`) is indented under its
  parent rough and shares its weight (TE-004/005). No separate screens.
- **Live break-even & bid in the header**, plus a **weight-mismatch warning** (TE-033) and a
  margin menu.

## The five inputs

Four compact numeric mini-fields — **pcs · rough ct · yield % · $/polished ct** — plus the
**grade** typed as shorthand. Everything else is derived by `ValuationService` and shown in
the header; each card shows its own bid.

## Files
- `features/lot/presentation/lot_entry_page.dart` — the whole screen.
- `features/evaluation/domain/grade_parser.dart` — the shorthand parser.
- `features/evaluation/domain/grade_vocabulary.dart` — the managed code lists.
- `features/evaluation/presentation/valuation_providers.dart` — service + margin.

## Look
Terminal aesthetic that **follows the theme** (client choice): near-black + gold in dark
(≈ the POC), clean-light + gold accents in light. Codes render in the monospace `code`
style; the feed background and gold accent are theme tokens (`context.feedBg`,
`context.codeAccent`). See [../06-UI-VISUAL-LOCK.md](../06-UI-VISUAL-LOCK.md).

## Going live
Add write methods to `LotRepository` to persist the plan's rows; the pure `ValuationService`
is unchanged. `..`, edit (pull-back-into-bar), and delete already manipulate the working
copy; wire them to the API.
