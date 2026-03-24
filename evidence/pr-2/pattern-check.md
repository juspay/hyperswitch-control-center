# Pattern Check: PR 2 - Add Exception Summary Count Badges

## Common Patterns (Repo-Wide)

### Architectural Patterns

- [x] **Feature-Based Module Organization** - Component placed in `ReconEngineExceptions/ReconEngineExceptionTransaction/ReconEngineExceptionTransactionComponents/`. Follows feature-based co-location.
- [x] **Three-Level Component Hierarchy** - Lives at Component level under the ExceptionTransaction Screen. Follows hierarchy.
- [x] **Container/Presentational Split** - `ExceptionCountBadge` is purely presentational. `make` receives data as props (no fetching). Parent handles data. Follows split.
- [x] **Provider Composition (Nested Providers)** - Not applicable (no new providers).
- [x] **Version Abstraction Pattern** - Not applicable (no API calls in this component).
- [x] **Entity-Based Architecture** - Not applicable (card badges, not table entity).
- [x] **Interface Module Pattern** - Not applicable.

### State Management Patterns

- [x] **Recoil Atoms for Global State** - Not used. ReconEngine avoids Recoil. Consistent.
- [x] **React Context for Scoped State** - Not applicable (receives data via props).
- [x] **Context Provider Factory Pattern** - Not applicable.
- [x] **Recoil Atom as Singleton** - Not applicable.
- [x] **Dual State Management (Recoil + Context)** - Not applicable.

### Component Patterns

- [x] **Compound Components** - `ExceptionCountBadge` is a nested sub-module. Follows compound component pattern.
- [x] **Controlled Input Components** - Not applicable.
- [x] **Conditional Rendering via `RenderIf`** - Uses `<RenderIf condition={totalExceptions > 0}>` to conditionally show badges. Follows pattern.
- [x] **Lazy Loading with React.lazy + Suspense** - Not applicable.
- [x] **Error Boundary Pattern** - Not applicable (parent handles).
- [x] **Suspense + ErrorBoundary Composition** - Not applicable.
- [x] **Page Loader State Machine** - Not applicable (presentational component, parent manages loading).
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

- [x] **Custom Hooks for HTTP Methods** - Not applicable (no API calls; receives data via props).
- [x] **Enum-Based API Routing** - Not applicable.
- [x] **Centralized API Client** - Not applicable.
- [x] **JSON -> Dict -> Typed Record Mapper Pattern** - Not applicable (works with already-typed data).
- [x] **Dedicated Mapper Modules** - Not applicable.
- [x] **Graceful Default Extraction** - Not applicable.
- [x] **Error Handling with Toast Feedback** - Not applicable.
- [x] **Centralized Logout on 401** - Not applicable.

### Routing Patterns

- [x] **Functional URL-Based Routing** - Not applicable.
- [x] **Product-Level Route Namespacing** - Not applicable.
- [x] **Breadcrumb Navigation Tracking** - Not applicable.

### Type System Patterns

- [x] **Discriminated Union Types** - Uses `domainTransactionStatus` variants for categorization in `categorizeExceptions`.
- [x] **Polymorphic Variants** - Not directly used in new code.
- [x] **Option Types for Nullability** - Not applicable.
- [x] **Separate Types Modules** - No new types needed. Uses `ReconEngineTypes.transactionType`.
- [x] **Generic Type Parameters** - Not applicable.
- [x] **Unknown Variant Catch-All** - `categorizeExceptions` has `_ =>` catch-all for unknown statuses.

### Styling Patterns

- [x] **Tailwind CSS Utility Classes** - All styling via Tailwind: `flex flex-row items-center gap-2 border border-nd_gray-150 rounded-lg px-3 py-2 bg-white`.
- [x] **Dynamic Theme System** - Uses `nd_gray-*`, `nd_yellow-*`, `nd_red-*` theme-aware colors.
- [x] **Dark Mode via Class Strategy** - Compatible with dark mode.
- [x] **Custom Breakpoints** - Not applicable (badges flex-wrap naturally).
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

- [x] **React.useMemo for Derived State** - Uses `React.useMemo` for `categorizeExceptions` computation, memoized on `exceptionData`. Follows pattern.
- [x] **React.useCallback for Handler Memoization** - Not applicable (no handlers).
- [x] **Code Splitting via Multiple Entry Points** - Not applicable.
- [x] **Lazy Monaco Editor** - Not applicable.

### Feature Flag Patterns

- [x] **Centralized Feature Flag Record** - Not applicable. Parent gated by `devReconEngineV1`.
- [x] **Recoil Feature Flag Atom** - Not applicable.
- [x] **Merchant-Specific Feature Configs** - Not applicable.
- [x] **Conditional Rendering via Feature Flags** - Not applicable.

### Configuration Patterns

- [x] **Window-Injected Configuration** - Not applicable.
- [x] **Theme Configuration from Server** - Not applicable.
- [x] **Entity Default Configuration** - Not applicable.

