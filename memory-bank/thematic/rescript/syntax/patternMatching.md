# ReScript Pattern Matching (`switch`)

ReScript's `switch` expression is a powerful tool for control flow, allowing you to destructure data types (like variants, options, lists, records) and execute code based on their shape and values.

## Matching on Variants

`switch` is commonly used to handle different cases of a variant type.

**Example: URL Generation in `APIUtils.res`**
The `getV2Url` function in `src/APIUtils/APIUtils.res` uses nested `switch` statements to determine the correct URL string based on `entityName` (a variant type) and `methodType` (another variant type, `Fetch.requestMethod`).

```rescript
// In src/APIUtils/APIUtils.res
// entityName is a variant like: type v2entityNameType = CUSTOMERS | V2_CONNECTOR | ...
// methodType is a variant like: type requestMethod = Get | Post | Put | ...

let getV2Url = (
  ~entityName: v2entityNameType,
  ~userType: userType=#NONE,
  ~methodType: Fetch.requestMethod,
  ~id=None,
  ~profileId,
  ~merchantId,
  ~queryParamerters: option<string>=None,
) => {
  // ...
  switch entityName {
  | CUSTOMERS =>
    switch (methodType, id) { // Matching on a tuple of (variant, option)
    | (Get, None) => "v2/customers/list"
    | (Get, Some(customerId)) => `v2/customers/${customerId}` // Destructuring Some
    | _ => "" // Wildcard for other methodType/id combinations
    }
  | V2_CONNECTOR =>
    switch methodType {
    | Get =>
      switch id { // Nested switch on an option type
      | Some(connectorID) => `${connectorBaseURL}/${connectorID}`
      | None => `v2/profiles/${profileId}/connector-accounts`
      }
    | Put =>
      // ...
    | _ => ""
    }
  // ... more cases for entityName ...
  | V2_ORDERS_LIST => // Another case for the outer switch
    // ...
  }
}
```

- The `switch` expression must be exhaustive, meaning all possible cases of the type being matched must be handled. The wildcard `_` can be used to match any case not explicitly listed.
- You can match on tuples, as seen with `switch (methodType, id)`.
- Values inside variant constructors or `Some` can be destructured (e.g., `Some(customerId)` makes `customerId` available).

**Example: Button Styling in `Button.res`**
The `useGetBgColor` function in `src/components/Button.res` uses `switch` to determine background color based on `buttonType` and `buttonState` (both variant types).

````rescript
// In src/components/Button.res
let useGetBgColor = (
  ~buttonType, // variant type
  ~buttonState, // variant type
  ~showBorder,
  ~isDropdownOpen=false,
  ~isPhoneDropdown=false,
) => {
  // ...
  switch buttonType {
  | Primary =>
    switch buttonState {
    | Focused | Normal => buttonConfig.primaryNormal // Multiple constructors can share a case
    | Loading => buttonConfig.primaryLoading
    | Disabled => buttonConfig.primaryDisabled
    | NoHover => buttonConfig.primaryNoHover
    }
  | SecondaryFilled =>
    switch buttonState {
    | Focused | Normal => "..."
    // ... other cases ...
    }
  // ... other buttonType cases ...
  }
}

## Matching on Polymorphic Variants

Polymorphic variants (often prefixed with `#` or using backticks like `` `ConstructorName `` in this codebase, though the official ReScript style is typically an initial uppercase without a prefix for the constructor itself, e.g., `` `MyConstructor ``) can also be pattern matched using `switch`.

**Example: Simple Match from `VaultHomeUtils.res`**

The `getTrackingName` function determines a string based on the `section` polymorphic variant.

```rescript
// In src/Vault/VaultScreens/VaultHomeUtils.res
// Assuming 'section' is of a polymorphic variant type like:
// type vaultSections = [#AuthenticateProcessor | #SetupPmts | #SetupWebhook | #ReviewAndConnect]

let getTrackingName = section =>
  switch section {
  | #AuthenticateProcessor => "vault_onboarding_step1"
  | #SetupPmts => "vault_onboarding_step2"
  | #SetupWebhook => "vault_onboarding_step3"
  | #ReviewAndConnect => "vault_onboarding_step4"
  // Note: If vaultSections is an exact polymorphic variant type ([ ... ]),
  // the switch must be exhaustive or include a wildcard _.
  // If it's an open one ([> ... ] or [< ...]), a wildcard is often necessary.
  }
````

**Example: Multiple Cases from `PaymentAttemptEntity.res`**

This example shows how different polymorphic variant cases can map to shared outcomes.

```rescript
// In src/screens/Analytics/GlobalSearchResults/GlobalSearchTables/PaymentAttempt/PaymentAttemptEntity.res
// Assuming 'status' is a polymorphic variant including these cases,
// and LabelGreen, LabelRed, LabelOrange are defined values (e.g., color strings or other variants).

