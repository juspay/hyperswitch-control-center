# Pattern Check: PR 3 - Add Side-by-Side Field Comparison in Transaction Detail

## Common Patterns (Repo-Wide)

### Architectural Patterns

- [x] **Feature-Based Module Organization** - Component in `ReconEngineTransactions/` directory, co-located with transaction features.
- [x] **Three-Level Component Hierarchy** - Component level under the Transactions Screen. Follows hierarchy.
- [x] **Container/Presentational Split** - Purely presentational; receives `entries` as props. No data fetching.
- [x] **Provider Composition (Nested Providers)** - Not applicable.
- [x] **Version Abstraction Pattern** - Not applicable.
- [x] **Entity-Based Architecture** - Not applicable (visual comparison, not table entity).
- [x] **Interface Module Pattern** - Not applicable.

### State Management Patterns

- [x] **Recoil Atoms for Global State** - Not used. Consistent with ReconEngine pattern.
- [x] **React Context for Scoped State** - Not applicable.
- [x] **Context Provider Factory Pattern** - Not applicable.
- [x] **Recoil Atom as Singleton** - Not applicable.
- [x] **Dual State Management (Recoil + Context)** - Not applicable.

### Component Patterns

- [x] **Compound Components** - `ComparisonField` is a nested sub-module. Follows compound pattern.
- [x] **Controlled Input Components** - Not applicable.
- [x] **Conditional Rendering via `RenderIf`** - Uses `<RenderIf condition={sourceEntry->Option.isSome && targetEntry->Option.isSome}>`.
- [x] **Lazy Loading with React.lazy + Suspense** - Not applicable.
- [x] **Error Boundary Pattern** - Not applicable.
- [x] **Suspense + ErrorBoundary Composition** - Not applicable.
- [x] **Page Loader State Machine** - Not applicable (parent handles).
- [x] **Virtualized Lists** - Not applicable.
- [x] **Card Table Alternate View** - Not applicable.
- [x] **Dynamic Table with Column Configuration** - Not applicable.
- [x] **Floating Action Button (FAB)** - Not applicable.

### Form Handling Patterns

- [x] **React Final Form Integration** - Not applicable.
- [x] **Field Builder/Factory Functions** - Not applicable.
- [x] **Custom Input Components** - Not applicable.
- [x] **Format/Parse Pipeline** - Not applicable.
- [x] **Schema-Based Validation** - Not applicable.

### API & Data Patterns

- [x] **Custom Hooks for HTTP Methods** - Not applicable (presentational).
- [x] **Enum-Based API Routing** - Not applicable.
- [x] **Centralized API Client** - Not applicable.
- [x] **JSON -> Dict -> Typed Record Mapper Pattern** - Not applicable (receives typed data).
- [x] **Dedicated Mapper Modules** - Not applicable.
- [x] **Graceful Default Extraction** - Not applicable.
- [x] **Error Handling with Toast Feedback** - Not applicable.
- [x] **Centralized Logout on 401** - Not applicable.

### Routing Patterns

- [x] **Functional URL-Based Routing** - Not applicable.
- [x] **Product-Level Route Namespacing** - Not applicable.
- [x] **Breadcrumb Navigation Tracking** - Not applicable.

### Type System Patterns

- [x] **Discriminated Union Types** - Uses `entryStatus`, `entryDirectionType` variants for string conversion.
- [x] **Polymorphic Variants** - Not applicable.
- [x] **Option Types for Nullability** - Uses `Array.get(0)` returning `option`, then pattern-matched with `Option.isSome` and `switch`.
- [x] **Separate Types Modules** - Reuses `ReconEngineTypes`. No new types.
- [x] **Generic Type Parameters** - Not applicable.
- [x] **Unknown Variant Catch-All** - `getEntryStatusString` and `getEntryDirectionString` handle `UnknownEntryStatus`/`UnknownEntryDirectionType`.

### Styling Patterns

