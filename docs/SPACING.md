# Spacing Guide

Practical reference for picking the right spacing in this dashboard. Companion to `dashboard-spacing-spec.md` (the formal spec).

## The scale

| Role                                            | Token              | px |
| ----------------------------------------------- | ------------------ | -- |
| **S1** — Heading → its description              | `gap-spacing-xs`   | 4  |
| **S2** — Peer components / controls + content   | `gap-spacing-3xl`  | 24 |
| **S3** — Between sections on a page             | `gap-spacing-4xl`  | 32 |
| **S4** — Major regions / outer page wrapper     | `gap-spacing-6xl`  | 48 |

There is no fifth value. If a gap doesn't fit a role, the role is wrong.

## Decision tree

```
Is one the description of the other?         → S1 (gap-spacing-xs)
Are they peers, or controls + their content? → S2 (gap-spacing-3xl)
Are they distinct sections of the page?      → S3 (gap-spacing-4xl)
Are they top-level page regions?             → S4 (gap-spacing-6xl)
```

## Standard page layout

```rescript
<div className="flex flex-col gap-spacing-4xl">           // S3 — major sections
  <PageUtils.PageHeading title=... subTitle=... />        // (internal title→subtitle = S1)
  <KpiGrid className="grid gap-spacing-3xl ..." />        // S2 — between cards
  <div className="flex flex-col gap-spacing-3xl">         // S2 — controls + content
    <Filter />
    <Table />
  </div>
</div>
```

## Rules

1. **Always semantic, never raw.** `gap-spacing-3xl`, not `gap-6`.
2. **Gap on parent, never margin between siblings.** No `mt-X` / `mb-X` / `space-y-X`.
3. **No arbitrary values.** Never `h-[18px]`. Declare in `tailwind.config.js` using the `<value>-<unit>` pattern (`18-px`, `5-rem`), then use by name (`h-18-px`).
4. **Section dividers don't replace spacing.** Gap still follows the scale.
5. **Page wrapper padding** = `p-spacing-6xl` (48), unless the route layout already provides outer padding. Pick one — never both.
6. **Inside-component spacing is out of scope.** Only fix when explicitly called out.

## All tokens (for off-scale needs)

| Token              | px  |    | Token              | px  |
| ------------------ | --- | -- | ------------------ | --- |
| `spacing-none`     | 0   |    | `spacing-3xl` ★    | 24  |
| `spacing-xxs`      | 2   |    | `spacing-4xl` ★    | 32  |
| `spacing-xs` ★     | 4   |    | `spacing-5xl`      | 40  |
| `spacing-sm`       | 6   |    | `spacing-6xl` ★    | 48  |
| `spacing-md`       | 8   |    | `spacing-7xl`      | 64  |
| `spacing-lg`       | 12  |    | `spacing-8xl`      | 80  |
| `spacing-xl`       | 16  |    | `spacing-9xl`      | 96  |
| `spacing-2xl`      | 20  |    | `spacing-10xl`     | 128 |
|                    |     |    | `spacing-11xl`     | 160 |

★ = part of the four-tier between-component scale. The rest are for inside-component / off-scale use.

Tokens work on **any** spacing utility: `gap-`, `p-`, `m-`, `space-y-`, `inset-`, `mt-`, `mb-` etc.

## Anti-patterns

| Don't                                | Do                                                |
| ------------------------------------ | ------------------------------------------------- |
| `gap-6`                              | `gap-spacing-3xl`                                 |
| `gap-8`                              | `gap-spacing-4xl`                                 |
| `mt-4` between siblings              | `gap-spacing-xl` on parent                        |
| `space-y-6`                          | `gap-spacing-3xl` on parent                       |
| `h-[18px]`                           | Add `"18-px": "18px"` to config, use `h-18-px`    |
| `<div className="mb-4">`             | `flex-col gap-spacing-...` on parent              |

## For AI agents

When generating UI in this dashboard:

1. Default to the four-tier scale (`gap-spacing-xs`/`3xl`/`4xl`/`6xl`) based on role.
2. Always wrap children in `flex flex-col gap-spacing-*`. Never `mt-X` / `mb-X` / `space-y-X` between siblings.
3. For values not on the scale, declare in `tailwind.config.js` first (`<value>-<unit>` pattern), then reference by name. Never `gap-[N]`.
4. Copy patterns from existing pages — `Orders.res`, `CustomerV2.res`, connector list pages.
