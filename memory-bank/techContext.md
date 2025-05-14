# Technical Context for Control Center

This document provides a high-level overview of the technical context in which the Hyperswitch Control Center operates. It outlines the key technologies, tools, and practices employed in its development.

## Key Technologies

- **Frontend Framework & UI Library:**
  - ReScript: A robust, statically-typed language that compiles to efficient JavaScript.
  - React: Used via ReScript bindings for building modular and reusable UI components.
- **Styling:**
  - Tailwind CSS: Utilized for utility-first styling.
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
- **ReScript File Conventions:**
  - `.res`: ReScript source files.
  - `.resi`: ReScript interface files (for defining module signatures).
  - For a comprehensive guide to ReScript syntax and patterns used in this project, see [./rescriptSyntaxGuide.md](./rescriptSyntaxGuide.md).
- **MCP Servers:**
  - MCP (Model Context Protocol) servers can be connected to the Control Center to provide additional tools and resources. These servers can extend the functionality of the Control Center by providing access to external APIs or other data sources.

## Project Directory Structure (High-Level)

- **`src/`**: Contains the main ReScript source code for the Control Center application.
- **`public/`**: Contains static assets (HTML, CSS, images) served directly to the browser.
- **`build/`**: (Generated) Output directory for the built and optimized application.
- **`node_modules/`**: (Generated) Contains installed Node.js packages and dependencies.

## Key Configuration Aspects

- **API URLs:** The Control Center is configured with URLs for the Hyperswitch backend API and SDK. These are critical for communication and resource loading.
- **Feature Flags:** Used to enable/disable functionalities, manage A/B testing, or control environment-specific features (e.g., `reports`, `mixpanel`, `test_processors`, `recon`).
- **Environment Variables:** Standard practice for configuring settings that vary between development, staging, and production environments (e.g., API endpoints, base URLs).

## Development Practices

- **Modular Architecture:** The Control Center is likely built using a modular architecture, promoting code reusability and maintainability.
- **Component-Based Development:** The UI is constructed using reusable components (see React above).
- **State Management:**
  - Recoil: Employed for global application state.
  - React Hooks (`useState`, `useEffect`): Used for local component state.
- **Testing:** The project should have a suite of tests (unit, integration, and/or end-to-end) to ensure code quality and prevent regressions.
- **Build Tools:** Tools are used to automate the process of building, optimizing, and deploying the Control Center application.
- **Code Style:** The project follows a specific code style and conventions (enforced by a linter).
- **Contribution Guidelines:** Refer to the main `docs/CONTRIBUTING.md` file for detailed instructions on how to contribute to the project.

## Local Development Setup

Setting up the Control Center for local development typically involves these steps:

1.  **Prerequisites:**
    - Node.js and npm.
    - Git.
    - A running Hyperswitch backend instance (often via Docker). Refer to [Hyperswitch Local Setup](https://docs.hyperswitch.io/hyperswitch-open-source/overview/local-setup-using-individual-components/).
2.  **Clone Repository:**
    ```bash
    git clone https://github.com/juspay/hyperswitch-control-center.git
    cd hyperswitch-control-center
    ```
3.  **Install Dependencies:**
    ```bash
    npm install
    ```
4.  **Start ReScript Compiler:**
    ```bash
    npm run re:start
    ```
5.  **Start Development Server:**
    ```bash
    npm run start
    ```
    (Typically accessible at `http://localhost:3000`)
6.  **Configure API URLs:**
    - Ensure the Control Center is configured with the correct URLs for your local Hyperswitch backend API (e.g., `http://localhost:8080`) and SDK (e.g., `http://localhost:9050/HyperLoader.js`). This might be in a `config.toml` or similar.

## Hyperswitch Ecosystem

The Control Center operates within the broader Hyperswitch ecosystem, interacting with other components:

- **Hyperswitch Backend:** The core payment processing engine.
- **Hyperswitch SDK:** The JavaScript SDK used to interact with Hyperswitch.

## Target Audience

This technical context is relevant for:

- Developers working on the Control Center.
- Developers integrating with the Control Center or Hyperswitch.
- Anyone interested in understanding the technology stack used in the project.
