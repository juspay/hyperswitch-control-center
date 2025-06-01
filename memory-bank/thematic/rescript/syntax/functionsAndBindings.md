# Functions and Let Bindings in ReScript (Hyperswitch Control Center)

This document covers function definitions (including labeled and optional arguments, recursion), `let` bindings, and the pipe operator (`->`).

## Let Bindings

### Basic Let Bindings

```rescript
// Immutable bindings
let name = "John Doe"
let age = 30
let isActive = true

// Type annotations (optional but helpful)
let userId: string = "user_123"
let count: int = 42
let price: float = 99.99
```

### Mutable Bindings

```rescript
// Mutable references
let counter = ref(0)
counter := counter.contents + 1

// Mutable record fields
type user = {
  name: string,
  mutable age: int,
  mutable isActive: bool,
}

let user = {name: "John", age: 30, isActive: true}
user.age = 31
user.isActive = false
```

### Destructuring in Let Bindings

```rescript
// Tuple destructuring
let coordinates = (10, 20)
let (x, y) = coordinates

// Record destructuring
type user = {name: string, age: int, email: string}
let user = {name: "John", age: 30, email: "john@example.com"}
let {name, age} = user
let {name: userName, email: userEmail} = user // with renaming

// Array destructuring
let numbers = [1, 2, 3, 4, 5]
let [first, second, ...rest] = numbers
```

### Pattern Matching in Let Bindings

```rescript
// Option destructuring
let userEmail: option<string> = Some("user@example.com")
let emailDisplay = switch userEmail {
| Some(email) => email
| None => "No email"
}

// Variant destructuring
type result<'a, 'b> = Ok('a) | Error('b)
let apiResult: result<string, string> = Ok("Success")
let message = switch apiResult {
| Ok(data) => `Success: ${data}`
| Error(err) => `Error: ${err}`
}
```

## Function Definitions

### Basic Functions

```rescript
// Simple function
let add = (a, b) => a + b

// Function with explicit types
let multiply = (a: int, b: int): int => a * b

// Multi-line function
let processUser = user => {
  let formattedName = user.name->String.trim->String.toUpperCase
  let isValid = user.age >= 18
  (formattedName, isValid)
}
```

### Function with Multiple Parameters

```rescript
// Multiple parameters
let createUser = (name, age, email) => {
  {
    id: Js.Math.random()->Float.toString,
    name: name,
    age: age,
    email: email,
    createdAt: Date.now(),
  }
}

// Curried function (automatic in ReScript)
let addThreeNumbers = (a, b, c) => a + b + c
let addFive = addThreeNumbers(2, 3) // Partial application
let result = addFive(4) // result = 9
```

### Labeled Arguments

```rescript
// Labeled arguments for clarity
let createPayment = (~amount, ~currency, ~description) => {
  {
    id: Js.Math.random()->Float.toString,
    amount: amount,
    currency: currency,
    description: description,
    status: "pending",
  }
}

// Usage with labeled arguments (order doesn't matter)
let payment = createPayment(
  ~currency="USD",
  ~amount=100.0,
  ~description="Test payment"
)
```

### Optional Arguments

```rescript
// Optional arguments with default values
let createUser = (~name, ~age, ~email=?, ~isActive=true, ()) => {
  {
    name: name,
    age: age,
    email: email,
    isActive: isActive,
    id: Js.Math.random()->Float.toString,
  }
}

// Usage
let user1 = createUser(~name="John", ~age=30, ())
let user2 = createUser(~name="Jane", ~age=25, ~email="jane@example.com", ())
let user3 = createUser(~name="Bob", ~age=35, ~isActive=false, ())
```

### Functions with Pattern Matching

```rescript
// Pattern matching in function parameters
let getStatusMessage = status => {
  switch status {
  | "pending" => "Processing..."
  | "completed" => "Done!"
  | "failed" => "Error occurred"
  | _ => "Unknown status"
  }
}

// Pattern matching with variants
type userRole = Admin | User | Guest

let getPermissions = role => {
  switch role {
  | Admin => ["read", "write", "delete", "admin"]
  | User => ["read", "write"]
  | Guest => ["read"]
  }
}
```

## Recursive Functions

### Basic Recursion

```rescript
// Simple recursive function
let rec factorial = n => {
  switch n {
  | 0 | 1 => 1
  | n => n * factorial(n - 1)
  }
}

// Tail-recursive version (more efficient)
let factorialTailRec = n => {
  let rec loop = (acc, n) => {
    switch n {
    | 0 | 1 => acc
    | n => loop(acc * n, n - 1)
    }
  }
  loop(1, n)
}
```

### List Processing with Recursion

