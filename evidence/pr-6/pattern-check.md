# Pattern Check: PR 6 - Add Status Badges for Ingestion Configs

## Common Patterns (Repo-Wide)

### Architectural Patterns

- [x] **Feature-Based Module Organization** - Component in `ReconEngineDataSources/ReconEngineDataSourcesComponents/`. Follows.
- [x] **Three-Level Component Hierarchy** - Component level under Data Sources Screen.
- [x] **Container/Presentational Split** - Purely presentational; receives `status` prop.
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

- [x] **Compound Components** - Single module with helper function. Simple.
- [x] **Controlled Input Components** - Not applicable.
- [x] **Conditional Rendering via `RenderIf`** - Uses `RenderIf` for animated ping and optional label.
- [x] **Lazy Loading** - Not applicable.
- [x] **Error Boundary Pattern** - Not applicable.
- [x] **Suspense + ErrorBoundary** - Not applicable.
- [x] **Page Loader State Machine** - Not applicable.
- [x] **Virtualized Lists** - Not applicable.
- [x] **Card Table Alternate View** - Not applicable.
- [x] **Dynamic Table** - Not applicable.
- [x] **Floating Action Button** - Not applicable.

### Form Handling Patterns

- [x] **React Final Form** - Not applicable.
- [x] **Field Builder** - Not applicable.
- [x] **Custom Input Components** - Not applicable.
- [x] **Format/Parse Pipeline** - Not applicable.
- [x] **Schema-Based Validation** - Not applicable.

### API & Data Patterns

- [x] **Custom Hooks for HTTP Methods** - Not applicable (presentational).
- [x] **Enum-Based API Routing** - Not applicable.
- [x] **Centralized API Client** - Not applicable.
- [x] **JSON -> Dict -> Typed Record Mapper** - Not applicable.
- [x] **Dedicated Mapper Modules** - Not applicable.
- [x] **Graceful Default Extraction** - Not applicable.
- [x] **Error Handling with Toast** - Not applicable.
- [x] **Centralized Logout on 401** - Not applicable.

### Routing Patterns

- [x] **Functional URL-Based Routing** - Not applicable.
- [x] **Product-Level Route Namespacing** - Not applicable.
- [x] **Breadcrumb Navigation** - Not applicable.

### Type System Patterns

- [x] **Discriminated Union Types** - Uses `ingestionTransformationStatusType` (Processed, Processing, Pending, Failed, Discarded).
- [x] **Polymorphic Variants** - Not applicable.
- [x] **Option Types** - Not applicable.
- [x] **Separate Types Modules** - Reuses `ReconEngineTypes`.
- [x] **Generic Type Parameters** - Not applicable.
- [x] **Unknown Variant Catch-All** - Handles `UnknownIngestionTransformationStatus`.

### Styling Patterns

- [x] **Tailwind CSS Utility Classes** - Full Tailwind.
- [x] **Dynamic Theme System** - Uses `nd_green-*`, `nd_yellow-*`, `nd_red-*`.
- [x] **Dark Mode** - Compatible.
- [x] **Custom Breakpoints** - Not applicable.
- [x] **UI Configuration Module** - Uses `Typography.body.sm.semibold`.
- [x] **Lottie Animations** - Uses CSS `animate-ping` for processing state, matching existing `EventCard` ping animation pattern.

### Permission & Authorization Patterns

- [x] All N/A for this presentational component.

### Modal & Dialog Patterns

- [x] All N/A.

### Notification Patterns

- [x] All N/A.

### Navigation Patterns

- [x] All N/A.

### Performance Patterns

- [x] **React.useMemo** - Not needed (pure function, no derived state).
- [x] **React.useCallback** - Not applicable.
- [x] **Code Splitting** - Not applicable.
- [x] **Lazy Monaco Editor** - Not applicable.

### Feature Flag Patterns

- [x] All N/A.

### Configuration Patterns

- [x] All N/A.

### Utility Patterns

- [x] All N/A.

### Filter & Search Patterns

- [x] All N/A.

### Async Patterns

- [x] All N/A.

### Immutability Patterns

- [x] **Functional Data Transformations** - `getStatusConfig` is a pure function returning new tuple.
- [x] **Immutable JSON.t Values** - Not applicable.
- [x] **New Dict/Array on Modification** - Not applicable.

### Analytics Patterns

- [x] All N/A.

---

## ReconEngine-Specific Patterns

### ReconEngine Architecture

- [x] All N/A.

### ReconEngine State & Data Flow

- [x] **Local React.useState** - No state. Consistent.
- [x] **Custom Data Fetching Hooks** - Not applicable.
- [x] **Enum-Tagged Fetch Hooks** - Not applicable.
- [x] **20+ Dedicated API Operations** - Not applicable.

### ReconEngine Domain Types

- [x] **Ingestion Pipeline Status Model** - Uses `ingestionTransformationStatusType` variants. Core pattern.
- [x] All other domain types N/A.

### ReconEngine Data Mappers

- [x] All N/A.

### ReconEngine UI Patterns

- [x] **Accordion-Per-Account Data View** - Integrates into existing accordion header. Follows.
- [x] **File Timeline Component** - Complements existing file timeline with status badge. Follows.
- [x] All other UI patterns N/A.

### ReconEngine Filter Patterns

- [x] All N/A.

### ReconEngine Operations

- [x] All N/A.

### ReconEngine Data Pipeline

- [x] **Ingestion -> Transformation -> Processing Pipeline** - Status indicator visualizes pipeline stage. Follows.
- [x] Other pipeline patterns N/A.

### ReconEngine vs Recon V2

- [x] **Product-Level Feature Toggle** - Inside V1. Follows.
- [x] Other coexistence patterns N/A.

### ReconEngine Helper Organization

- [x] **Co-located Component Directories** - In `ReconEngineDataSourcesComponents/`. Follows.
- [x] Other organization patterns N/A.

### ReconEngine Access Control

- [x] **Uniform Access Level** - No new restrictions. Follows.
- [x] **API-Layer Authorization** - Not applicable.
