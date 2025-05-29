# Common Standard Library Usage (Belt/Js) in ReScript (Hyperswitch Control Center)

This document provides examples of frequently used utility functions from the `Belt` and `Js` standard library modules.

## Belt.Array

### Basic Array Operations

```rescript
open Belt.Array

let numbers = [1, 2, 3, 4, 5]
let names = ["Alice", "Bob", "Charlie", "David"]

// Length and basic checks
let count = numbers->length // 5
let isEmpty = []->length == 0 // true
let hasItems = numbers->length > 0 // true

// Access elements
let first = numbers->get(0) // Some(1)
let last = numbers->get(length(numbers) - 1) // Some(5)
let outOfBounds = numbers->get(10) // None

// Safe access with default
let firstOrZero = numbers->get(0)->Option.getOr(0)
```

### Array Transformation

```rescript
open Belt.Array

let numbers = [1, 2, 3, 4, 5]

// Map - transform each element
let doubled = numbers->map(x => x * 2) // [2, 4, 6, 8, 10]
let strings = numbers->map(Int.toString) // ["1", "2", "3", "4", "5"]

// Filter - keep elements that match condition
let evens = numbers->filter(x => x mod 2 == 0) // [2, 4]
let positives = numbers->filter(x => x > 0) // [1, 2, 3, 4, 5]

// Reduce - combine elements into single value
let sum = numbers->reduce(0, (acc, x) => acc + x) // 15
let product = numbers->reduce(1, (acc, x) => acc * x) // 120

// Map with index
let withIndex = numbers->mapWithIndex((x, i) => (i, x))
// [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5)]
```

### Array Search and Find

```rescript
open Belt.Array

let users = [
  {id: "1", name: "Alice", age: 25},
  {id: "2", name: "Bob", age: 30},
  {id: "3", name: "Charlie", age: 35},
]

// Find first element matching condition
let youngUser = users->getBy(user => user.age < 30) // Some({id: "1", name: "Alice", age: 25})
let oldUser = users->getBy(user => user.age > 40) // None

// Find index of element
let bobIndex = users->getIndexBy(user => user.name == "Bob") // Some(1)

// Check if any element matches
let hasYoungUsers = users->some(user => user.age < 30) // true
let hasOldUsers = users->some(user => user.age > 40) // false

// Check if all elements match
let allAdults = users->every(user => user.age >= 18) // true
let allYoung = users->every(user => user.age < 30) // false
```

### Array Manipulation

```rescript
open Belt.Array

let numbers = [1, 2, 3]
let moreNumbers = [4, 5, 6]

// Concatenate arrays
let combined = concat(numbers, moreNumbers) // [1, 2, 3, 4, 5, 6]
let flattened = concatMany([[1, 2], [3, 4], [5, 6]]) // [1, 2, 3, 4, 5, 6]

// Slice array
let middle = numbers->slice(~offset=1, ~len=2) // [2, 3]
let fromIndex = numbers->sliceToEnd(1) // [2, 3]

// Reverse array
let reversed = numbers->reverse // [3, 2, 1]

// Sort array
let unsorted = [3, 1, 4, 1, 5, 9]
let sorted = unsorted->sort((a, b) => a - b) // [1, 1, 3, 4, 5, 9]

// Sort with custom comparison
let usersByAge = users->sort((a, b) => a.age - b.age)
let usersByName = users->sort((a, b) => String.compare(a.name, b.name))
```

### Advanced Array Operations

```rescript
open Belt.Array

// Zip arrays together
let names = ["Alice", "Bob", "Charlie"]
let ages = [25, 30, 35]
let zipped = zip(names, ages) // [("Alice", 25), ("Bob", 30), ("Charlie", 35)]

// Unzip array of tuples
let (extractedNames, extractedAges) = unzip(zipped)

// Keep elements with their indices
let withIndices = numbers->keepWithIndex((x, i) => i mod 2 == 0)

// Partition array based on condition
let (evens, odds) = numbers->partition(x => x mod 2 == 0)

// Group consecutive elements
let grouped = [1, 1, 2, 2, 2, 3, 1]->groupBy((a, b) => a == b)
```

## Belt.Option

### Basic Option Operations

