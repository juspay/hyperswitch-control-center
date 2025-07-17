# Pattern Matching in ReScript (Hyperswitch Control Center)

This document illustrates the use of `switch` expressions for pattern matching on various data types like variants, options, and lists.

## Basic Switch Expressions

### Simple Value Matching

```rescript
let getStatusMessage = status => {
  switch status {
  | "pending" => "Payment is being processed"
  | "completed" => "Payment completed successfully"
  | "failed" => "Payment failed"
  | _ => "Unknown status"
  }
}

let processNumber = num => {
  switch num {
  | 0 => "Zero"
  | 1 => "One"
  | 2 => "Two"
  | n when n > 10 => "Large number"
  | n => `Number: ${Int.toString(n)}`
  }
}
```

### Boolean Pattern Matching

```rescript
let getAccessLevel = (isAdmin, isActive) => {
  switch (isAdmin, isActive) {
  | (true, true) => "Full Access"
  | (true, false) => "Admin (Inactive)"
  | (false, true) => "User Access"
  | (false, false) => "No Access"
  }
}
```

## Variant Pattern Matching

### Basic Variants

```rescript
type status = Loading | Success | Error | Empty

let renderStatus = status => {
  switch status {
  | Loading => <div> {React.string("Loading...")} </div>
  | Success => <div> {React.string("Data loaded successfully")} </div>
  | Error => <div> {React.string("An error occurred")} </div>
  | Empty => <div> {React.string("No data available")} </div>
  }
}
```

### Variants with Data

```rescript
type apiResponse<'data> =
  | Loading
  | Success('data)
  | Error(string)
  | NetworkError(int, string)

let handleResponse = response => {
  switch response {
  | Loading => "Processing request..."
  | Success(data) => `Received: ${data}`
  | Error(message) => `Error: ${message}`
  | NetworkError(code, message) => `Network Error ${Int.toString(code)}: ${message}`
  }
}
```

### Complex Variant Matching

```rescript
type userAction =
  | Login(string, string) // email, password
  | Logout
  | UpdateProfile(string, option<string>) // name, avatar
  | ChangePassword(string, string) // old, new
  | DeleteAccount(string) // confirmation

let processAction = action => {
  switch action {
  | Login(email, password) =>
    `Attempting login for ${email}`
  | Logout =>
    "User logged out"
  | UpdateProfile(name, Some(avatar)) =>
    `Updating profile: ${name} with avatar ${avatar}`
  | UpdateProfile(name, None) =>
    `Updating profile: ${name} without avatar`
  | ChangePassword(oldPass, newPass) =>
    "Password change requested"
  | DeleteAccount(confirmation) when confirmation == "DELETE" =>
    "Account deletion confirmed"
  | DeleteAccount(_) =>
    "Invalid confirmation for account deletion"
  }
}
```

## Option Pattern Matching

### Basic Option Handling

```rescript
let getUserEmail = user => {
  switch user.email {
  | Some(email) => email
  | None => "No email provided"
  }
}

let getEmailDomain = user => {
  switch user.email {
  | Some(email) => {
      let parts = email->String.split("@")
      switch parts[1] {
      | Some(domain) => domain
      | None => "Invalid email format"
      }
    }
  | None => "No email"
  }
}
```

### Nested Option Matching

```rescript
type address = {
  street: option<string>,
  city: option<string>,
  country: option<string>,
}

type user = {
  name: string,
  address: option<address>,
}

let getFullAddress = user => {
  switch user.address {
  | None => "No address provided"
  | Some({street: None, city: None, country: None}) => "Incomplete address"
  | Some({street: Some(s), city: Some(c), country: Some(co)}) =>
    `${s}, ${c}, ${co}`
  | Some({city: Some(c), country: Some(co)}) =>
    `${c}, ${co}`
  | Some({country: Some(co)}) =>
    co
  | Some(_) => "Partial address available"
  }
}
```

### Option with Guards

