---
name: blend-component-migration
description: End-to-end Blend Design System migration workflow for a single component. Use this skill when the user says "migrate X to blend", "blend migration for X", "move X to blend design system", or "next blend component".
---

You are running the Blend Design System migration workflow for a single React component in the hyperswitch-control-center repo. Walk through each step below, printing a clear status update before and after every action.

---

## Background

The repo is migrating components from legacy implementations to `@juspay/blend-design-system` incrementally. There are two migration approaches — one is a clean direct cut to Blend with no feature flag, the other uses the feature flag `devBlendEnabled` (read via `BlendContext.blendEnabledContext`) to toggle between Blend and legacy at runtime.

---

### Approach 1 — Direct Binding (no feature flag)

**When to use:** Component is straightforward enough for a clean cut to Blend. No rollback needed.

**What happens:**
- Dropped styling props are acceptable — Blend handles them internally
- Behavioral logic can be preserved inline in the new implementation
- **No feature flag. No adapter. No dual rendering path.**
- Two sub-approaches:
  - **A1**: Overwrite the legacy component file with a Blend-powered implementation — same props signature, zero JSX call site changes. The binding is used *internally* inside the rewritten file; call sites still say `<LegacyComponent`. **But always clean up dropped styling props from all call sites** — don't silently accept props that are no longer used.
  - **A2**: Create the binding and update **all call sites** to use it directly (e.g. `<ToolTipBinding` instead of `<ToolTip`). The legacy component file is deleted or left unused. Use this only when call sites are few and prop mappings are 1:1.
- Example: RangeSlider → A2 (`<SliderBinding` directly at all call sites); BreadCrumbNavigation → A1 (rewrite internals, strip dropped props from 29 call sites)

---

### Approach 2 — Adapter with Feature Flag

**When to use:** You want a safe rollback path, OR the Blend API is significantly different from legacy and you need controlled state / prop diffing.

**What happens:**
- Create `src/blend/bindings/XBinding.res` — raw Blend binding
- Create `src/blend/adapters/XAdapter.res` — feature-flagged adapter:
  - Reads `BlendContext.blendEnabledContext`
  - If `true` → renders Blend component with mapped props
  - If `false` → renders legacy component with all original props passed through unchanged
- Update all call sites from `<LegacyComponent` → `<XAdapter`
- Re-export legacy types in the adapter so type annotation files need no changes
- Example: Accordion → `AccordionAdapter.res`

---

## Step 0: Classify the component

Ask the user which component to migrate (if not specified). Then run all of these in parallel:

1. **Find the legacy file** — try `src/components/<ComponentName>.res` first. If not found, also try `src/utils/<ComponentName>.res`, `src/screens/`, and grep for partial/alternate spellings (e.g., for "BreadCrumb" also try "Breadcrumb", "breadcrumb"). Read whichever file you find.
2. **Count JSX call sites** — grep `<ComponentName\b` across `src/`. If 0 results, try alternate spellings or partial names.
3. **Count type annotation usages** — grep `ComponentName\.` to find files using `ComponentName.someType` (these also need updating in adapters).
4. **Check complexity** — for each call site, scan actual prop usage:
   - Custom JSX slots (e.g. `renderContentOnTop`, `renderHeader`)
   - Per-item callbacks (e.g. `onItemExpandClick`, `warning` fields)
   - Controlled state patterns (`closeFn`, programmatic open/close)
   - Complex prop mapping (enums, union types, inverted logic)
   - App-level behavior inside the component (popups, routing logic)
5. **Identify dead props** — props accepted in the legacy `make` signature but never passed at any call site

**Approach classification rules:**

- **Direct Binding (Approach 1)**: Clean cut to Blend, no feature flag. Use when the Blend API maps cleanly, styling props can be dropped, and rollback is not needed. Call site count doesn't matter — choose A1 (rewrite internals) if there are many call sites / type annotation files to avoid updating them all.
- **Adapter with Feature Flag (Approach 2)**: Use when rollback safety is needed, OR behavioral differences require controlled state / prop diffing. Costs more: all call sites must be renamed to `<XAdapter`, type annotations need re-exporting.