```rescript
open Belt.Option

let someValue: option<string> = Some("hello")
let noneValue: option<string> = None

// Check if option has value
let hasSome = someValue->isSome // true
let hasNone = noneValue->isNone // true

// Get value with default
let value = someValue->getOr("default") // "hello"
let defaultValue = noneValue->getOr("default") // "default"

// Get value unsafely (throws if None)
let unsafeValue = someValue->getExn // "hello" (use carefully!)
```

### Option Transformation

```rescript
open Belt.Option

let maybeNumber: option<int> = Some(42)

// Map - transform value if present
let doubled = maybeNumber->map(x => x * 2) // Some(84)
let noneDoubled = None->map(x => x * 2) // None

// FlatMap - chain optional operations
let maybeString = maybeNumber->flatMap(x => 
  if x > 0 {
    Some(Int.toString(x))
  } else {
    None
  }
) // Some("42")

// Filter - keep value only if condition is met
let evenNumber = maybeNumber->filter(x => x mod 2 == 0) // Some(42)
let oddNumber = maybeNumber->filter(x => x mod 2 == 1) // None
```

### Option Utilities

```rescript
open Belt.Option

// Convert between option and nullable
let nullable = Js.Nullable.return("value")
let option = nullable->Js.Nullable.toOption // Some("value")
let backToNullable = option->Js.Nullable.fromOption

// Option with side effects
let loggedValue = someValue->tap(value => Js.log(`Got value: ${value}`))

// Combine multiple options
let combineOptions = (opt1, opt2) => {
  switch (opt1, opt2) {
  | (Some(a), Some(b)) => Some((a, b))
  | _ => None
  }
}

// Alternative using flatMap
let combined = opt1->flatMap(a => opt2->map(b => (a, b)))
```

## Belt.Result

### Basic Result Operations

```rescript
open Belt.Result

type apiError = string
type userData = {name: string, age: int}

let successResult: result<userData, apiError> = Ok({name: "Alice", age: 25})
let errorResult: result<userData, apiError> = Error("User not found")

// Check result type
let isSuccess = successResult->isOk // true
let isError = errorResult->isError // true

// Get value with default
let user = successResult->getOr({name: "Unknown", age: 0})
let errorMsg = errorResult->getError->Option.getOr("Unknown error")
```

### Result Transformation

```rescript
open Belt.Result

// Map success value
let upperCaseName = successResult->map(user => {
  ...user,
  name: String.toUpperCase(user.name)
})

// Map error value
let detailedError = errorResult->mapError(err => `API Error: ${err}`)

// FlatMap for chaining operations
let validateAge = user => {
  if user.age >= 18 {
    Ok(user)
  } else {
    Error("User must be 18 or older")
  }
}

let validatedUser = successResult->flatMap(validateAge)

// Convert result to option
let maybeUser = successResult->toOption // Some({name: "Alice", age: 25})
let maybeError = errorResult->toOption // None
```

## Belt.List

### Basic List Operations

```rescript
open Belt.List

let numbers = list{1, 2, 3, 4, 5}
let empty = list{}

// Length and basic checks
let count = numbers->length // 5
let isEmpty = empty->length == 0 // true

// Head and tail
let first = numbers->head // Some(1)
let rest = numbers->tail // Some(list{2, 3, 4, 5})

// Add to front (cons)
let withZero = list{0, ...numbers} // list{0, 1, 2, 3, 4, 5}
```

### List Transformation

```rescript
open Belt.List

let numbers = list{1, 2, 3, 4, 5}

// Map, filter, reduce (similar to Array)
let doubled = numbers->map(x => x * 2)
let evens = numbers->filter(x => x mod 2 == 0)
let sum = numbers->reduce(0, (acc, x) => acc + x)

// Reverse list
let reversed = numbers->reverse

// Take and drop elements
let firstThree = numbers->take(3) // list{1, 2, 3}
let afterTwo = numbers->drop(2) // list{3, 4, 5}

// Convert to/from array
let asArray = numbers->toArray // [1, 2, 3, 4, 5]
let backToList = asArray->fromArray // list{1, 2, 3, 4, 5}
```

## Belt.Map

### String Maps

