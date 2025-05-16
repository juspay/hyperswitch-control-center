# ReScript JSX Syntax Reminders

This file contains specific reminders about ReScript syntax, particularly within JSX for React components.

## JSX `key` Prop with `int` to `string` Conversion

- When using an integer as the `key` in a list of JSX elements, it must be converted to a string.
- Use `Int.toString(index)` or string interpolation like `{\`$index\`}`.
- The expression must be enclosed in curly braces `{}`.

- **Example (Correct):**
  ```rescript
  <div key={Int.toString(index)} className="col-span-4">
    {/* ... */}
  </div>
  ```
  or
  ```rescript
  <div key={`$index`} className="col-span-4">
    {/* ... */}
  </div>
  ```

## Passing Boolean Expressions as Props

- When passing a boolean expression (e.g., using the `!` not operator, or a variable) directly as the value of a prop in a ReScript JSX element, it **must** be enclosed in curly braces `{}`.

- **Example (Correct):**
  ```rescript
  <MyComponent isDisabled={someBooleanVariable} />
  <SubmitButton disabledParameter={!allowEdit} />
  ```
- **Explanation:** Curly braces `{}` in JSX indicate that the content within is a ReScript expression that needs to be evaluated.

## Prop Passing for Function Calls and Chained Operations

- When passing the result of a function call or a chain of operations (using `->`) as a prop to a React component in ReScript JSX, ensure the entire expression is enclosed in curly braces `{}`.

- **Example (Function Call - Correct):**

  ```rescript
  <MyComponent someProp={myFunction()} />
  ```

- **Example (Chained Operation - Correct):**
  ```rescript
  <MyComponent data={someValue->processA->processB} />
  ```
- **Example (Function Call like `makeFieldInfo` - Correct):**

  ```rescript
  <FieldRenderer
    field={
      makeFieldInfo(
        ~name="someName",
        ~label="Some Label"
        // ... other arguments ...
      )
    }
    // ... other props
  />
  ```

- **Example (Chained Array Operations - Correct):**
  ```rescript
  <FieldRenderer
    field={
      someList
      ->Array.map(item => processItem(item))
      ->Array.filter(isValid)
    }
    // ... other props
  />
  ```

## Object Literals (Records) as Props

- When passing ReScript records (similar to JavaScript object literals) as props, ensure they are enclosed in curly braces `{}`.

- **Example (Correct):**
  ```rescript
  <FormComponent initialValues={{name: "", age: 0}} />
  ```

## Conditional Rendering in JSX

ReScript allows embedding `if/else` and `switch` expressions directly within JSX for conditional rendering. The entire conditional block must be enclosed in `{}`.

### Using `if/else`

- An `if/else` expression can return different JSX elements or `React.null`.

  ```rescript
  {if condition {
    <p> {"Condition is true"->React.string} </p>
  } else {
    <p> {"Condition is false"->React.string} </p>
  }}
  ```

  ```rescript
  {if showIcon {
    <Icon name="my-icon" />
  } else {
    React.null
  }}
  ```

### Using `switch`

- A `switch` expression can be used to render different components or elements based on the value of a variable. Each case should return JSX or `React.null`.

  ```rescript
  {switch userStatus {
  | LoggedIn(userData) => <UserProfile data={userData} />
  | Guest => <GuestWelcomeMessage />
  | Loading => <Spinner />
  | _ => React.null
  }}
  ```

## `React.null` for No Output

- When a conditional branch or a component's render logic should result in no visual output, use `React.null`.

  ```rescript
  {if shouldRender {
    <MyComponent />
  } else {
    React.null
  }}
  ```

## Optional Props (`=?` syntax) and Handling `option` Types

- Components can define optional props using the `~propName=?` syntax.
- Inside the component, these props are of an `option` type (e.g., `option<string>`).
- They are typically handled using `switch` or `Option.getOr()` before rendering.

  ```rescript
  // Component definition
  @react.component
  let make = (~optionalText=?, ~alwaysVisibleText) => {
    // ...
    <div>
      {alwaysVisibleText->React.string}
      {switch optionalText {
      | Some(text) => <p> {text->React.string} </p>
      | None => React.null
      }}
    </div>
  }

  // Usage
  <MyComponent optionalText="Hello" alwaysVisibleText="World" />
  <MyComponent alwaysVisibleText="Only this" />
  ```

## String Interpolation for Dynamic Class Names

- Dynamic CSS class names can be constructed using ReScript's string interpolation `{\`...\`}`.

  ```rescript
  let isActive = true;
  let baseClass = "button";
  <button className={`$baseClass ${isActive ? "active" : "inactive"}`}>
    {"Click Me"->React.string}
  </button>
  ```

