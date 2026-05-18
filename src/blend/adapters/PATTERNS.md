# Blend Adapter Patterns

Conventions and gotchas for writing or refactoring adapters in `src/blend/adapters/`. Distilled from the TextInputAdapter refactor; applies to all current and future adapters.

## 1. Match the canonical adapter style

`SelectBoxAdapter.res` is the reference. Every adapter should mirror it on:

- `open ReactFinalForm` and `open LogicUtils` at the top.
- `<RenderIf condition={isBlendEnabled}>` and `<RenderIf condition={!isBlendEnabled}>` wrapped in `<>...</>`, **not** `if isBlendEnabled { jsx } else { jsx }`.
- Keep public prop type annotations qualified (`~input: ReactFinalForm.fieldRenderPropsInput`) even after `open` — better readability for consumers reading the prop list.

## 2. LogicUtils swap-ins

Look for these every time you touch an adapter:

| Replace | With | Reason |
|---|---|---|
| `JSON.Decode.string->Option.getOr("")` | `getStringFromJson(json, "")` | Canonical helper. |
| `if str->isNonEmptyString { Some(str) } else { None }` | `str->getNonEmptyString` | Returns `option<string>` directly. |
| `String.replace(s, old, "")` (for stripping) | `stringReplaceAll(s, old, "")` | `String.replace` only replaces first occurrence — silent bug if the input has multiples. |
| `Js.Nullable.isNullable(x)` / its negation | `x->getOptionalFromNullable->Option.isNone` / `Option.isSome` | Drops legacy `Js.Nullable` namespace. |
| `x->Nullable.toOption` | `x->getOptionalFromNullable` | Same call, but consistent with the helpers above. |

## 3. Don't expose `type_` on adapter APIs