let getStatusColor = status =>
  switch status {
  | #AUTO_REFUNDED => LabelGreen
  | #VOID_FAILED // Fall-through: shares the result of #FAILURE
  | #FAILURE => LabelRed
  | #CAPTURE_INITIATED // Fall-through: shares the result of #PENDING
  | #PENDING => LabelOrange
  | _ => DefaultLabel // Wildcard for any other statuses
  }
```

**Example: UI Rendering based on Match from `RecoveryConnectorHome.res`**

Different React components are rendered based on the `currentStep` polymorphic variant.

```rescript
// In src/RevenueRecovery/RevenueRecoveryScreens/RecoveryProcessors/RecoveryProcessorsPaymentProcessors/RecoveryConnectorHome.res
// Assuming 'currentStep' is of a polymorphic variant type like:
// type sectionType = [#AuthenticateProcessor | #SetupPmts | #SetupWebhook | #ReviewAndConnect]
// And <AuthenticateProcessorComponent />, etc., are defined React components.

let renderSection = currentStep =>
  switch currentStep {
  | #AuthenticateProcessor => <AuthenticateProcessorComponent />
  | #SetupPmts => <SetupPaymentsComponent />
  | #SetupWebhook => <SetupWebhookComponent />
  | #ReviewAndConnect => <ReviewAndConnectComponent />
  // Assuming 'sectionType' is exact and all cases are covered.
  }
```

_(Note: Component names in the example above are illustrative.)_

````

## Matching on Option (`option<'a>`)

`switch` is the idiomatic way to handle `option` types.

**Example: From `LogicUtils.res` (conceptual, actual code might use `Option.mapOr` etc.)**

```rescript
// In src/utils/LogicUtils.res (illustrative example)
let processOptionalString = (optStr: option<string>) => {
  switch optStr {
  | Some(s) => "Got string: " ++ s
  | None => "No string provided"
  }
}
````

Many functions in `LogicUtils.res` like `getString` or `getOptionIntFromJson` internally use `switch` or `Option` module functions (which themselves use `switch`-like logic) to handle optional values. For instance, `getOptionIntFromJson` uses `switch json->JSON.Classify.classify` which can result in `None`.

## Matching on Other Types

`switch` can also be used with booleans, integers, strings, lists, and other types.

**Example: Boolean match in `LogicUtils.res` (for `getBoolFromString`)**

```rescript
// In src/utils/LogicUtils.res
let getBoolFromString = (boolString, default: bool) => {
  switch boolString->String.toLowerCase {
  | "true" => true
  | "false" => false
  | _ => default // Wildcard for any other string
  }
}
```

**Example: List pattern matching (from `typesAndDataStructures.md` for illustration)**

```rescript
// In src/utils/LogicUtils.res
let stripV4 = (path: list<string>): list<string> => {
  switch path {
  | list{"v4", ...remaining} => remaining // Matches a list starting with "v4"
  | _ => path // Matches any other list (empty or not starting with "v4")
  }
}
```

- `list{...}` syntax is used for matching list patterns.
- `...remaining` (spread operator) captures the rest of the list.

## Guards (When Clauses)

You can add `when` clauses to `switch` cases for more complex conditions.

**Example (Generic):**

```rescript
let processNumber = (x: int) => {
  switch x {
  | n when n < 0 => "Negative"
  | n when n == 0 => "Zero"
  | n when n > 0 && n < 10 => "Small positive"
  | _ => "Large positive or other"
  }
}
```

_(Specific examples of `when` clauses from the codebase will be added if prominently found.)_

Pattern matching is a cornerstone of ReScript development, leading to safe, expressive, and often more readable code compared to deeply nested if-else statements.