- [x] **Tailwind CSS Utility Classes** - Full Tailwind: `grid grid-cols-3 gap-4 px-4 py-3 bg-nd_gray-50 border-b`.
- [x] **Dynamic Theme System** - Uses `nd_gray-*`, `nd_red-*` theme colors.
- [x] **Dark Mode via Class Strategy** - Compatible.
- [x] **Custom Breakpoints** - Not applicable (grid auto-adjusts).
- [x] **UI Configuration Module** - Uses `Typography.body.sm.medium` and `Typography.body.sm.semibold`.
- [x] **Lottie Animations** - Not applicable.

### Permission & Authorization Patterns

- [x] **ACL-Wrapped Components** - Not applicable.
- [x] **Binary Authorization Type** - Not applicable.
- [x] **Group ACL Hook** - Not applicable.
- [x] **Recoil-Based ACL Cache** - Not applicable.
- [x] **Role-Based Sidebar Filtering** - Not applicable.

### Modal & Dialog Patterns

- [x] **Recoil-Managed Modal Stack** - Not applicable.
- [x] **Click-Outside Dismiss** - Not applicable.
- [x] **Modal Nesting Support** - Not applicable.
- [x] **Confirmation Dialog Pattern** - Not applicable.

### Notification Patterns

- [x] **Typed Toast System** - Not applicable.
- [x] **Auto-Close with Duration Control** - Not applicable.
- [x] **Toast Factory Function** - Not applicable.
- [x] **Hook-Based Show/Hide** - Not applicable.

### Navigation Patterns

- [x] **Sidebar Context Provider** - Not applicable.
- [x] **Organization-Specific Sidebar** - Not applicable.
- [x] **Product Sidebar Switch** - Not applicable.

### Performance Patterns

- [x] **React.useMemo for Derived State** - Not needed; `Array.filter` on small entry arrays (typically 2-4) is negligible.
- [x] **React.useCallback for Handler Memoization** - Not applicable.
- [x] **Code Splitting via Multiple Entry Points** - Not applicable.
- [x] **Lazy Monaco Editor** - Not applicable.

### Feature Flag Patterns

- [x] **Centralized Feature Flag Record** - Not applicable.
- [x] **Recoil Feature Flag Atom** - Not applicable.
- [x] **Merchant-Specific Feature Configs** - Not applicable.
- [x] **Conditional Rendering via Feature Flags** - Not applicable.

### Configuration Patterns

- [x] **Window-Injected Configuration** - Not applicable.
- [x] **Theme Configuration from Server** - Not applicable.
- [x] **Entity Default Configuration** - Not applicable.

### Utility Patterns

- [x] **Centralized Logic Utilities** - Not directly used (self-contained pure functions).
- [x] **DOM Utility Bindings** - Not applicable.
- [x] **Date/Time Utilities** - Not applicable.
- [x] **Currency Utilities** - Not applicable (shows raw amount values).
- [x] **URL Utilities** - Not applicable.
- [x] **Case Conversion Utilities** - Not applicable.

### Filter & Search Patterns

- [x] **Local Filters (Client-Side)** - Not applicable.
- [x] **Remote Filters (Server-Side)** - Not applicable.
- [x] **Dynamic Filter Configuration** - Not applicable.
- [x] **Filter Context Provider** - Not applicable.

### Async Patterns

- [x] **Async/Await with Try-Catch** - Not applicable.
- [x] **Promise-Based Data Fetching** - Not applicable.
- [x] **Custom Hook for API Progress** - Not applicable.

### Immutability Patterns

- [x] **Functional Data Transformations** - `Array.filter` returns new arrays; no mutation.
- [x] **Immutable JSON.t Values** - Not applicable.
- [x] **New Dict/Array on Modification** - Not applicable.

### Analytics Patterns

- [x] **Mixpanel Integration Hook** - Not applicable.
- [x] **Chart Context Provider** - Not applicable.
- [x] **Custom Chart Components** - Not applicable.

---

## ReconEngine-Specific Patterns

### ReconEngine Architecture

- [x] **Dedicated App Router** - Not applicable.
- [x] **Feature Container Layer** - Not applicable.
- [x] **Dedicated Sidebar Configuration** - Not applicable.
- [x] **Separate ReconEngine Entry Point** - Not applicable.