```rescript
module StringMap = Belt.Map.String

// Create and populate map
let userAges = StringMap.empty
  ->StringMap.set("alice", 25)
  ->StringMap.set("bob", 30)
  ->StringMap.set("charlie", 35)

// Get values
let aliceAge = userAges->StringMap.get("alice") // Some(25)
let unknownAge = userAges->StringMap.get("unknown") // None

// Check existence
let hasAlice = userAges->StringMap.has("alice") // true

// Update map
let updatedAges = userAges->StringMap.set("alice", 26)
let withoutBob = userAges->StringMap.remove("bob")

// Map operations
let size = userAges->StringMap.size // 3
let keys = userAges->StringMap.keysToArray // ["alice", "bob", "charlie"]
let values = userAges->StringMap.valuesToArray // [25, 30, 35]
```

### Int Maps

```rescript
module IntMap = Belt.Map.Int

let scoreMap = IntMap.empty
  ->IntMap.set(1, "Alice")
  ->IntMap.set(2, "Bob")
  ->IntMap.set(3, "Charlie")

// Transform map values
let upperCaseNames = scoreMap->IntMap.map(name => String.toUpperCase(name))

// Filter map
let filteredMap = scoreMap->IntMap.keep((key, _value) => key > 1)

// Reduce map
let allNames = scoreMap->IntMap.reduce("", (acc, _key, name) => `${acc} ${name}`)
```

## Belt.Set

### String Sets

```rescript
module StringSet = Belt.Set.String

// Create and populate set
let fruits = StringSet.empty
  ->StringSet.add("apple")
  ->StringSet.add("banana")
  ->StringSet.add("orange")
  ->StringSet.add("apple") // Duplicates are ignored

// Check membership
let hasApple = fruits->StringSet.has("apple") // true
let hasGrape = fruits->StringSet.has("grape") // false

// Set operations
let moreFruits = StringSet.fromArray(["grape", "kiwi", "apple"])
let union = StringSet.union(fruits, moreFruits)
let intersection = StringSet.intersect(fruits, moreFruits)
let difference = StringSet.diff(fruits, moreFruits)

// Convert to array
let fruitArray = fruits->StringSet.toArray
```

## Js.Dict

### Dictionary Operations

```rescript
// Create dictionary
let userPrefs: Js.Dict.t<string> = Js.Dict.empty()

// Set values
userPrefs->Js.Dict.set("theme", "dark")
userPrefs->Js.Dict.set("language", "en")
userPrefs->Js.Dict.set("timezone", "UTC")

// Get values
let theme = userPrefs->Js.Dict.get("theme") // Some("dark")
let unknown = userPrefs->Js.Dict.get("unknown") // None

// Get all keys and values
let keys = userPrefs->Js.Dict.keys // ["theme", "language", "timezone"]
let values = userPrefs->Js.Dict.values // ["dark", "en", "UTC"]
let entries = userPrefs->Js.Dict.entries // [("theme", "dark"), ...]

// Create from array
let fromArray = Js.Dict.fromArray([
  ("name", "John"),
  ("email", "john@example.com"),
])

// Convert to array
let toArray = userPrefs->Js.Dict.entries
```

## Js.String

### String Manipulation

```rescript
let text = "Hello, World!"

// Basic operations
let length = text->Js.String2.length // 13
let upper = text->Js.String2.toUpperCase // "HELLO, WORLD!"
let lower = text->Js.String2.toLowerCase // "hello, world!"

// Substring operations
let slice = text->Js.String2.slice(~from=0, ~to_=5) // "Hello"
let substring = text->Js.String2.substring(~from=7, ~to_=12) // "World"

// Search operations
let indexOf = text->Js.String2.indexOf("World") // 7
let includes = text->Js.String2.includes("Hello") // true
let startsWith = text->Js.String2.startsWith("Hello") // true
let endsWith = text->Js.String2.endsWith("!") // true

// Split and join
let words = text->Js.String2.split(", ") // ["Hello", "World!"]
let joined = words->Js.Array2.joinWith(" - ") // "Hello - World!"

// Trim whitespace
let padded = "  hello  "
let trimmed = padded->Js.String2.trim // "hello"
```

### String Replacement

```rescript
let text = "Hello, World! Hello, Universe!"

// Replace first occurrence
let replaced = text->Js.String2.replace("Hello", "Hi") // "Hi, World! Hello, Universe!"

// Replace all occurrences (using regex)
let replaceAll = text->Js.String2.replaceByRe(%re("/Hello/g"), "Hi")
// "Hi, World! Hi, Universe!"

// Replace with function
let withFunction = text->Js.String2.replaceByRe(%re("/\w+/g"), match => 
  String.toUpperCase(match)
)
```