## Rendering Custom `React.element` Passed as Prop

- If a prop is expected to be a `React.element`, it can be directly rendered within JSX by enclosing the prop name in `{}`.

  ```rescript
  // Component definition
  @react.component
  let Wrapper = (~icon: React.element) => {
    <div className="wrapper">
      {icon}
      <span> {"Wrapped Content"->React.string} </span>
    </div>
  }

  // Usage
  let myCustomIcon = <Icon name="star" />;
  <Wrapper icon={myCustomIcon} />
  ```

## Using `React.string()` for String Literals

- To render a string literal directly in JSX, it should be wrapped with `React.string()` or `->React.string` pipe.

  ```rescript
  <p> {"This is a string."->React.string} </p>
  <p> {React.string("Another string.")} </p>
  ```

## Rendering Lists: Mapping Arrays to JSX Elements

- When rendering a list of items, you typically map an array of data to an array of JSX elements.
- The result of `Array.map` must be piped to `->React.array` to convert it into a type that JSX can render.
- Remember to provide a unique `key` prop for each element in the list.

  ```rescript
  let items = ["apple", "banana", "cherry"];

  <ul>
    {items
     ->Array.mapWithIndex((item, index) => <li key={index->Int.toString}> {item->React.string} </li>)
     ->React.array}
  </ul>
  ```

## Passing JSX Elements as Props

- Components can accept other React elements as props. This is useful for layout components or components that decorate content.
- The prop type would be `React.element`.

  ```rescript
  // Definition of a Card component
  @react.component
  let make = (~title: React.element, ~children: React.element) => {
    <div className="card">
      <div className="card-title"> {title} </div>
      <div className="card-body"> {children} </div>
    </div>
  }

  // Usage
  <Card
    title={<IconAndText icon="info" text="Card Title" />}
    children={
      <> // Using a fragment
        <p> {"This is the card content."->React.string} </p>
        <Button text="Click Me" />
      </>
    }
  />
  ```

  _Note: In the example above, `IconAndText` would be another component, and a fragment `</>` is used to pass multiple children._

## Using React Portals

- Portals provide a way to render children into a DOM node that exists outside the DOM hierarchy of the parent component.
- In ReScript, you can use `<Portal to="dom-node-id"> {children} </Portal>`. The `to` prop specifies the ID of the DOM element where the children will be rendered.

  ```rescript
  // Assuming there's a <div id="modal-root"></div> in your HTML
  @react.component
  let MyModal = (~message) => {
    <Portal to="modal-root">
      <div className="modal-overlay">
        <div className="modal-content">
          {message->React.string}
        </div>
      </div>
    </Portal>
  }
  ```

## React Fragments (`<>...</>`)

- Fragments let you group a list of children without adding extra nodes to the DOM.
- The syntax is `<> ...children... </>` or `<React.Fragment> ...children... </React.Fragment>`.

  ```rescript
  @react.component
  let MyComponent = () => {
    <> // Shorthand fragment syntax
      <td> {"Hello"->React.string} </td>
      <td> {"World"->React.string} </td>
    </>
  }
  ```

## Render Props Pattern

- The "render prop" pattern involves passing a function as a prop to a component. This function is then called by the component to render part of its UI, often with data provided by the component itself.
- The prop's type is a function that returns `React.element`.

  ```rescript
  // Component definition
  @react.component
  let DataProvider = (~renderContent: (~data: string) => React.element) => {
    let fetchedData = "Data from API"; // Simulate fetching data
    <div>
      <h1> {"Data Provider"->React.string} </h1>
      {renderContent(~data=fetchedData)}
    </div>
  }

  // Usage
  <DataProvider
    renderContent={data => {
      <p> {("Received: " ++ data)->React.string} </p>
    }}
  />
  ```

- Render props can also have default implementations in the component, often returning `React.null`.
  ```rescript
  @react.component
  let Layout = (~header=_ => React.null, ~body) => {
    <div>
      <header> {header()} </header>
      <main> {body()} </main>
    </div>
  }
  ```

## List Pattern Matching for Routing in JSX

- ReScript's powerful pattern matching can be used on lists (e.g., URL path segments) within a `switch` statement to determine which component or render prop to invoke. This is a common way to handle sub-routing within a component.

  ```rescript
  // ~remainingPath is a list<string> representing URL segments
  @react.component
  let PageRouter = (~remainingPath, ~renderList, ~renderItem, ~renderNew) => {
    {switch remainingPath {
    | list{"new"} => renderNew()
    | list{id} => renderItem(id)
    | list{} => renderList()
    | _ => <NotFoundPage />
    }}
  }
  ```

  _In this example, `renderList`, `renderItem`, and `renderNew` are render props._

