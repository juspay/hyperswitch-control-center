# Types and Data Structures in ReScript (Hyperswitch Control Center)

This document explains the definition and usage of ReScript types (records, variants, aliases) and common data structures (`option`, `array`, `list`, `Js.Dict`, `Belt` collections).

## Basic Types

### Primitive Types

```rescript
// Basic primitive types
let name: string = "John"
let age: int = 25
let height: float = 5.9
let isActive: bool = true
let nothing: unit = ()
```

### Type Aliases

```rescript
// Create aliases for existing types
type userId = string
type timestamp = float
type count = int

let user: userId = "user_123"
let createdAt: timestamp = Date.now()
let itemCount: count = 42
```

## Records

### Basic Record Definition

```rescript
type user = {
  id: string,
  name: string,
  email: string,
  age: int,
  isActive: bool,
}

// Creating a record
let john: user = {
  id: "123",
  name: "John Doe",
  email: "john@example.com",
  age: 30,
  isActive: true,
}
```

### Record with Optional Fields

```rescript
type userProfile = {
  id: string,
  name: string,
  email: string,
  avatar: option<string>,
  bio: option<string>,
  lastLogin: option<float>,
}

let profile: userProfile = {
  id: "123",
  name: "John",
  email: "john@example.com",
  avatar: Some("avatar.jpg"),
  bio: None,
  lastLogin: Some(Date.now()),
}
```

### Record Updates (Immutable)

```rescript
// Update records immutably
let updatedUser = {...john, age: 31, isActive: false}

// Functional update
let updateUserAge = (user, newAge) => {...user, age: newAge}
let olderJohn = updateUserAge(john, 35)
```

### Nested Records

```rescript
type address = {
  street: string,
  city: string,
  country: string,
  zipCode: string,
}

type userWithAddress = {
  id: string,
  name: string,
  email: string,
  address: address,
}

let userAddress: address = {
  street: "123 Main St",
  city: "New York",
  country: "USA",
  zipCode: "10001",
}

let userWithAddr: userWithAddress = {
  id: "123",
  name: "John",
  email: "john@example.com",
  address: userAddress,
}
```

## Variants (Union Types)

### Basic Variants

```rescript
type status = Loading | Success | Error

type paymentStatus =
  | Pending
  | Processing
  | Completed
  | Failed
  | Cancelled

let currentStatus: status = Loading
let payment: paymentStatus = Completed
```

### Variants with Data

```rescript
type result<'success, 'error> =
  | Ok('success)
  | Error('error)

type apiResponse =
  | Loading
  | Success(string)
  | Error(string)
  | NetworkError(int, string)

let response: apiResponse = Success("Data loaded successfully")
let errorResponse: apiResponse = NetworkError(500, "Internal Server Error")
```

### Complex Variants

```rescript
type userAction =
  | Login(string, string) // email, password
  | Logout
  | UpdateProfile(string, option<string>) // name, avatar
  | ChangePassword(string, string) // old, new
  | DeleteAccount(string) // confirmation

let action: userAction = Login("user@example.com", "password123")
let updateAction: userAction = UpdateProfile("New Name", Some("new-avatar.jpg"))
```

### Polymorphic Variants

```rescript
// Polymorphic variants (open variants)
type color = [#red | #green | #blue | #yellow]
type primaryColor = [#red | #green | #blue]

let userColor: color = #red
let brandColor: primaryColor = #blue

// Can be extended
type extendedColor = [color | #purple | #orange]
let newColor: extendedColor = #purple
```

## Option Type

### Basic Option Usage

```rescript
// Option represents a value that might not exist
type user = {
  id: string,
  name: string,
  email: option<string>, // might not have email
}

let userWithEmail: user = {
  id: "123",
  name: "John",
  email: Some("john@example.com"),
}

let userWithoutEmail: user = {
  id: "456",
  name: "Jane",
  email: None,
}
```

### Working with Options

```rescript
// Pattern matching on options
let getEmailDisplay = user => {
  switch user.email {
  | Some(email) => email
  | None => "No email provided"
  }
}

// Using Belt.Option utilities
open Belt.Option

let emailLength = user.email->map(String.length)->getOr(0)
let hasEmail = user.email->isSome
let emailOrDefault = user.email->getOr("default@example.com")
```

### Chaining Options