## Js.Array2

### Array Methods

```rescript
let numbers = [1, 2, 3, 4, 5]

// Mutating methods (use carefully)
let _ = numbers->Js.Array2.push(6) // Adds 6 to end
let popped = numbers->Js.Array2.pop // Removes and returns last element
let shifted = numbers->Js.Array2.shift // Removes and returns first element
let _ = numbers->Js.Array2.unshift(0) // Adds 0 to beginning

// Non-mutating methods
let sliced = numbers->Js.Array2.slice(~start=1, ~end_=4) // [2, 3, 4]
let joined = numbers->Js.Array2.joinWith(", ") // "1, 2, 3, 4, 5"

// Find methods
let found = numbers->Js.Array2.find(x => x > 3) // Some(4)
let foundIndex = numbers->Js.Array2.findIndex(x => x > 3) // 3
```

## Common Patterns in Hyperswitch

### Data Processing Pipeline

```rescript
open Belt.Array

type payment = {
  id: string,
  amount: float,
  currency: string,
  status: string,
  createdAt: float,
}

let processPayments = (rawPayments: array<payment>) => {
  rawPayments
  ->filter(payment => payment.amount > 0.0)
  ->map(payment => {
    ...payment,
    formattedAmount: `${payment.currency} ${Float.toString(payment.amount)}`,
    isRecent: Date.now() -. payment.createdAt < 86400000.0, // 24 hours
  })
  ->sort((a, b) => Float.compare(b.createdAt, a.createdAt))
  ->slice(~offset=0, ~len=10) // Take first 10
}
```

### Option Chaining for Nested Data

```rescript
open Belt.Option

type address = {street: string, city: string, country: string}
type user = {name: string, address: option<address>}
type response = {user: option<user>}

let getCountry = (response: response) => {
  response.user
  ->flatMap(user => user.address)
  ->map(addr => addr.country)
  ->getOr("Unknown")
}

// Alternative with pipe
let getCountryPipe = (response: response) => {
  response.user
  ->Belt.Option.flatMap(user => user.address)
  ->Belt.Option.map(addr => addr.country)
  ->Belt.Option.getOr("Unknown")
}
```

### Result-based Error Handling

```rescript
open Belt.Result

let validateEmail = email => {
  if Js.String2.includes(email, "@") {
    Ok(email)
  } else {
    Error("Invalid email format")
  }
}

let validateAge = age => {
  if age >= 18 {
    Ok(age)
  } else {
    Error("Must be 18 or older")
  }
}

let validateUser = (email, age) => {
  validateEmail(email)
  ->flatMap(_email => validateAge(age)->map(_age => (email, age)))
}

// Usage
switch validateUser("user@example.com", 25) {
| Ok((email, age)) => Js.log(`Valid user: ${email}, age ${Int.toString(age)}`)
| Error(message) => Js.log(`Validation error: ${message}`)
}
```

### Map-based Caching

```rescript
module StringMap = Belt.Map.String

type cache<'a> = StringMap.t<'a>

let createCache = () => StringMap.empty

let getCached = (cache, key, fetchFn) => {
  switch cache->StringMap.get(key) {
  | Some(value) => (cache, value)
  | None => {
      let value = fetchFn(key)
      let updatedCache = cache->StringMap.set(key, value)
      (updatedCache, value)
    }
  }
}

// Usage
let (cache, userData) = getCached(userCache, "user123", fetchUserFromApi)
```

## Best Practices

1. **Use Belt modules** for functional programming patterns over JavaScript array methods
2. **Prefer immutable operations** over mutating array methods
3. **Chain operations with pipe operator** for readable data transformations
4. **Use Option.getOr** to provide sensible defaults for optional values
5. **Leverage Result types** for explicit error handling
6. **Use appropriate data structures** - Map for key-value pairs, Set for unique values
7. **Convert between data structures** when needed (Array ↔ List, Option ↔ Nullable)
8. **Use pattern matching** with Option and Result types for safe value extraction
9. **Combine multiple operations** using flatMap and map for complex transformations
10. **Document complex transformations** with intermediate variable names for clarity