```rescript
// Recursive list processing
let rec sumList = lst => {
  switch lst {
  | list{} => 0
  | list{head, ...tail} => head + sumList(tail)
  }
}

let rec mapList = (lst, fn) => {
  switch lst {
  | list{} => list{}
  | list{head, ...tail} => list{fn(head), ...mapList(tail, fn)}
  }
}

let rec filterList = (lst, predicate) => {
  switch lst {
  | list{} => list{}
  | list{head, ...tail} => 
    if predicate(head) {
      list{head, ...filterList(tail, predicate)}
    } else {
      filterList(tail, predicate)
    }
  }
}
```

### Mutual Recursion

```rescript
// Mutually recursive functions
let rec isEven = n => {
  switch n {
  | 0 => true
  | n => isOdd(n - 1)
  }
}
and isOdd = n => {
  switch n {
  | 0 => false
  | n => isEven(n - 1)
  }
}
```

## Higher-Order Functions

### Functions as Parameters

```rescript
// Function that takes another function as parameter
let applyTwice = (fn, value) => fn(fn(value))

let double = x => x * 2
let result = applyTwice(double, 5) // 20

// Array processing with higher-order functions
let processNumbers = (numbers, operation) => {
  numbers->Belt.Array.map(operation)
}

let squared = processNumbers([1, 2, 3, 4], x => x * x)
```

### Functions Returning Functions

```rescript
// Function that returns a function
let makeAdder = increment => {
  value => value + increment
}

let addFive = makeAdder(5)
let result = addFive(10) // 15

// Configurable validation function
let makeValidator = (minLength, maxLength) => {
  value => {
    let len = String.length(value)
    len >= minLength && len <= maxLength
  }
}

let validatePassword = makeValidator(8, 50)
let isValid = validatePassword("mypassword123")
```

### Partial Application

```rescript
// Partial application examples
let createApiUrl = (baseUrl, version, endpoint) => {
  `${baseUrl}/api/${version}/${endpoint}`
}

// Partially apply base URL and version
let createV1Url = createApiUrl("https://api.example.com", "v1")
let usersUrl = createV1Url("users")
let paymentsUrl = createV1Url("payments")

// Practical example with API calls
let makeApiCall = (method, headers, url, body) => {
  // API call implementation
}

let makeGetCall = makeApiCall("GET", [])
let makePostCall = makeApiCall("POST", [("Content-Type", "application/json")])
```

## Pipe Operator

### Basic Pipe Usage

```rescript
// Without pipe operator
let result = String.toUpperCase(String.trim("  hello world  "))

// With pipe operator (more readable)
let result = "  hello world  "->String.trim->String.toUpperCase

// Complex data transformation
let processUserData = userData => {
  userData
  ->Belt.Array.filter(user => user.isActive)
  ->Belt.Array.map(user => {...user, name: String.trim(user.name)})
  ->Belt.Array.sort((a, b) => String.compare(a.name, b.name))
}
```

### Pipe with Function Calls

```rescript
// Pipe with function calls
let calculateTotal = items => {
  items
  ->Belt.Array.map(item => item.price * item.quantity)
  ->Belt.Array.reduce(0.0, (acc, price) => acc +. price)
  ->Float.toFixed(~digits=2)
}

// API data processing pipeline
let processApiResponse = response => {
  response
  ->Js.Json.parseExn
  ->getDataField
  ->Belt.Array.map(parseUser)
  ->Belt.Array.filter(user => user.age >= 18)
  ->Belt.Array.sort((a, b) => String.compare(a.name, b.name))
}
```

### Pipe with Optional Chaining

```rescript
// Pipe with option handling
let getUserEmail = user => {
  user.email
  ->Belt.Option.map(String.trim)
  ->Belt.Option.map(String.toLowerCase)
  ->Belt.Option.getOr("no-email@example.com")
}

// Complex option chaining
let getNestedValue = data => {
  data.user
  ->Belt.Option.flatMap(user => user.profile)
  ->Belt.Option.flatMap(profile => profile.settings)
  ->Belt.Option.map(settings => settings.theme)
  ->Belt.Option.getOr("default")
}
```

## Async Functions

### Basic Async Functions

```rescript
// Async function definition
let fetchUserData = async userId => {
  try {
    let response = await fetch(`/api/users/${userId}`)
    let json = await response->Fetch.Response.json
    Ok(json)
  } catch {
  | Exn.Error(e) => Error(Exn.message(e)->Belt.Option.getOr("Unknown error"))
  }
}

// Using async functions
let loadUser = async () => {
  switch await fetchUserData("123") {
  | Ok(userData) => Js.log("User loaded successfully")
  | Error(message) => Js.log(`Failed to load user: ${message}`)
  }
}
```

### Async with Pipe Operator

```rescript
// Async data processing pipeline
let processUserAsync = async userId => {
  let result = await userId
    ->fetchUserData
    ->Promise.then(result => {
      switch result {
      | Ok(data) => data->parseUserData->Promise.resolve
      | Error(e) => Promise.reject(Exn.raiseError(e))
      }
    })
    ->Promise.then(userData => {
      userData->validateUserData->Promise.resolve
    })
  
  result
}
```

