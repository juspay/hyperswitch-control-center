# Pattern Check: PR 5 - Add Event Type Filtering to Audit Trail

## Common Patterns (Repo-Wide)

### Architectural Patterns

- [x] **Feature-Based Module Organization** - Changes in `ReconEngineAuditLogDrawer/` directory. Follows.
- [x] **Three-Level Component Hierarchy** - `EventFilterChips` is a Component under the AuditLogDrawer Screen.
- [x] **Container/Presentational Split** - `EventFilterChips` is presentational (receives props). Drawer manages state.
- [x] **Provider Composition (Nested Providers)** - Not applicable.
- [x] **Version Abstraction Pattern** - Not applicable.
- [x] **Entity-Based Architecture** - Not applicable.
- [x] **Interface Module Pattern** - Not applicable.

### State Management Patterns

- [x] **Recoil Atoms for Global State** - Not used. Consistent.
- [x] **React Context for Scoped State** - Not applicable.
- [x] **Context Provider Factory Pattern** - Not applicable.
- [x] **Recoil Atom as Singleton** - Not applicable.
- [x] **Dual State Management (Recoil + Context)** - Not applicable.

### Component Patterns

- [x] **Compound Components** - `EventFilterChips` is a nested sub-module. Follows.
- [x] **Controlled Input Components** - Not applicable.
- [x] **Conditional Rendering via `RenderIf`** - Uses `RenderIf` for empty/non-empty filtered events.
- [x] **Lazy Loading with React.lazy + Suspense** - Not applicable.
- [x] **Error Boundary Pattern** - Not applicable.
- [x] **Suspense + ErrorBoundary Composition** - Not applicable.
- [x] **Page Loader State Machine** - Existing `PageLoaderWrapper` unchanged. Follows.
- [x] **Virtualized Lists** - Not applicable.
- [x] **Card Table Alternate View** - Not applicable.
- [x] **Dynamic Table with Column Configuration** - Not applicable.
- [x] **Floating Action Button (FAB)** - Existing FAB integration unchanged.

### Form Handling Patterns

- [x] **React Final Form Integration** - Not applicable.
- [x] **Field Builder/Factory Functions** - Not applicable.
- [x] **Custom Input Components** - Not applicable.
- [x] **Format/Parse Pipeline** - Not applicable.
- [x] **Schema-Based Validation** - Not applicable.

### API & Data Patterns

- [x] **Custom Hooks for HTTP Methods** - Existing fetch unchanged.
- [x] **Enum-Based API Routing** - Uses existing `#AUDIT_TRAIL` tag.
- [x] **Centralized API Client** - Uses existing centralized client.
- [x] **JSON -> Dict -> Typed Record Mapper Pattern** - Uses existing `getEventTypeFromJson`.
- [x] **Dedicated Mapper Modules** - Not applicable.
- [x] **Graceful Default Extraction** - Existing mappers handle defaults.
- [x] **Error Handling with Toast Feedback** - Existing error handling unchanged.
- [x] **Centralized Logout on 401** - Handled by underlying hooks.

### Routing Patterns

- [x] **Functional URL-Based Routing** - Not applicable.
- [x] **Product-Level Route Namespacing** - Not applicable.
- [x] **Breadcrumb Navigation Tracking** - Not applicable.

### Type System Patterns

- [x] **Discriminated Union Types** - Uses `eventType` (EventSuccess, EventInfo, EventWarning, EventError) for filtering.
- [x] **Polymorphic Variants** - Not applicable.
- [x] **Option Types for Nullability** - Not applicable.
- [x] **Separate Types Modules** - Reuses `ReconEngineAuditLogDrawerTypes`. No new types.
- [x] **Generic Type Parameters** - Not applicable.
- [x] **Unknown Variant Catch-All** - Existing `NoAuditEvent` maps to `EventNone` (excluded from filter chips intentionally).

### Styling Patterns

- [x] **Tailwind CSS Utility Classes** - Full Tailwind: `flex flex-row flex-wrap gap-2 px-6 py-3 border-b`.
- [x] **Dynamic Theme System** - Uses `nd_gray-*` theme colors.
- [x] **Dark Mode via Class Strategy** - Compatible.
- [x] **Custom Breakpoints** - Not applicable.
- [x] **UI Configuration Module** - Uses `Typography.body.sm.medium`.
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

- [x] **React.useMemo for Derived State** - Uses `React.useMemo` for `filteredEvents` computation, memoized on `(auditEvents, activeFilters)`.
- [x] **React.useCallback for Handler Memoization** - `toggleFilter` is a simple function; memoization not needed for this scale.
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

