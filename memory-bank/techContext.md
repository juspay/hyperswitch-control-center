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
- **Code Style:** The project follows a specific code style and conventions, enforced by a linter. Key conventions include:
  - Using camelCase for variable names (e.g., `myVariable`).
  - Using kebab-case for ReScript file names (e.g., `my-file.res`).
  - Potentially using snake_case for database column names (though this is more relevant to the backend, it's a general convention sometimes noted).
- **Contribution Guidelines:** Refer to the main `docs/CONTRIBUTING.md` file for detailed instructions on how to contribute to the project.

## Local Development Setup

This section outlines the steps to set up and run the Hyperswitch Control Center frontend locally for development, connecting to a local instance of the Hyperswitch backend services running via Docker.

### Prerequisites

1.  **Node.js and npm**: Ensure Node.js (which includes npm) is installed. (Tested with Node v16.0.0, npm v7.10.0; newer versions generally recommended).
2.  **Git**: Ensure Git is installed for cloning repositories.
3.  **Docker**: Ensure Docker Desktop (or Docker Engine) is installed and running.
4.  **Hyperswitch Backend Repository**: Clone the `hyperswitch` backend repository, typically as a sibling to `hyperswitch-control-center`.
    ```bash
    # Example: If hyperswitch-control-center is in /Workspace/hyperswitch-control-center
    # Run from /Workspace:
    git clone --depth 1 --branch latest https://github.com/juspay/hyperswitch
    ```

### Setup Steps

1.  **Navigate to Control Center Directory**:
    Ensure your terminal is in the `hyperswitch-control-center` project root.

2.  **Install Frontend Dependencies**:
    If not already done, install Node.js packages:
    ```bash
    npm install
    ```
    _(Note: If `npm run start` yields module resolution errors for packages like `react-color`, ensure they are installed and saved, e.g., `npm install react-color --save`)_

3.  **Configure Backend URLs**:
    - Open `config/config.toml` in the `hyperswitch-control-center` project.
    - Verify these endpoint configurations for local backend (default Docker ports):
      ```toml
      [default.endpoints]
      api_url="http://localhost:8080/api"
      sdk_url="http://localhost:9050/HyperLoader.js"
      ```

4.  **Start Hyperswitch Backend Services (Docker)**:
    - In a terminal, navigate to the `hyperswitch` backend repository (e.g., `cd ../hyperswitch`).
    - Start services:
      ```bash
      # Inside the ../hyperswitch directory
      docker compose up -d --scale hyperswitch-control-center=0
      ```
    - This starts services in detached mode (`-d`).
    - `--scale hyperswitch-control-center=0` prevents Docker's control center UI, allowing local use.
    - Monitor logs: `docker compose logs -f hyperswitch-server` (or other services).

5.  **Start ReScript Compiler (Frontend)**:
    - In a new terminal (in `hyperswitch-control-center` directory).
    - Run ReScript compiler in watch mode:
      ```bash
      npm run re:start
      ```
    - Keep this running for automatic recompilation of `.res` to `.bs.js` files.

6.  **Start Frontend Development Server**:
    - In another new terminal (in `hyperswitch-control-center` directory).
    - Run the development server:
      ```bash
      npm run start
      ```
    - This starts webpack dev server, typically at `http://localhost:9000/` (check terminal output).

7.  **Access the Application**:
    - Open your browser to `http://localhost:9000/` (or the URL from `npm run start`).

Keep `npm run re:start` and `npm run start` terminals running during development.

## Hyperswitch Ecosystem

The Control Center operates within the broader Hyperswitch ecosystem, interacting with other components:

- **Hyperswitch Backend:** The core payment processing engine.
- **Hyperswitch SDK:** The JavaScript SDK used to interact with Hyperswitch.

## Target Audience

This technical context is relevant for:

- Developers working on the Control Center.
- Developers integrating with the Control Center or Hyperswitch.
- Anyone interested in understanding the technology stack used in the project.