Don't expose `~type_: string` on an adapter's public API — rename to `~inputType` (or whatever's semantically right). Translate to `type_` only at the binding boundary (`type_=inputType` in the JSX call) where the underlying API requires the escape — e.g. HTML's reserved `type` attribute, escaped via `@as("type") ~type_` in the binding's `external`.

Same rule for any prop that mirrors a JS reserved word (`for_`, `default_`, etc.). Adapter exposes the clean semantic name; translate at the binding edge.

## 4. Dead-`inputRef` hazard (most important)

The adapter pattern renders either `<LegacyComponent>` or `<BlendBinding>`. If you copy `useEffect`s from the legacy file, you may also copy `let inputRef = React.useRef(Nullable.null)` and `useEffect` bodies that gate on `inputRef.current->...->Option.forEach(...)`.

**The trap:** the legacy file wires its ref via `ref={inputRef->ReactDOM.Ref.domRef}` on its own `<input>` element. The adapter doesn't render an input itself — it renders a child component. Unless the binding or legacy exposes a `ref` prop and you forward it, the adapter's `inputRef.current` is always `null` and the `useEffect` bodies are unreachable.

**Audit checklist before claiming the adapter is complete:**

- Did you declare a `ref`? Where is it attached in JSX?
- If it's nowhere, the dependent `useEffect`s are dead code — delete them or wire the ref through.
- For Blend bindings without ref support: features dependent on the DOM element (size attribute, focus, scroll) silently break in Blend mode. Either extend the binding (`React.forwardRef`) or document the gap.

## 5. "Dead" useEffects often have live side effects

Before deleting a useEffect that gates on a dead ref, trace the *outer* effects. Common live parts:

- `Window.addEventListener("keydown", fn)` — the listener fires regardless of the ref. The predicate inside may have side effects (`preventDefault`, `stopPropagation`) even if the ref-dependent action (focus) is dead.
- Anything not gated by `inputRef.current` runs.

Distinguish "body that touches the dead ref" (dead) from "outer subscription/listener registration" (live). Keep the live half, drop the dead half.

## 6. Helper placement

One-off helpers used by a single component go *inside* `@react.component let make = ...`, not at module top — even when they're pure and could technically be hoisted. Colocation with the only caller wins over the marginal "no closure" benefit.

Helpers genuinely shared by multiple components / exported → module top is fine.

## 7. Structural cleanups that come up repeatedly

- **Nested switches on `option`** → single tuple-pattern:
  ```rescript
  switch (a, b) {
  | (Some(x), Some(y)) => ...
  | _ => ()
  }
  ```
- **OR-pattern arms** for duplicate switch cases:
  ```rescript
  | "w-full" | "w-96" => Lg   // not two separate arms
  ```
- **Nested boolean `if`s returning `bool`** → flatten with `&&` / `||`, name sub-expressions for readability:
  ```rescript
  // before
  if !cond1 { if cond2 && cond3 { expr1 || expr2 } else { false } } else { false }
  // after
  let hasA = expr1
  let hasB = expr2
  !cond1 && cond2 && cond3 && (hasA || hasB)
  ```
- **JSX eta-expansion** → punning: `<div onClick={ev => onClick(ev)}>` → `<div onClick>`.
- **`switch opt { | Some => Some(fn) | None => None }`** → `opt->Option.map(...)` (useful for `useEffect` cleanup returns).
- **Two `Some(fn)`-arm switches with overlapping bodies** → one arm + early-return `None`:
  ```rescript
  let handler = if everythingIsNoOp { None } else { Some(combinedFn) }
  ```

## 8. Eliminate `Webapi.Dom.*` redundancy

`Webapi.Dom.Element.setAttribute` / `getAttribute` are necessary when no React prop exists for a DOM attribute (e.g. HTML `size`). But check whether you already have the value in props before reading it from the DOM — `getAttribute("placeholder")` is redundant when `placeholder` is a prop in scope.

## 9. Cross-palette renames are dangerous

`jp-gray` and `nd_gray` are **not** 1:1 — they're separate palettes in `tailwind.config.js`.

- `nd_gray` only defines `0, 25, 50, 100, 150, 200, 300–800`. No named tokens, nothing past `800`.
- `jp-gray` has many tokens without `nd_gray` equivalents: `250, 850, 900+`, plus 18+ named tokens (`text_darktheme`, `darkgray_background`, `lightmode_steelgray`, `no_data_border`, `dark_table_border_color`, etc.).

A blind `jp-gray` → `nd_gray` substitution produces invalid Tailwind classes that compile to no CSS — silent visual regressions across hundreds of sites.

**How to apply when migrating colors:**

1. Check both palette definitions in `tailwind.config.js` first.
2. Map by hex closeness, not token name. Examples used in TextInputAdapter:
   - `jp-gray-700` (`#666666`) → `nd_gray-500` (`#606B85`)
   - `jp-gray-darkgray_background` (`#151A1F`) → `nd_gray-800` (`#222530`)
3. For unsupported tokens (named or `900+`), options are: map to closest `nd_gray`, extend `nd_gray` config first, or leave as `jp-gray` until design provides a real mapping.
4. There is no official mapping table — confirm with design before any cross-palette swap.

For PR-scoped renames, scope by "lines this PR adds vs main":

```bash
git diff main...HEAD | grep "^+" | grep "<token>"
```

— not "files this PR touches", which includes pre-existing code you didn't author.

## 10. Dead `external` aliases

`external ffInputToStringInput = "%identity"` and friends are type-specialized identity coercions. If never called, delete them. The generic `ReactFinalForm.toTypedField` already exists for the rare case you actually need one.

## 11. Workflow notes

- Run `npx rescript build` after every refactor. If it errors with `.bsb.lock already exists`, wait 2-3s and retry.
- After bulk find/replace, run `git diff` before committing to catch collateral damage.
- For "what did this PR change" questions, `git diff main...HEAD` is the right reference — not `git diff HEAD` (uncommitted) or `git status` (file-level).
- Confirm scope before expanding from "files I touched" to "entire branch" for mass edits — the blast radius is rarely what it first looks like.
