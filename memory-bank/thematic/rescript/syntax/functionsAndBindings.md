# ReScript Functions and Let Bindings

This section covers how functions are defined and used in ReScript, including labeled arguments, optional arguments, recursion, `let` bindings for values and functions, and the pipe operator for chaining operations.

## `let` Bindings

`let` is used to bind values and functions to names.

**Binding Values:**

```rescript
let companyName = "Hyperswitch";
let year = 2023;
let pi = 3.14159;
```

**Binding Functions:**
Functions are first-class citizens and are also bound using `let`.

```rescript
// Simple function
let add = (a: int, b: int): int => a + b;

// Calling the function
let sum = add(5, 3); // sum is 8
```

**Type Annotations:**
While ReScript has powerful type inference, explicit type annotations are often good practice for clarity, especially for function signatures.

```rescript
let greet = (name: string): string => "Hello, " ++ name ++ "!";
```

## Function Definitions

**Anonymous Functions (Lambdas):**
Functions can be defined anonymously.

```rescript
let numbers = [1, 2, 3];
let doubledNumbers = numbers->Array.map(x => x * 2); // x => x * 2 is an anonymous function
```

**Labeled Arguments (`~labelName`):**
For clarity, especially with multiple arguments of the same type, ReScript encourages labeled arguments.

```rescript
// Definition in Button.resi
let useGetBgColor: (
  ~buttonType: buttonType, // Labeled argument
  ~buttonState: buttonState, // Labeled argument
  ~showBorder: bool, // Labeled argument (can also be positional if last)
  ~isDropdownOpen: bool=?, // Optional labeled argument
  ~isPhoneDropdown: bool=?,
) => string;

// Calling with labeled arguments (order doesn't matter for labeled ones)
let bgColor = useGetBgColor(
  ~buttonState=Normal,
  ~buttonType=Primary,
  ~showBorder=true,
  // Optional arguments can be omitted or passed
  ~isDropdownOpen=false,
);
```

- When calling a function with labeled arguments, you use the `~labelName=value` syntax.
- If all arguments are labeled, their order during the call does not matter.
- A final positional argument can exist after labeled arguments.

**Optional Labeled Arguments (`~labelName=?defaultValue` or `~labelName=?`):**
Arguments can be made optional by adding a `?` after the label.

- If a default value is provided (`~labelName=?defaultValue`), the argument is of type `typeOfDefaultValue`.
- If no default value is provided (`~labelName=?`), the argument inside the function is an `option<typeOfArgument>`.

```rescript
// From Button.res - ~isDropdownOpen is option<bool>, defaults to false if not provided by caller
// The type signature in .resi was ~isDropdownOpen: bool=?, which means it's option<bool>
// and the implementation provides the default.
let useGetBgColor = (
  ~buttonType,
  ~buttonState,
  ~showBorder,
  ~isDropdownOpen=false, // Default value provided in implementation
  ~isPhoneDropdown=false,
) => {
  // ...
};

// From Button.resi - make function has many optional arguments
// ~text: string=? means text is option<string> inside the 'make' function
@react.component
let make = (
  ~text: string=?, // This will be option<string> inside 'make'
  ~buttonState: buttonState=Normal, // Defaults to Normal if not passed
  // ...
) => React.element;
```

**Type Casting with Labeled Arguments (`:>`)**
Sometimes, you might need to cast a polymorphic variant to its concrete type when passing it as a labeled argument if the function expects a more general type.

```rescript
// Example from APIUtils.res
// userType is a polymorphic variant like type userType = [ | #SIGNUP | #SIGNOUT | ...]
// The string_of_userType function might expect a specific variant, or it's being used
// in a context (like URL construction) where it needs to be a string.
let urlPart = (userType :> string)->String.toLowerCase;
// (userType :> string) casts the polymorphic variant userType to a string.
// This is often used when a polymorphic variant needs to be passed to a function
// expecting a more general type, or for specific interop scenarios.
```

