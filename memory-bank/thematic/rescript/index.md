# ReScript Syntax Guide (Hyperswitch Control Center)

This guide serves as a comprehensive reference for ReScript syntax and common patterns used within the Hyperswitch Control Center project. Its purpose is to ensure consistency, promote best practices, and help developers write idiomatic ReScript code.

This index is located within the `thematic/rescript/` folder. All links are relative to this location.

## Core Syntax Categories

Below are links to detailed sections covering various aspects of ReScript syntax as observed and applied in this project.

- **[JSX Patterns](./syntax/jsxPatterns.md)**
  - Covers ReScript-specific syntax for writing React components using JSX, including prop handling, conditional rendering, list rendering, fragments, and integration with React features.

- **[Modules and File Structure](./syntax/modules.md)**
  - Details how ReScript modules are defined, opened, and used, including file-based modules and interface files (`.resi`).

- **[Types and Data Structures](./syntax/typesAndDataStructures.md)**
  - Explains the definition and usage of ReScript types (records, variants, aliases) and common data structures (`option`, `array`, `list`, `Js.Dict`, `Belt` collections).

- **[Pattern Matching](./syntax/patternMatching.md)**
  - Illustrates the use of `switch` expressions for pattern matching on various data types like variants, options, and lists.

- **[Functions and Let Bindings](./syntax/functionsAndBindings.md)**
  - Covers function definitions (including labeled and optional arguments, recursion), `let` bindings, and the pipe operator (`->`).

- **[JavaScript Interop](./syntax/jsInterop.md)**
  - Describes how to interoperate with JavaScript code using `@bs.*` attributes, `external`s, and handling types like `Js.Promise` and `Js.Nullable`.

- **[Common Standard Library Usage (Belt/Js)](./syntax/commonStdLib.md)**
  - Provides examples of frequently used utility functions from the `Belt` and `Js` standard library modules.

- **[React Hooks Dependency Arrays](./syntax/reactHooksDependencies.md)**
  - Details how to correctly specify dependency arrays for React hooks like `useEffect`, `useCallback`, and `useMemo`, especially when dealing with mixed data types.

---

_This guide is a living document and will be updated as more patterns are identified and documented._
