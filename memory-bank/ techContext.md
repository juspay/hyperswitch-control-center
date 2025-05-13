# Technical Context for Control Center

This document provides a high-level overview of the technical context in which the Hyperswitch Control Center operates. It outlines the key technologies, tools, and practices employed in its development.

## Key Technologies

- **Frontend Framework:**
  - ReScript: A robust, statically-typed language that compiles to efficient JavaScript. It's used for building the user interface.
- **JavaScript Runtime:**
  - Node.js: Used for the development server and build tools.
- **Package Manager:**
  - npm: The standard package manager for Node.js, used for managing project dependencies.
- **Version Control:**
  - Git: Used for source code management and collaboration.
- **Backend Interaction:**
  - RESTful APIs: The Control Center communicates with the Hyperswitch backend using RESTful API endpoints.
- **Documentation:**
  - Markdown: Used for documentation files.
- **MCP Servers:**
  - MCP (Model Context Protocol) servers can be connected to the Control Center to provide additional tools and resources. These servers can extend the functionality of the Control Center by providing access to external APIs or other data sources.

## Development Practices

- **Modular Architecture:** The Control Center is likely built using a modular architecture, promoting code reusability and maintainability.
- **Component-Based Development:** The UI is constructed using reusable components.
- **State Management:** The application uses a state management solution (likely built-in to React or a library like Redux) to manage the data and UI state.
- **Testing:** The project should have a suite of tests (unit, integration, and/or end-to-end) to ensure code quality and prevent regressions.
- **Build Tools:** Tools are used to automate the process of building, optimizing, and deploying the Control Center application.
- **Code Style:** The project follows a specific code style and conventions (enforced by a linter).

## Hyperswitch Ecosystem

The Control Center operates within the broader Hyperswitch ecosystem, interacting with other components:

- **Hyperswitch Backend:** The core payment processing engine.
- **Hyperswitch SDK:** The JavaScript SDK used to interact with Hyperswitch.

## Target Audience

This technical context is relevant for:

- Developers working on the Control Center.
- Developers integrating with the Control Center or Hyperswitch.
- Anyone interested in understanding the technology stack used in the project.
