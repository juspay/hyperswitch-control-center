# Common Standard Library Usage (Belt / Js)

ReScript comes with a standard library, often split into two main families: `Js` (for direct, often mutable, JavaScript-like operations) and `Belt` (a ReScript-specific, immutable, and often more optimized standard library). This document highlights common usage patterns.

## `Js` Module Family

The `Js` module provides submodules for JavaScript primitive types and common objects.

**`Js.String` / `Js.String2`**
Used for string manipulations. `Js.String2` often contains more pipe-friendly versions or additional functionalities.

```rescript
// From LogicUtils.res
let isEmptyString = str => str->String.length === 0; // String.length is Js.String.length
let capitalized = str->String.toUpperCase; // Js.String.toUpperCase

// Js.String2.replaceByRe (older name) or Js.String.replaceRegExp
let newStr = "hello-world"->String.replaceRegExp(%re("/-/g"), " "); // "hello world"

// Js.String2.split (older name) or String.split
let parts = "a,b,c"->String.split(","); // ["a", "b", "c"]

// Js.String2.match_ (older name) or Js.String.match
let maybeMatch = "text"->Js.String.match(%re("/ex/")); // Some(["ex"])
```

**`Js.Array` / `Js.Array2`**
For operations on JavaScript arrays. `Js.Array2` is often an alias or provides pipe-first versions.

```rescript
// From LogicUtils.res
let joined = ["a", "b", "c"]->Array.joinWith("-"); // "a-b-c" (Array is Js.Array)

// Array.map from LogicUtils.res
let mapped = anArray->Array.map(item => item->transform);
```

_Note: The global `Array` module in ReScript typically refers to `Js.Array`._

**`Js.Dict`**
For working with JavaScript objects as string-keyed dictionaries.

```rescript
// From LogicUtils.res
let myDict = Dict.make(); // Js.Dict.make
Dict.set(myDict, "key1", "value1"->JSON.Encode.string);
let valOpt = Dict.get(myDict, "key1"); // Js.Dict.get
```

**`Js.Json`**
For working with `JSON.t` type, parsing, and stringifying.

```rescript
// From LogicUtils.res
let jsonValue: JSON.t = JSON.parseExn("{\"name\": \"Rescript\"}");
let nameOpt: option<string> = jsonValue->JSON.Decode.object->Option.flatMap(obj =>
  obj->Dict.get("name")->Option.flatMap(JSON.Decode.string)
);
let str = JSON.stringifyWithIndent(jsonValue, 2);
```

**`Js.Promise`**
Covered in `jsInterop.md`.

**`Js.Nullable`**
Covered in `jsInterop.md`.

**`Js.Date`**
For working with JavaScript `Date` objects.

```rescript
// From LogicUtils.res (conceptual, actual might use DayJs)
let now = Js.Date.now(); // Returns float (milliseconds since epoch)
let date = Js.Date.fromFloat(now);
let year = Js.Date.getFullYear(date);
```

## `Belt` Module Family

`Belt` is ReScript's own standard library, designed to be fast, type-safe, and often immutable. It's generally preferred over `Js` counterparts for new ReScript code when performance and immutability are desired.

**`Belt.Option`**
Provides utility functions for working with `option<'a>` types.

```rescript
// From LogicUtils.res
let value = opt->Belt.Option.getWithDefault("default"); // Replaces Option.getOr
let mappedOpt = opt->Belt.Option.map(x => x + 1);
let flatMappedOpt = opt->Belt.Option.flatMap(x => if x > 0 {Some(x)} else {None});
```

- `Belt.Option.getWithDefault` (or `Option.getOr` which is often an alias)
- `Belt.Option.map`
- `Belt.Option.flatMap`
- `Belt.Option.isSome`, `Belt.Option.isNone`

**`Belt.Result`**
For representing computations that can succeed (`Ok('a)`) or fail (`Error('e)`).

```rescript
// Generic Example
let divide = (a, b) => {
  if b == 0 {
    Belt.Result.Error("Division by zero")
  } else {
    Belt.Result.Ok(a / b)
  }
}
```

**`Belt.Array`**
For immutable operations on arrays.

```rescript
// From LogicUtils.res
let filtered = anArray->Belt.Array.keep(x => x > 0); // Replaces Array.filter
let mapped = anArray->Belt.Array.map(x => x * 2);   // Replaces Array.map
let reduced = anArray->Belt.Array.reduce(0, (acc, x) => acc + x);

// From LogicUtils.res (getStrArrayFromJsonArray)
// jsonArr->Belt.Array.keepMap(JSON.Decode.string)
// keepMap is like a map followed by a filter for Some values.
```

- `Belt.Array.keep` (filter)
- `Belt.Array.map`
- `Belt.Array.reduce`
- `Belt.Array.keepMap` (map and then filter out `None`s)
- `Belt.Array.length`, `Belt.Array.get`, etc.

**`Belt.Array.zipBy`**
Combines two arrays element-wise using a provided function. If arrays have different lengths, it stops at the shorter length.

```rescript
// From src/utils/AnalyticsNewUtils.res (simplified context)
// let dictOfDates = [("2023-01-01", 10), ("2023-01-02", 20)];
// let deltaPrefixArr = ["sales_", "profit_"];
// let generatePayload = ((date, count), prefix) => ({ /* ... */ });

let tablePayload = Belt.Array.zipBy(dictOfDates, deltaPrefixArr, generatePayload);
// tablePayload would be an array of results from generatePayload
```

**`Belt.List`**
For immutable operations on `list<'a>`.

```rescript
// Generic Example
let myList = list{1, 2, 3};
let mappedList = myList->Belt.List.map(x => x->Int.toString); // list{"1", "2", "3"}
let length = myList->Belt.List.length;
let headOpt = myList->Belt.List.head; // option<int>
```

**`Belt.Map.String` / `Belt.Map.Int` / etc.**
For immutable map (dictionary) structures, keyed by string, int, etc.

```rescript
// Generic Example
let myMap = Belt.Map.String.empty;
let map1 = myMap->Belt.Map.String.set("key1", "value1");
let valOpt = map1->Belt.Map.String.get("key1"); // option<string>
```

**`Belt.Set.String` / `Belt.Set.Int` / etc.**
For immutable set structures.

```rescript
// Generic Example
let mySet = Belt.Set.String.empty;
let set1 = mySet->Belt.Set.String.add("apple");
let hasApple = set1->Belt.Set.String.has("apple"); // bool
```

**`Belt` Numeric Type Conversions**

`Belt.Int` and `Belt.Float` provide safe string-to-number parsing and number-to-string conversion.

```rescript
// Belt.Int.toString
// From src/screens/Analytics/GlobalSearch/GlobalSearchBarHelper.res
let indexStr = index->Belt.Int.toString;

// Belt.Float.toString
// From src/screens/Analytics/GlobalSearch/GlobalSearchBarUtils.res
let amountStr = someFloatValue->Belt.Float.toString;

// Belt.Int.fromString (returns option<int>)
let maybeInt = "123"->Belt.Int.fromString; // Some(123)
let notAnInt = "abc"->Belt.Int.fromString; // None
```

**`Belt.MutableQueue`, `Belt.MutableStack`, `Belt.MutableMap`, `Belt.MutableSet`**
`Belt` also provides mutable collection alternatives if needed for performance-critical sections, though the immutable versions are generally preferred.

This document provides an overview. The ReScript documentation for `Js` and `Belt` should be consulted for a complete list of available functions and their detailed behavior. The choice between `Js` and `Belt` often depends on whether direct JS interop with existing mutable structures is needed, or if the benefits of Belt's immutability and ReScript-idiomatic API are preferred.
