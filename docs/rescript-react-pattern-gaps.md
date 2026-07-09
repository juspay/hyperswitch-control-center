# ReScript and React Pattern Gap Audit

Date: 2026-07-09

This audit turns the repo's strongest existing ReScript and React patterns into review criteria, then records the places where the current codebase does not consistently follow them.

## Target Patterns

- Keep domain shape in `Types.res`.
- Keep API and JSON mapping in `Utils.res` or mapper-specific modules.
- Keep table contracts in `Entity.res` or clearly named table utility modules.
- Drive reusable list/table UI through `EntityType.entityType`.
- Call backend APIs through shared API hooks instead of ad hoc fetch/status handling.
- Expose stable shared UI APIs through `.resi` signatures when the component is broadly reused.
- Keep React components focused on state orchestration and composition.

## Scope and Scan Summary

The scan covered the full `src` tree.

| Signal | Result |
| --- | ---: |
| ReScript implementation files | 1,299 |
| ReScript interface files | 16 |
| Files containing `@react.component` | 744 |
| Component files that also contain JSON/dict decoding markers | 297 |
| Files matching `*Types.res` | 141 |
| Files matching `*Utils.res` | 228 |
| Files matching `*Entity.res` | 66 |
| Files matching `*Helper.res` | 65 |
| Direct `Fetch.fetchWithInit` usage outside bindings | 1, only `src/hooks/AuthHooks.res` |

The strongest repo-wide pattern is the `EntityType` table contract plus shared API hooks. The main gaps are that some feature and shared UI modules bypass, overload, or inconsistently apply those patterns.

## Reproduction Commands

```sh
find src -name '*.res' | wc -l
find src -name '*.resi' | wc -l
rg -l '@react\.component' src -g '*.res' | wc -l
rg -l '@react\.component' src -g '*.res' | while read f; do if rg -q 'getDictFromJsonObject|JSON\.Decode|JSON\.Classify|getArrayFromDict|getJsonObjectFromDict' "$f"; then echo "$f"; fi; done | wc -l
find src -name '*.res' -print0 | xargs -0 wc -l | sort -nr
rg -n 'Fetch\.fetch|fetchWithInit|window\.fetch|@val external fetch|\.fetch\(' src -g '*.res'
rg -n 'Fetch\.Response\.status|responseStatus|status >=|status ===|status ==|status <' src -g '*.res'
rg -l 'useApiFetcher\(|fetchApi\(' src -g '*.res'
rg -l 'Table\.makeHeaderInfo|getCell =|getHeading =' src -g '*.res'
```

## Gap 1: JSON Mapping Leaks Into React Components

The good pattern is visible in modules such as `PaymentsProcessedTypes.res` and `PaymentsProcessedUtils.res`: finite domain values are modeled as variants, and raw JSON/dicts are converted to typed records before rendering.

However, 297 component files contain both `@react.component` and JSON/dict decoding markers such as `getDictFromJsonObject`, `JSON.Decode`, `JSON.Classify`, `getArrayFromDict`, or `getJsonObjectFromDict`.

This makes component code responsible for reading payload structure, interpreting domain state, rendering UI, and managing React state/effects.

Examples:

- `src/screens/Developer/PaymentSettings/PaymentSettings.res`
  - `AuthenticationInput` reads form JSON directly.
  - `CollectDetails`, `AutoRetries`, `ClickToPaySection`, and `Vault` each derive domain state directly from form JSON.
- `src/screens/NewAnalytics/Insights/PaymentAnalytics/SuccessfulPaymentsDistribution/SuccessfulPaymentsDistribution.res`
  - sample-data response parsing, filtering, aggregation, and component state orchestration happen together.
- `src/Recon/ReconScreens/ReconReports/ReconReportsList.res`
  - fetch, JSON parsing, payload mapping, state updates, search state, and modal rendering live in one component.

Recommendation:

- Move JSON-to-record mapping, string-to-variant conversion, and request body construction into feature utilities.
- For form-heavy components, move repeated form JSON accessors into helpers such as `getIsAutoRetryEnabled`, `getOutgoingWebhookHeaders`, or `getVaultStatusFromForm`.

## Gap 2: Generic Shared Components Have Very Broad APIs

The repo benefits from powerful primitives such as `DynamicTable`, `LoadedTable`, `SelectBox`, and `FilterSelectBox`. The risk is that these components have grown into large multi-mode components where future changes are hard to reason about.

Examples:

- `src/components/DynamicTable.res`
  - accepts a very large prop surface
  - handles entity extraction, Recoil feature flags, filters, URL params, API fetching, pagination, column customization, local filtering, error handling, and table rendering in one module
- `src/components/LoadedTable.res`
  - over 1,000 lines
  - has a `.resi`, which is good, but still carries sorting, pagination, filtering, row interactions, and rendering
