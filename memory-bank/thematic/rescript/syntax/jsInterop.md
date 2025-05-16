# ReScript JavaScript Interoperability

ReScript provides a comprehensive set of features to seamlessly interoperate with JavaScript code. This includes calling JavaScript functions from ReScript, exposing ReScript functions to JavaScript, and handling JavaScript-specific types like Promises and Nullables.

## Raw JavaScript (`%raw`)

The `%raw` extension allows embedding arbitrary JavaScript code directly within ReScript. This should be used sparingly, as it bypasses ReScript's type safety.

**Example: `isUint8Array` in `LogicUtils.res`**
This function uses `%raw` to perform an `instanceof` check, which is a JavaScript-specific operation.

```rescript
// In src/utils/LogicUtils.res
let isUint8Array: 'a => bool = %raw("(val) => val instanceof Uint8Array")

// Usage:
// let arr = getSomeValue();
// if isUint8Array(arr) { ... }
```

- The type signature `'a => bool` is provided to ReScript, but the implementation is raw JavaScript.

## Externals (`external`)

The `external` keyword is used to declare bindings to existing JavaScript values or functions. It tells the ReScript compiler that a certain identifier exists in JavaScript and provides its ReScript type signature.

**Common `@bs.*` Attributes with `external`:**

These attributes modify how `external` declarations are compiled to JavaScript.

- **`@bs.val`**: Binds to a JavaScript value that is globally accessible or accessible via a specified scope.

  ```rescript
  // From src/libraries/Window.res - Accessing window.location.hostname
  // 'location' is an abstract type representing the window.location object
  type location;
  @bs.val @bs.scope("window", "location") external hostname: string = "hostname";
  // Usage: let currentHost = Window.hostname;

  // From src/components/RippleEffectBackground.res - Accessing global 'document'
  @bs.val external document: Dom.document = "document";
  ```

- **`@bs.module("module-name")`**: Imports a value or function from a JavaScript module.

  ```rescript
  // From src/libraries/GoogleAnalytics.res
  // Assuming 'analyticsType' is defined elsewhere.
  type analyticsType;
  @bs.module("react-ga4") external analytics: analyticsType = "default";
  // This imports the default export from "react-ga4" module.

  // From src/server/NodeJs.res - Importing 'execFile' from 'child_process'
  type promisifyable;
  @bs.module("child_process") external execFile: promisifyable = "execFile";
  ```

  If importing a named export `foo`, it would be `external foo: type = "foo"`.
  For the default export, the external name is often `"default"`.

- **`@bs.send`**: Used for calling methods on JavaScript objects. The first ReScript argument is the object instance.

  ```rescript
  // From src/hooks/TimeZoneHook.res - Calling Date.prototype.toLocaleString
  type timeZoneObject = {timeZone: string};
  @bs.send external toLocaleString: (Date.t, string, timeZoneObject) => string = "toLocaleString";
  // Usage: myDate->toLocaleString("en-US", {timeZone: "America/New_York"})

  // From src/components/DynamicTabs.res - Calling element.scrollIntoView
  type scrollIntoViewParams = {behavior: string, block: string, inline: string};
  @bs.send external scrollIntoView: (Dom.element, scrollIntoViewParams) => unit = "scrollIntoView";
  // Usage: myElement->scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"})
  ```

- **`@bs.get`**: Used for accessing properties of JavaScript objects.

  ```rescript
  // From src/components/RippleEffectBackground.res - Getting element.style
  type styleObj; // Abstract type for a style object
  @bs.get external style: Dom.element => styleObj = "style";
  // Usage: let s = myElement->style;
  ```

- **`@bs.set`**: Used for setting properties of JavaScript objects.

  ```rescript
  // From src/components/RippleEffectBackground.res - Setting style.width
  type styleObj; // As above
  @bs.set external setWidth: (styleObj, string) => unit = "width";
  // Usage: myStyleObject->setWidth("100px");
  ```

- **`@bs.new`**: Used for calling JavaScript constructors (e.g., `new AbortController()`).

  ```rescript
  // From src/libraries/bsfetch/Fetch.res - AbortController constructor
  module AbortController = {
    type t; // Abstract type for AbortController instance
    @bs.new external make: unit => t = "AbortController";
  };
  // Usage: let controller = AbortController.make();
  ```

