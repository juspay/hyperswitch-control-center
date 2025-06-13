# Modules and File Structure in ReScript (Hyperswitch Control Center)

This document details how ReScript modules are defined, opened, and used, including file-based modules and interface files (`.resi`).

## File-Based Modules

In ReScript, every file automatically becomes a module. The filename determines the module name.

### Basic File Module

```rescript
// File: UserUtils.res
// This creates a module named UserUtils

let formatName = (firstName, lastName) => {
  `${firstName} ${lastName}`
}

let validateEmail = email => {
  email->String.includes("@")
}

type user = {
  id: string,
  name: string,
  email: string,
}
```

### Using File Modules

```rescript
// In another file
let user = UserUtils.{
  id: "123",
  name: UserUtils.formatName("John", "Doe"),
  email: "john@example.com",
}

let isValid = UserUtils.validateEmail(user.email)
```

## Module Interfaces (.resi files)

Interface files define the public API of a module, hiding implementation details.

### Creating an Interface File

```rescript
// File: UserUtils.resi
// This defines what's publicly available from UserUtils.res

type user = {
  id: string,
  name: string,
  email: string,
}

let formatName: (string, string) => string
let validateEmail: string => bool
```

### Benefits of Interface Files

1. **Encapsulation**: Hide internal implementation details
2. **Documentation**: Serve as API documentation
3. **Compilation**: Faster compilation for consumers
4. **Type Safety**: Enforce specific type signatures

## Opening Modules

### Global Module Opening

```rescript
// Opens the module globally in the file
open Belt

// Now you can use Belt functions directly
let numbers = [1, 2, 3, 4, 5]
let doubled = numbers->Array.map(x => x * 2)
```

### Local Module Opening

```rescript
// Open module locally within a scope
let processData = data => {
  open Array
  data
  ->map(x => x * 2)
  ->filter(x => x > 5)
  ->reduce(0, (acc, x) => acc + x)
}
```

### Selective Opening

```rescript
// Open specific items from a module
open Belt.Array

let numbers = [1, 2, 3, 4, 5]
let result = numbers->map(x => x * 2)
```

## Nested Modules

### Defining Nested Modules

```rescript
// File: APIUtils.res
module Types = {
  type response<'a> = {
    data: 'a,
    status: int,
    message: string,
  }

  type error = {
    code: int,
    message: string,
  }
}

module HTTP = {
  let get = url => {
    // Implementation
  }

  let post = (url, body) => {
    // Implementation
  }
}

module Validation = {
  let isValidUrl = url => {
    url->String.startsWith("http")
  }

  let isValidEmail = email => {
    email->String.includes("@")
  }
}
```

### Using Nested Modules

```rescript
// Using nested modules
let response: APIUtils.Types.response<string> = {
  data: "success",
  status: 200,
  message: "OK",
}

let isValid = APIUtils.Validation.isValidUrl("https://example.com")
let result = APIUtils.HTTP.get("https://api.example.com/data")
```

## Module Aliases

### Creating Module Aliases

```rescript
// Create shorter aliases for frequently used modules
module A = Belt.Array
module O = Belt.Option
module R = Belt.Result

let processArray = arr => {
  arr
  ->A.map(x => x * 2)
  ->A.filter(x => x > 0)
  ->O.getOr([])
}
```

### Aliasing Nested Modules

```rescript
module Types = APIUtils.Types
module HTTP = APIUtils.HTTP

let makeRequest = () => {
  let response = HTTP.get("/api/data")
  // Process response as Types.response
}
```

## Module Functors

### Basic Functor

```rescript
// Define a functor (module that takes other modules as parameters)
module MakeComparable = (T: {
  type t
  let compare: (t, t) => int
}) => {
  type t = T.t

  let equal = (a, b) => T.compare(a, b) == 0
  let lessThan = (a, b) => T.compare(a, b) < 0
  let greaterThan = (a, b) => T.compare(a, b) > 0
}

// Use the functor
module IntComparable = MakeComparable({
  type t = int
  let compare = (a, b) => a - b
})

let result = IntComparable.equal(5, 5) // true
```

## Common Module Patterns in Hyperswitch

### API Module Pattern

```rescript
// File: PaymentAPI.res
module Types = {
  type payment = {
    id: string,
    amount: float,
    currency: string,
    status: string,
  }

  type paymentRequest = {
    amount: float,
    currency: string,
    description: option<string>,
  }
}

module Endpoints = {
  let payments = "/api/v1/payments"
  let payment = id => `/api/v1/payments/${id}`
  let capture = id => `/api/v1/payments/${id}/capture`
}

module API = {
  open Types

  let getPayments = async () => {
    // API call implementation
  }

  let getPayment = async id => {
    // API call implementation
  }

  let createPayment = async request => {
    // API call implementation
  }
}
```

### Utility Module Pattern

