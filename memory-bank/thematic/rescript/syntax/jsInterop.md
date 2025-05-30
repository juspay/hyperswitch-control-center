# JavaScript Interop in ReScript (Hyperswitch Control Center)

This document describes how to interoperate with JavaScript code using `@bs.*` attributes, `external`s, and handling types like `Js.Promise` and `Js.Nullable`.

## External Bindings

### Basic External Bindings

```rescript
// Binding to global JavaScript functions
@val external alert: string => unit = "alert"
@val external confirm: string => bool = "confirm"
@val external parseInt: string => int = "parseInt"
@val external parseFloat: string => float = "parseFloat"

// Usage
alert("Hello World!")
let userConfirmed = confirm("Are you sure?")
let number = parseInt("42")
```

### Binding to Object Methods

```rescript
// Binding to console methods
@val external console: 'a = "console"
@send external log: (console, 'a) => unit = "log"
@send external error: (console, 'a) => unit = "error"
@send external warn: (console, 'a) => unit = "warn"

// Usage
console->log("Debug message")
console->error("Error occurred")

// Alternative approach
@scope("console") @val external consoleLog: 'a => unit = "log"
@scope("console") @val external consoleError: 'a => unit = "error"

consoleLog("Direct console log")
consoleError("Direct console error")
```

### Binding to DOM APIs

```rescript
// DOM element types and methods
type element
type document

@val external document: document = "document"
@send external getElementById: (document, string) => Js.Nullable.t<element> = "getElementById"
@send external querySelector: (document, string) => Js.Nullable.t<element> = "querySelector"
@send external createElement: (document, string) => element = "createElement"

@send external addEventListener: (element, string, unit => unit) => unit = "addEventListener"
@send external removeEventListener: (element, string, unit => unit) => unit = "removeEventListener"
@send external setAttribute: (element, string, string) => unit = "setAttribute"
@send external getAttribute: (element, string) => Js.Nullable.t<string> = "getAttribute"

// Usage
let button = document->getElementById("myButton")
switch button->Js.Nullable.toOption {
| Some(btn) => {
    btn->addEventListener("click", () => Js.log("Button clicked!"))
    btn->setAttribute("disabled", "true")
  }
| None => Js.log("Button not found")
}
```

### Binding to Browser APIs

```rescript
// Local Storage
@scope("localStorage") @val external setItem: (string, string) => unit = "setItem"
@scope("localStorage") @val external getItem: string => Js.Nullable.t<string> = "getItem"
@scope("localStorage") @val external removeItem: string => unit = "removeItem"
@scope("localStorage") @val external clear: unit => unit = "clear"

// Usage
setItem("user", "john_doe")
let user = getItem("user")->Js.Nullable.toOption

// Fetch API
@val external fetch: string => Js.Promise.t<'response> = "fetch"
@send external json: 'response => Js.Promise.t<'a> = "json"
@send external text: 'response => Js.Promise.t<string> = "text"

// Usage
let fetchData = async () => {
  try {
    let response = await fetch("/api/data")
    let data = await response->json
    data
  } catch {
  | Exn.Error(e) => Js.log("Fetch failed")
  }
}
```

## Working with JavaScript Objects

### Object Creation and Access

```rescript
// Creating JavaScript objects
let userObj = %raw(`{
  name: "John Doe",
  age: 30,
  email: "john@example.com"
}`)

// Accessing object properties
@get external getName: 'a => string = "name"
@get external getAge: 'a => int = "age"
@get external getEmail: 'a => string = "email"

let name = userObj->getName
let age = userObj->getAge

// Setting object properties
@set external setName: ('a, string) => unit = "name"
@set external setAge: ('a, int) => unit = "age"

userObj->setName("Jane Doe")
userObj->setAge(25)
```

### Dynamic Object Access

```rescript
// Dynamic property access
@get_index external getProperty: ('obj, string) => 'a = ""
@set_index external setProperty: ('obj, string, 'a) => unit = ""

let config = %raw(`{
  apiUrl: "https://api.example.com",
  timeout: 5000,
  retries: 3
}`)

let apiUrl = config->getProperty("apiUrl")
config->setProperty("timeout", 10000)

// Using Js.Dict for dynamic objects
let configDict: Js.Dict.t<string> = %raw(`{
  theme: "dark",
  language: "en",
  timezone: "UTC"
}`)

let theme = configDict->Js.Dict.get("theme") // option<string>
configDict->Js.Dict.set("theme", "light")
```

### Object Type Definitions

```rescript
// Defining object types for JavaScript interop
type userConfig = {
  @as("api_url") apiUrl: string,
  @as("max_retries") maxRetries: int,
  timeout: option<int>,
}

// Converting from JavaScript object
@scope("JSON") @val external parseJson: string => 'a = "parse"

let configJson = `{
  "api_url": "https://api.example.com",
  "max_retries": 3,
  "timeout": 5000
}`

let config: userConfig = parseJson(configJson)
```

## Promises and Async Operations

### Working with Js.Promise

