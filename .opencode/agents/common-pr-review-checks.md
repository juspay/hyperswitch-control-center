---
description: "Checklist of the most common PR review comments observed historically in this repo. The review bot should run these checks on every PR diff before involving a human reviewer."
mode: reference
---

# Common PR Review Checks

This file lists the recurring code-review feedback patterns observed across closed PRs in this repository. The PR review bot should treat each section as a concrete check to run against the diff. The goal is to catch these issues automatically so human reviewers do not have to repeat the same comments on every PR.

For each check below:
- **What to flag**: the concrete pattern in the diff to detect
- **Why**: the reason this is a problem in this codebase
- **Suggested fix**: what the bot should recommend in its review comment

---

## 1. Use variants instead of raw string checks

**What to flag**
- `switch` expressions matching on raw string literals for domain values (status, type, mode, currency, role, product, etc.)
- Equality comparisons like `value == "succeeded"`, `str === "card"`, `mode->String.toLowerCase == "test"`
- Chains of `if/else if` over string values

**Why**
String comparisons are typo-prone and case-sensitive. The codebase has variant types and `getXxxFromString` helpers for nearly every domain enum (currencies, payment statuses, connector types, product types, environments, etc.). Strings drift; variants are exhaustively checked.

**Suggested fix**
- Convert the string to its variant via the existing `getXxxFromString` helper, then `switch` on the variant
- If no helper exists yet, create one in the corresponding `*Types.res` / `*Utils.res` file

---

## 2. Reuse existing utilities (LogicUtils and friends)

**What to flag**
- Inline empty-checks: `str == ""`, `str->String.length == 0`, `arr->Array.length == 0`, `dict == Dict.make()`
- Hand-rolled JSON helpers: `json->JSON.Decode.string->Option.getOr("")`, manual `getDict`/`getArray` chains
- Re-implementations of:
  - `LogicUtils.isEmptyString`, `isNonEmptyString`, `isEmptyDict`, `isNonEmptyArray`
  - `LogicUtils.getString`, `getInt`, `getFloat`, `getBool`, `getDict`, `getArray`, `getOptionString`
  - `LogicUtils.getJsonFromArrayOfJson`, `getValueFromArray`, `safeParse`
- Custom integer/number validators when `LogicUtils` already has one

**Why**
`LogicUtils.res` is the canonical home for these helpers. Reinventing them locally causes inconsistent behavior across the app and bloats files.

**Suggested fix**
Recommend the specific `LogicUtils.*` function by name. If a needed helper does not exist, suggest adding it to `LogicUtils` rather than inlining.

---

## 3. Extract repeated logic into a reusable function

**What to flag**
- Three or more near-identical code blocks in the same file or across sibling files (especially V1/V2 pairs)
- Validation logic that mirrors an existing validator with a different field name
- Long inline expressions that are repeated more than once

**Why**
Duplication makes future bug-fixes inconsistent. Reviewers consistently ask for extraction.

