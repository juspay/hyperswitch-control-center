# Pattern Check: PR 1 - Add Reconciliation Status Summary Cards to Overview

## Common Patterns (Repo-Wide)

### Architectural Patterns

- [x] **Feature-Based Module Organization** - New component placed in `ReconEngine/ReconEngineScreens/ReconEngineOverview/ReconEngineOverviewSummary/ReconEngineOverviewSummaryComponents/` following the existing feature-based organization.
- [x] **Three-Level Component Hierarchy** - Component is at the Screen-level (ReconEngineOverviewSummary) → Component-level (ReconEngineOverviewSummaryStatusCards), fitting the three-level hierarchy.
- [x] **Container/Presentational Split** - `StatusCard` is a pure presentational sub-module; the parent `make` handles data fetching and state. Follows Container/Presentational split.
- [x] **Provider Composition (Nested Providers)** - Not directly applicable to this PR (no new providers added). Existing provider chain is respected.
- [x] **Version Abstraction Pattern** - Uses `V1(HYPERSWITCH_RECON)` for API URL construction, following the version abstraction pattern.
- [x] **Entity-Based Architecture** - Not directly applicable (no table entity introduced). This is a card-based visualization, not a table.
- [x] **Interface Module Pattern** - Not directly applicable (no new interfaces). Uses existing API interfaces.

### State Management Patterns

- [x] **Recoil Atoms for Global State** - Not used; ReconEngine follows local state pattern (see ReconEngine-specific section). Consistent with existing code.
- [x] **React Context for Scoped State** - Uses `FilterContext.filterContext` for accessing filter state, following the context pattern.
- [x] **Context Provider Factory Pattern** - Not directly applicable (no new context created). Consumes existing FilterContext.
- [x] **Recoil Atom as Singleton** - Not applicable (ReconEngine avoids Recoil). Consistent.
- [x] **Dual State Management (Recoil + Context)** - Not applicable. ReconEngine uses local state + FilterContext only.

### Component Patterns

- [x] **Compound Components** - `StatusCard` is a nested sub-module within the main component, following compound component pattern.
- [x] **Controlled Input Components** - Not applicable (no form inputs in this PR).
- [x] **Conditional Rendering via `RenderIf`** - Not needed in this component (all cards always render). The parent `ReconEngineOverviewSummary` already handles `RenderIf` for the rules check.
- [x] **Lazy Loading with React.lazy + Suspense** - Not applicable (component is small, no code splitting needed).
- [x] **Error Boundary Pattern** - Not applicable (parent already wraps with error handling).
- [x] **Suspense + ErrorBoundary Composition** - Not applicable at this level.
- [x] **Page Loader State Machine** - Uses `PageLoaderWrapper.Loading | Success | Custom` state machine pattern, matching existing code exactly.
- [x] **Virtualized Lists** - Not applicable (only 4 cards, no list virtualization needed).
- [x] **Card Table Alternate View** - Not applicable (this is a card-only view).
- [x] **Dynamic Table with Column Configuration** - Not applicable (no table in this component).
- [x] **Floating Action Button (FAB)** - Not applicable (no FAB in this component).

### Form Handling Patterns

- [x] **React Final Form Integration** - Not applicable (no forms in this PR).
- [x] **Field Builder/Factory Functions** - Not applicable.
- [x] **Custom Input Components** - Not applicable.
- [x] **Format/Parse Pipeline** - Not applicable.
- [x] **Schema-Based Validation** - Not applicable.

### API & Data Patterns

- [x] **Custom Hooks for HTTP Methods** - Uses `ReconEngineHooks.useGetTransactions()` which internally uses `useGetMethod()`. Follows the custom hook pattern.
- [x] **Enum-Based API Routing** - Uses `V1(HYPERSWITCH_RECON)` with `#TRANSACTIONS_LIST` tag for URL construction. Matches pattern.
- [x] **Centralized API Client** - Uses the centralized API client through the hooks layer. Consistent.
- [x] **JSON → Dict → Typed Record Mapper Pattern** - Leverages existing `transactionItemToObjMapper` via `getArrayDataFromJson`. Follows pattern.
- [x] **Dedicated Mapper Modules** - Uses existing mappers from `ReconEngineUtils.res`. No new mappers needed.
- [x] **Graceful Default Extraction** - All existing mappers use `getString(dict, key, default)` pattern. Component relies on these.
- [x] **Error Handling with Toast Feedback** - Error caught in try-catch, sets screen state to `Custom` (showing "No data" UI). Matches existing pattern in `RuleWiseStackedBarGraph`.
- [x] **Centralized Logout on 401** - Handled by the underlying `useGetMethod()` hook. Consistent.