## Direct SVG Usage in JSX

- SVG elements like `<svg>`, `<path>`, `<circle>`, etc., can be used directly within ReScript JSX.
- Attributes are passed as props, similar to HTML elements. Remember that ReScript JSX props are camelCased (e.g., `fillRule` for `fill-rule`).

  ```rescript
  @react.component
  let MySvgIcon = (~fillColor="black") => {
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path
        d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z"
        fill={fillColor}
      />
    </svg>
  }
  ```

## Prop Spreading with `React.cloneElement`

- ReScript doesn't have a direct JSX spread operator like JavaScript (`{...props}`).
- To add or override props on a child `React.element`, `React.cloneElement` is often used.
- A common pattern is to define a helper function `spreadProps = React.cloneElement`.

  ```rescript
  let spreadProps = React.cloneElement;

  @react.component
  let AddAttributes = (~attributes: Dict.t<string>, ~children) => {
    // attributes is a Dict.t<string> which is compatible with the props type for React.cloneElement
    children->spreadProps(attributes)
  }

  // Usage:
  <AddAttributes attributes={Dict.fromArray([("data-custom", "value"), ("aria-label", "Descriptive label")])}>
    <Button text="Click Me" />
  </AddAttributes>
  ```

  _This will render the `Button` with `data-custom="value"` and `aria-label="Descriptive label"` attributes._

## Using `React.Children` Utilities

- The `React.Children` module provides utilities for working with the `children` prop.
- `React.Children.mapWithIndex` is useful for iterating over children and applying transformations or wrapping them.
- `React.Children.count` can get the number of child elements.

  ```rescript
  module ButtonWrapper = {
    @react.component
    let make = (~element, ~count, ~index) => {
      // Example: add specific classes or props based on index/count
      <div className={`item-${index}`}> {element} </div>
    }
  }

  @react.component
  let ButtonGroup = (~children) => {
    let count = children->React.Children.count;
    <div className="button-group">
      {children->React.Children.mapWithIndex((element, index) => {
        <ButtonWrapper element count index />
      })}
    </div>
  }
  ```

## Integrating Third-Party UI/Animation Libraries

- When using components from JavaScript libraries (e.g., Framer Motion, Headless UI), you'll typically use their ReScript bindings if available, or `React.createElement` with `Obj.magic` for direct JS interop if not.
- Props are passed as usual. Ensure the types match the bindings.
- Framer Motion specific examples:

  - `layoutId` prop on `Motion.Div` for shared layout animations between components.
    ```rescript
    // Tab A
    {if isSelectedA { <Motion.Div className="underline" layoutId="active-tab-underline" /> }}
    // Tab B
    {if isSelectedB { <Motion.Div className="underline" layoutId="active-tab-underline" /> }}
    ```
  - `<FramerMotion.TransitionComponent>` (or similar custom wrapper) for animating the appearance/disappearance of content.
    ```rescript
    <FramerMotion.TransitionComponent id={selectedTabId}>
      {selectedTabContent}
    </FramerMotion.TransitionComponent>
    ```

  ```rescript
  // General Example: Assuming FramerMotion.Motion.Div bindings are available
  open FramerMotion;

  @react.component
  let AnimatedBox = () => {
    <Motion.Div
      className="box"
      initial={{opacity: 0.0, scale: 0.5}}
      animate={{opacity: 1.0, scale: 1.0}}
      transition={{duration: 0.5}}
    />
  }
  ```

  _The `initial`, `animate`, and `transition` props would take ReScript records/objects that conform to Framer Motion's API._

## Higher-Order Functions for Configurable Form Inputs

- A common pattern in ReScript React, especially for forms (e.g., with React Final Form), is to use higher-order functions (HOFs) to create configurable input components.
- These HOFs take configuration options as arguments (e.g., `~isDisabled`, `~options` for a select box) and return a function.
- The returned function matches the signature expected by form libraries for custom input rendering (e.g., `(~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder: string) => React.element`).
- This pattern promotes reusability and configurability of form field components.

  ```rescript
  // In InputFields.res (or similar)
  let textInput = (~isDisabled=false, ~customStyle="") =>
    // This inner function is what ReactFinalForm.FieldRenderer uses
    (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder) => {
      <TextInputComponent // This is the actual component rendering the input
        input
        placeholder
        isDisabled
        customStyle
        // ... other props passed through ...
      />
    };

  // In a form definition file
  module UserForm = {
    let usernameField = FormRenderer.makeFieldInfo(
      ~name="username",
      ~label="Username",
      ~customInput=InputFields.textInput(~isDisabled=false, ~customStyle="my-input"),
      // ... other field configurations ...
    );

    @react.component
    let make = () => {
      <Form onSubmit={...}>
        <FormRenderer.FieldRenderer field={usernameField} />
        // ... other fields ...
      </Form>
    }
  }
  ```

  _This demonstrates how `InputFields.textInput` (a HOF) is used to provide a configured text input component to `FormRenderer.FieldRenderer`._