- `src/components/SelectBox.res` and `src/components/FilterSelectBox.res`
  - both are over 2,000 lines
  - share similar setup for return types, DOM externals, final-form externals, regex handling, and list item rendering

Recommendation:

- Add `.resi` files before broad reuse.
- Split behavior hooks from render components.
- Avoid adding another optional prop when a smaller wrapper component would preserve the core contract.
- Extract repeated select/dropdown internals into a shared module before adding more behavior.

## Gap 3: Table Entity Pattern Is Applied Inconsistently

The best table code uses `EntityType.makeEntity` with typed column variants, `getHeading`, and `getCell` in an `Entity.res` or utility module.

Examples:

- `src/screens/Analytics/ErrorReasons.res`
  - defines `errorObject`, `cols`, `visibleColumns`, `tableItemToObjMapper`, `getObjects`, `getHeading`, `getCell`, `tableEntity`, and the React component in the same file
- `src/screens/Transaction/Order/OrderVoidForm.res`
  - matches table-heading/entity patterns despite being a form component
- `src/screens/Transaction/Order/OrderRefundForm.res`
  - matches table-heading/entity patterns despite being a form component
- `src/components/HSwitchSingleStatTableWidget.res`
  - defines table entity behavior inside a shared widget

Recommendation:

- If a table has reusable domain meaning, put it in `*Entity.res`.
- If it is private to one component, keep the table contract in a nested module named `TableEntity`.
- Avoid top-level table contract definitions in files whose main name implies a screen or form component.

## Gap 4: Some Callers Bypass API Response Handling

Direct `Fetch.fetchWithInit` usage is well centralized: the only non-binding usage is `src/hooks/AuthHooks.res`. That is good.

The weaker pattern is that many components use `AuthHooks.useApiFetcher()` directly and then manually parse `Fetch.Response.json`. This bypasses some behavior centralized in `APIUtils.useGetMethod`, `APIUtils.useUpdateMethod`, and `responseHandler`, such as response status handling, toast behavior, session-expiry handling, and API error tracking.

Examples:

- `src/Recon/ReconScreens/ReconReports/ReconReports.res`
  - uses `AuthHooks.useApiFetcher()` and parses report data directly
- `src/Recon/ReconScreens/ReconReports/ReconReportsList.res`
  - uses `AuthHooks.useApiFetcher()` and parses report data directly
- `src/screens/NewAnalytics/Insights/PaymentAnalytics/SuccessfulPaymentsDistribution/SuccessfulPaymentsDistribution.res`
  - uses both `APIUtils.useUpdateMethod()` and `AuthHooks.useApiFetcher()` in one component

Recommendation:

- Normal API calls should use `useGetMethod` or `useUpdateMethod`.
- Direct `useApiFetcher` should be limited to static/test assets, blob downloads, non-standard response formats, instrumentation calls, or custom chart logging.
- When direct `useApiFetcher` is necessary, wrap it in a named hook/helper so component code does not own status parsing.

## Gap 5: Analytics Modules Repeat Similar Fetch Logic

Newer analytics modules show good typed mapping and graph/table separation, but many modules repeat the same orchestration shape:

- read `filterValueJson`
- derive dates, comparison, currency, smart retry flag, sample-data flag
- choose sample-data fetch versus API request
- map `queryData`
- fill missing data points
- set `PageLoaderWrapper` state

Examples:

- `src/screens/NewAnalytics/Insights/PaymentAnalytics/PaymentsProcessed/PaymentsProcessed.res`
- `src/screens/NewAnalytics/Insights/InsightsRefundsAnalytics/RefundsProcessed/RefundsProcessed.res`
- `src/screens/NewAnalytics/Insights/SmartRetryAnalytics/SmartRetryPaymentsProcessed/SmartRetryPaymentsProcessed.res`
- `src/screens/NewAnalytics/Insights/PaymentAnalytics/PaymentsSuccessRate/PaymentsSuccessRate.res`

Recommendation:

- Extract a reusable analytics query hook or helper such as `useInsightQuery`, `useComparisonQuery`, `fetchAnalyticsMetricData`, or `fetchSampleOrRemoteAnalyticsData`.
- Let feature modules provide endpoint/domain, metrics, mapper, and default empty data.

## Gap 6: Feature Directory Naming Is Not Uniform

The repo has a useful convention: feature folders often contain `Types`, `Utils`, `Entity`, `Helper`, and the screen component. Several feature directories have multiple `.res` files but lack either local `Types` or `Utils` files.

Examples:

- `src/screens/Connectors/PaymentProcessor`
- `src/RevenueRecovery/RevenueRecoveryScreens/RecoveryProcessors/RevenueRecoveryBillingProcessors`
- `src/screens/Routing/AdvancedRouting`
- `src/screens/PayoutRouting`
- `src/screens/Customers`
- `src/screens/Developer/PaymentSettingsRevamped/AcquirerConfigSettingsRevamp`