### Routing Patterns

- [x] **Functional URL-Based Routing** - Not applicable (no new routes).
- [x] **Product-Level Route Namespacing** - Not applicable (no new routes).
- [x] **Breadcrumb Navigation Tracking** - Not applicable.

### Type System Patterns

- [x] **Discriminated Union Types** - Uses existing `domainTransactionStatus` discriminated union for transaction categorization.
- [x] **Polymorphic Variants** - Uses `#TRANSACTIONS_LIST` polymorphic variant for API routing.
- [x] **Option Types for Nullability** - Not directly used in new code, but existing types use `option<>` throughout.
- [x] **Separate Types Modules** - No new types introduced; reuses `ReconEngineOverviewSummaryTypes` and `ReconEngineTypes`.
- [x] **Generic Type Parameters** - Not applicable (no new generic types).
- [x] **Unknown Variant Catch-All** - Not applicable (no new enums). Existing mappers handle unknown variants.

### Styling Patterns

- [x] **Tailwind CSS Utility Classes** - All styling uses Tailwind classes: `flex flex-col gap-2 border border-nd_gray-150 rounded-xl p-4 min-w-[180px]`.
- [x] **Dynamic Theme System** - Not directly applicable (no theme vars). Uses `nd_gray-*` and `nd_green-*` which are theme-aware.
- [x] **Dark Mode via Class Strategy** - Tailwind classes used are compatible with dark mode strategy.
- [x] **Custom Breakpoints** - Uses `lg:grid-cols-4` responsive breakpoint, following the custom breakpoint system.
- [x] **UI Configuration Module** - Uses `Typography.heading.md.semibold` and `Typography.body.sm.medium` from UIConfig.
- [x] **Lottie Animations** - Not applicable (uses `Shimmer` for loading, consistent with existing code).

### Permission & Authorization Patterns

- [x] **ACL-Wrapped Components** - Not applicable (no permission-gated actions in summary cards).
- [x] **Binary Authorization Type** - Not applicable.
- [x] **Group ACL Hook** - Not applicable.
- [x] **Recoil-Based ACL Cache** - Not applicable.
- [x] **Role-Based Sidebar Filtering** - Not applicable.

### Modal & Dialog Patterns

- [x] **Recoil-Managed Modal Stack** - Not applicable (no modals).
- [x] **Click-Outside Dismiss** - Not applicable.
- [x] **Modal Nesting Support** - Not applicable.
- [x] **Confirmation Dialog Pattern** - Not applicable.

### Notification Patterns

- [x] **Typed Toast System** - Not applicable (no toasts in this component).
- [x] **Auto-Close with Duration Control** - Not applicable.
- [x] **Toast Factory Function** - Not applicable.
- [x] **Hook-Based Show/Hide** - Not applicable.

### Navigation Patterns

- [x] **Sidebar Context Provider** - Not applicable (no sidebar changes).
- [x] **Organization-Specific Sidebar** - Not applicable.
- [x] **Product Sidebar Switch** - Not applicable.

### Performance Patterns

- [x] **React.useMemo for Derived State** - Derived values (reconciledPercentage, totalTransactions) are computed directly in render since they're cheap arithmetic. Memoization not needed for simple int arithmetic.
- [x] **React.useCallback for Handler Memoization** - `fetchAllTransactions` is defined inline as async, matching existing pattern in `RuleWiseStackedBarGraph`.
- [x] **Code Splitting via Multiple Entry Points** - Not applicable.
- [x] **Lazy Monaco Editor** - Not applicable.

### Feature Flag Patterns

- [x] **Centralized Feature Flag Record** - Not applicable (no new feature flags). Parent feature flag (`dev_recon_engine_v1`) gates the entire ReconEngine.
- [x] **Recoil Feature Flag Atom** - Not applicable.
- [x] **Merchant-Specific Feature Configs** - Not applicable.
- [x] **Conditional Rendering via Feature Flags** - Not applicable.

