# Control Center Dependencies

This document lists the dependencies used by the Hyperswitch Control Center, as defined in the `package.json` file.

## Key Dependencies

The following is a summary of the main dependencies. For the most accurate and up-to-date list, please refer to the `package.json` file in the repository.

* **ReScript:** The primary language used to build the Control Center.
* **React:** A JavaScript library for building user interfaces.  ReScript bindings to React are used.
* **(Other Libraries):** The Control Center likely uses other libraries for various functionalities, such as:
    * **State management:** Libraries for managing application state (e.g., Redux, React Context).
    * **Routing:** Libraries for handling navigation between different pages.
    * **UI components:** Libraries providing pre-built UI elements.
    * **API communication:** Libraries for making HTTP requests to the Hyperswitch backend.
    * **Testing:** Libraries for writing and running tests (e.g., Jest).

## Examining `package.json`

To get the complete and most accurate list of dependencies:

1.  Open the `package.json` file in the root of the `hyperswitch-control-center` repository.
2.  Look for the `"dependencies"` and `"devDependencies"` sections.
    * `"dependencies"` lists the libraries required for the application to run in production.
    * `"devDependencies"` lists libraries used for development tasks (e.g., building, testing).

## Why This Matters

Understanding the dependencies is important for:

* Setting up the development environment (installing dependencies with `npm install`).
* Identifying potential conflicts or compatibility issues.
* Understanding the technologies used in the project.
* Security auditing (being aware of the libraries used).