```rescript
// File: DateUtils.res
module Format = {
  let toISOString = date => {
    // Implementation
  }

  let toDisplayString = date => {
    // Implementation
  }

  let toTimestamp = date => {
    // Implementation
  }
}

module Parse = {
  let fromString = str => {
    // Implementation
  }

  let fromTimestamp = timestamp => {
    // Implementation
  }
}

module Validation = {
  let isValidDate = str => {
    // Implementation
  }

  let isInRange = (date, startDate, endDate) => {
    // Implementation
  }
}
```

### Component Module Pattern

```rescript
// File: Button.res
module Types = {
  type variant = Primary | Secondary | Danger
  type size = Small | Medium | Large

  type props = {
    variant: variant,
    size: size,
    disabled: bool,
    onClick: unit => unit,
    children: React.element,
  }
}

module Styles = {
  let getVariantClass = variant => {
    switch variant {
    | Primary => "btn-primary"
    | Secondary => "btn-secondary"
    | Danger => "btn-danger"
    }
  }

  let getSizeClass = size => {
    switch size {
    | Small => "btn-sm"
    | Medium => "btn-md"
    | Large => "btn-lg"
    }
  }
}

@react.component
let make = (~variant=Types.Primary, ~size=Types.Medium, ~disabled=false, ~onClick, ~children) => {
  let className = [
    "btn",
    Styles.getVariantClass(variant),
    Styles.getSizeClass(size),
    disabled ? "disabled" : "",
  ]->Array.join(" ")

  <button className disabled onClick={_ => onClick()}>
    {children}
  </button>
}
```

## Module Organization Best Practices

### 1. Logical Grouping

```rescript
// Group related functionality together
module UserManagement = {
  module Types = {
    // User-related types
  }

  module Validation = {
    // User validation functions
  }

  module API = {
    // User API calls
  }

  module Utils = {
    // User utility functions
  }
}
```

### 2. Clear Naming Conventions

```rescript
// Use descriptive module names
module PaymentProcessing = {
  // Payment-specific logic
}

module ConnectorConfiguration = {
  // Connector setup logic
}

module AnalyticsReporting = {
  // Analytics and reporting logic
}
```

### 3. Interface Segregation

```rescript
// File: DatabaseConnection.resi
// Only expose what's necessary
type connection
type query
type result

let connect: string => connection
let execute: (connection, query) => result
let close: connection => unit

// Don't expose internal implementation details
```

## Module Import Patterns

### Selective Imports

```rescript
// Import only what you need
open Belt.Array
open Belt.Option

// Or use module aliases
module A = Belt.Array
module O = Belt.Option
```

### Avoiding Global Opens

```rescript
// Instead of opening globally
// open SomeModule

// Use local opens or qualified access
let result = {
  open SomeModule
  processData(data)
}

// Or
let result = SomeModule.processData(data)
```

### Standard Library Patterns

```rescript
// Common standard library usage patterns
open Belt

let processUsers = users => {
  users
  ->Array.map(user => {...user, name: String.trim(user.name)})
  ->Array.filter(user => String.length(user.name) > 0)
  ->Array.sort((a, b) => String.compare(a.name, b.name))
}
```

## File Organization in Hyperswitch

### Directory Structure

```
src/
├── components/
│   ├── Button/
│   │   ├── Button.res
│   │   ├── Button.resi
│   │   └── ButtonTypes.res
│   └── Modal/
│       ├── Modal.res
│       └── ModalTypes.res
├── utils/
│   ├── APIUtils.res
│   ├── DateUtils.res
│   └── ValidationUtils.res
├── types/
│   ├── CommonTypes.res
│   └── APITypes.res
└── screens/
    ├── Dashboard/
    │   ├── Dashboard.res
    │   └── DashboardTypes.res
    └── Settings/
        ├── Settings.res
        └── SettingsTypes.res
```

### Module Dependencies

```rescript
// Lower-level modules (no dependencies)
// CommonTypes.res
type user = {id: string, name: string}

// Mid-level modules (depend on types)
// UserUtils.res
open CommonTypes
let formatUser = user => `${user.name} (${user.id})`

// Higher-level modules (depend on utils and types)
// UserComponent.res
open CommonTypes
@react.component
let make = (~user: user) => {
  <div> {React.string(UserUtils.formatUser(user))} </div>
}
```

## Best Practices

1. **Use interface files** for public modules to hide implementation details
2. **Group related functionality** into nested modules
3. **Use descriptive names** for modules and their contents
4. **Avoid deep nesting** - keep module hierarchies shallow
5. **Open modules locally** rather than globally when possible
6. **Create module aliases** for frequently used long module names
7. **Organize files logically** by feature or functionality
8. **Keep dependencies clear** - avoid circular dependencies
9. **Use consistent naming** across similar modules
10. **Document module purposes** in interface files or comments
