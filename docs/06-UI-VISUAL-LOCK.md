# 06 · UI visual lock

The "visual lock" is the small set of design tokens every screen must pull from. Lock them
here and the app stays consistent, professional, and re-skinnable in one place. **A screen
never hard-codes a colour, font size, or padding number.**

Design intent: **neat, clean, professional, global** — a viewing-table tool under neutral
light. Restrained colour; one brand hue; the **bid** is the only thing allowed to shout.

## Files

| Token set | File |
|-----------|------|
| Colours | `lib/core/theme/app_colors.dart` |
| Type scale | `lib/core/theme/app_typography.dart` |
| Spacing / radius / breakpoints | `lib/core/theme/app_spacing.dart` |
| Assembled themes (light + dark) | `lib/core/theme/app_theme.dart` |
| Light/dark toggle state | `lib/core/theme/theme_controller.dart` |

## Colour

One brand hue (indigo) + one money accent (green) + neutral surface stack + semantic
status. Everything else derives from these.

| Role | Light | Dark |
|------|-------|------|
| Brand primary | `#2743B0` | `#8FA2FF` (brightened for contrast) |
| Accent (the BID, money) | `#13A15A` | `#13A15A` |
| Background | `#F6F7FB` | `#0E1017` |
| Surface (cards) | `#FFFFFF` | `#181B24` |
| Surface alt (raised) | `#F0F2F8` | `#212533` |
| Border | `#E2E5EF` | `#2C3140` |
| Text primary | `#161A2B` | `#ECEEF5` |
| Warning / Danger | `#C9820A` / `#D23B3B` | same |

## Theming — how light ⇄ dark actually works

1. `app_theme.dart` builds a full **light** and **dark** `ThemeData` from one M3
   `ColorScheme` each. All Material surfaces (app bar, cards, inputs, nav) are themed there.
2. Widgets resolve colour from the **active theme**, via the helper
   `context.scheme.<role>` (a `BuildContext` extension) — never a literal.
3. Headline text styles carry **no colour**; they inherit `onSurface`, so the same `Text`
   is dark-on-light and light-on-dark automatically. Only intentionally-muted styles pin a
   mid-grey that reads on both.
4. `themeControllerProvider` holds the `ThemeMode`. The header ☀️/🌙 button toggles it and
   `MaterialApp.router(themeMode: …)` restyles the whole tree. **Default is light.**

> **The rule that makes dark mode free:** every element that renders colour states it via
> the theme (`context.scheme.*`, `SectionCard`, themed `Text`). An element with only layout
> and a hard-coded colour will look wrong in one of the two themes.

## Type scale

System font (no network fetch → offline-safe). Numbers use **tabular figures** so columns
of carats/dollars align. Styles: `display, h1, h2, title, body, numeric` (colour-inheriting)
· `bodyMuted, caption, label` (mid-grey) · `bidNumber` (big, green — the hero).

## Spacing & radius

4-based scale: `xs 4 · sm 8 · md 12 · lg 16 · xl 24 · xxl 32`. Radius: `sm 8 · md 12 ·
lg 16 · pill`. Breakpoint: tablet at **720 dp**; content max width **1100 dp**.

## Shared components (`core/widgets/app_widgets.dart`)

`SectionCard` · `StatCard` · `PillTag` · `StatusDot` · `EmptyState` · `KeyValueRow` ·
`ResponsiveContent` · `ThemeToggleButton`. Build screens from these before inventing new
containers — they're already theme-correct.

## Alignment & density

- Page padding is `AppSpacing.page` (16). Cards use the same.
- Group related fields in a `SectionCard`; separate groups with `SizedBox(height: lg)`.
- Right-align numeric columns; left-align labels.
- On tablet/web, wrap scroll bodies in `ResponsiveContent` so they stay centred and
  readable.