- **`@obj`**: Used to create a ReScript function that, when called, generates a plain JavaScript object.
  The function must have only labeled arguments.
  ```rescript
  // From src/server/Server.res - Creating a rewrite rule object
  type rewrite; // Abstract type for the object shape
  @obj external makeRewrite: (~source: string, ~destination: string) => rewrite = "";
  // Usage: let rule = makeRewrite(~source="/old", ~destination="/new");
  // 'rule' is now a JS object like {source: "/old", destination: "/new"}
  ```

**Identity External (`"%identity"`)**
Sometimes, you need to tell ReScript that two types are equivalent at runtime, essentially a type cast. `external identityCast: typeA => typeB = "%identity"` can be used for this. It has no runtime cost.
`rescript
    // From src/hooks/OutsideClick.res
    // Casting Dom.eventTarget to a more specific DOM node like type
    external ffToDomType: Dom.eventTarget => Dom.node_like<'a> = "%identity";
    `
Use with caution, as it bypasses some type safety if the types aren't actually compatible.

## JavaScript Promises (`Js.Promise.t<'a>`)

ReScript represents JavaScript Promises with the `Js.Promise.t<'a>` type. The `Js.Promise` module provides functions to work with them.

**Example: Handling Fetch response in `APIUtils.res`**
The `fetchApi` function (likely from `AuthHooks.useApiFetcher`) returns a `Js.Promise.t<Fetch.Response.t>`.

```rescript
// In src/APIUtils/APIUtils.res (simplified from useHandleLogout)
open Promise // Often Js.Promise is aliased or its functions are used directly

let handleLogoutLogic = () => {
  // fetchApi(...) returns a Js.Promise.t<Fetch.Response.t>
  fetchApi(logoutUrl, ~method_=Post, ...)
  ->then(Fetch.Response.json) // Fetch.Response.json also returns a Js.Promise.t<JSON.t>
  ->then(json => { // 'json' here is the resolved JSON.t
    // Process the JSON
    json->resolve // Resolve the outer promise created by this chain
  })
  ->catch(_err => { // Catch errors from any preceding promise in the chain
    JSON.Encode.null->resolve // Resolve with a default value in case of error
  })
  // ...
}
```

- `->then(callback)` is used for successful resolution.
- `->catch(errorCallback)` is used for handling promise rejections.
- `value->resolve` creates a new resolved promise (often `Js.Promise.resolve(value)`).
- `error->reject` creates a new rejected promise (often `Js.Promise.reject(error)`).
- Async/await syntax can also be used with promises if preferred, by marking functions with `async` and using `await` keyword.

## Nullable Values (`Js.Nullable.t<'a>`)

To interoperate with JavaScript functions or libraries that might return `null` or `undefined`, ReScript uses the `Js.Nullable.t<'a>` type. This is distinct from ReScript's `option<'a>`.

**Constructors/Values:**

- `Js.Nullable.null`: Represents `null`.
- `Js.Nullable.undefined`: Represents `undefined`.
- `Js.Nullable.return(value)`: Wraps a ReScript `value` into a `Js.Nullable.t<value>`.

**Conversion:**

- `Js.Nullable.toOption(nullableValue)`: Converts `Js.Nullable.t<'a>` to `option<'a>`.
- `Js.Nullable.fromOption(optionValue)`: Converts `option<'a>` to `Js.Nullable.t<'a>` (where `None` becomes `undefined`).

**Example: React Refs in `Button.res`**
React refs are often initialized with `null`.

```rescript
// In src/components/Button.res
let parentRef = React.useRef(Js.Nullable.null); // Initializing a ref with null

// Later, to use the ref's current value (which is a DOM element or null):
// myRef.current is Js.Nullable.t<Dom.element>
myRef.current
->Js.Nullable.toOption // Convert to option<Dom.element>
->Option.forEach(element => {
  // Now 'element' is Dom.element, and this block only runs if it's Some(element)
  // Do something with the element
})
```

This section provides a starting point for understanding JS interop. More specific patterns and attributes will be added as they are identified in the codebase.