### ReconEngine State & Data Flow

- [x] **Local React.useState (No Global Store)** - No state. Purely presentational. Consistent.
- [x] **Custom Data Fetching Hooks** - Not applicable.
- [x] **Enum-Tagged Fetch Hooks** - Not applicable.
- [x] **20+ Dedicated API Operations** - Not applicable.

### ReconEngine Domain Types

- [x] **Rich Transaction Status ADT** - Not directly used (works at entry level).
- [x] **Nested Variant Types** - Not applicable.
- [x] **Entry Type Modeling** - Uses `entryDirectionType` (Debit/Credit) and `entryStatus`. Follows pattern.
- [x] **Processing Entry Lifecycle** - Not applicable.
- [x] **Ingestion Pipeline Status Model** - Not applicable.
- [x] **Transformation Pipeline Status Model** - Not applicable.
- [x] **Balance/Account Model** - Uses `balanceType` for amount display (`source.amount.value`).
- [x] **Rule-Based Reconciliation Model** - Not applicable.
- [x] **Linked Transaction Model** - Not applicable.
- [x] **Metadata Schema Model** - Not applicable.
- [x] **Discarded State Pattern** - Not applicable.

### ReconEngine Data Mappers

- [x] **Comprehensive Object Mappers** - Not applicable (works with pre-mapped data).
- [x] **Status String-to-Variant Converters** - Provides `getEntryStatusString` and `getEntryDirectionString` (variant-to-string, reverse direction).
- [x] **Grouped Status Filter Mapping** - Not applicable.
- [x] **Merged Filter Logic** - Not applicable.

### ReconEngine UI Patterns

- [x] **Tab-Per-Account Navigation** - Not applicable.
- [x] **Tab-Per-Rule Navigation** - Not applicable.
- [x] **Accordion-Per-Account Data View** - Not applicable.
- [x] **Nested Accordion Pattern** - Not applicable.
- [x] **Drawer-Based Detail Views** - Integrates within the detail drawer view. Complementary.
- [x] **Activity Floating Action Button** - Not applicable.
- [x] **Audit Log Drawer** - Not applicable.
- [x] **File Timeline Component** - Not applicable.
- [x] **Stacked Bar Graphs for Overview** - Not applicable.
- [x] **Flow Diagram Visualization** - Not applicable.
- [x] **Graph/Table View Toggle** - Not applicable.
- [x] **Column Graphs for Rule Details** - Not applicable.
- [x] **Hierarchical Transaction Table** - Adds comparison to existing hierarchical transaction detail.
- [x] **Exception Resolution Drawer** - Not applicable.

### ReconEngine Filter Patterns

- [x] **Account Options Extraction from Data** - Not applicable.
- [x] **Query String Builder from Filter JSON** - Not applicable.
- [x] **Grouped Status Filter Options** - Not applicable.
- [x] **Staging Entry Status Options** - Not applicable.
- [x] **FilterContext Key Isolation** - Not applicable.

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

- [x] **Product-Level Feature Toggle** - Inside ReconEngine V1. Follows pattern.
- [x] **Parallel Product Registration** - Not applicable.
- [x] **Configuration-Driven V2 vs Transaction-Driven V1** - V1 transaction-driven. Follows pattern.
- [x] **Onboarding Flow (V2-Specific)** - Not applicable.

### ReconEngine Helper Organization

- [x] **Co-located Helper Files** - No new helper file (utility functions are component-local).
- [x] **Co-located Utility Files** - `getEntryStatusString`, `getEntryDirectionString` are co-located in the component. If reused, would extract to Utils.
- [x] **Co-located Entity Files** - Not applicable.
- [x] **Co-located Component Directories** - Component in `ReconEngineTransactions/` directory. Follows co-location.

### ReconEngine Access Control

- [x] **Uniform Access Level** - No new access restrictions. Follows pattern.
- [x] **API-Layer Authorization** - Not applicable.