```rescript
// Basic promise handling
let fetchUser = userId => {
  fetch(`/api/users/${userId}`)
  ->Js.Promise.then_(response => {
    response->json->Js.Promise.resolve
  }, _)
  ->Js.Promise.then_(userData => {
    Js.log("User data received")
    userData->Js.Promise.resolve
  }, _)
  ->Js.Promise.catch(error => {
    Js.log("Error fetching user")
    Js.Promise.reject(error)
  }, _)
}

// Converting to async/await
let fetchUserAsync = async userId => {
  try {
    let response = await fetch(`/api/users/${userId}`)
    let userData = await response->json
    userData
  } catch {
  | Exn.Error(e) => {
    Js.log("Error fetching user")
    Exn.raiseError("Failed to fetch user")
  }
  }
}
```

### Promise Utilities

```rescript
// Promise.all equivalent
@val external promiseAll: array<Js.Promise.t<'a>> => Js.Promise.t<array<'a>> = "Promise.all"

let fetchMultipleUsers = userIds => {
  userIds
  ->Belt.Array.map(id => fetchUser(id))
  ->promiseAll
}

// Promise.race equivalent
@val external promiseRace: array<Js.Promise.t<'a>> => Js.Promise.t<'a> = "Promise.race"

// Custom promise creation
@new external makePromise: (('a => unit, 'b => unit) => unit) => Js.Promise.t<'a> = "Promise"

let delayPromise = ms => {
  makePromise((resolve, _reject) => {
    let _ = Js.Global.setTimeout(() => resolve(), ms)
  })
}
```

## Nullable and Optional Values

### Working with Js.Nullable

```rescript
// Converting between nullable and option
let processNullableValue = (nullableStr: Js.Nullable.t<string>) => {
  switch nullableStr->Js.Nullable.toOption {
  | Some(str) => `Value: ${str}`
  | None => "No value"
  }
}

// Creating nullable values
let someValue = Js.Nullable.return("hello")
let nullValue = Js.Nullable.null

// Nullable in function parameters
@val external getElementById: string => Js.Nullable.t<element> = "document.getElementById"

let getElementText = elementId => {
  elementId
  ->getElementById
  ->Js.Nullable.toOption
  ->Belt.Option.map(element => element->getTextContent)
  ->Belt.Option.getOr("Element not found")
}
```

### Undefined Values

```rescript
// Working with undefined
@val external undefined: 'a = "undefined"

type jsValue<'a> = 
  | @as(undefined) Undefined
  | Value('a)

let processJsValue = value => {
  switch value {
  | Undefined => "No value provided"
  | Value(v) => `Value: ${v}`
  }
}
```

## Event Handling

### DOM Events

```rescript
// Event types
type event
type mouseEvent
type keyboardEvent

@get external target: event => element = "target"
@get external preventDefault: event => unit = "preventDefault"
@get external stopPropagation: event => unit = "stopPropagation"

// Mouse events
@get external clientX: mouseEvent => int = "clientX"
@get external clientY: mouseEvent => int = "clientY"
@get external button: mouseEvent => int = "button"

// Keyboard events
@get external key: keyboardEvent => string = "key"
@get external keyCode: keyboardEvent => int = "keyCode"
@get external ctrlKey: keyboardEvent => bool = "ctrlKey"
@get external shiftKey: keyboardEvent => bool = "shiftKey"

// Event handlers
let handleClick = (event: mouseEvent) => {
  let x = event->clientX
  let y = event->clientY
  Js.log(`Clicked at (${Int.toString(x)}, ${Int.toString(y)})`)
}

let handleKeyPress = (event: keyboardEvent) => {
  let key = event->key
  if key == "Enter" {
    event->preventDefault
    Js.log("Enter key pressed")
  }
}
```

### Custom Events

```rescript
// Custom event creation
@new external customEvent: (string, 'options) => event = "CustomEvent"
@send external dispatchEvent: (element, event) => bool = "dispatchEvent"

let createCustomEvent = (eventName, data) => {
  let options = %raw(`{ detail: data, bubbles: true }`)
  customEvent(eventName, options)
}

let triggerCustomEvent = (element, eventName, data) => {
  let event = createCustomEvent(eventName, data)
  element->dispatchEvent(event)->ignore
}
```

## JSON Handling

### JSON Parsing and Stringifying

```rescript
// JSON operations
@scope("JSON") @val external stringify: 'a => string = "stringify"
@scope("JSON") @val external parse: string => 'a = "parse"

// Safe JSON parsing
let safeJsonParse = jsonString => {
  try {
    Some(parse(jsonString))
  } catch {
  | _ => None
  }
}

// JSON with specific types
type apiResponse = {
  status: string,
  data: array<string>,
  message: option<string>,
}

let parseApiResponse = jsonString => {
  try {
    let parsed: apiResponse = parse(jsonString)
    Ok(parsed)
  } catch {
  | Exn.Error(e) => Error("Invalid JSON format")
  }
}
```

### Working with JSON Objects

