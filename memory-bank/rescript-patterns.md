# ReScript Patterns — Hyperswitch Control Center

> Copy-pasteable, compiler-validated snippets. Keep under 300 lines.
> Patterns validated against `systemPatterns.md`, `.clinerules`, and `rescript.json`.

---

## 1. New React Component

```rescript
// src/components/MyComponent.res
@react.component
let make = (~title: string, ~onClose: unit => unit) => {
  <div className="flex flex-col gap-4">
    <p> {title->React.string} </p>
    <button onClick={_ => onClose()}> {"Close"->React.string} </button>
  </div>
}
```

With optional props and local state:
```rescript
@react.component
let make = (~title: string, ~count: int=0) => {
  let (isOpen, setIsOpen) = React.useState(_ => false)

  <div className="flex items-center gap-2">
    <span> {title->React.string} </span>
    <span> {count->React.int} </span>
    <button onClick={_ => setIsOpen(v => !v)}>
      {(isOpen ? "Hide" : "Show")->React.string}
    </button>
  </div>
}
```

---

## 2. New API GET Call (per `.clinerules` pattern)

**Step 1** — Add variant in `src/APIUtils/APIUtilsTypes.res`:
```rescript
type entityName =
  | ...
  | MyNewEntity
```

**Step 2** — Add URL mapping in `src/APIUtils/APIUtils.res` (`getURL` function):
```rescript
| V1(MyNewEntity) => `/api/my-new-entity`
```

**Step 3** — Call in component:
```rescript
// In MyScreen.res
let getMyData = APIUtils.useGetMethod()
let (data, setData) = React.useState(_ => None)
let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

React.useEffect(() => {
  let fetchData = async () => {
    try {
      let url = APIUtils.getURL(~entityName=V1(MyNewEntity), ~methodType=Get)
      let res = await getMyData(url)
      setData(_ => Some(res))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Error)
    }
  }
  fetchData()->ignore
  None
}, [])

// Wrap render:
<PageLoaderWrapper screenState>
  // ... component body using data
</PageLoaderWrapper>
```

---

## 3. New POST / UPDATE Call

```rescript
let updateData = APIUtils.useUpdateMethod()

let handleSubmit = async payload => {
  let url = APIUtils.getURL(~entityName=V1(MyNewEntity), ~methodType=Post)
  let _ = await updateData(url, payload)
}
```

---

## 4. Record Type with Variants

```rescript
// Domain types — prefer records over JS objects, variants over string constants
type status = Active | Inactive | Pending

type merchant = {
  id: string,
  name: string,
  status: status,
}

let statusToString = s =>
  switch s {
  | Active  => "active"
  | Inactive => "inactive"
  | Pending => "pending"
  }

let statusFromString = s =>
  switch s {
  | "active"   => Some(Active)
  | "inactive" => Some(Inactive)
  | "pending"  => Some(Pending)
  | _          => None
  }
```

---

## 5. Feature Flag Consumption

```rescript
// Feature flags are read from the Recoil atom or context, not from config.toml directly.
// TODO(maintainer): confirm exact atom/context name for featureFlags in src/Recoils/

// Pattern (illustrative — verify atom name in src/Recoils/):
let featureFlags = Recoil.useRecoilValue(FeatureFlagUtils.featureFlagAtom)

// Guard UI:
{featureFlags.generate_report
  ? <ReportButton />
  : React.null}
```

---

## 6. JS Interop — Nullable to Option

```rescript
// Converting JS nullable values
let maybeValue: option<string> = jsNullable->Js.Nullable.toOption

// Safe fallback
let value = maybeValue->Option.getOr("default")

// Dict lookup (returns option<'a>)
let result = myDict->Dict.get("key")
```

---

## 7. External JS Module Binding

```rescript
// Bind to a named export
@module("some-library") @val
external formatDate: (string, string) => string = "format"

// Bind to a default export
@module("some-library")
external createInstance: unit => t = "default"
```

---

## 8. Async/Await Pattern

```rescript
// ReScript 11 uncurried async
let fetchAndProcess = async () => {
  let data = await someAsyncFn()
  data->Array.map(item => processItem(item))
}

// In useEffect:
React.useEffect(() => {
  fetchAndProcess()->ignore
  None  // cleanup function (None = no cleanup)
}, [dependency])
```

---

## 9. Conditional Class Names

```rescript
// Build Tailwind class strings conditionally
let buttonClass =
  "px-4 py-2 rounded " ++
  (isDisabled ? "bg-gray-300 cursor-not-allowed" : "bg-blue-500 hover:bg-blue-600")

<button className={buttonClass} disabled={isDisabled}>
  {"Submit"->React.string}
</button>
```

---

## 10. PageLoaderWrapper Usage

```rescript
// Wrap screen content with loading/error states
<PageLoaderWrapper screenState customLoader={<MyCustomLoader />}>
  <div className="p-4">
    // ... actual content (only rendered in Success state)
  </div>
</PageLoaderWrapper>
```

States: `PageLoaderWrapper.Loading | Success | Error | Custom(...)`

---

*Patterns validated against `systemPatterns.md` and `.clinerules`.*
*Mark uncertain snippets with `// TODO(maintainer): verify` before committing.*
