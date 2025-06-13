# JSX Patterns in ReScript (Hyperswitch Control Center)

This document covers ReScript-specific syntax for writing React components using JSX, including prop handling, conditional rendering, list rendering, fragments, and integration with React features.

## Component Definition

### Basic Component Structure

```rescript
@react.component
let make = () => {
  <div> {React.string("Hello World")} </div>
}
```

### Component with Props

```rescript
@react.component
let make = (~title: string, ~isVisible: bool=true, ~onClick: unit => unit) => {
  <div className={isVisible ? "visible" : "hidden"} onClick={_ => onClick()}>
    {React.string(title)}
  </div>
}
```

### Component with Children

```rescript
@react.component
let make = (~children: React.element) => {
  <div className="wrapper">
    {children}
  </div>
}
```

## Prop Handling

### Optional Props with Default Values

```rescript
@react.component
let make = (~title: string, ~size: string="medium", ~disabled: bool=false) => {
  let className = `btn btn-${size} ${disabled ? "disabled" : ""}`

  <button className disabled>
    {React.string(title)}
  </button>
}
```

### Props Destructuring

```rescript
type buttonProps = {
  title: string,
  variant: string,
  size: string,
}

@react.component
let make = (~props: buttonProps) => {
  let {title, variant, size} = props

  <button className={`btn-${variant} btn-${size}`}>
    {React.string(title)}
  </button>
}
```

## Conditional Rendering

### Simple Conditional

```rescript
@react.component
let make = (~isLoggedIn: bool, ~userName: string) => {
  <div>
    {isLoggedIn
      ? <span> {React.string(`Welcome, ${userName}`)} </span>
      : <span> {React.string("Please log in")} </span>
    }
  </div>
}
```

### Pattern Matching for Conditionals

```rescript
type userStatus = Loading | LoggedIn(string) | LoggedOut

@react.component
let make = (~status: userStatus) => {
  <div>
    {switch status {
    | Loading => <div> {React.string("Loading...")} </div>
    | LoggedIn(name) => <div> {React.string(`Welcome, ${name}`)} </div>
    | LoggedOut => <div> {React.string("Please log in")} </div>
    }}
  </div>
}
```

### Option Type Rendering

```rescript
@react.component
let make = (~user: option<string>) => {
  <div>
    {switch user {
    | Some(name) => <span> {React.string(`Hello, ${name}`)} </span>
    | None => React.null
    }}
  </div>
}
```

## List Rendering

### Array Mapping

```rescript
@react.component
let make = (~items: array<string>) => {
  <ul>
    {items
    ->Array.mapWithIndex((item, index) =>
        <li key={Int.toString(index)}> {React.string(item)} </li>
      )
    ->React.array}
  </ul>
}
```

### Complex List Rendering

```rescript
type user = {
  id: string,
  name: string,
  email: string,
}

@react.component
let make = (~users: array<user>) => {
  <div className="user-list">
    {users
    ->Array.map(user =>
        <div key={user.id} className="user-card">
          <h3> {React.string(user.name)} </h3>
          <p> {React.string(user.email)} </p>
        </div>
      )
    ->React.array}
  </div>
}
```

### List with Filtering

```rescript
@react.component
let make = (~items: array<string>, ~filter: string) => {
  let filteredItems = items->Array.filter(item =>
    item->String.includes(filter)
  )

  <ul>
    {filteredItems
    ->Array.mapWithIndex((item, index) =>
        <li key={Int.toString(index)}> {React.string(item)} </li>
      )
    ->React.array}
  </ul>
}
```

## Fragments

### React.Fragment

```rescript
@react.component
let make = () => {
  <React.Fragment>
    <h1> {React.string("Title")} </h1>
    <p> {React.string("Description")} </p>
  </React.Fragment>
}
```

### Short Fragment Syntax

```rescript
@react.component
let make = () => {
  <>
    <h1> {React.string("Title")} </h1>
    <p> {React.string("Description")} </p>
  </>
}
```

## Event Handling

### Basic Event Handlers

```rescript
@react.component
let make = () => {
  let (count, setCount) = React.useState(_ => 0)

  let handleClick = _ => {
    setCount(prev => prev + 1)
  }

  <button onClick={handleClick}>
    {React.string(`Count: ${Int.toString(count)}`)}
  </button>
}
```

### Event Handlers with Parameters