### Configuration Patterns

- [x] **Window-Injected Configuration** - Not applicable.
- [x] **Theme Configuration from Server** - Not applicable.
- [x] **Entity Default Configuration** - Not applicable.

### Utility Patterns

- [x] **Centralized Logic Utilities** - Uses `LogicUtils.isNonEmptyString` and `LogicUtils.isEmptyDict`. Follows pattern.
- [x] **DOM Utility Bindings** - Not applicable.
- [x] **Date/Time Utilities** - Not applicable.
- [x] **Currency Utilities** - Not applicable (shows counts, not currency values).
- [x] **URL Utilities** - Not applicable.
- [x] **Case Conversion Utilities** - Not applicable.

### Filter & Search Patterns

- [x] **Local Filters (Client-Side)** - Not applicable.
- [x] **Remote Filters (Server-Side)** - Uses `ReconEngineFilterUtils.buildQueryStringFromFilters` for server-side filtering. Follows pattern.
- [x] **Dynamic Filter Configuration** - Not applicable (consumes existing filter context).
- [x] **Filter Context Provider** - Consumes `FilterContext.filterContext` for filter values. Follows pattern.

### Async Patterns

- [x] **Async/Await with Try-Catch** - Uses `async/try/catch` pattern matching existing code exactly.
- [x] **Promise-Based Data Fetching** - Uses `await getTransactions()` promise-based fetching.
- [x] **Custom Hook for API Progress** - Uses `PageLoaderWrapper` screen state for progress tracking.

### Immutability Patterns

- [x] **Functional Data Transformations** - `calculateTransactionCounts` returns new tuple; no mutation.
- [x] **Immutable JSON.t Values** - No JSON mutation.
- [x] **New Dict/Array on Modification** - No dict/array mutation. State updates use `_ => newValue` pattern.

### Analytics Patterns

- [x] **Mixpanel Integration Hook** - Not applicable (no new events). Parent page already tracks events.
- [x] **Chart Context Provider** - Not applicable.
- [x] **Custom Chart Components** - Not applicable (uses text cards, not charts).

---

## ReconEngine-Specific Patterns

### ReconEngine Architecture

- [x] **Dedicated App Router** - Not applicable (no routing changes). Component lives within existing route.
- [x] **Feature Container Layer** - Not applicable (no new container). Integrated into existing `ReconEngineOverviewSummary`.
- [x] **Dedicated Sidebar Configuration** - Not applicable.
- [x] **Separate ReconEngine Entry Point** - Not applicable.

### ReconEngine State & Data Flow

- [x] **Local React.useState (No Global Store)** - Uses `React.useState` for `screenState` and `transactionCounts`. No Recoil. Matches pattern.
- [x] **Custom Data Fetching Hooks** - Uses `ReconEngineHooks.useGetTransactions()`. Follows pattern.
- [x] **Enum-Tagged Fetch Hooks** - Hook internally uses `#TRANSACTIONS_LIST` tag. Follows pattern.
- [x] **20+ Dedicated API Operations** - Uses existing `#TRANSACTIONS_LIST` operation. No new operations needed.

### ReconEngine Domain Types

- [x] **Rich Transaction Status ADT** - Uses `domainTransactionStatus` variants (Posted, OverAmount, UnderAmount, etc.) for status filtering.
- [x] **Nested Variant Types** - Uses `Posted(Auto)`, `Posted(Manual)`, `OverAmount(Mismatch)`, etc. Follows nested variant pattern.
- [x] **Entry Type Modeling** - Not directly used (works at transaction level).
- [x] **Processing Entry Lifecycle** - Not applicable (works with transactions, not processing entries).
- [x] **Ingestion Pipeline Status Model** - Not applicable.
- [x] **Transformation Pipeline Status Model** - Not applicable.
- [x] **Balance/Account Model** - Not applicable (uses transaction counts, not balance).
- [x] **Rule-Based Reconciliation Model** - Uses `rulePayload` type. Follows pattern.
- [x] **Linked Transaction Model** - Not applicable.
- [x] **Metadata Schema Model** - Not applicable.
- [x] **Discarded State Pattern** - Not applicable.