```rescript
let validateAge = age => {
  switch age {
  | Some(a) when a >= 18 && a <= 120 => "Valid adult age"
  | Some(a) when a < 18 => "Minor"
  | Some(a) when a > 120 => "Invalid age"
  | Some(_) => "Age out of range"
  | None => "Age not provided"
  }
}
```

## Array and List Pattern Matching

### Array Pattern Matching

```rescript
let processArray = arr => {
  switch arr {
  | [] => "Empty array"
  | [single] => `Single item: ${single}`
  | [first, second] => `Two items: ${first}, ${second}`
  | [first, second, third] => `Three items: ${first}, ${second}, ${third}`
  | [first, ...rest] => `First: ${first}, remaining: ${Int.toString(Array.length(rest))}`
  }
}

let getFirstTwo = numbers => {
  switch numbers {
  | [] => (None, None)
  | [first] => (Some(first), None)
  | [first, second, ..._] => (Some(first), Some(second))
  }
}
```

### List Pattern Matching

```rescript
let processList = lst => {
  switch lst {
  | list{} => "Empty list"
  | list{single} => `Single item: ${single}`
  | list{first, second} => `Two items: ${first}, ${second}`
  | list{first, ...rest} => `First: ${first}, rest length: ${Belt.List.length(rest)->Int.toString}`
  }
}

// Recursive list processing
let rec sumList = lst => {
  switch lst {
  | list{} => 0
  | list{head, ...tail} => head + sumList(tail)
  }
}

let rec findInList = (lst, target) => {
  switch lst {
  | list{} => false
  | list{head, ...tail} when head == target => true
  | list{_, ...tail} => findInList(tail, target)
  }
}
```

## Record Pattern Matching

### Basic Record Matching

```rescript
type user = {
  id: string,
  name: string,
  role: string,
  isActive: bool,
}

let getUserPermissions = user => {
  switch user {
  | {role: "admin", isActive: true} => "Full permissions"
  | {role: "admin", isActive: false} => "Admin account disabled"
  | {role: "user", isActive: true} => "User permissions"
  | {role: "user", isActive: false} => "User account disabled"
  | {role} => `Unknown role: ${role}`
  }
}
```

### Partial Record Matching

```rescript
type payment = {
  id: string,
  amount: float,
  currency: string,
  status: string,
  metadata: option<Js.Dict.t<string>>,
}

let getPaymentInfo = payment => {
  switch payment {
  | {status: "completed", amount} when amount > 1000.0 =>
    "Large completed payment"
  | {status: "completed"} =>
    "Payment completed"
  | {status: "pending", metadata: Some(_)} =>
    "Pending payment with metadata"
  | {status: "pending"} =>
    "Pending payment"
  | {status: "failed", amount} =>
    `Failed payment of ${Float.toString(amount)}`
  | {status} =>
    `Payment status: ${status}`
  }
}
```

## Tuple Pattern Matching

### Basic Tuple Matching

```rescript
let processCoordinates = coords => {
  switch coords {
  | (0, 0) => "Origin"
  | (x, 0) => `On X-axis at ${Int.toString(x)}`
  | (0, y) => `On Y-axis at ${Int.toString(y)}`
  | (x, y) when x == y => `Diagonal at ${Int.toString(x)}`
  | (x, y) => `Point at (${Int.toString(x)}, ${Int.toString(y)})`
  }
}

let analyzeResult = result => {
  switch result {
  | (true, Some(data)) => `Success with data: ${data}`
  | (true, None) => "Success without data"
  | (false, Some(error)) => `Failed with error: ${error}`
  | (false, None) => "Failed without error message"
  }
}
```

### Complex Tuple Matching

```rescript
type httpMethod = GET | POST | PUT | DELETE
type httpStatus = int

let analyzeRequest = (method, status, hasBody) => {
  switch (method, status, hasBody) {
  | (GET, 200, false) => "Successful GET request"
  | (GET, 404, false) => "Resource not found"
  | (POST, 201, true) => "Resource created successfully"
  | (POST, 400, _) => "Bad request"
  | (PUT, 200, true) => "Resource updated"
  | (DELETE, 204, false) => "Resource deleted"
  | (_, status, _) when status >= 500 => "Server error"
  | (method, status, _) => `${method->methodToString} request with status ${Int.toString(status)}`
  }
}
```

