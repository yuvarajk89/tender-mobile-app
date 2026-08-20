# 07 · The valuation model

This is the heart of the app. One calculation, five inputs, one number. Implemented in
`lib/features/evaluation/domain/valuation.dart` as a **pure** service, and pinned by
`test/widget_test.dart` against the BRD's real worked examples.

## The chain

```
rough carats  ×  yield %            =  polish carats
polish carats ×  $/polished carat   =  polished value
polished value ÷ rough carats       =  break-even rough $/ct
break-even    ×  (1 − margin)       =  BID          (margin default 15%)
```

**Worked example (BRD lot 117).** 39.39 ct rough, cut into two stones:

```
39.39 × 11% = 4.33 ct × $28,000 = $121,321
39.39 ×  5% = 1.97 ct × $13,500 =  $26,588
                     polished value $147,909
$147,909 ÷ 39.39 = $3,755 /ct   (break-even)
$3,755 × 0.85    = $3,191.75     (the bid)
```

## The five inputs vs the derived values

| Buyer enters (5) | App derives (never asks) |
|------------------|--------------------------|
| pieces | rough size (`rough ÷ pcs`) |
| rough carats | polish carats (`rough × yield%`) |
| grade (colour/clarity/fluor/shape) | polish size (`polish ÷ pcs`) |
| yield % | total value (`polish × $/ct`) |
| $/polished carat | break-even, **bid** |

## The six lot shapes (all handled by one recursive `LotRow`)

| Shape | How it's modelled |
|-------|-------------------|
| **Simple** | one row, own rough |
| **Child / cleavage** | header row holds the rough; children (`usesParentRough=true`) carry grades + their own yields. Yields need **not** sum to 100% |
| **Sub-lot** | top rows, each with its **own** pieces + rough (they sum to the lot) |
| **Bunch** | a sub-lot row with `pieces > 1` — **not a separate feature** |
| **`OR` plans** | a `LotPlan` per scenario; exactly one `isActive` |
| **Pure rough** | `category = pureRough`; a direct rough $/ct or total; **no polish carats** |
| **Rejection** | `category = rejection`; zero value, still counts pcs + carats |

## The rules that are easy to get wrong

- **Yield is an INPUT, stored** (TE-002). The buyer decides it by looking; polish weight is
  derived from it. Do not re-derive yield from summed stone weights.
- **Pure rough must never be treated as 100 % polished** (TE-009). Its `polishCarats` is 0
  and it is excluded from yield-based averages on the summary screen.
- **Rejection keeps its carats and pieces** in totals but contributes zero value (TE-011).
- **Children borrow the parent's rough** — counting it once. The engine adds a header row's
  rough exactly once and takes value + piece count from the children.
- **Margin is a setting, not a constant** (TE-001). Held in `marginPctProvider`; the entry
  screen's slider moves it and the bid re-computes live. In the live app it becomes
  per-tender / per-lot.

## API surface

```dart
Valuation valueRow(LotRow row, {required double marginPct, double? parentRoughCarats});
Valuation valuePlanRows(List<LotRow> rows, {required double marginPct});
```

`Valuation` carries `pieces, roughCarats, polishCarats, polishSize, totalValue, breakEven,
bid, category`. Change the maths only with the tests green.

## Open questions (from BRD PART N) that affect these numbers

1. Average polish size across sub-lots — simple mean or **piece-weighted**?
2. Margin — fixed / per-tender / per-lot?
3. Pure-rough vs rejection — one zero-value category or two?

These are flagged in code where they bite; resolve with the client before finalising the
summary maths.