Print:

```
=== Component Analysis ===
Legacy file: <path> (<N> lines)
Call sites: <N> usages across <M> files
Type annotations: <N> files use ComponentName.someType
Props used at call sites: <list>
Dead props (defined but never passed): <list>
Complexity flags:
  - Custom JSX slots: yes/no
  - Per-item callbacks: yes/no
  - Controlled state needed: yes/no
  - Enum/union type mapping: yes/no
  - App-level behavior in component: yes/no
Approach recommendation: Direct Binding (A1/A2) / Adapter with Feature Flag
Reason: <why>
```

Ask the user to confirm the pattern before proceeding.

---

## Step 1: Create the plan file

Print: `[1/5] Creating migration plan...`

Create `.opencode/blend-migration-<componentname>.md` with:

```markdown
# Blend Migration - <ComponentName> Plan

> **Risk:** LOW/MEDIUM/HIGH
> **Approach:** Direct Binding (A1/A2) / Adapter with Feature Flag
> **Call sites:** N usages across M files
> **Date:** <today>

## Strategy

<one paragraph>

## Files to Create

- `src/blend/bindings/<Name>Binding.res`
- (if complex) `src/blend/adapters/<Name>Adapter.res`

## Prop Mapping: Legacy → Blend

| Legacy Prop | Blend Equivalent | Notes |
| ----------- | ---------------- | ----- |

## Props Dropped in Blend Branch

| Prop | Reason |

## Dead Props (never used at call sites)

| Prop | Reason |

## Call Sites

| File | Line | Notable props |

## Key Risks

| Risk | Mitigation |
```

Show the plan to the user and ask for confirmation before proceeding.

---

## Step 2: Create the Blend binding

Print: `[2/5] Creating Blend binding...`

Create `src/blend/bindings/<Name>Binding.res`.

### Binding rules:

- Use `@module("@juspay/blend-design-system") @react.component external make: (...) => React.element = "<ComponentName>"`
- For subcomponents (e.g. `AccordionItem`): use a `module Item = { ... }` with `external make = "<SubComponentName>"`
- For union/opaque types passed to Blend (e.g. accordion value that is `string | array<string>`): create a `module Value` with `external fromString`, `external fromArray`, `external toString`, `external toArray` all typed as `"%identity"`
- For enums: use `@as("blendValue")` inline variant annotations
- All optional props use `prop=?`

### Check the Euler reference:

Read `.opencode/blend-migration-euler.md` for the exact binding patterns used in Euler for this component. Match them.

---

## Step 3: Create the adapter (Approach 2 — Adapter with Feature Flag only)

Print: `[3/5] Creating adapter...`

Create `src/blend/adapters/<Name>Adapter.res`.

### Adapter rules:

```rescript
// Re-export legacy types so call sites need no type annotation changes
type foo = LegacyComponent.foo

@react.component
let make = (
  // Mirror ALL props from legacy make, with same defaults
  ~prop1,
  ~prop2=defaultValue,
  ...
) => {
  let isBlendEnabled = React.useContext(BlendContext.blendEnabledContext)
  // NOTE: all React.useState / React.useRef hooks MUST be hoisted here,
  // above the if isBlendEnabled check — React rules of hooks

  if isBlendEnabled {
    // Blend branch: map props, render Blend component
    // Preserve ALL functionality:
    // - Custom JSX slots → pass to equivalent Blend slot prop
    // - Callbacks → wire to Blend's onChange/onValueChange
    // - Controlled state → use value + onValueChange, track with useState
    // - closeAccordionFn / programmatic close → update controlled state
    // - Enum mapping → switch statement
    <BlendBinding ... />
  } else {
    // Legacy branch: pass ALL props through unchanged, no logic
    <LegacyComponent prop1 prop2 ... />
  }
}
```

### Critical patterns:

**Controlled mode** (when callbacks or programmatic close needed):

