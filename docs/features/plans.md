# Feature · Plans (OR)

Competing cutting scenarios for the same lot — the "OR" (TE-007). The requirement the
discovery session missed; it's all over the workbook.

> **Now lives inside Lot entry** (client note #4): plans are **tabs across the top** of the
> feed, not a separate screen. Switching a tab re-values the whole feed live in the header.

## Where
- `features/lot/presentation/lot_entry_page.dart` → `_PlanTabs`.
- Entity: `evaluation/domain/entities/lot_plan.dart` (a `LotPlan` holds rows; exactly one
  `isActive`).

## Behaviour
- Each plan's rows value with `valuePlanRows`; the header shows the active plan's break-even
  & bid. `+` adds a plan. (Persisting the active-plan choice is wired in the live build.)

## BRD
TE-007. In Excel this is literally the word `OR` typed between two blocks — here it's a real
structure so a $22k decision isn't held together by two letters in a cell.