### ReconEngine Data Mappers

- [x] **Comprehensive Object Mappers** - Uses existing `transactionItemToObjMapper` via `getArrayDataFromJson`. Follows pattern.
- [x] **Status String-to-Variant Converters** - Not directly called (mappers handle this internally).
- [x] **Grouped Status Filter Mapping** - Uses `getTransactionStatusValueFromStatusList()` to build status filter. Follows pattern.
- [x] **Merged Filter Logic** - Not applicable (fetches all statuses).

### ReconEngine UI Patterns

- [x] **Tab-Per-Account Navigation** - Not applicable (this is a summary card, not tabs).
- [x] **Tab-Per-Rule Navigation** - Not applicable.
- [x] **Accordion-Per-Account Data View** - Not applicable.
- [x] **Nested Accordion Pattern** - Not applicable.
- [x] **Drawer-Based Detail Views** - Not applicable.
- [x] **Activity Floating Action Button** - Not applicable.
- [x] **Audit Log Drawer** - Not applicable.
- [x] **File Timeline Component** - Not applicable.
- [x] **Stacked Bar Graphs for Overview** - Integrates alongside existing `ReconEngineOverviewSummaryStackedBarGraphs`. Complementary.
- [x] **Flow Diagram Visualization** - Not applicable.
- [x] **Graph/Table View Toggle** - Not applicable.
- [x] **Column Graphs for Rule Details** - Not applicable.
- [x] **Hierarchical Transaction Table** - Not applicable.
- [x] **Exception Resolution Drawer** - Not applicable.

### ReconEngine Filter Patterns

- [x] **Account Options Extraction from Data** - Not applicable.
- [x] **Query String Builder from Filter JSON** - Uses `buildQueryStringFromFilters()`. Follows pattern exactly.
- [x] **Grouped Status Filter Options** - Uses `getTransactionStatusValueFromStatusList()`. Follows pattern.
- [x] **Staging Entry Status Options** - Not applicable.
- [x] **FilterContext Key Isolation** - Parent `ReconEngineOverviewSummary` already wraps in `FilterContext`. Component inherits filter context.

### ReconEngine Operations

- [x] **Void Transaction Action** - Not applicable.
- [x] **Force Reconciliation Action** - Not applicable.
- [x] **Manual Reconciliation Action** - Not applicable.
- [x] **Transaction Resolution Action** - Not applicable.
- [x] **Processing Entry Resolution** - Not applicable.
- [x] **Void Processing Entry** - Not applicable.
- [x] **Linkable Staging Entry Discovery** - Not applicable.
- [x] **File Download Action** - Not applicable.

### ReconEngine Data Pipeline

- [x] **Ingestion -> Transformation -> Processing Pipeline** - Not applicable.
- [x] **Transformation Configuration with Metadata Schema** - Not applicable.
- [x] **File Upload Ingestion** - Not applicable.
- [x] **Ingestion Configuration** - Not applicable.

### ReconEngine vs Recon V2 (Coexistence Pattern)

- [x] **Product-Level Feature Toggle** - Component lives inside ReconEngine V1, gated by `devReconEngineV1` flag. Follows pattern.
- [x] **Parallel Product Registration** - Not applicable.
- [x] **Configuration-Driven V2 vs Transaction-Driven V1** - This is a V1 transaction-driven component. Follows pattern.
- [x] **Onboarding Flow (V2-Specific)** - Not applicable.

### ReconEngine Helper Organization

- [x] **Co-located Helper Files** - No new helper file needed; uses existing helpers from `ReconEngineOverviewSummaryHelper` and `ReconEngineOverviewUtils`.
- [x] **Co-located Utility Files** - No new utility file needed; reuses existing utils.
- [x] **Co-located Entity Files** - Not applicable (no table entity).
- [x] **Co-located Component Directories** - Component placed in `ReconEngineOverviewSummaryComponents/` directory. Follows pattern.

### ReconEngine Access Control

- [x] **Uniform Access Level** - No new sidebar links. Component inherits existing access. Follows pattern.
- [x] **API-Layer Authorization** - Authorization handled by backend API. Follows pattern.