### Utility Patterns

- [x] **Centralized Logic Utilities** - Not directly used (pure function operates on typed data).
- [x] **DOM Utility Bindings** - Not applicable.
- [x] **Date/Time Utilities** - Not applicable.
- [x] **Currency Utilities** - Not applicable.
- [x] **URL Utilities** - Not applicable.
- [x] **Case Conversion Utilities** - Not applicable.

### Filter & Search Patterns

- [x] **Local Filters (Client-Side)** - Not applicable.
- [x] **Remote Filters (Server-Side)** - Not applicable.
- [x] **Dynamic Filter Configuration** - Not applicable.
- [x] **Filter Context Provider** - Not applicable.

### Async Patterns

- [x] **Async/Await with Try-Catch** - Not applicable (no async in this component).
- [x] **Promise-Based Data Fetching** - Not applicable.
- [x] **Custom Hook for API Progress** - Not applicable.

### Immutability Patterns

- [x] **Functional Data Transformations** - `categorizeExceptions` is a pure reduce returning new tuple. No mutation.
- [x] **Immutable JSON.t Values** - Not applicable.
- [x] **New Dict/Array on Modification** - No dict/array mutation.

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

- [x] **Local React.useState (No Global Store)** - No state in this component. Receives data as props. Consistent with ReconEngine pattern.
- [x] **Custom Data Fetching Hooks** - Not applicable (presentational component).
- [x] **Enum-Tagged Fetch Hooks** - Not applicable.
- [x] **20+ Dedicated API Operations** - Not applicable.

### ReconEngine Domain Types

- [x] **Rich Transaction Status ADT** - Uses `domainTransactionStatus` variants: `OverAmount(Mismatch)`, `UnderAmount(Mismatch)`, `Missing`, `DataMismatch`, `Expected`, `PartiallyReconciled`, `OverAmount(Expected)`, `UnderAmount(Expected)`.
- [x] **Nested Variant Types** - Uses `OverAmount(Mismatch)`, `OverAmount(Expected)` etc.
- [x] **Entry Type Modeling** - Not applicable.
- [x] **Processing Entry Lifecycle** - Not applicable.
- [x] **Ingestion Pipeline Status Model** - Not applicable.
- [x] **Transformation Pipeline Status Model** - Not applicable.
- [x] **Balance/Account Model** - Not applicable.
- [x] **Rule-Based Reconciliation Model** - Not applicable.
- [x] **Linked Transaction Model** - Not applicable.
- [x] **Metadata Schema Model** - Not applicable.
- [x] **Discarded State Pattern** - Not applicable.

### ReconEngine Data Mappers

- [x] **Comprehensive Object Mappers** - Not applicable.
- [x] **Status String-to-Variant Converters** - Not applicable (works with already-converted types).
- [x] **Grouped Status Filter Mapping** - Not applicable.
- [x] **Merged Filter Logic** - Not applicable.

### ReconEngine UI Patterns

- [x] **Tab-Per-Account Navigation** - Not applicable.
- [x] **Tab-Per-Rule Navigation** - Integrates within the existing tab-per-rule view. Follows pattern.
- [x] **Accordion-Per-Account Data View** - Not applicable.
- [x] **Nested Accordion Pattern** - Not applicable.
- [x] **Drawer-Based Detail Views** - Not applicable.
- [x] **Activity Floating Action Button** - Not applicable.
- [x] **Audit Log Drawer** - Not applicable.
- [x] **File Timeline Component** - Not applicable.
- [x] **Stacked Bar Graphs for Overview** - Not applicable.
- [x] **Flow Diagram Visualization** - Not applicable.
- [x] **Graph/Table View Toggle** - Not applicable.
- [x] **Column Graphs for Rule Details** - Not applicable.
- [x] **Hierarchical Transaction Table** - Integrates alongside the hierarchical transaction table. Complementary.
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

- [x] **Product-Level Feature Toggle** - Inside ReconEngine V1, gated by parent. Follows pattern.
- [x] **Parallel Product Registration** - Not applicable.
- [x] **Configuration-Driven V2 vs Transaction-Driven V1** - V1 transaction-driven component. Follows pattern.
- [x] **Onboarding Flow (V2-Specific)** - Not applicable.

### ReconEngine Helper Organization

- [x] **Co-located Helper Files** - No new helper needed.
- [x] **Co-located Utility Files** - `categorizeExceptions` utility function lives in the component file since it's only used there. If reused, would move to Utils file.
- [x] **Co-located Entity Files** - Not applicable.
- [x] **Co-located Component Directories** - Placed in `ReconEngineExceptionTransactionComponents/`. Follows pattern.

### ReconEngine Access Control

- [x] **Uniform Access Level** - No new access restrictions. Follows pattern.
- [x] **API-Layer Authorization** - Not applicable.
