# Architecture — Hyperswitch Control Center

> Request lifecycle, key modules, and data flow. Keep under 300 lines.

---

## Request Lifecycle

```
User clicks UI
  → React component calls useGetMethod() or useUpdateMethod() from APIUtils
  → APIUtils.fetchApi() adds auth headers (session token)
  → HTTP request sent to Hyperswitch backend
  → HTTP response received
  → responseHandler() processes response (error handling, toast, type conversion)
  → Typed data stored in Recoil atom (global) or local React state
  → Component re-renders with new data
```

### Key Files in This Lifecycle

| File | Role |
|------|------|
| `src/APIUtils/APIUtils.res` | `fetchApi`, `useGetMethod`, `useUpdateMethod`, `responseHandler` |
| `src/APIUtils/APIUtilsTypes.res` | `entityTypeWithVersion`, `getUrlTypes`, `entityName` variant, `getURL` function signature |
| `src/Recoils/` | Global Recoil atoms (auth state, user info, toast, feature flags) |
| `src/entryPoints/` | App routing, session bootstrap, auth guards |
| `src/screens/` | Page-level modules — each screen orchestrates data fetching and rendering |

---

## API Call Pattern (Canonical)

Defined in `.clinerules`; reproduced here for quick reference.

### 1. Add route variant (`src/APIUtils/APIUtilsTypes.res`)
```rescript
type entityName =
  | ...existing variants...
  | MyNewEntity
```

### 2. Add URL mapping (`src/APIUtils/APIUtils.res` — `getURL` function)
```rescript
| V1(MyNewEntity) => `/api/my-new-entity`
```

### 3. Call in component
```rescript
let getMyData = useGetMethod()
let (data, setData) = React.useState(_ => None)

React.useEffect(() => {
  let fetchData = async () => {
    let url = getURL(~entityName=V1(MyNewEntity), ~methodType=Get)
    let res = await getMyData(url)
    setData(_ => Some(res))
  }
  fetchData()->ignore
  None
}, [])
```

Wrap the component render in `PageLoaderWrapper` with `screenState` set to `Loading`
before the fetch and `Success` after. Set to `Error` if the call throws.

---

## Module Organization

```
src/
├── APIUtils/           # Central API communication layer
│   ├── APIUtils.res    # fetchApi, useGetMethod, useUpdateMethod, responseHandler
│   └── APIUtilsTypes.res  # entityName variants, getUrlTypes, URL generation
├── Recoils/            # Global Recoil atoms  ⚠️ UNSAFE — changes affect all screens
├── entryPoints/        # App routing and auth  ⚠️ UNSAFE — auth bootstrapping
├── screens/            # Page modules (one directory per feature/route)
├── components/         # Shared UI components
│   └── (Button, Table, Modal, Form, PageLoaderWrapper, etc.)
├── hooks/              # Custom React hooks
├── context/            # React context providers (auth, permissions, theme)
├── entities/           # Domain entity types and mappers
├── utils/              # Pure utility functions (LogicUtils, etc.)
├── IntelligentRouting/ # Smart routing configuration feature
├── Hypersense/         # AI analytics feature
├── Recon/              # Reconciliation feature
├── ReconEngine/        # Reconciliation engine
├── Vault/              # Vault/tokenization UI
├── OrchestrationV2/    # Payment orchestration v2
└── Themes/             # Theme context and configuration
```

---

## State Management

| State type | Where | Pattern |
|-----------|-------|---------|
| Global auth / user | `src/Recoils/` | Recoil atoms |
| Global feature flags | `src/Recoils/` | Recoil atom, read from `window.__env__` |
| Toast notifications | `src/Recoils/` | Recoil atom, `ToastState` |
| Local component state | component `.res` | `React.useState` |
| Derived state | selectors | Recoil selectors |

---

## Sequence Diagram — API Request

```
Component → APIUtils.useGetMethod() → APIUtils.fetchApi()
         ← (auth headers added)
fetchApi() → Hyperswitch Backend (HTTP)
           ← HTTP Response
fetchApi() → responseHandler()
           ← typed data / error
Component ← updates Recoil atom or local state
Component → re-renders
```

---

## Sequence Diagram — Page Render

```
User navigates → entryPoints routing
              → Screen module renders
              → Container fetches data via APIUtils
              → PageLoaderWrapper shows Loading state
              → data arrives → Success state
              → Screen composes from components
              → User sees UI
```

---

*See `systemPatterns.md` for the full architecture with Mermaid diagrams.*
*See `.clinerules` for the step-by-step API call recipe.*