Recommendation:

- Add `Types.res` when a feature has more than one domain record or finite state enum.
- Add `Utils.res` when a component reads or writes API/form JSON.
- Add `Entity.res` when a feature owns table columns/cells.
- Avoid adding new domain types at the top of screen components unless they are truly private and tiny.

## Gap 7: Some Contexts Are Data Pipelines

Contexts should ideally provide state and narrow operations. Some context modules have grown into data-fetching engines.

Examples:

- `src/context/ChartContext.res`
  - initializes many chart states in the provider
  - builds request bodies, calls `fetchApi`, logs requests, transforms newline-separated data, merges chart data, and updates chart state in the same context
- `src/context/SingleStatContext.res`
  - similar context plus fetch orchestration and transformation
- `src/context/ThemeProvider.res`
  - fetches and transforms theme data in provider code

Recommendation:

- Split large contexts into context value/provider, fetch hook, mapper/transform helper, and presentational children where needed.
- The provider should read like orchestration, not a full data pipeline.

## Gap 8: Old And New Patterns Coexist Without Migration Boundaries

The repo contains older analytics and UI patterns beside newer typed/entity-driven modules. Without explicit migration boundaries, new code may copy older patterns.

Examples:

- `src/screens/Analytics/*` contains older analytics modules with larger component files and more inline mapping.
- `src/screens/NewAnalytics/*` has better `Types`/`Utils` separation in many areas, but still repeats fetch orchestration.
- `src/components/SelectBox.res` and `src/blend/bindings/SingleSelectBinding.res` coexist.

Recommendation:

- New analytics work should follow the `src/screens/NewAnalytics/.../*Types.res` and `*Utils.res` pattern.
- New design-system-backed inputs should prefer `src/blend/bindings/*` or adapters unless the old custom component is required.
- Old modules can remain stable, but new behavior should not expand older large components without a migration reason.

## Gap 9: Recoil Atom Ownership Is Broad

`src/Recoils/HyperswitchAtom.res` is typed, which is good. The gap is that many unrelated global atoms live in one module. This makes import boundaries broad and makes it harder to see which product area owns which state.

Recommendation:

- Split ownership over time into modules such as `MerchantAtoms.res`, `ConnectorAtoms.res`, `FeatureFlagAtoms.res`, `UserAccessAtoms.res`, and `SearchAtoms.res`.
- Preserve re-export compatibility if many imports depend on `HyperswitchAtom`.

## Gap 10: Large Feature Components Make Testing And Review Hard

Large files are not all bad, but large feature components are harder to review than large pure utility dictionaries or shared infrastructure.

High-signal files:

- `src/screens/Developer/PaymentSettings/PaymentSettings.res`: 1,150 lines
- `src/screens/Transaction/Order/ShowOrder.res`: 1,069 lines
- `src/screens/Routing/AdvancedRouting/AdvancedRouting.res`: 934 lines
- `src/screens/Analytics/Analytics.res`: 872 lines
- `src/ReconEngine/ReconEngineScreens/ReconEngineExceptions/ReconEngineExceptionTransaction/ReconEngineExceptionTransactionComponents/ReconEngineExceptionTransactionResolution.res`: 987 lines and 26 `useState` occurrences

Recommendation:

- Do not add new independent behavior inline when touching these files.
- Extract private nested modules into local helper files when they cross roughly 100 to 150 lines.
- Move form parsing and request construction out before adding new form sections.
- Use small domain hooks for repeated state/effect clusters.

## What Is Already Good And Should Be Preserved

- `EntityType.entityType` is a strong abstraction and should remain the default for table/list pages.
- `TableUtils.cell` and `Table.makeHeaderInfo` provide a useful semantic table DSL.
- `AuthHooks.useApiFetcher` centralizes low-level fetch behavior well.
- `APIUtils.responseHandler`, `useGetMethod`, and `useUpdateMethod` provide a better caller-level API contract than manual response parsing.
- Newer analytics modules often use `Types.res` and `Utils.res` well, even when fetch orchestration is still repetitive.
- The app root provider composition in `EntryPointUtils.res` is centralized and clear.

## Suggested Priority Order

1. Add a short contributor guideline documenting the preferred `Types` / `Utils` / `Entity` / screen split.
2. Create an analytics query helper to remove repeated sample-data and comparison fetch logic.
3. Stop adding direct `useApiFetcher` calls in feature components unless the call is a documented exception.
4. Extract table contracts from screen/form files when those files are next touched.
5. Add `.resi` files for heavily reused shared components that do not already have one.
6. Split broad global Recoil atom ownership after stabilizing imports.