```rescript
let (openValues, setOpenValues) = React.useState(_ => initialValues)

let handleChange = newVal => {
  // diff newVal vs openValues to fire per-item callbacks
  // then setOpenValues(_ => newVal)
}
let makeCloseFn = i => () => setOpenValues(prev => prev->Array.filter(...))

<BlendBinding value={openValues->...} onValueChange={handleChange}>
  {items->Array.mapWithIndex((item, i) =>
    <BlendBinding.Item ...>
      {item.renderContent(~closeAccordionFn=makeCloseFn(i))}
    </BlendBinding.Item>
  )->React.array}
</BlendBinding>
```

**Union type normalization** (e.g. Blend passes `string` in single mode, `array<string>` in multi mode):

```rescript
let normalizeValue = (v: Binding.Value.t): array<string> => {
  if Js.Array.isArray(v) {
    v->Binding.Value.toArray
  } else {
    let s = v->Binding.Value.toString
    s->String.length === 0 ? [] : [s]
  }
}
```

**Passing correct value type to Blend**:

```rescript
let blendValue = if singleMode {
  openValues->Array.get(0)->Option.getOr("")->Binding.Value.fromString
} else {
  openValues->Binding.Value.fromArray
}
```

---

## Step 4: Update call sites

Print: `[4/5] Updating call sites...`

For each file with `<LegacyComponent` JSX:

1. Replace `<LegacyComponent` → `<XAdapter`
2. Replace `LegacyComponent.someType` type annotations → `XAdapter.someType`

**For Simple pattern (A1)**: the component signature is preserved so no JSX tag changes needed. But always do the following cleanup too:

- Identify all props that are now dropped (Blend handles styling) — grep each call site for those prop names
- Remove dropped props from every call site (don't just silently accept them in the component signature)
- Use parallel agent batches to edit many files at once efficiently (batch 7 files per agent)
- Verify with: `grep -rn "droppedProp1\|droppedProp2" $(grep -rl "<ComponentName" src/ --include="*.res") | grep -v "ComponentName.res"` — must return nothing

After all edits, run:

```bash
npm run re:build
```

- If build passes: `✓ Build passed`
- If build fails: show errors, fix them, rebuild

---

## Step 5: Verify nothing missed

Print: `[5/5] Verifying...`

Run these checks:

```bash
# No remaining legacy JSX usages (except inside the adapter's own legacy branch)
grep -r "<LegacyComponent\b" src/ --include="*.res"

# No remaining legacy type annotations at call sites
grep -r "LegacyComponent\.someType" src/ --include="*.res"
```

Fix any remaining occurrences. Re-run `npm run re:build` to confirm clean.

Print a verification table:

```
=== Verification ===
✓ No remaining <LegacyComponent JSX outside adapter
✓ Type annotations updated
✓ Build passes
✓ All N call sites use <XAdapter
```

---

## Step 6: Raise PR

Follow the `/raise-pr` skill (`.opencode/skills/raise-pr/SKILL.md`) for commit, push, and PR creation.

PR title format: `feat: migrate <ComponentName> to Blend Design System`
Base branch: the previous blend phase branch (e.g. `blend-phase2-rangeslider`, `blend-phase2-accordion`)

---

## Key invariants (never violate these)

1. **Legacy branch is always a clean pass-through** — no logic, no mapping, all original props forwarded unchanged
2. **React hooks always hoisted** — `useState`, `useRef`, `useContext` above the `if isBlendEnabled` check
3. **Feature flag context** — always `BlendContext.blendEnabledContext` (camelCase, no underscore)
4. **Type re-exports** — adapter always re-exports legacy types so call sites don't need to change type annotations
5. **Build must pass** before raising PR
6. **Never modify legacy component files** — only create new binding/adapter files and update call sites
7. **Always clean up dropped props from call sites** — even in Pattern A1, don't leave dead styling props at call sites; grep and remove them all
8. **Verify call site completeness** — after editing, run `grep -rn "<ComponentName\b" src/ --include="*.res"` to get the full list, then cross-check every file for leftover dropped props

## Binding patterns learned

### Optional record fields for Blend item arrays

When Blend takes `items: BreadcrumbItemType[]` where items have optional fields (e.g. `onClick?`), define the ReScript record with optional field syntax:

```rescript
type breadcrumbItemType = {
  label: string,
  href: string,
  onClick?: ReactEvent.Mouse.t => unit,  // optional — omit field to not set it
}
```

To create a record without an optional field, simply don't include it. This compiles to a JS object without that key (not `undefined`).

### `useUrlPrefix` is always `""`

`LogicUtils.useUrlPrefix()` in this repo always returns `""`. Drop it — it adds noise with no effect.

### Breadcrumb-specific: last item is the active page

Blend's `Breadcrumb` renders the last item in the `items` array as the active/current page automatically. Add `currentPageTitle` as `{ label: currentPageTitle, href: "" }` at the end. No `isActive` field needed.

### PR description must include file locations

When raising a PR for a migration, the description must include a table of all modified call site files grouped by feature area. Use the `/raise-pr` skill — never raise a PR manually.

### Finding the right nd- icon

The design system uses `nd-` prefixed icons. There are two families — don't mix them:

- **`nd-toast-*`** — context-specific icons for alert/toast slots: `nd-toast-info`, `nd-toast-warning`, `nd-toast-success`, `nd-toast-error`. Use these only inside Blend alert/toast slot props.
- **`nd-*`** — general purpose icons: `nd-info-circle`, `nd-cross`, `nd-edit-pencil`, `nd-external-link-square`, etc. Use these for tooltips, buttons, inline UI elements.

When migrating a component that uses a generic `info-circle` or `exclamation` icon, **search for the `nd-` equivalent first** before assuming the old icon name is correct:
```bash
grep -r "nd-" src/ --include="*.res" | grep "Icon name" | sort -u
```
Check what similar components in the codebase already use for the same semantic meaning.

### Match Blend typography when writing inline JSX inside Blend component slots

When you place custom JSX inside a Blend component's slot (rather than using the component's own `description`/`heading` props), the text will not automatically inherit Blend's font styles. You must explicitly match the component's internal font size.