## Advanced Pattern Matching

### Guards and When Clauses

```rescript
let categorizeNumber = num => {
  switch num {
  | n when n < 0 => "Negative"
  | 0 => "Zero"
  | n when n > 0 && n <= 10 => "Small positive"
  | n when n > 10 && n <= 100 => "Medium positive"
  | n when n > 100 => "Large positive"
  | _ => "Unknown" // This case is unreachable but required for exhaustiveness
  }
}

let validateUser = user => {
  switch user {
  | {name, age: Some(a)} when String.length(name) > 0 && a >= 18 =>
    "Valid adult user"
  | {name} when String.length(name) > 0 =>
    "Valid user (age unknown)"
  | {name} when String.length(name) == 0 =>
    "Invalid: empty name"
  | _ =>
    "Invalid user"
  }
}
```

### Exception Pattern Matching

```rescript
let safeParseInt = str => {
  try {
    Some(Int.fromString(str))
  } catch {
  | Failure(_) => None
  | Invalid_argument(_) => None
  | _ => None
  }
}

let handleApiCall = () => {
  try {
    // Some API call
    "Success"
  } catch {
  | Fetch.Error(NetworkError) => "Network error occurred"
  | Fetch.Error(ParseError) => "Failed to parse response"
  | Exn.Error(obj) =>
    switch Exn.message(obj) {
    | Some(msg) => `Error: ${msg}`
    | None => "Unknown error occurred"
    }
  | _ => "Unexpected error"
  }
}
```

### Polymorphic Variant Matching

```rescript
type color = [#red | #green | #blue | #yellow]
type size = [#small | #medium | #large]

let getButtonClass = (color, size) => {
  switch (color, size) {
  | (#red, #large) => "btn-red-lg"
  | (#red, _) => "btn-red"
  | (#green, #small) => "btn-green-sm"
  | (#green, _) => "btn-green"
  | (#blue, _) => "btn-blue"
  | (#yellow, _) => "btn-yellow"
  }
}
```

## Pattern Matching in React Components

### Component State Matching

```rescript
type loadingState<'data> =
  | Loading
  | Success('data)
  | Error(string)
  | Empty

@react.component
let make = (~data: loadingState<array<string>>) => {
  switch data {
  | Loading =>
    <div className="loading"> {React.string("Loading...")} </div>
  | Success(items) when Array.length(items) == 0 =>
    <div className="empty"> {React.string("No items found")} </div>
  | Success(items) =>
    <ul>
      {items
      ->Array.mapWithIndex((item, index) =>
          <li key={Int.toString(index)}> {React.string(item)} </li>
        )
      ->React.array}
    </ul>
  | Error(message) =>
    <div className="error"> {React.string(`Error: ${message}`)} </div>
  | Empty =>
    <div className="empty"> {React.string("No data available")} </div>
  }
}
```

### Event Handling with Pattern Matching

```rescript
type formEvent =
  | Submit(ReactEvent.Form.t)
  | InputChange(string, string) // field name, value
  | Reset

let handleFormEvent = event => {
  switch event {
  | Submit(e) => {
      ReactEvent.Form.preventDefault(e)
      // Handle form submission
    }
  | InputChange("email", value) => {
      // Validate email
      if String.includes(value, "@") {
        // Valid email format
      } else {
        // Invalid email
      }
    }
  | InputChange(field, value) => {
      // Handle other field changes
      Js.log(`Field ${field} changed to: ${value}`)
    }
  | Reset => {
      // Reset form
    }
  }
}
```

## Common Patterns in Hyperswitch

### API Response Handling