- [x] **Centralized Logic Utilities** - Not applicable.
- [x] **DOM Utility Bindings** - Not applicable.
- [x] **Date/Time Utilities** - Not applicable.
- [x] **Currency Utilities** - Not applicable.
- [x] **URL Utilities** - Not applicable.
- [x] **Case Conversion Utilities** - Not applicable.

### Filter & Search Patterns

- [x] **Local Filters (Client-Side)** - Implements client-side filtering via `activeFilters` state. Follows local filter pattern.
- [x] **Remote Filters (Server-Side)** - Not applicable.
- [x] **Dynamic Filter Configuration** - Not applicable (static chip configuration).
- [x] **Filter Context Provider** - Not applicable (uses local state).

### Async Patterns

- [x] **Async/Await with Try-Catch** - Existing fetch unchanged.
- [x] **Promise-Based Data Fetching** - Existing.
- [x] **Custom Hook for API Progress** - Existing.

### Immutability Patterns

- [x] **Functional Data Transformations** - `toggleFilter` uses `Array.filter` and spread to create new arrays. No mutation.
- [x] **Immutable JSON.t Values** - Not applicable.
- [x] **New Dict/Array on Modification** - `toggleFilter` creates new array via filter/spread.

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

- [x] **Local React.useState (No Global Store)** - Adds `activeFilters` local state. No Recoil. Consistent.
- [x] **Custom Data Fetching Hooks** - Not applicable (existing fetch).
- [x] **Enum-Tagged Fetch Hooks** - Uses existing `#AUDIT_TRAIL`.
- [x] **20+ Dedicated API Operations** - Uses existing operation.

### ReconEngine Domain Types

- [x] **Rich Transaction Status ADT** - Not applicable.
- [x] **Nested Variant Types** - Not applicable.
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

- [x] **Comprehensive Object Mappers** - Uses existing `getEventTypeFromJson`.
- [x] **Status String-to-Variant Converters** - Uses existing converters.
- [x] **Grouped Status Filter Mapping** - Not applicable.
- [x] **Merged Filter Logic** - Not applicable.

### ReconEngine UI Patterns

- [x] **Tab-Per-Account Navigation** - Not applicable.
- [x] **Tab-Per-Rule Navigation** - Not applicable.
- [x] **Accordion-Per-Account Data View** - Not applicable.
- [x] **Nested Accordion Pattern** - Not applicable.
- [x] **Drawer-Based Detail Views** - Enhances existing audit log drawer. Follows pattern.
- [x] **Activity Floating Action Button** - Existing FAB integration unchanged. Follows pattern.
- [x] **Audit Log Drawer** - THIS IS the audit log drawer enhancement. Core pattern.
- [x] **File Timeline Component** - Not applicable.
- [x] **Stacked Bar Graphs for Overview** - Not applicable.
- [x] **Flow Diagram Visualization** - Not applicable.
- [x] **Graph/Table View Toggle** - Not applicable.
- [x] **Column Graphs for Rule Details** - Not applicable.
- [x] **Hierarchical Transaction Table** - Not applicable.
- [x] **Exception Resolution Drawer** - Not applicable.

### ReconEngine Filter Patterns

- [x] **Account Options Extraction from Data** - Not applicable.
- [x] **Query String Builder from Filter JSON** - Not applicable.
- [x] **Grouped Status Filter Options** - Not applicable.
- [x] **Staging Entry Status Options** - Not applicable.
- [x] **FilterContext Key Isolation** - Not applicable (local state filtering).

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

- [x] **Product-Level Feature Toggle** - Inside ReconEngine V1. Follows.
- [x] **Parallel Product Registration** - Not applicable.
- [x] **Configuration-Driven V2 vs Transaction-Driven V1** - V1 component.
- [x] **Onboarding Flow (V2-Specific)** - Not applicable.

### ReconEngine Helper Organization

- [x] **Co-located Helper Files** - No new helper. Uses existing utils.
- [x] **Co-located Utility Files** - Uses existing `ReconEngineAuditLogDrawerUtils`.
- [x] **Co-located Entity Files** - Not applicable.
- [x] **Co-located Component Directories** - In `ReconEngineAuditLogDrawer/`. Follows.

### ReconEngine Access Control

- [x] **Uniform Access Level** - No new restrictions.
- [x] **API-Layer Authorization** - Not applicable.
