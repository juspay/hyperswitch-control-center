# System Patterns

This document serves as an index for detailed system patterns observed in the codebase. The patterns are broken down into more specific documents for clarity and maintainability.

## Core System Pattern Documents

- **[Component Architecture](./systemPatterns/component-architecture.md)**

  - Outlines component relationships and overall structure.
  - Covers entry points, containers, screens, components, utilities, API integration, and context.

- **[Utility Functions](./systemPatterns/utility-functions.md)**

  - Details common utility functions, with `LogicUtils.res` as a key example.
  - Covers string manipulation, data conversion, validation, etc.

- **[Coding Conventions](./systemPatterns/coding-conventions.md)**

  - Describes naming conventions (camelCase, kebab-case, snake_case) used in the project.

- **[Architectural and React Patterns](./systemPatterns/architectural-react-patterns.md)**

  - Discusses overarching architectural patterns like feature-based modules.
  - Provides examples of React component implementations (e.g., `HyperSwitchApp.res`, `OrchestrationApp.res`) and their use of hooks, context, and state management.

- **[Modules and Fragments](./systemPatterns/modules-and-fragments.md)**
  - Details specific module implementations like the Authentication module (`AuthEntry.res`).
  - Explains the use of Fragments for reusable UI snippets, including `ConnectorFragments`.

## Overview

The codebase follows a modular architecture, emphasizing reusable components and clear separation of concerns. Key technologies include ReScript and React, with a focus on type safety and efficient state management.

Refer to the linked documents for in-depth information on each specific pattern.
