# React Hooks Dependency Arrays in ReScript

When working with React hooks like `useEffect`, `useCallback`, and `useMemo` in ReScript, the dependency array plays a crucial role in determining when the hook should re-run or when a memoized value should be recalculated.

## Homogeneous Dependencies (Array)

If all dependencies are of the **same type**, you can use a standard ReScript array `[...]` for the dependency list.

```rescript
let memoizedValue = React.useMemo(() => {
  // compute value based on a and b
  a + b
}, [a, b]) // Both a and b are, for example, type int
```

## Heterogeneous Dependencies (Tuple)

If your dependencies are of **different types**, ReScript requires you to use a **tuple `(...)`** instead of an array for the dependency list. This is because ReScript arrays are homogeneous (all elements must be of the same type), while tuples can contain elements of different types.

The React runtime still treats this tuple as a list of dependencies for comparison.

**Example:**

```rescript
let (count, setCount) = React.useState(_ => 0)
let (name, setName) = React.useState(_ => "Guest")
let someCallback = React.useCallback(() => {
  Js.log2("Count:", count)
  Js.log2("Name:", name)
}, (count, name)) // count is int, name is string - use a tuple

React.useEffect(() => {
  Js.log("Effect ran due to change in count or name.")
  None // Cleanup function
}, (count, name)) // Tuple for mixed-type dependencies
```

**Incorrect Usage (Mixed Types in Array):**

Attempting to use an array with mixed types will result in a ReScript type error:

```rescript
// INCORRECT - This will cause a type error
React.useEffect(() => {
  // ...
  None
}, [count, name]) // Error: This array item has type string, but this array is expected to have items of type int.
```

**Key Takeaway:**

- Use `[...]` (array) for dependency lists where all items have the same type.
- Use `(...)` (tuple) for dependency lists where items have different types.

This ensures type safety in ReScript while correctly interacting with React's hook dependency mechanism.
