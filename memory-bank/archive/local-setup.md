# Local Development Setup for Hyperswitch Control Center

This document outlines the steps to set up and run the Hyperswitch Control Center frontend locally for development, connecting to a local instance of the Hyperswitch backend services running via Docker.

## Prerequisites

1.  **Node.js and npm**: Ensure Node.js (which includes npm) is installed on your machine. (The setup was tested with Node v16.0.0 and npm v7.10.0; newer versions are generally recommended).
2.  **Git**: Ensure Git is installed for cloning repositories.
3.  **Docker**: Ensure Docker Desktop (or Docker Engine) is installed and running, as the backend services will run in Docker containers.
4.  **Hyperswitch Backend Repository**: The `hyperswitch` backend repository should be cloned, typically as a sibling directory to the `hyperswitch-control-center` repository. If it's not present:
    ```bash
    # Example: If hyperswitch-control-center is in /Workspace/hyperswitch-control-center
    # Run from /Workspace:
    git clone --depth 1 --branch latest https://github.com/juspay/hyperswitch
    ```

## Setup Steps

1.  **Navigate to Control Center Directory**:
    Ensure your terminal is in the `hyperswitch-control-center` project root. (e.g., `/Users/jeeva.ramachandran/Workspace/hyperswitch-control-center`).

2.  **Install Frontend Dependencies**:
    If you haven't already, install the Node.js packages for the Control Center:

    ```bash
    npm install
    ```

    _(Note: If you encounter module resolution errors during `npm run start` for packages like `react-color`, ensure they are installed and saved to `package.json`, e.g., `npm install react-color --save`)_

3.  **Configure Backend URLs**:

    - Open the `config/config.toml` file located in the `hyperswitch-control-center` project.
    - Ensure the following endpoint configurations are set correctly to point to your local backend. These are the typical default ports for the Hyperswitch backend services when run via Docker:
      ```toml
      [default.endpoints]
      api_url="http://localhost:8080/api"
      sdk_url="http://localhost:9050/HyperLoader.js"
      ```

4.  **Start Hyperswitch Backend Services**:

    - In a terminal, navigate to the `hyperswitch` backend repository directory (e.g., `cd ../hyperswitch` if it's a sibling directory).
    - Run the following command to start the backend services using Docker Compose:
      ```bash
      # Inside the ../hyperswitch directory
      docker compose up -d --scale hyperswitch-control-center=0
      ```
    - This command starts all necessary backend services in detached mode (`-d`).
    - The `--scale hyperswitch-control-center=0` flag is important; it prevents Docker from starting its own version of the control center web UI, allowing our local version to be used instead.
    - Wait for the services to initialize. You can monitor logs using `docker compose logs -f hyperswitch-server` (or other service names like `hyperswitch-web`, `redis-standalone`, `pg`).

5.  **Start ReScript Compiler (Frontend)**:

    - In a new terminal window/tab, ensure you are in the `hyperswitch-control-center` directory.
    - Run the ReScript compiler in watch mode:
      ```bash
      npm run re:start
      ```
    - Keep this terminal running. It will automatically recompile ReScript (`.res`) files to JavaScript (`.bs.js`) as you make changes.

6.  **Start Frontend Development Server**:

    - In another new terminal window/tab (also in the `hyperswitch-control-center` directory).
    - Run the development server:
      ```bash
      npm run start
      ```
    - This will start the webpack development server, typically on `http://localhost:9000/`. Observe the terminal output for the exact URL (e.g., "Project is running at: Loopback: http://localhost:9000/").

7.  **Access the Application**:
    - Open your web browser and navigate to `http://localhost:9000/` (or the URL provided by the `npm run start` output).

You should now have the Hyperswitch Control Center running locally, connected to your local Hyperswitch backend services. Remember to keep the `npm run re:start` and `npm run start` terminals running while you are developing.
