# Control Center Architecture

The Hyperswitch Control Center is a web-based dashboard that provides a user interface for managing and monitoring payment operations within the Hyperswitch ecosystem. It interacts with the Hyperswitch backend to facilitate various functionalities.

## Key Components and Interactions

While the Control Center is primarily a frontend application, it relies heavily on the Hyperswitch backend. Here's a simplified overview:

* **Frontend (Control Center):**
    * Built using ReScript.
    * Provides the user interface for interacting with Hyperswitch.
    * Handles user authentication and authorization.
    * Makes API requests to the Hyperswitch backend.
    * Visualizes data and provides tools for managing payments, processors, and routing.
* **Backend (Hyperswitch Core):**
    * Written in Rust.
    * Provides the API endpoints that the Control Center interacts with.
    * Handles the core payment processing logic, routing, and connector management.
    * Manages data storage (PostgreSQL) and caching (Redis).
* **Database (PostgreSQL):**
    * Stores persistent data, including merchant information, payment details, processor configurations, and routing rules.
* **Message Queue (Redis):**
    * Used for caching and potentially for asynchronous task management.

## Architectural Diagram (Simplified)

## Interaction Flow

1.  A user interacts with the Control Center through their web browser.
2.  The Control Center sends API requests to the Hyperswitch backend to perform actions such as:
    * Creating and managing payment processors.
    * Configuring routing rules.
    * Viewing payment details.
    * Initiating refunds.
3.  The Hyperswitch backend processes these requests, interacting with the database and other components as needed.
4.  The backend sends responses back to the Control Center, which then displays the information to the user.

## Relevant Hyperswitch Architecture Documentation

For more detailed information on the overall Hyperswitch architecture, refer to the official documentation:

* [Hyperswitch Architecture](https://docs.hyperswitch.io/learn-more/hyperswitch-architecture)