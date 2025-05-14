# ReScript Types and Data Structures

ReScript has a strong, static type system. This document covers common type definitions (records, variants, aliases) and usage of built-in data structures like `option`, `array`, `list`, and `Js.Dict`.

## Variant Types (Sum Types)

Variant types allow you to define a type that can be one of several distinct cases, each with an optional payload.

**Example: Simple Variants from `Button.resi`**

```rescript
// In src/components/Button.resi
type buttonState = Normal | Loading | Disabled | NoHover | Focused
type buttonVariant = Fit | Long | Full | Rounded
type buttonSize = Large | Medium | Small | XSmall
```

- `buttonState` can be `Normal`, `Loading`, etc. These are simple constructors without payloads.

**Example: Variants with Payloads from `Button.resi`**

```rescript
// In src/components/Button.resi
type iconType =
  | FontAwesome(string) // Constructor FontAwesome takes a string payload
  | CustomIcon(React.element) // CustomIcon takes a React.element payload
  | CustomRightIcon(React.element)
  | Euler(string)
  | NoIcon // No payload
```

**Example: Extensive Variants from `APIUtilsTypes.res`**

This file defines many variant types to represent different kinds of API entities or user roles.

```rescript
// In src/APIUtils/APIUtilsTypes.res
type entityName =
  | CONNECTOR
  | ROUTING
  | MERCHANT_ACCOUNT
  // ... many more constructors ...
  | SDK_PAYMENT
  | GET_REVIEW_FIELDS

type userRoleTypes = USER_LIST | ROLE_LIST | ROLE_ID | NONE
```

**Example: Polymorphic Variants from `APIUtilsTypes.res`**

Polymorphic variants start with a `#` and are structurally typed. They are useful for creating types that can be easily extended or combined.

```rescript
// In src/APIUtils/APIUtilsTypes.res
type reconType = [#TOKEN | #REQUEST | #NONE] // Note the # prefix
type hypersenseType = [#TOKEN | #HOME | #NONE]

type userType = [ // Square brackets also denote polymorphic variants
  | #CONNECT_ACCOUNT
  | #SIGNUP
  // ... many more constructors ...
  | #NONE
]

// Example from src/screens/Connectors/PaymentProcessor/ConnectorMetaData/ApplePay/ApplePayIntegrationTypes.res
// Demonstrates polymorphic variant constructors with payloads
type applePayConfig = [#manual(manual) | #simplified(simplified)]
// Here, 'manual' and 'simplified' would be types of the payloads.

// Example from src/entryPoints/AuthModule/SSOAuth/SSOTypes.res
// Demonstrates mixed constructors with and without payloads
type redirectmethods = [#Okta(okta) | #Google | #Github]
// '#Okta' takes a payload of type 'okta', while '#Google' and '#Github' do not.
```

**Example: Parameterized Variants from `APIUtilsTypes.res`**

Variants can also carry other types as payloads, effectively creating a new type that wraps existing ones.

```rescript
// In src/APIUtils/APIUtilsTypes.res
// 'entityName' and 'v2entityNameType' are other variant types defined in the same file.
type entityTypeWithVersion = V1(entityName) | V2(v2entityNameType)
```

Here, `entityTypeWithVersion` can either be `V1` holding an `entityName` value, or `V2` holding a `v2entityNameType` value.

## Record Types

Record types define named fields, similar to objects in JavaScript. They are structurally typed by default.

**Example: `badge` type from `Button.resi`**

```rescript
// In src/components/Button.resi
type badgeColor = // This is a variant type used in the record
  | BadgeGreen
  | BadgeRed
  // ... other colors ...
  | NoBadge

type badge = {
  value: string,
  color: badgeColor, // Field 'color' is of type badgeColor
}
```

- A `badge` record must have a `value` field of type `string` and a `color` field of type `badgeColor`.

**Creating Record Values:**

```rescript
let myBadge: badge = {value: "New", color: BadgeGreen};
```

## Option Type (`option<'a>`)

The `option` type is a built-in variant used to represent values that might be absent. It's ReScript's way of handling `null` or `undefined` in a type-safe manner.

- It has two constructors: `Some('a)` (value is present) or `None` (value is absent).
- Many functions in ReScript that might not return a value (e.g., finding an item in a dictionary) return an `option`.

**Example: Optional props in `Button.resi`**
Many props in `Button.resi` are optional, indicated by `option<type>` or `~propName=?type` in the `make` function signature.

