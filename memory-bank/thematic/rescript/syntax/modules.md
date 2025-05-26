# ReScript Modules and File Structure

ReScript's module system is a core feature for organizing code, managing namespaces, and defining clear interfaces.

## File-based Modules

In ReScript, each file is implicitly a module.

- A file named `MyModule.res` automatically defines a module named `MyModule`.
- All `let` bindings (values, functions) and `type` definitions within `MyModule.res` become part of the `MyModule` module.

**Example:** `Button.res`

The file `src/components/Button.res` implicitly defines the `Button` module. It contains type definitions like `buttonState`, `buttonType`, and functions like `make`, `useGetBgColor`.

```rescript
// In Button.res
type buttonState = Normal | Loading | Disabled | NoHover | Focused
// ... other types ...

@react.component
let make = (~text=?, /* ...other props... */) => {
  // ... component logic ...
}

let useGetBgColor = (~buttonType, /* ... */) => {
  // ... logic ...
}
```

## Interface Files (`.resi`)

Interface files (with a `.resi` extension) are used to explicitly define the public signature or API of a module.

- If a `MyModule.resi` file exists, it dictates what parts of `MyModule.res` are accessible from other modules.
- If no `.resi` file exists, all top-level `let` bindings and `type` definitions in the `.res` file are public by default.
- Interface files help enforce abstraction and clearly define module boundaries.

**Example:** `Button.resi`

The file `src/components/Button.resi` defines the public interface for the `Button` module.

```rescript
// In Button.resi
// Publicly exposed types
type buttonState = Normal | Loading | Disabled | NoHover | Focused
type buttonVariant = Fit | Long | Full | Rounded
// ... other public types ...

// Publicly exposed functions
let useGetBgColor: (
  ~buttonType: buttonType,
  ~buttonState: buttonState,
  ~showBorder: bool,
  ~isDropdownOpen: bool=?,
  ~isPhoneDropdown: bool=?,
) => string

@react.component
let make: (
  ~buttonFor: string=?,
  ~loadingText: string=?,
  // ... many other props ...
  ~dataTestId: string=?,
) => React.element
```

Only the types and functions listed in `Button.resi` are accessible from outside the `Button` module.

## Accessing Other Modules

You can access values, types, and functions from other modules using dot notation: `ModuleName.identifier`.

**Example:** In `Button.res`, other modules are accessed:

```rescript
// Accessing a context from ThemeProvider module
let config = React.useContext(ThemeProvider.themeContext)

// Using a hook from RippleEffectBackground module
let rippleEffect = RippleEffectBackground.useHorizontalRippleHook(buttonRef)

// Using a utility function from LogicUtils module
let isTextEmpty = textId->LogicUtils.isEmptyString
```

## `open` Statement (General Concept)

The `open ModuleName;` statement brings all public identifiers from `ModuleName` into the current scope, allowing you to use them without the `ModuleName.` prefix.

- **Use with caution:** Overuse of `open` can lead to namespace collisions and make it harder to trace the origin of identifiers. It's often preferred for widely used utility modules (like `Belt` for data structures) or within a limited scope (e.g., inside a function).

**Example (Generic):**

```rescript
// Without open
let listLength = Belt.List.length(myList);
let firstItem = Belt.Option.getExn(Belt.List.head(myList));

// With open
open Belt;
let listLength = List.length(myList);
let firstItem = Option.getExn(List.head(myList));
```

**Example: Top-Level `open` in `APIUtils.res`**

The `src/APIUtils/APIUtils.res` file opens `LogicUtils` and `APIUtilsTypes` at the beginning of the file. This makes all public functions and types from `LogicUtils` and `APIUtilsTypes` directly available throughout `APIUtils.res` without needing to prefix them.

```rescript
// In src/APIUtils/APIUtils.res
open LogicUtils // All public items from LogicUtils are now in scope
open APIUtilsTypes // All public items from APIUtilsTypes are now in scope

exception JsonException(JSON.t)

let getV2Url = (
  ~entityName: v2entityNameType, // v2entityNameType is from APIUtilsTypes
  // ...
) => {
  // ...
  // isEmptyString is from LogicUtils (if it were used directly here)
}

// ... other functions ...
```

This pattern is useful when a module heavily relies on several other utility or type modules.

**Example: Locally Scoped `open` in `LogicUtils.res`**

The `LogicUtils.res` file uses an `open` statement within a specific function to bring types from `MapTypes` into that function's local scope. This avoids repeatedly prefixing `MapTypes.` within that block of code.

```rescript
// In src/utils/LogicUtils.res

let convertMapObjectToDict = (genericTypeMapVal: JSON.t) => {
  try {
    open MapTypes // Opens MapTypes only for the scope of this try block
    let map = create(genericTypeMapVal) // 'create' is from MapTypes
    let mapIterator = map.entries()
    let dict = object.fromEntries(mapIterator)->getDictFromJsonObject // 'object' is from MapTypes
    dict
  } catch {
  | _ => Dict.make()
  }
}
```

This is a common and recommended way to use `open` – limiting its scope to where it's most beneficial without polluting the global module namespace.

## Nested Modules (General Concept)

Modules can be nested within other modules for further organization.

**Example (Generic):**

```rescript
// In MyComponent.res
module Styles = {
  let primaryButton = "bg-blue-500 text-white p-2 rounded";
  let textInput = "border border-gray-300 p-1";
};

@react.component
let make = () => {
  <button className=Styles.primaryButton> {"Click Me"->React.string} </button>
};
```

**Codebase Example: Sub-components as Nested Modules in `Tabs.res`**

In `src/components/Tabs.res`, helper components like `TabInfo` and `IndicationArrow` are defined as nested modules. This encapsulates their logic and types within the scope of the main `Tabs` component/module.

```rescript
// In src/components/Tabs.res

// ... (other type definitions for Tabs) ...

module TabInfo = {
  @react.component
  let make = (
    ~title,
    ~tabElement=None,
    ~isSelected,
    // ... other props for TabInfo ...
  ) => {
    // ... implementation of the TabInfo component ...
    React.null // Simplified
  };
}; // End of TabInfo module

module IndicationArrow = {
  @react.component
  let make = (
    ~iconName,
    ~side,
    ~refElement: React.ref<Js.nullable<Dom.element>>,
    ~isVisible
  ) => {
    // ... implementation of the IndicationArrow component ...
    React.null // Simplified
  };
}; // End of IndicationArrow module

// Main make function for Tabs component, which can use TabInfo and IndicationArrow
@react.component
let make = (
  ~tabs: array<tab>,
  // ... other props for Tabs ...
) => {
  // ...
  // Usage of nested module components:
  // <TabInfo title=... />
  // <IndicationArrow iconName=... />
  // ...
  React.null // Simplified
};
```

This pattern helps in organizing complex components by breaking them down into smaller, manageable, and co-located sub-modules/sub-components.