```rescript
// JSON object manipulation
let createJsonPayload = (userId, action, data) => {
  let payload = %raw(`{}`)
  payload->setProperty("userId", userId)
  payload->setProperty("action", action)
  payload->setProperty("data", data)
  payload->setProperty("timestamp", Date.now())
  payload
}

// Converting ReScript records to JSON
type user = {
  id: string,
  name: string,
  email: string,
}

let userToJson = user => {
  %raw(`{
    id: user.id,
    name: user.name,
    email: user.email
  }`)
}
```

## Error Handling

### JavaScript Error Handling

```rescript
// Catching JavaScript errors
let safeOperation = () => {
  try {
    // Some operation that might throw
    let result = %raw(`someRiskyJavaScriptFunction()`)
    Ok(result)
  } catch {
  | Exn.Error(e) => {
    let message = Exn.message(e)->Belt.Option.getOr("Unknown error")
    Error(message)
  }
  | _ => Error("Unexpected error")
  }
}

// Error object properties
@get external errorMessage: Exn.t => string = "message"
@get external errorName: Exn.t => string = "name"
@get external errorStack: Exn.t => option<string> = "stack"

let logError = error => {
  let message = error->errorMessage
  let name = error->errorName
  let stack = error->errorStack->Belt.Option.getOr("No stack trace")
  
  Js.log(`Error: ${name} - ${message}`)
  Js.log(`Stack: ${stack}`)
}
```

## Common Patterns in Hyperswitch

### API Integration

```rescript
// Fetch wrapper with error handling
let apiCall = async (~method="GET", ~url, ~body=?, ~headers=[], ()) => {
  try {
    let fetchOptions = %raw(`{
      method: method,
      headers: {
        'Content-Type': 'application/json',
        ...Object.fromEntries(headers)
      }
    }`)
    
    switch body {
    | Some(b) => fetchOptions->setProperty("body", stringify(b))
    | None => ()
    }
    
    let response = await fetch(url, fetchOptions)
    
    if response->getOk {
      let data = await response->json
      Ok(data)
    } else {
      let errorText = await response->text
      Error(`HTTP ${response->getStatus->Int.toString}: ${errorText}`)
    }
  } catch {
  | Exn.Error(e) => Error(Exn.message(e)->Belt.Option.getOr("Network error"))
  }
}

// Response property bindings
@get external getOk: 'response => bool = "ok"
@get external getStatus: 'response => int = "status"
@get external getStatusText: 'response => string = "statusText"
```

### Browser Storage

```rescript
// Enhanced localStorage wrapper
module LocalStorage = {
  let setItem = (key, value) => {
    try {
      let jsonValue = stringify(value)
      setItem(key, jsonValue)
      Ok()
    } catch {
    | _ => Error("Failed to serialize value")
    }
  }
  
  let getItem = key => {
    try {
      switch getItem(key)->Js.Nullable.toOption {
      | Some(jsonValue) => Some(parse(jsonValue))
      | None => None
      }
    } catch {
    | _ => None
    }
  }
  
  let removeItem = removeItem
  let clear = clear
}

// Usage
LocalStorage.setItem("userPrefs", {theme: "dark", language: "en"})
let prefs = LocalStorage.getItem("userPrefs")
```

### Window and Location APIs

```rescript
// Window object bindings
@val external window: 'a = "window"
@get external location: 'a => 'b = "location"
@get external href: 'a => string = "href"
@get external pathname: 'a => string = "pathname"
@get external search: 'a => string = "search"
@get external hash: 'a => string = "hash"

@send external pushState: ('a, 'b, string, string) => unit = "pushState"
@send external replaceState: ('a, 'b, string, string) => unit = "replaceState"

// Navigation utilities
let getCurrentPath = () => {
  window->location->pathname
}

let getQueryParams = () => {
  let search = window->location->search
  // Parse query parameters
  search
}

let navigateTo = path => {
  window->location->pushState(Js.null, "", path)
}
```

### Third-party Library Integration

```rescript
// Chart.js integration example
type chartConfig = {
  @as("type") chartType: string,
  data: 'a,
  options: option<'b>,
}

@module("chart.js") @new external createChart: (element, chartConfig) => 'chart = "Chart"
@send external update: 'chart => unit = "update"
@send external destroy: 'chart => unit = "destroy"

let createLineChart = (canvasElement, data) => {
  let config = {
    chartType: "line",
    data: data,
    options: Some(%raw(`{
      responsive: true,
      plugins: {
        title: {
          display: true,
          text: 'Chart Title'
        }
      }
    }`)),
  }
  
  createChart(canvasElement, config)
}
```

## Best Practices

1. **Use type-safe bindings** whenever possible to catch errors at compile time
2. **Handle nullable values explicitly** using `Js.Nullable.toOption`
3. **Wrap risky JavaScript operations** in try-catch blocks
4. **Use `@as` attributes** to map between ReScript and JavaScript naming conventions
5. **Create wrapper modules** for complex JavaScript libraries
6. **Validate JSON data** before using it in your application
7. **Use external bindings** instead of `%raw` when possible for better type safety
8. **Document your bindings** with comments explaining the JavaScript API
9. **Test JavaScript interop code** thoroughly as it bypasses ReScript's type system
10. **Keep JavaScript interop minimal** and isolated to specific modules
