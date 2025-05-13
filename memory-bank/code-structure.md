# Control Center Code Structure

This document provides an overview of the Hyperswitch Control Center's code structure to help developers navigate the codebase.

## Top-Level Directories

Here's a breakdown of the main directories in the repository:

- \`src\`: Contains the main source code for the Control Center application.
- \`public\`: Contains static assets such as HTML, CSS, images, and other files served directly to the browser.
- \`build\`: The output directory where the built and optimized application is placed. (This is created during the build process.)
- \`node_modules\`: Contains the installed Node.js packages (libraries and dependencies). (This is created when you run `npm install`.)

## Key Files and Directories within `src`

Inside the `src` directory, you'll find the core application logic. The structure here is ReScript-specific, so some familiarity with ReScript is helpful.

- (The following is a general outline. A precise structure requires inspecting the actual codebase.)
- `index.res`: The main entry point of the Control Center application.
- Components:
  - Contains reusable UI components.
  - Organized by feature or functionality (e.g., `PaymentTable.res`, `RoutingConfiguration.res`).
- Pages:
  - Contains the code for different pages or views in the Control Center (e.g., the main dashboard, payment details page, processor settings).
- App.res: Main application component.
- Routes/Routing: Files related to defining the application's navigation and routing logic.
- Styles: CSS or styling-related files (if not using a CSS-in-JS approach).
- Lib: Utility functions, helper modules, and shared logic.
- Context: React Context files for managing global state.
- Api: Files related to making API requests to the Hyperswitch backend.

## ReScript Specifics

- The Control Center is built using ReScript, a language that compiles to JavaScript.
- ReScript code is organized into modules.
- File extensions are typically `.res` for ReScript source files and `.resi` for interface files.

## Important Considerations

- The code structure may evolve over time.
- Refer to the ReScript documentation for language-specific details.
- Use your IDE's code navigation features to explore the codebase effectively.