```rescript
// In src/components/Button.resi
// ~text: string=? means text is option<string>
// ~buttonState: buttonState=? means buttonState is option<buttonState>
@react.component
let make: (
  ~text: string=?,
  ~buttonState: buttonState=?,
  // ...
) => React.element
```

**Example: Usage in `LogicUtils.res`**
`LogicUtils.res` has many functions that return or manipulate `option` types.

```rescript
// In src/utils/LogicUtils.res
let getOptionString = (dict, key): option<string> => {
  // Dict.get returns an option, JSON.Decode.string also returns an option
  dict->Dict.get(key)->Option.flatMap(obj => obj->JSON.Decode.string)
}

let getNonEmptyString = (str: string): option<string> => {
  if str->isEmptyString {
    None // Return None if string is empty
  } else {
    Some(str) // Return Some(string) if not empty
  }
}
```

- `Option.flatMap` is often used to chain operations that return `option`s.
- `Option.getOr(defaultValue)` is used to extract the value from an `option` or provide a default if it's `None`.
  ```rescript
  let myString: string = getOptionString(myDict, "myKey")->Option.getOr("default value");
  ```

## Type Aliases for Function Signatures

You can create a named alias for a function type signature.

**Example: `getUrlTypes` from `APIUtilsTypes.res`**

```rescript
// In src/APIUtils/APIUtilsTypes.res
type getUrlTypes = (
  ~entityName: entityTypeWithVersion,
  ~methodType: Fetch.requestMethod,
  ~id: option<string>=?,
  ~connector: option<string>=?,
  ~userType: userType=?,
  ~userRoleTypes: userRoleTypes=?,
  ~reconType: reconType=?,
  ~hypersenseType: hypersenseType=?,
  ~queryParamerters: option<string>=?,
) => string
```

Now, `getUrlTypes` can be used as a type annotation for functions matching this signature.

## Array (`array<'a>`)

ReScript arrays are mutable, fixed-length (at compile-time, though JS arrays are dynamic at runtime), and zero-indexed. They are JavaScript arrays at runtime.

**Example: Usage in `LogicUtils.res`**

```rescript
// In src/utils/LogicUtils.res
let removeDuplicate = (arr: array<string>): array<string> => {
  arr->Array.filterWithIndex((item, i) => {
    arr->Array.indexOf(item) === i
  })
}

let strArr = ["apple", "banana", "apple"];
let uniqueArr = removeDuplicate(strArr); // ["apple", "banana"]
```

- The `Array` module provides many functions for working with arrays (e.g., `Array.mapWithIndex`, `Array.filterWithIndex`, `Array.joinWith`).
- `Belt.Array` is often preferred for more optimized and purely functional operations.

## List (`list<'a>`)

ReScript lists are immutable, singly-linked lists. They are well-suited for functional programming patterns.

**Example: `stripV4` in `LogicUtils.res`**

```rescript
// In src/utils/LogicUtils.res
let stripV4 = (path: list<string>): list<string> => {
  switch path {
  | list{"v4", ...remaining} => remaining // Pattern matching on a list
  | _ => path
  }
}

let path1 = list{"v4", "users", "list"};
let strippedPath1 = stripV4(path1); // list{"users", "list"}

let path2 = list{"api", "items"};
let strippedPath2 = stripV4(path2); // list{"api", "items"}
```

- The `List` module (and `Belt.List`) provides functions for list manipulation.
- Lists are often processed using recursion or pattern matching.

## Js.Dict.t (`Js.Dict.t<'a>`)

`Js.Dict.t<'a>` represents JavaScript objects used as dictionaries (string keys to values of type `'a`).

**Example: Usage in `LogicUtils.res`**

```rescript
// In src/utils/LogicUtils.res
let getDictFromJsonObject = (json: JSON.t): Js.Dict.t<JSON.t> => {
  switch json->JSON.Decode.object {
  | Some(dict) => dict
  | None => Dict.make() // Creates an empty dictionary
  }
}

let getString = (dict: Js.Dict.t<JSON.t>, key: string, default: string): string => {
  // Dict.get returns option<JSON.t>
  dict->Dict.get(key)
  ->Option.flatMap(obj => obj->JSON.Decode.string)
  ->Option.getOr(default)
}
```

- The `Dict` module (often an alias for `Js.Dict`) is used for operations.

_(More examples for `Belt` collections and other data structures will be added as encountered.)_