**How to find the right size**: check `dist/components/<ComponentName>/<componentName>.light.tokens.d.ts` or search the bundle:
```bash
node -e "
const c = require('fs').readFileSync('node_modules/@juspay/blend-design-system/dist/main.js','utf8');
const idx = c.indexOf('description:');
console.log(c.substring(idx, idx+300));
"
```

Then map to the repo's Typography system:

| Blend token | Typography class | Tailwind fallback |
|-------------|-----------------|-------------------|
| `body.md` (14px) | `body.md.regular` | `text-fs-14` |
| `body.sm` (12px) | `body.sm.regular` | `text-fs-12` |
| `body.lg` (16px) | `body.lg.regular` | `text-fs-16` |

Use `body.md.regular` from `open Typography` if available in the file; otherwise use the literal `text-fs-14`. Never leave inline slot text unstyled — it will inherit browser defaults and look mismatched.

### Always check actual exports before using V2 components

When `@juspay/blend-design-system` has both `Tooltip` and `TooltipV2` dist folders, **verify the component is actually exported** before using V2. Check the real export list:
```bash
node -e "const b = require('@juspay/blend-design-system'); console.log(Object.keys(b).filter(k => k.toLowerCase().includes('tooltip')))"
```
`TooltipV2` exists in `dist/components/` but is **not exported** from the package root — use `"Tooltip"` in the binding. Always verify against the actual exports, not just the dist folder structure.

### Check Blend component defaults before writing the binding wrapper

Before finalising a binding, inspect the component in `dist/main.js` to find prop defaults that may be undesirable (e.g. a close button that shows by default). Override these in a `make` wrapper around the `Raw` external so all call sites get safe defaults without having to pass them explicitly.

### Scope bulk replacements tightly and always verify with git diff

When doing batch icon/color updates across many files via `sed` or `replace_all`, make the pattern specific enough to match only the target context (e.g. include surrounding JSX like `slot={{slot: <Icon name=`). A loose pattern silently changes icons in tooltips, tab borders, and other unrelated UI. Always run `git diff -- src/` after any bulk change to review every line before committing.
