# SPEC — Retain filters on Reconciliation → Pipelines listing after visiting a file

## Problem statement
On the Reconciliation → Pipelines listing page, when a user applies filters (date range,
account, status), clicks a file to open its detail page, and then returns to the listing
via the breadcrumb, the previously applied filters are lost. The listing re-mounts with
default filters, forcing the user to re-apply them.

## Root cause
`ReconEnginePipelinesContainer.res` wraps the list and the detail in **two separate**
`FilterContext` providers. `FilterContext.res` clears its `sessionStorage` on unmount
(`Some(() => clearSessionStorage())`, line 191). Navigating list → detail unmounts the
list provider and wipes its saved filters, so returning re-seeds defaults.

The payments pattern (`TransactionContainer.res`) uses a single provider around the whole
`EntityScaffold`. Copying that verbatim is unsafe here because the recon **detail page**
(`ReconEnginePipelineDetails.res:271-285`) consumes the same `FilterContext` with its own
`DynamicFilter` (`tabNames=filterKeys`), whereas the payments detail (`ShowOrder.res`) does
not. A shared provider would leak the list's filter tabs into the detail (and vice-versa).

## Approach
Add an opt-in `~persistFilters=false` prop to `FilterContext`. When `true`, the provider
skips `clearSessionStorage()` on unmount, so its `sessionStorage[index]` survives the
list → detail → list round-trip and is restored on re-mount (existing mount effect,
lines 169-192). Keep the list and detail providers separate (no cross-contamination).
Set `persistFilters=true` only on the list provider.

`useSetInitialFilters` only seeds defaults when the filter dict is empty
(`HSwitchRemoteFilter.res`), so restored filters are not overwritten on return.

## Affected files
- `src/context/FilterContext.res` — add `~persistFilters=false` param; guard the
  on-unmount `clearSessionStorage()` behind `!persistFilters`. Default preserves current
  behavior for all existing callers.
- `src/ReconEngine/ReconEngineContainer/ReconEnginePipelinesContainer.res` — pass
  `persistFilters=true` to the list's `FilterContext`.

## Data model / API changes
None.

## Risks & out-of-scope
- Default `persistFilters=false` keeps every other `FilterContext` caller unchanged.
- Detail-page filters remain fully independent (separate provider/index).
- Not consolidating providers (payments pattern) — deliberately avoided to prevent
  list/detail filter-tab contamination.

## Test plan
- `npm run re:build` + `npm run build` must pass.
- Manual: apply account/status/date filters on Pipelines, open a file, click the
  "Pipelines" breadcrumb → filters remain applied.