```rescript
type address = {
  street: option<string>,
  city: option<string>,
  country: option<string>,
}

type user = {
  id: string,
  name: string,
  address: option<address>,
}

// Chain option operations
let getCountry = user => {
  user.address
  ->Belt.Option.flatMap(addr => addr.country)
  ->Belt.Option.getOr("Unknown")
}
```

## Arrays

### Basic Array Operations

```rescript
// Array creation and basic operations
let numbers = [1, 2, 3, 4, 5]
let names = ["Alice", "Bob", "Charlie"]
let empty: array<string> = []

// Array access
let firstNumber = numbers[0] // option<int>
let secondName = names[1]   // option<string>
```

### Array Processing with Belt

```rescript
open Belt.Array

let numbers = [1, 2, 3, 4, 5]

// Map, filter, reduce
let doubled = numbers->map(x => x * 2)
let evens = numbers->filter(x => x mod 2 == 0)
let sum = numbers->reduce(0, (acc, x) => acc + x)

// Find operations
let found = numbers->getBy(x => x > 3) // option<int>
let index = numbers->getIndexBy(x => x == 3) // option<int>

// Array utilities
let length = numbers->length
let isEmpty = numbers->length == 0
let contains = numbers->some(x => x == 3)
```

### Array Transformation Patterns

```rescript
type user = {id: string, name: string, age: int}

let users = [
  {id: "1", name: "Alice", age: 25},
  {id: "2", name: "Bob", age: 30},
  {id: "3", name: "Charlie", age: 35},
]

// Complex transformations
let adultNames = users
  ->Belt.Array.filter(user => user.age >= 18)
  ->Belt.Array.map(user => user.name)
  ->Belt.Array.sort(String.compare)

// Group by age ranges
let groupByAgeRange = users => {
  let young = users->Belt.Array.filter(u => u.age < 30)
  let old = users->Belt.Array.filter(u => u.age >= 30)
  (young, old)
}
```

## Lists

### Basic List Operations

```rescript
// Lists are immutable linked lists
let numbers = list{1, 2, 3, 4, 5}
let names = list{"Alice", "Bob", "Charlie"}
let empty = list{}

// List construction
let newList = list{0, ...numbers} // prepend
```

### List Processing

```rescript
open Belt.List

let numbers = list{1, 2, 3, 4, 5}

// Map, filter, reduce
let doubled = numbers->map(x => x * 2)
let evens = numbers->filter(x => x mod 2 == 0)
let sum = numbers->reduce(0, (acc, x) => acc + x)

// List utilities
let length = numbers->length
let head = numbers->head // option<int>
let tail = numbers->tail // option<list<int>>
```

### List vs Array Choice

```rescript
// Use arrays for:
// - Random access
// - Frequent updates
// - Interop with JavaScript

// Use lists for:
// - Functional programming patterns
// - Prepending operations
// - Recursive algorithms

let processRecursively = lst => {
  switch lst {
  | list{} => 0
  | list{head, ...tail} => head + processRecursively(tail)
  }
}
```

## Dictionaries and Maps

### Js.Dict (JavaScript Objects)

```rescript
// JavaScript-style dictionaries
let userPrefs: Js.Dict.t<string> = Js.Dict.empty()

// Set values
userPrefs->Js.Dict.set("theme", "dark")
userPrefs->Js.Dict.set("language", "en")

// Get values
let theme = userPrefs->Js.Dict.get("theme") // option<string>

// From object literal
let config = %raw(`{
  apiUrl: "https://api.example.com",
  timeout: "5000",
  retries: "3"
}`)
```

### Belt.Map (Immutable Maps)

```rescript
// String-keyed maps
module StringMap = Belt.Map.String

let userAges = StringMap.empty
  ->StringMap.set("alice", 25)
  ->StringMap.set("bob", 30)
  ->StringMap.set("charlie", 35)

// Get values
let aliceAge = userAges->StringMap.get("alice") // option<int>

// Map operations
let hasUser = userAges->StringMap.has("alice")
let userCount = userAges->StringMap.size
let allUsers = userAges->StringMap.keysToArray
```

### Belt.HashMap (Mutable Maps)

```rescript
// Mutable hash maps for performance
module IntHash = Belt.HashMap.Int

let cache = IntHash.make(~hintSize=10)

// Set and get
cache->IntHash.set(1, "first")
cache->IntHash.set(2, "second")

let value = cache->IntHash.get(1) // option<string>
```

## Advanced Type Patterns

### Generic Types