_Note: The `(userType :> string)` syntax is more about type coercion for polymorphic variants to their underlying representation (often strings for URLs or JS interop) rather than a general argument passing feature._

## Pipe Operator (`->`)

The pipe operator `->` is used to chain operations in a readable, left-to-right fashion. It passes the result of the expression on its left as the _first_ argument to the function call on its right.

**Basic Pipe:**

```rescript
let result = value->function1->function2(argForFunc2);
// Equivalent to: function2(function1(value), argForFunc2)
```

**Example from `LogicUtils.res`:**

````rescript
// In src/utils/LogicUtils.res
let getNameFromEmail = email => {
  email
  ->String.split("@") // result of String.split(email, "@")
  ->Array.get(0)      // result of Array.get(previous_result, 0)
  ->Option.getOr("")  // result of Option.getOr(previous_result, "")
  ->String.split(".")
  ->Array.map(name => /* ... */)
  ->Array.joinWith(" ")
};

**Further Examples of Pipe Usage:**

**Piping to a Custom Mapper Function:**
This pattern is common for transforming data, often for UI display or further processing.

```rescript
// In src/Vault/VaultCustomersAndTokens/VaultPSPTokensEntity.res
// 'pspTokens.status' (a string) is piped into a custom function
// 'VaultPaymentMethodUtils.connectrTokensStatusToVariantMapper'.
// This mapper likely converts the status string to a variant or another suitable type
// for UI display or logic.

let statusDisplay = pspTokens.status->VaultPaymentMethodUtils.connectrTokensStatusToVariantMapper;
````

**Piping the Result of an Initial Function Call:**
The output of one function can be directly piped into another.

```rescript
// In src/Vault/VaultOnboarding.res
// The result of 'UrlUtils.useGetFilterDictFromUrl("")' (which might return a Js.Dict.t)
// is piped into 'LogicUtils.getString' to extract the "name" field, with "" as a default.

let connectorName = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "");
```

````

**Pipe with Labeled Arguments:**
When piping to a function that takes labeled arguments, the piped value still becomes the first *positional* argument. If the function *only* takes labeled arguments, or if the first argument it expects is the one being piped, it works naturally.

If the function expects the piped value for a *specific labeled argument* that isn't the first one, you'd typically use an anonymous function:
```rescript
// Assume: let processData = (~config: configType, ~data: dataType) => ...
let myData = initialValue->transform;
let result = myData->(d => processData(~config=someConfig, ~data=d));
````

## Recursion

Functions can call themselves to perform recursive operations. ReScript requires the `rec` keyword for `let` bindings of recursive functions. This is often used for tasks like traversing nested data structures or, as in the example below, iterative string manipulation.

**Example: `addCommas` from `src/utils/LogicUtils.res`**

The `addCommas` function is part of a larger `formatAmount` function. It recursively adds commas to a number string for formatting.

```rescript
// In src/utils/LogicUtils.res (within formatAmount function)

// Definition of the recursive function 'addCommas'
let rec addCommas = str => {
  let len = String.length(str)
  if len <= 3 {
    str // Base case: if the string length is 3 or less, no more commas needed
  } else {
    // Recursive step:
    // Take the part of the string before the last 3 digits
    let prefix = String.slice(~start=0, ~end=len - 3, str)
    // Take the last 3 digits
    let suffix = String.slice(~start=len - 3, ~end=len, str)
    // Recursively call addCommas on the prefix, then append comma and suffix
    addCommas(prefix) ++ "," ++ suffix
  }
}

// Example of how addCommas might be used (simplified from formatAmount)
let formattedNumberString = addCommas("1234567"); // Results in "1,234,567"

/*
Full context in formatAmount:
let formatAmount = (amount, currency) => {
  // ... addCommas definition from above ...
  `${currency} ${addCommas(amount->Int.toString)}`
}
*/
```

This example demonstrates how `let rec` is used to define `addCommas`, which calls itself to build up the formatted string.

This covers the fundamental aspects of defining and using functions and `let` bindings in ReScript.