## Function Composition

### Composing Functions

```rescript
// Function composition utility
let compose = (f, g) => x => f(g(x))

// Example functions
let addOne = x => x + 1
let double = x => x * 2
let square = x => x * x

// Compose functions
let addOneThenDouble = compose(double, addOne)
let result = addOneThenDouble(5) // (5 + 1) * 2 = 12

// Multiple composition
let complexTransform = x => x->addOne->double->square
let result2 = complexTransform(3) // ((3 + 1) * 2)^2 = 64
```

### Practical Function Composition

```rescript
// Data validation pipeline
let validateEmail = email => {
  email->String.trim->String.toLowerCase
}

let validatePassword = password => {
  let trimmed = password->String.trim
  if String.length(trimmed) >= 8 {
    Ok(trimmed)
  } else {
    Error("Password too short")
  }
}

let validateUser = userData => {
  let email = validateEmail(userData.email)
  switch validatePassword(userData.password) {
  | Ok(password) => Ok({...userData, email, password})
  | Error(e) => Error(e)
  }
}
```

## Common Patterns in Hyperswitch

### API Call Functions

```rescript
// Generic API call function
let makeApiCall = async (~method, ~url, ~body=?, ~headers=[], ()) => {
  try {
    let response = await fetch(url, {
      method: method,
      headers: headers->Belt.Array.concat([("Content-Type", "application/json")]),
      body: body,
    })
    
    if response->Fetch.Response.ok {
      let json = await response->Fetch.Response.json
      Ok(json)
    } else {
      let errorText = await response->Fetch.Response.text
      Error(`HTTP ${response->Fetch.Response.status->Int.toString}: ${errorText}`)
    }
  } catch {
  | Exn.Error(e) => Error(Exn.message(e)->Belt.Option.getOr("Network error"))
  }
}

// Specialized API functions
let getPayments = async () => {
  await makeApiCall(~method="GET", ~url="/api/v1/payments", ())
}

let createPayment = async paymentData => {
  await makeApiCall(
    ~method="POST",
    ~url="/api/v1/payments",
    ~body=paymentData->Js.Json.stringify,
    ()
  )
}
```

### Data Transformation Functions

```rescript
// Data transformation pipeline
let transformPaymentData = rawData => {
  rawData
  ->Belt.Array.map(parsePaymentJson)
  ->Belt.Array.filter(payment => payment.amount > 0.0)
  ->Belt.Array.map(payment => {
    ...payment,
    formattedAmount: `${payment.currency} ${Float.toString(payment.amount)}`,
    isLarge: payment.amount > 1000.0,
  })
  ->Belt.Array.sort((a, b) => Float.compare(b.amount, a.amount))
}

// Form validation functions
let validateRequired = (fieldName, value) => {
  if String.length(String.trim(value)) > 0 {
    Ok(value)
  } else {
    Error(`${fieldName} is required`)
  }
}

let validateEmail = email => {
  if String.includes(email, "@") {
    Ok(email)
  } else {
    Error("Invalid email format")
  }
}

let validateForm = formData => {
  let nameResult = validateRequired("Name", formData.name)
  let emailResult = formData.email->validateRequired("Email")->Belt.Result.flatMap(validateEmail)
  
  switch (nameResult, emailResult) {
  | (Ok(name), Ok(email)) => Ok({...formData, name, email})
  | (Error(e), _) => Error(e)
  | (_, Error(e)) => Error(e)
  }
}
```

### Event Handler Functions

```rescript
// Event handler with state updates
let createEventHandler = (setState, transform) => {
  event => {
    let value = ReactEvent.Form.target(event)["value"]
    setState(prevState => transform(prevState, value))
  }
}

// Usage in components
let handleNameChange = createEventHandler(setFormData, (prev, value) => {
  {...prev, name: value}
})

let handleEmailChange = createEventHandler(setFormData, (prev, value) => {
  {...prev, email: value}
})
```

## Best Practices

1. **Use descriptive function names** that clearly indicate what the function does
2. **Prefer labeled arguments** for functions with multiple parameters
3. **Use optional arguments** with sensible defaults when appropriate
4. **Leverage the pipe operator** for data transformation pipelines
5. **Keep functions small and focused** on a single responsibility
6. **Use pattern matching** instead of nested if-else statements
7. **Prefer immutable data** and pure functions when possible
8. **Use partial application** to create specialized versions of generic functions
9. **Handle errors explicitly** with Result types or try-catch blocks
10. **Document complex functions** with comments explaining their purpose and usage
11. **Use tail recursion** for recursive functions that might process large datasets
12. **Compose functions** to build complex operations from simple building blocks
