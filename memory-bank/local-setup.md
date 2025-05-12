# Local Setup for Control Center

This guide outlines the steps to set up the Hyperswitch Control Center for local development.

## Prerequisites

* Node.js and npm installed on your machine.
* Git for cloning the repository.
* A running Hyperswitch backend instance.  See the Hyperswitch documentation for instructions on setting up the backend.  This usually involves Docker.

## Steps

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/juspay/hyperswitch-control-center.git](https://github.com/juspay/hyperswitch-control-center.git)
    cd hyperswitch-control-center
    ```

2.  **Install dependencies:**
    ```bash
    npm install
    ```

3.  **Start the ReScript compiler:**
    ```bash
    npm run re:start
    ```

4.  **Start the development server:**
    ```bash
    npm run start
    ```

5.  **Configure API URLs:**
    * The Control Center needs to know the URLs of your running Hyperswitch backend.  This is typically configured in a configuration file.  You'll need to set:
        * `api_url`: The URL of your Hyperswitch API (e.g., `http://localhost:8080`).
        * `sdk_url`:  The URL of the Hyperswitch SDK (e.g., `http://localhost:9050/HyperLoader.js`).
    * The exact configuration file and method may vary, so consult the Hyperswitch documentation for the most accurate instructions.  A common file is `config.toml` in the Hyperswitch backend.

6.  **Access the Control Center:**
    * Once the development server is running, you can access the Control Center in your web browser, typically at `http://localhost:3000`.

## Setting up the Hyperswitch Backend

The Control Center requires a running Hyperswitch backend to function.  Refer to the Hyperswitch documentation for detailed instructions on setting up the backend:

* [Hyperswitch Local Setup](https://docs.hyperswitch.io/hyperswitch-open-source/overview/local-setup-using-individual-components/)

This usually involves cloning the Hyperswitch repository and using Docker Compose to start the necessary services (PostgreSQL, Redis, Hyperswitch server).