```rescript
type apiError = {
  code: string,
  message: string,
}

type apiResponse<'data> =
  | Loading
  | Success('data)
  | Error(apiError)
  | NetworkError(string)

let handleApiResponse = response => {
  switch response {
  | Loading =>
    <PageLoaderWrapper screenState={PageLoaderWrapper.Loading}>
      React.null
    </PageLoaderWrapper>
  | Success(data) =>
    <PageLoaderWrapper screenState={PageLoaderWrapper.Success}>
      <DataDisplay data />
    </PageLoaderWrapper>
  | Error({code: "UNAUTHORIZED"}) =>
    <PageLoaderWrapper screenState={PageLoaderWrapper.Error("Please log in again")}>
      React.null
    </PageLoaderWrapper>
  | Error({code: "FORBIDDEN"}) =>
    <PageLoaderWrapper screenState={PageLoaderWrapper.Error("Access denied")}>
      React.null
    </PageLoaderWrapper>
  | Error({message}) =>
    <PageLoaderWrapper screenState={PageLoaderWrapper.Error(message)}>
      React.null
    </PageLoaderWrapper>
  | NetworkError(msg) =>
    <PageLoaderWrapper screenState={PageLoaderWrapper.Error(`Network error: ${msg}`)}>
      React.null
    </PageLoaderWrapper>
  }
}
```

### Form Validation

```rescript
type validationError =
  | Required(string) // field name
  | InvalidFormat(string, string) // field name, expected format
  | TooShort(string, int) // field name, minimum length
  | TooLong(string, int) // field name, maximum length

let getErrorMessage = error => {
  switch error {
  | Required(field) => `${field} is required`
  | InvalidFormat(field, format) => `${field} must be in ${format} format`
  | TooShort(field, minLength) => `${field} must be at least ${Int.toString(minLength)} characters`
  | TooLong(field, maxLength) => `${field} must be no more than ${Int.toString(maxLength)} characters`
  }
}

let validateField = (fieldName, value) => {
  switch (fieldName, value) {
  | ("email", "") => Some(Required("Email"))
  | ("email", email) when !String.includes(email, "@") =>
    Some(InvalidFormat("Email", "user@domain.com"))
  | ("password", "") => Some(Required("Password"))
  | ("password", pwd) when String.length(pwd) < 8 =>
    Some(TooShort("Password", 8))
  | ("name", "") => Some(Required("Name"))
  | ("name", name) when String.length(name) > 50 =>
    Some(TooLong("Name", 50))
  | _ => None
  }
}
```

### Route Matching

```rescript
type route =
  | Dashboard
  | Payments(option<string>) // optional payment ID
  | Connectors
  | ConnectorDetail(string) // connector ID
  | Settings(string) // settings section
  | NotFound

let matchRoute = path => {
  switch path->String.split("/") {
  | ["", "dashboard"] => Dashboard
  | ["", "payments"] => Payments(None)
  | ["", "payments", id] => Payments(Some(id))
  | ["", "connectors"] => Connectors
  | ["", "connectors", id] => ConnectorDetail(id)
  | ["", "settings", section] => Settings(section)
  | _ => NotFound
  }
}

let renderRoute = route => {
  switch route {
  | Dashboard => <DashboardScreen />
  | Payments(None) => <PaymentsListScreen />
  | Payments(Some(id)) => <PaymentDetailScreen paymentId={id} />
  | Connectors => <ConnectorsScreen />
  | ConnectorDetail(id) => <ConnectorDetailScreen connectorId={id} />
  | Settings(section) => <SettingsScreen section />
  | NotFound => <NotFoundScreen />
  }
}
```

## Best Practices

1. **Use exhaustive matching**: Always handle all possible cases
2. **Order patterns from specific to general**: Put more specific patterns first
3. **Use guards for complex conditions**: When simple pattern matching isn't enough
4. **Prefer pattern matching over if-else chains**: More readable and type-safe
5. **Use meaningful variable names in patterns**: Make the code self-documenting
6. **Avoid deep nesting**: Break complex patterns into smaller functions
7. **Use wildcards sparingly**: Be explicit about what you're matching
8. **Combine patterns when possible**: Use tuples to match multiple values at once
9. **Use when clauses for validation**: Add guards for additional constraints
10. **Document complex patterns**: Add comments for non-obvious pattern matching logic