```rescript
// Generic record types
type response<'data> = {
  data: 'data,
  status: int,
  message: string,
}

type apiResult<'success, 'error> =
  | Loading
  | Success('success)
  | Error('error)

// Usage
let userResponse: response<array<user>> = {
  data: [john],
  status: 200,
  message: "Success",
}

let result: apiResult<string, string> = Success("Data loaded")
```

### Recursive Types

```rescript
// Tree structures
type tree<'a> =
  | Leaf('a)
  | Node(tree<'a>, tree<'a>)

let numberTree = Node(
  Leaf(1),
  Node(Leaf(2), Leaf(3))
)

// JSON-like structures
type json =
  | String(string)
  | Number(float)
  | Boolean(bool)
  | Null
  | Array(array<json>)
  | Object(Js.Dict.t<json>)
```

### Phantom Types

```rescript
// Phantom types for type safety
type validated<'a>
type unvalidated<'a>

type email<'validation> = string

let validateEmail = (email: email<unvalidated>): option<email<validated>> => {
  if email->String.includes("@") {
    Some(email->Obj.magic) // Safe cast after validation
  } else {
    None
  }
}

// Usage
let rawEmail: email<unvalidated> = "user@example.com"
let validEmail = validateEmail(rawEmail)
```

## Common Patterns in Hyperswitch

### API Response Types

```rescript
type apiError = {
  code: string,
  message: string,
  details: option<Js.Dict.t<string>>,
}

type apiResponse<'data> =
  | Loading
  | Success('data)
  | Error(apiError)
  | NetworkError(string)

type paginatedResponse<'item> = {
  data: array<'item>,
  total: int,
  page: int,
  pageSize: int,
  hasMore: bool,
}
```

### Form State Types

```rescript
type fieldError = {
  field: string,
  message: string,
}

type formState<'data> = {
  data: 'data,
  errors: array<fieldError>,
  isSubmitting: bool,
  isDirty: bool,
  isValid: bool,
}

type validationResult<'data> =
  | Valid('data)
  | Invalid(array<fieldError>)
```

### Entity Types

```rescript
type payment = {
  id: string,
  amount: float,
  currency: string,
  status: paymentStatus,
  createdAt: float,
  updatedAt: float,
  metadata: option<Js.Dict.t<string>>,
}

type connector = {
  id: string,
  name: string,
  connectorType: string,
  isEnabled: bool,
  configuration: Js.Dict.t<string>,
  supportedPaymentMethods: array<string>,
}
```

## Type Conversion and Interop

### JSON Conversion

```rescript
// Manual JSON conversion
let userToJson = user => {
  open Js.Json
  object_(Js.Dict.fromArray([
    ("id", string(user.id)),
    ("name", string(user.name)),
    ("age", number(Int.toFloat(user.age))),
  ]))
}

let userFromJson = json => {
  open Js.Json
  switch classify(json) {
  | JSONObject(obj) => {
      let id = obj->Js.Dict.get("id")->Belt.Option.flatMap(decodeString)
      let name = obj->Js.Dict.get("name")->Belt.Option.flatMap(decodeString)
      let age = obj->Js.Dict.get("age")->Belt.Option.flatMap(decodeNumber)

      switch (id, name, age) {
      | (Some(id), Some(name), Some(age)) => Some({
          id: id,
          name: name,
          age: Float.toInt(age),
        })
      | _ => None
      }
    }
  | _ => None
  }
}
```

### External Type Bindings

```rescript
// Binding to JavaScript types
type element
type document

@val external document: document = "document"
@send external getElementById: (document, string) => option<element> = "getElementById"
@send external addEventListener: (element, string, unit => unit) => unit = "addEventListener"

// Usage
switch document->getElementById("myButton") {
| Some(button) => button->addEventListener("click", () => Js.log("Clicked!"))
| None => ()
}
```

## Best Practices

1. **Use descriptive type names** that clearly indicate their purpose
2. **Prefer records over tuples** for structured data with multiple fields
3. **Use variants for state machines** and discriminated unions
4. **Leverage option types** instead of nullable values
5. **Use generic types** to create reusable data structures
6. **Keep types close to usage** - define types near where they're used
7. **Use phantom types** for additional type safety when needed
8. **Prefer immutable data structures** unless performance requires mutation
9. **Use Belt collections** for functional programming patterns
10. **Document complex types** with comments explaining their purpose and usage