## Structuring Complex Components and Advanced Hook Usage

When building complex UI components in ReScript React (e.g., a data table), several structural and hook-related patterns are commonly employed:

- **Nested Modules for Component Scoping:**

  - Large components are often broken down into smaller, more manageable sub-components, each defined within its own ReScript module inside the parent component's file. This aids in encapsulation and organization.
  - _Example:_ A `Table.res` component might contain `module TableRow = { ... }`, `module TableCell = { ... }`, etc. Each sub-module would define its own `@react.component let make = (...) => { ...JSX... }`.

- **`React.useCallback` for Memoizing Event Handlers:**

  - Event handler functions (e.g., `onClick`, `onChange`) that are passed as props to child components are often wrapped in `React.useCallback`.
  - This memoizes the handler, ensuring it only changes if its dependencies change. This is an optimization, particularly if the child component is memoized (e.g., with `React.memo` or if it's a pure component).
  - _Syntax:_ `let handleClick = React.useCallback(event => { /* ... */ }, [dependency1, dependency2]);`
  - The memoized `handleClick` is then passed in JSX: `<ChildComponent onClick={handleClick} />`.

- **`React.useMemo` for Memoizing Derived Values:**

  - Complex calculations or data transformations that are used in rendering can be memoized with `React.useMemo`.
  - This prevents re-computing these values on every render, only re-calculating if their dependencies change.
  - _Syntax:_ `let derivedData = React.useMemo(() => computeExpensiveValue(propA, propB), [propA, propB]);`
  - The `derivedData` can then be used directly in JSX: `<div> {derivedData->React.string} </div>`.

- **React Context API for Global/Shared State:**
  - For state that needs to be accessed by many components at different levels of the tree, the React Context API (`React.createContext`, `React.useContext`) is used to avoid excessive prop drilling.
  - A context provider component wraps a part of the component tree, and consumer components use `React.useContext` to access the shared data.
  - _Example (Context Definition):_
    ```rescript
    module ThemeContext = {
      type theme = {color: string};
      let context = React.createContext({color: "blue"});
      let provider = React.Context.provider(context);
    };
    ```
  - _Example (Provider Usage in JSX):_
    ```rescript
    <ThemeContext.provider value={{color: "red"}}>
      <MyApp />
    </ThemeContext.provider>
    ```
  - _Example (Consumer Usage in a Component):_
    ```rescript
    @react.component
    let MyThemedButton = () => {
      let theme = React.useContext(ThemeContext.context);
      <button style={ReactDOM.Style.make(~color=theme.color, ())}>
        {"Click Me"->React.string}
      </button>
    };
    ```

These patterns, while not strictly new JSX syntax elements, are crucial for how JSX is effectively used and managed in larger, performance-sensitive ReScript React applications.

## Direct DOM Manipulation with Refs and Externals

- While React promotes a declarative approach, sometimes direct DOM manipulation is necessary (e.g., for managing focus, animations, or integrating with third-party DOM-based libraries).
- `React.useRef` is used to get a reference to a DOM element. The ref is attached to a JSX element via the `ref` prop.
  ```rescript
  let myDivRef = React.useRef(Js.Nullable.null);
  <div ref={myDivRef->ReactDOM.Ref.domRef} />
  ```
- ReScript's `@send` external can be used to call DOM methods on the element obtained from the ref.

  ```rescript
  // Define externals for DOM methods
  type scrollIntoViewParams = {behavior: string, block: string, inline: string}
  @send external scrollIntoView: (Dom.element, scrollIntoViewParams) => unit = "scrollIntoView"
  @send external getBoundingClientRect: Dom.element => {..} = "getBoundingClientRect" // Return type can be more specific

  // Usage in a component
  React.useEffect(() => {
    myDivRef.current
    ->Js.Nullable.toOption
    ->Option.forEach(element => {
      element->scrollIntoView({behavior: "smooth", block: "nearest", inline: "start"})
    })
  }, [/* dependencies */]);
  ```

- This pattern allows controlled interaction with the DOM when React's declarative model isn't sufficient.