```rescript
@react.component
let make = (~onItemClick: string => unit) => {
  let handleClick = (itemId: string) => {
    _ => onItemClick(itemId)
  }

  <div>
    <button onClick={handleClick("item1")}>
      {React.string("Item 1")}
    </button>
    <button onClick={handleClick("item2")}>
      {React.string("Item 2")}
    </button>
  </div>
}
```

### Form Event Handling

```rescript
@react.component
let make = () => {
  let (inputValue, setInputValue) = React.useState(_ => "")

  let handleChange = event => {
    let value = ReactEvent.Form.target(event)["value"]
    setInputValue(_ => value)
  }

  let handleSubmit = event => {
    ReactEvent.Form.preventDefault(event)
    // Handle form submission
  }

  <form onSubmit={handleSubmit}>
    <input
      type_="text"
      value={inputValue}
      onChange={handleChange}
    />
    <button type_="submit"> {React.string("Submit")} </button>
  </form>
}
```

## Refs and DOM Manipulation

### useRef Hook

```rescript
@react.component
let make = () => {
  let inputRef = React.useRef(Nullable.null)

  let focusInput = _ => {
    switch inputRef.current->Nullable.toOption {
    | Some(element) => element->focus
    | None => ()
    }
  }

  <div>
    <input ref={ReactDOM.Ref.domRef(inputRef)} />
    <button onClick={focusInput}>
      {React.string("Focus Input")}
    </button>
  </div>
}
```

## CSS and Styling

### Dynamic Class Names

```rescript
@react.component
let make = (~isActive: bool, ~size: string, ~variant: string) => {
  let className = [
    "btn",
    `btn-${size}`,
    `btn-${variant}`,
    isActive ? "active" : "",
  ]->Array.filter(cls => cls !== "")->Array.join(" ")

  <button className>
    {React.string("Button")}
  </button>
}
```

### Inline Styles

```rescript
@react.component
let make = (~color: string, ~fontSize: int) => {
  let style = ReactDOM.Style.make(
    ~color,
    ~fontSize=`${Int.toString(fontSize)}px`,
    ()
  )

  <div style>
    {React.string("Styled text")}
  </div>
}
```

## Integration with React Features

### Context Usage

```rescript
@react.component
let make = () => {
  let {theme, toggleTheme} = React.useContext(ThemeContext.context)

  <div className={`app ${theme}`}>
    <button onClick={_ => toggleTheme()}>
      {React.string("Toggle Theme")}
    </button>
  </div>
}
```

### Portal Usage

```rescript
@react.component
let make = (~children: React.element, ~isOpen: bool) => {
  switch isOpen {
  | true =>
    ReactDOM.createPortal(
      <div className="modal-overlay">
        <div className="modal">
          {children}
        </div>
      </div>,
      %raw(`document.getElementById("modal-root")`)
    )
  | false => React.null
  }
}
```

## Common Patterns

### Loading States

```rescript
type loadingState<'a> = Loading | Success('a) | Error(string)

@react.component
let make = (~data: loadingState<array<string>>) => {
  switch data {
  | Loading => <div> {React.string("Loading...")} </div>
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
  }
}
```

### Compound Components

```rescript
module Card = {
  @react.component
  let make = (~children: React.element) => {
    <div className="card">
      {children}
    </div>
  }

  module Header = {
    @react.component
    let make = (~children: React.element) => {
      <div className="card-header">
        {children}
      </div>
    }
  }

  module Body = {
    @react.component
    let make = (~children: React.element) => {
      <div className="card-body">
        {children}
      </div>
    }
  }
}

// Usage
@react.component
let make = () => {
  <Card>
    <Card.Header>
      {React.string("Card Title")}
    </Card.Header>
    <Card.Body>
      {React.string("Card content")}
    </Card.Body>
  </Card>
}
```

## Best Practices

1. **Always use keys for list items**: Provide unique keys when rendering arrays
2. **Handle events properly**: Use the correct event types and prevent default when needed
3. **Use fragments to avoid wrapper divs**: When you don't need a wrapper element
4. **Pattern match on variants**: Use ReScript's pattern matching for conditional rendering
5. **Type your props**: Always provide proper types for component props
6. **Use React.string for text**: Convert strings to React elements using React.string
7. **Handle optional values**: Use pattern matching with option types for conditional rendering