**Suggested fix**
Suggest extracting into a small util function. Name a likely host file (e.g., `LogicUtils.res`, the feature's `*Utils.res`, or a shared `Validators.res`). For V1/V2 pairs, suggest sharing the helper across both.

**Sub-pattern: collapse twin functions that differ by one boolean/string constant**
When two functions in the same file have near-identical bodies and differ only in a single boolean literal or string constant (e.g. `sumIsRegulatedTransactions` vs `sumIsUnregulatedTransactions`, `mapperForRoutingSuccess` vs `mapperForVolume`), merge them into a single function and pass the differing value as a labeled parameter.

---

## 4. Use the Typography component

**What to flag**
- Raw text-styling Tailwind classes in JSX: `text-sm`, `text-base`, `text-lg`, `font-medium`, `font-semibold`, `font-bold`, `leading-*`, `tracking-*`
- `<p>`, `<span>`, `<h1..h6>` with inline `className` text styles instead of `<Typography>`
- Arbitrary text-size literals like `text-[14px]`

**Why**
Typography is centrally managed for design-system consistency and theme support. Ad-hoc text classes drift from the design system.

**Suggested fix**
Replace with `<Typography variant=... />` using the appropriate variant token.

---

## 5. Use theme-aware color tokens (no hardcoded colors)

**What to flag**
- Hardcoded color classes such as `text-blue-500`, `bg-gray-200`, `border-red-400`
- Specific shade values on the design tokens: `text-nd_primary_blue-500`, `bg-nd_gray-100` (these break dark/light theme switching when used directly)
- Hex codes inside `className` or inline styles: `text-[#1A1A1A]`, `bg-[#fff]`
- Manually added `dark:` overrides instead of using a theme-aware token

**Why**
The app supports multiple themes. Hardcoded shades and hex values do not adapt. Design tokens (`nd_*` without a numeric shade, or semantic tokens) handle theme switching automatically.

**Suggested fix**
Recommend the corresponding semantic / theme-aware token from the design system.

**Sub-pattern: legacy palette → `nd_*` tokens**
Specifically flag the legacy Tailwind palette (`gray-*`, `blue-*`, `red-*`, `green-*`, `yellow-*`) anywhere in the diff and require migration to the `nd_*` design-system tokens. This is the most frequent flavor of this comment.

---

## 6. Remove unused code, props, and redundant Tailwind defaults

**What to flag**
- Unused `let` bindings, unused destructured props, unused function parameters
- Props passed to a child component that the child does not consume
- Props passed when the value is already available as a module-level constant or global state
- Tailwind classes that are defaults: `flex-row` (default of `flex`), `items-start` (default), `justify-start` (default)
- Empty `className=""`, no-op handlers like `onClick={_ => ()}` left from earlier iterations

**Why**
Dead code and redundant props raise reviewer questions and make refactoring harder.

**Suggested fix**
Remove the unused binding/prop/class. If the unused item is intentional, ask why.

---

## 7. Use meaningful, context-specific variable names

**What to flag**
- Single-letter names outside tight loops (`x`, `y`, `t`, `v`)
- Generic placeholders for domain objects: `data`, `temp`, `val`, `arr`, `obj`, `item` when something more specific is available
- Obvious typos or duplicated letters (e.g., `ompTypee`, `produceValue`, `lenghts`)
- Boolean variables not prefixed with `is/has/should/can`

**Why**
Naming is the cheapest form of documentation. Reviewers repeatedly call out vague names.

**Suggested fix**
Suggest a domain-specific name based on what the value represents in context.

---

## 8. Do not introduce unnecessary custom hooks

**What to flag**
- A new `use*` hook that:
  - Is called from only one place
  - Does not use `useState`, `useEffect`, `useMemo`, `useContext`, or Recoil
  - Could be a plain function returning the same value
- A hook whose only consumer is another hook (chained hooks for no reason)
- Wrapping a Recoil `useRecoilValue` access in a hook only to "make it look like a hook"

**Why**
Custom hooks force re-execution every render and add ceremony with no benefit. Plain functions are cheaper and easier to test.

**Suggested fix**
Suggest converting the hook into a regular function (or inlining it if used once).

**Sub-pattern: dedicated `*Hook.res` files used from one place**
If a new `*Hook.res` file is added and grep shows exactly one import site, propose inlining the logic at the call site (or moving it into a `useEffect` there) instead of keeping a separate file.

---

## 9. Avoid unnecessary `useEffect` and add loaders for async data

**What to flag**
- `useEffect` whose body only derives state from props/other state (should be computed inline or via `useMemo`)
- `useEffect` that calls `setState` on every render with a value that could be an initial state value
- Async data fetching without a loader / skeleton component visible while the request is in flight (data may render with stale/empty values)
- Sequential `await` calls for independent network requests (should be parallelised)

**Why**
Unnecessary effects cause flicker, double renders, and wasted requests. Missing loaders show stale data. Sequential awaits make pages slow.

**Suggested fix**
- Inline derived state, or compute with `useMemo`
- Use `Promise.all` / `PromiseUtils.all` for independent fetches
- Add `<PageLoaderWrapper>` / appropriate loader while data is loading

**Sub-pattern: `useState` that only mirrors a context / Recoil value**
Flag `React.useState(() => contextValue)` / `React.useState(() => recoilVal)` patterns where the local state never diverges from the source. Read directly from the context/atom instead.

**Sub-pattern: stale `useEffect` dependencies**
Flag values listed in a `useEffect` dependency array that are not actually read inside the effect body. Either remove them, or read them inside the effect.

**Sub-pattern: hoist pure computations out of `useEffect`**
Statements inside a `useEffect` body that have no side effect (pure derivations, constant lookups, helper calls that only return a value the effect ignores) belong outside the effect. Move them to the component body or a `useMemo`.

**Sub-pattern: split one `useEffect` per concern**
A single `useEffect` should not bundle two unrelated concerns just because they happen to share a dependency array. If the body has two distinct responsibilities, split it into two effects so that each one's deps reflect what it actually depends on.

---

## 10. Do not refetch data already loaded at app boot

**What to flag**
- Fetches to endpoints typically called in `HyperswitchApp` / app bootstrap (merchants list, user info, feature flags, business profiles)
- Component-level fetches whose data is already in a Recoil atom

**Why**
Duplicate fetches waste bandwidth and can cause race conditions where stale values overwrite fresh ones.

**Suggested fix**
Read from the existing Recoil atom / context. If the bootstrap fetch is missing data this component needs, expand the bootstrap fetch instead.

---

## 11. Prefer immutable / functional patterns

**What to flag**
- `Array.push` inside a `reduce`/`map`
- In-place mutation of a parameter array or dict
- Accumulator mutation inside a fold

**Why**
Mutation makes data flow harder to follow and hides side effects.

**Suggested fix**
Return a new array via spread, `Array.concat`, or `reduceWithIndex`/`Array.reduce` returning a fresh accumulator.

---

## 12. Avoid prop drilling — prefer global state

**What to flag**
- The same prop forwarded unchanged through three or more component layers
- A leaf component receiving a prop only because an ancestor needed to pass it down

**Why**
Prop drilling couples intermediate components to data they do not use, and breaks every time the shape changes.

**Suggested fix**
Move the value into a Recoil atom or React context. Read it where it is consumed.

---

## 13. Use ReScript idioms

**What to flag**
- `switch` on `option<>` that only handles `Some(x) => ... | None => default` — could be `Option.mapOr(default, x => ...)` or `Option.getOr(default)`
- Field names matching JS reserved words written awkwardly — should use `@as("type") type_: string`
- Multiple record types with mostly the same fields — should use record spread `{...base, extraField: ...}` and a shared base type
- Tuples used to pass multiple named values — prefer a typed record
- `Js.*` modules where a Core / standard equivalent exists (`Js.Array2` → `Array`, `Js.String2` → `String`)
- `->Belt.*` usage — repo standard is the ReScript Core API

**Why**
ReScript idioms keep the codebase consistent and unlock exhaustive checks and better type inference.

**Suggested fix**
Recommend the idiomatic replacement explicitly.

---

## 14. Keep config files in sync with feature flags

**What to flag**
- A new feature flag added in `FeatureFlagUtils.res` (or similar) without a corresponding entry in `config/*.toml`
- A new constant referenced from config that does not exist in the toml file

**Why**
A flag without a config entry is silently disabled in some environments.

**Suggested fix**
Ask for the toml file to be updated in the same PR.

**Sub-pattern: hardcoded boolean constants for environment / mode**
Flag hardcoded `true`/`false` literals assigned to variables named `isLive*`, `isEnabled*`, `is*Mode`, `show*`, `enable*` inside `src/screens/**` or `src/entryPoints/**`. These should read from `FeatureFlagUtils` or `config.toml` so they can vary per environment.

---

## 15. Keep V1 and V2 in sync

**What to flag**
- A change to a V1 file (`*V1.res`, `getUrl`, `PaymentInterfaceUtilsV1.res`, etc.) without a mirrored change in the V2 counterpart, when the feature exists in both
- Naming divergence between sibling V1/V2 modules (e.g., `list` in one, `overview` in the other, for the same screen)
- Helper functions duplicated across V1 and V2 instead of shared

**Why**
The codebase maintains parallel V1 and V2 surfaces for the orchestration product. Drift between them causes feature gaps that surface much later.

**Suggested fix**
- Mirror the change in the V2 (or V1) file
- Rename for consistency
- Extract shared logic to a version-agnostic helper

---

## 16. Provide specific error messages in catch blocks

**What to flag**
- `catch` blocks that swallow the error
- Generic error messages (`"Something went wrong"`, `"Error"`) where a specific one is possible
- Toast / banner errors with no message at all

**Why**
Vague errors are useless for debugging in production and frustrating for users.

**Suggested fix**
Use the API error message when available; otherwise a specific operation-level message.

**Sub-pattern: never downgrade `Error` → `Success`/`Custom` in a catch block**
A `catch` branch must not set the page state to `Success` / `Custom` and must not silently swallow the original `exn`. Always: (a) set the page state to `Error` (see check #31), (b) log the underlying exception via `Console.error2("...", exn)`, and (c) include enough detail in the message that a user or QA can act on it.

---

## 17. Use `RenderIf` instead of ternary-with-`React.null`

**What to flag**
- `condition ? <Component /> : React.null`
- `condition ? <Component /> : <> </>`
- `condition ? handler : (_ => ())` event handlers (collapse the no-op into the handler instead)

**Why**
The repo uses `<RenderIf condition=... />` as the standard idiom for conditional rendering. It is more readable and easier to grep for.

**Suggested fix**
Replace with `<RenderIf condition=...> <Component /> </RenderIf>`.

**Sub-pattern: unnecessary single-child Fragments**
Flag `<> singleChild </>` with exactly one child element — unwrap it. Conversely, flag adjacent root elements that need a `<>...</>` wrapper.

---

## 18. Avoid hardcoded magic values

**What to flag**
- Numeric literals used as semantic values (e.g., `0` for "no count", status codes scattered inline)
- String literals representing IDs, types, or modes inlined instead of pulled from constants/variants
- Hardcoded URLs, endpoints, or asset paths in component code

**Why**
Magic values break silently when the underlying value changes and have no documentation.

**Suggested fix**
Move to a named constant in the appropriate constants/types file, or use the existing variant.

---

## 19. Remove redundant `open` statements

**What to flag**
- `open X` repeated inside a function or nested block when `X` is already opened at the top of the file
- `open X` at the top of a file where `X` is opened in only one nested function — push the open down or remove altogether
- `RescriptCore.` qualifiers anywhere in code (the codebase opens `RescriptCore` globally — they are noise)
- `open BigModule` used solely to call one function — fully qualify the call instead

**Why**
Duplicate opens create implicit-scope confusion, hide which module a name comes from, and bloat diffs. The codebase has clear conventions for which modules are globally open.

**Suggested fix**
Remove the redundant `open`. For one-shot calls, use `Module.fnName(...)` directly. Never write `RescriptCore.X` — just `X`.

---

## 20. Avoid redundant JSON ↔ Dict round-tripping

**What to flag**
- Sequences within one function where a value flows `JSON.Encode.object(dict)` → some helper that immediately calls `JSON.Decode.object` on it (or vice versa)
- Building a `dict`, encoding it to a `JSON.t`, then decoding it back to a `dict` before using it
- `dict->JSON.Encode.object` followed shortly by another `->getDictFromJsonObject`

**Why**
These conversions cost nothing semantically but make the data flow harder to follow and indicate an API boundary that should accept the original type directly.

**Suggested fix**
Pass the `dict` (or `JSON.t`) through unchanged; change the helper signature if necessary so the conversion happens once at the boundary.

---

## 21. Honor file-placement conventions: Types, Utils, Helper, Components

**What to flag**
- New top-level `type` declarations inside a non-`*Types.res` file — should live in `<Feature>Types.res`
- Pure helper functions (no JSX, no hooks) declared inside a component file — should live in `<Feature>Utils.res` or `<Feature>Helper.res`
- Mock data / default config records declared inside a component file — should live in the corresponding `*Types.res` or constants file
- Business-domain logic added under `src/components/` (the shared components folder) — should live in the feature folder under `src/screens/...` and be passed in via props/callbacks

**Why**
The codebase has a strict layering convention: shared `components/` are domain-agnostic, business logic lives in feature folders, types live in `*Types.res`, helpers in `*Utils.res`/`*Helper.res`. Reviewers consistently push back when these are violated.

**Suggested fix**
Move the declaration to the correct file and import it. For shared components that need feature-specific behavior, parameterize via a callback prop instead of importing feature code.

**Sub-pattern: utility file naming convention**
New utility files must be named `<Feature>Utils.res` and match the owning module/screen. Avoid generic catch-all names like `*GlobalUtils.res`, `*Common.res`, `*Misc.res`, `*Helper.res` (helpers are fine, but the file should still be feature-scoped). One feature → one `<Feature>Utils.res`.

---

## 22. Don't over-annotate types — let inference work

**What to flag**
- Local `let` bindings inside a function with explicit type annotations that the compiler can infer (`let count: int = arr->Array.length`)
- Function parameters annotated with their inferred type when no overloading or ambiguity exists

**Why**
Excess annotations add noise and break when the underlying type is refactored. ReScript's inference is strong; rely on it.

**Suggested fix**
Remove the annotation unless it serves a documentation or disambiguation purpose at a public API boundary.

---

## 23. Provide stable `key` props on dynamic lists

**What to flag**
- JSX produced by `Array.map` / `Array.mapWithIndex` returning React elements without a `key` prop on the root element of each item
- `key={index->Int.toString}` for lists whose items can be reordered or filtered (use a stable id instead)
- Static, non-unique key strings (`"item"`, `"row"`)

**Why**
Missing or unstable keys cause React reconciliation bugs (lost focus, wrong animations, mis-rendered state).

**Suggested fix**
Use a stable id from the data. For genuinely dynamic content with no id, use `LogicUtils.randomString(...)` to generate one.

**Sub-pattern: array index is forbidden as `key` for add/remove rows**
Specifically flag `<Component key={i->Int.toString}>` inside `Array.mapWithIndex` for forms that allow adding/deleting rows (custom headers, metadata fields, dynamic config rows, etc.). Index-as-key causes React to reuse the wrong DOM node when a row in the middle is removed. Generate and store a stable id (`LogicUtils.randomString`) on the row object itself when first created.

---

## 24. Inline single-use throwaway variables

**What to flag**
- `let x = expr` followed on the very next line by a single use of `x` that doesn't improve readability
- Intermediate `body` / `payload` / `data` variables created only to be passed straight into the next function call

**Why**
Throwaway bindings add line count and force the reader to track an extra name. Reviewers regularly request inlining.

**Suggested fix**
Inline the expression. Keep the binding only when it documents intent or when the expression is reused.

---

## 25. Prefer `Array.reduce` and one-liners over imperative accumulation

**What to flag**
- A `ref` built up inside `Array.forEach` to accumulate a value — should be `Array.reduce`
- An if/else block whose only effect is to choose between two values — should be a ternary
- Multi-step transformations that the existing `LogicUtils` helpers (`getJsonFromArrayOfJson`, `getValueFromArray`, etc.) collapse into one call

**Why**
Imperative accumulation hides the data flow and is more bug-prone than a fold. The codebase strongly prefers functional one-liners where they fit.

**Suggested fix**
Rewrite as `Array.reduce` / ternary / single helper call. Name the helper if one already exists.

---

## 26. Use `(Variant :> string)` coercion instead of string-mapper functions

**What to flag**
- Newly added functions of shape `let toString = v => switch v { | A => "a" | B => "b" }` where each constructor maps 1:1 to its `@as` literal
- Manual mapping tables from variant to string when the variant already declares `@as("...")` for each constructor

**Why**
ReScript supports subtype coercion `(value :> string)` for poly variants and `@as`-tagged variants. It is cheaper, can't drift from the variant definition, and is the codebase's preferred idiom.

**Suggested fix**
Delete the mapper and use `(value :> string)` at call sites. Add `@as("...")` to the variant if missing.

---

## 27. Use `LogicUtils.valueFormatter` / `shortNum` for numeric display

**What to flag**
- Direct `Float.toString` / `Int.toString` of metric/analytics values into JSX without formatting
- Hand-rolled percentage / abbreviation logic (`/1000`, `+ "K"`) when an analytics formatter exists
- Repeated currency / percentage formatting inline across multiple components

**Why**
Analytics values must format consistently across the app (separators, abbreviations, decimals). `LogicUtils` already has the formatters; reinventing them produces visual drift.

**Suggested fix**
Use `LogicUtils.valueFormatter` / `shortNum` (or the appropriate currency-format util). If a new formatter is genuinely needed, add it there, not inline.

---

## 28. Mixpanel events: name parity with PR description, and useful metadata

**What to flag**
- A `mixpanelEvent(~eventName="...")` call whose event name string does not appear verbatim in the PR description / body
- Identical event names used for both create and update flows (no way to distinguish them in analytics)
- Mixpanel events fired without contextual metadata when relevant context (`profile_id`, `merchant_id`, count of items, etc.) is in scope

**Why**
Analytics is only useful if the event names match the documentation and carry enough context to slice on. Reviewers (and the existing review bot) flag this consistently.

**Suggested fix**
- Rename to match the PR description, or update the PR description
- Differentiate create vs update with distinct event names or an `action` property
- Attach `profile_id` / contextual metadata as event properties

**Sub-pattern: name parity across sibling files and V1/V2 versions**
For sibling files touched in the same PR (e.g. `PaymentSettingsCustomMetadataHeaders.res` and `PaymentSettingsCustomWebhookHeaders.res`), Mixpanel event-name prefixes / token shapes must match. Same for sidebar / tab ordering between V1 and V2 versions of a screen — the order and labels should be identical unless there is a specific reason to diverge.

---

## 29. Keep default / fallback values in a single source of truth

**What to flag**
- The same default config record / fallback object literal declared in two or more files
- Default values written into the API payload when the read path already applies the same fallback at render time
- A default removed from one branch of code while another copy still exists elsewhere

**Why**
Duplicate defaults drift apart silently and are a frequent source of subtle bugs (theme defaults, config defaults, form defaults).

**Suggested fix**
Move the default into one canonical location (the relevant `*Types.res`, a provider component, or a constants file) and import it everywhere. Apply fallbacks at read time rather than persisting them.

**Sub-pattern: keep formatter/default fallbacks instead of deleting them**
When a diff removes a default-formatter or default-value branch, prefer keeping it as the fallback via `Option.getOr` / `Option.mapOr` and accepting an optional override prop, instead of deleting the default outright.

**Sub-pattern: don't persist values that equal the default**
When constructing a create/update API payload, do not include fields whose value equals the central default/fallback constant — the read path will apply the same default. Strip empty / default-equal fields before encoding the request body. This keeps API payloads small and lets us distinguish "user explicitly set this" from "user accepted the default".

---

## 30. Tailwind arbitrary values: extract repeated literals to config

**What to flag**
- The same arbitrary Tailwind value literal (`h-[84px]`, `w-[320px]`, `text-[#1A1A1A]`, `top-[14px]`) appearing 3+ times across the diff or across 2+ files
- Arbitrary values that closely match an existing scale token (e.g. `h-[84px]` when an `h-21` token exists)

**Why**
Arbitrary values bypass the design system, can't be themed, and drift over time as each developer picks slightly different values.

**Suggested fix**
Move the value into `tailwind.config.js` (or the equivalent design-token file) and reference it by name. If the value matches an existing token, use that token instead.

---

## 31. Page state on API failure must be `Error`, not `Custom`/`Success`

**What to flag**
- `catch` blocks inside data-fetching code that set a `PageLoaderWrapper` state to `Custom`/`Success`/no-data when the API actually failed
- Generic "no data to display" empty states shown for both empty and errored responses

**Why**
Conflating empty with errored hides real failures from users and from QA. Each state needs a distinct UI affordance.

**Suggested fix**
In the `catch` branch, set the page state to `Error` (with a meaningful message). Reserve the empty / no-data state for genuinely successful-but-empty responses.

---

## 32. Wire modal "X" close to the same handler as Cancel

**What to flag**
- A modal component with a `handleCancel` (toast, redirect, cleanup, etc.) where the header `onClose` / `closeOnX` prop is wired to a different (or no) handler — clicking the X silently bypasses the cleanup
- Modal close handlers that diverge between the keyboard `Esc`, the X button, and the Cancel button

**Why**
Users expect all three exit paths to behave the same. Divergence is a stealth bug class.

**Suggested fix**
Pass `handleCancel` (or a shared `onClose`) to every dismissal path on the modal.

---

## 33. Form library: drop unused subscriptions

**What to flag**
- `useForm` / `Form` `subscription` objects with keys set to `true` (`hasSubmitErrors`, `submitErrors`, `submitting`, etc.) where the corresponding value is never destructured or used in the component body

**Why**
Unused subscriptions cause unnecessary re-renders and mislead readers about which form state matters.

**Suggested fix**
Subscribe only to the keys actually consumed by the component.

---

## 34. Currency / amount handling must use precision helpers

**What to flag**
- Hardcoded `100`, `100.0`, `/ 100`, `* 100`, `Float.toFixed(_, 2)`, or literal `2` precision applied to variables named `amount`, `total`, `refund`, `value`, `price`, `minor*`, `major*`
- Manual decimal-place math when a currency context is in scope
- Floating-point comparisons (`==`, `>`, `<`) on monetary values without an epsilon or precision-aware helper

**Why**
Different currencies have 0, 2, or 3 decimal places. Hardcoding 2 silently breaks JPY, KWD, BHD, etc. and produces real refund / capture bugs. The repo has helpers (`CurrencyUtils.getAmountPrecisionDigits(currency)`, conversion-factor utilities) precisely for this.

**Suggested fix**
Use the currency-aware helper from `CurrencyUtils` / `CurrencyFormatUtils`. If a needed helper does not exist, add it there rather than computing precision inline.

---

## 35. Permission checks must scope to resource / group, not role name

**What to flag**
- Equality checks against `role.name` / role-name strings (`role == "merchant_admin"`, `roleName === "viewer"`)
- Hardcoded role-string lists used to gate UI
- Permission code that switches on `errorCode` strings instead of an error variant

**Why**
Role names change as the permissions system evolves; resource/scope/group identifiers are stable. Gating on role name produces silent regressions whenever a role is renamed or split.

**Suggested fix**
Check the underlying resource / scope / permission group via the permissions util (e.g. `userHasAccess`, `getGroupAccess`). For error checks, define and use a variant for known error codes.

**Where this matters most**
Files under `src/entryPoints/AuthModule/**`, `*Permission*.res`, `*Role*.res`, anything using `useUserInfo` to gate UI.

---

## 36. Remove dead debug logs and commented-out code

**What to flag**
- Net-added `Console.log*`, `Js.log*`, `Js.Console.log*` calls outside of `catch` blocks
- Three or more consecutive `//`-prefixed lines that look like commented-out ReScript / JS code
- Stray `debugger` / `Js.Debugger.*` statements
- Empty placeholder comments like `// TODO` with no description

**Why**
Debug noise makes production logs unusable, and commented blocks rot — nobody knows whether they should be revived or deleted. PR reviewers consistently ask for them to be removed before merge.

**Suggested fix**
Delete the log / commented block. If a TODO is genuinely needed, write a complete sentence explaining what is missing and why.

**Allowed**
`Console.error2("operation failed", exn)` inside `catch` blocks (this is encouraged — see check #16).

---

## 37. Centralize mock / dummy data into a Types or Mock file

**What to flag**
- Inline object literals in component or helper files whose field names clearly belong to a domain record (orgs, merchant, profile, user, theme, etc.)
- Hardcoded preview/sample data declared inside the component that consumes it
- The same mock object copy-pasted into multiple files for "previewing" purposes

**Why**
Inline mock data drifts from real API shapes and gets copy-pasted across previews. A single `*Types.res` / `*Mock.res` location keeps mocks aligned with the real types and easy to update.

**Suggested fix**
Move the mock to the corresponding `*Types.res` (next to the type definition) or a dedicated `*Mock.res` file, and import it everywhere it is used.

---

## 38. File uploads: validate extension/content-type and don't hardcode format in URLs

**What to flag**
- An upload component where `acceptTypes` lists multiple extensions but the destination URL hardcodes a single one (e.g. `acceptTypes=".png,.jpg"` with `url = "/themes/${id}/logo.png"`)
- `FormData` / multipart upload calls passing an empty headers dict
- Upload code that does not check the file's extension or MIME type before sending

**Why**
Mismatched extensions cause silent storage / caching bugs (a `.jpg` saved as `.png` fails to render anywhere downstream). Missing `Content-Type` causes API rejections that surface only at runtime.

**Suggested fix**
- Derive the destination extension from the actual uploaded file, not from a literal
- Set `Content-Type: multipart/form-data` (or let `FormData` set it via the browser) explicitly
- Validate the file extension/MIME against `acceptTypes` before constructing the request

---

## 39. Don't store raw API responses in component state

**What to flag**
- `setState(_ => response)` / `setState(_ => json)` where `response` / `json` is the untransformed API result (a `JSON.t` or untyped dict)
- Storing the entire response when only one nested field is consumed downstream

**Why**
Raw responses pollute the component with parsing logic at every read site, defeat type-safety, and force every consumer to know the API shape.

**Suggested fix**
Transform the response into a typed record (via the feature's `itemToObjMapper` / decoder) at the API boundary, then store only the typed slice the component actually needs.

---

## 40. Don't use empty string to mean "absent"

**What to flag**
- `LocalStorage.setItem(key, "")` / `SessionStorage.setItem(key, "")` to mark a value as cleared
- `->Option.getOr("")` immediately followed by an `isNonEmptyString` check (double-negative — use `Option.isSome` or `getNonEmptyString` once)
- Function signatures that take a `string` parameter where `option<string>` would be more honest, with `""` as the "no value" sentinel

**Why**
`""` and "absent" are different states. Conflating them produces bugs at every consumer (storage, validation, display) and forces every reader to know which interpretation is intended in this code path.

**Suggested fix**
- Use `removeItem` instead of setting `""`
- Use `option<string>` and `LogicUtils.getNonEmptyString` to convert at the boundary
- Pattern-match on `Some(value)` / `None` rather than checking equality with `""`

---

## 41. Always handle the default / `None` / `_` case explicitly on domain types

**What to flag**
- `switch` expressions on critical domain variants (Currency, PaymentStatus, Scope, RoleType, EntityType, ConnectorType) whose default branch is a silent `| _ => ()` / `| _ => ""` / `| None => ""`
- Missing `| None =>` branch when an `option<>` is destructured for a user-facing decision

**Why**
Silent defaults hide gaps in domain handling — a new variant added later goes unhandled with no compiler warning, and reviewers consistently ask "what happens in the default case?".

**Suggested fix**
- Enumerate the variants explicitly so the compiler enforces exhaustiveness
- If a fallback is genuinely correct, leave a one-line comment explaining why this default is safe

---

## 42. Attach screenshots / videos for UI-affecting changes (and cover empty states)

**What to flag**
- A PR that touches `.res` files under `src/screens/**` or `src/components/**` with visible UI diffs but the PR body has no image or video attachment (no `user-attachments/assets/`, no `![`)
- A PR adding tooltip / description / list / table code with no screenshot of the empty / zero-data case

**Why**
Reviewers consistently ask for screenshots / videos before approving UI changes, and explicitly ask for the empty-state screenshot when one isn't provided. Surfacing this automatically shortens review cycles.

**Suggested fix**
Ask the author to attach (a) a screenshot / short video of the change in its primary state, and (b) a screenshot of the empty / zero-data / error state when relevant. For substantial UI restructuring, ask whether designer review has happened.

---

## 43. Centralize DOM access via `DomUtils`

**What to flag**
- `.res` files outside `src/libraries/DomUtils*` that import from `Dom`, `Webapi`, or use raw `document.*` / `window.*` calls
- `Dom.Document.getElementById`, `document.querySelector`, `window.location.*`, `window.addEventListener` called inline in component / screen / embeddable code
- New bindings to DOM APIs added in feature files

**Why**
The codebase routes all DOM access through `DomUtils` (and friends like `Window.res`) so that bindings, type-safety, and SSR/embeddable concerns are in one place. Inline `Dom.*`/`window.*` access fragments these guarantees and makes embeddable + iframe scenarios fragile.

**Suggested fix**
Use the existing `DomUtils` binding. If a needed binding is missing, add it to `DomUtils` and import from there.

---

## 44. Don't throw exceptions for control flow — use `option` / `result`

**What to flag**
- `raise(...)`, `Exn.raise*`, `Js.Exn.raiseError`, `assert(...)`, `%raw("throw ...")` in non-error-boundary code paths
- Functions that throw to signal "not found" / "invalid input" instead of returning `option<>` or `result<>`

**Why**
ReScript has first-class `option` and `result` types. Exceptions for control flow break exhaustiveness checking, are invisible to callers, and force every consumer to wrap calls in `try`. They are a source of silent bugs.

**Suggested fix**
Return `option<value>` (for "missing") or `result<value, error>` (for "failed with reason"). Reserve raised exceptions for genuinely unrecoverable programmer errors at module boundaries.

---

## 45. Canonical `switch` arm ordering: `Some` before `None`, `Ok` before `Error`

**What to flag**
- `switch` on `option<>` where `| None =>` is written before `| Some(...) =>`
- `switch` on `result<>` where `| Error(...) =>` is written before `| Ok(...) =>`

**Why**
Consistent ordering across the codebase makes scanning code faster: the success / present case is always first, the absent / failure case is second. Reviewers consistently ask for this ordering.

**Suggested fix**
Reorder so `Some` / `Ok` is the first arm.

---

## 46. No hardcoded `setTimeout` / fixed-delay waits for async readiness

**What to flag**
- `setTimeout`, `Js.Global.setTimeout`, custom `delayPromise` / `wait` helpers used to wait for a DOM node, script, iframe, or async resource to become "ready"
- Fixed `1000` / `2000` / `500` ms delays before reading state that should be event-driven

**Why**
Fixed timeouts are a race condition waiting to happen. The element might still not be ready in 1 second on a slow network, or it might be ready in 50ms and the user sees an unnecessary delay.

**Suggested fix**
Use an event-driven readiness signal: `onload`, `onreadystatechange`, `MutationObserver`, an explicit promise from the loader, or a Recoil atom that flips when ready.

---

## 47. Don't `switch` on plain booleans / two-way values — use `if`

**What to flag**
- `switch` expressions whose discriminant is a `bool`, or a 2-branch `int`/`string`
- `switch x { | true => ... | false => ... }`

**Why**
`switch` is for variants and tuples where exhaustiveness matters. For plain booleans, `if`/`else` is shorter and more readable. Reviewers explicitly call this out as overuse of `switch`.

**Suggested fix**
Rewrite as `if cond { ... } else { ... }`. Reserve `switch` for variant types.

---

## 48. Form input validation: trim, use `LogicUtils`, fixed error precedence

**What to flag**
- Form `validate` / `validateForm` functions that read string inputs without `String.trim`
- Validators that compare directly to `""` instead of using `LogicUtils.isEmptyString` / `isNonEmptyString`
- Validators that check regex / length before checking emptiness
- Validators that build the error dict imperatively instead of returning a final `JSON.Encode.object`

**Why**
Untrimmed strings produce bogus "not empty" passes for `"   "`, and inconsistent error precedence makes UX feel random across forms. The repo has a canonical pattern for this.

**Suggested fix**
The canonical shape is:
1. Read with `LogicUtils.getString(values, key, "")->String.trim`
2. Check empty first via `isEmptyString`
3. Then length / format / regex
4. Return errors via `Dict` → `JSON.Encode.object` at the end

---

## 49. Use `Primary` button type for the primary CTA

**What to flag**
- A submit / create / save / continue button inside a modal, form, or wizard with `buttonType=Secondary` / `NonFilled` / no `buttonType` prop
- The primary action of a screen rendered as a tertiary / link-style button

**Why**
The design system reserves `Primary` for the single primary action on any screen / modal. Using `Secondary` makes the CTA invisible and is one of the most common reviewer comments on form PRs.

**Suggested fix**
Set `buttonType=Primary` on the main CTA. Use `PrimaryOutline` / `Secondary` only for cancel / dismiss / alternate actions.

---

## 50. Audit dead / unreachable variant arms in auth and SSO switches

**What to flag**
- `switch` arms in `src/entryPoints/AuthModule/**`, `AuthSelect.res`, `PreLogin*.res`, etc. that handle a variant constructor which the upstream filter or array has already excluded
- Auth-flow switches that handle every constructor of a variant when the runtime can only ever pass a subset

**Why**
Auth flows accumulate dead branches as auth methods come and go (magic link, SSO, 2FA, OIDC). Dead arms mislead future readers and hide gaps when a new method is added.

**Suggested fix**
Trace the call site: if the constructor cannot reach this switch, delete the arm. If it can, document the path. If unsure, add a comment with "reachable from X" rather than a silent `| _ => ()`.

---

## 51. Spell-check newly added identifiers and comments

**What to flag**
- New identifiers (variables, function names, type names, prop names) with obvious typos: `conditionDIct`, `setUpConnectorContainer`, `produceValue`, `lenghts`, doubled letters, transposed characters
- Typos in newly added code comments

**Why**
Identifier typos are a permanent rename cost and surface during every later refactor. Reviewers consistently catch these manually; the bot should pre-empt them.

**Suggested fix**
Run a spell-check (e.g. `codespell`) over added identifiers and comments. Maintain a project allow-list for domain terms (`hyperswitch`, `hypersense`, `juspay`, connector names, etc.).

---

## 52. Regression-audit shared component call-sites when modifying a shared component

**What to flag**
- A diff that touches a file under `src/components/` (shared UI), modifies a component's prop signature, or changes its layout/styling
- A diff that changes the rendered DOM of a `src/components/` component used in 5+ places without a screenshot of the impact on existing call-sites

**Why**
Shared components have many consumers. A subtle alignment, spacing, or default-prop change in `MultiSelectInput` / `Button` / `Modal` ripples across the app. Reviewers consistently ask "did you check the other places this is used?".

**Suggested fix**
List the importing files via grep, verify each visually, and either attach screenshots / a video walkthrough of the affected screens or call out which call-sites you've audited in the PR description.

---

## How the bot should use this file

1. On every PR review, walk the diff and run each check above against added / modified lines.
2. Group findings by section number when posting review comments.
3. When a check fires, quote the line, name the rule (e.g., "Check 1: variant over string"), and give the concrete fix.
4. Skip a check only when the diff context clearly justifies the pattern (e.g., a literal string check inside a parser that genuinely consumes raw strings).
5. If a reviewer marks one of the bot's comments as a false positive, treat that as feedback to refine the corresponding check — do not silently keep firing it.
