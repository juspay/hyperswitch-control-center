# Control Center Configuration

The Hyperswitch Control Center's behavior can be configured through various settings. This document outlines key configuration aspects.

## Key Configuration Areas

* **API URLs:**
    * The Control Center needs to be configured with the correct URLs for the Hyperswitch backend API and SDK.
    * These URLs define where the Control Center sends requests and loads resources.
    * See the `local-setup.md` for details on setting these URLs during local development.  In a deployed environment, these would be set to your production URLs.
* **Feature Flags:**
    * The Control Center may use feature flags to enable or disable certain functionalities.
    * These flags can control access to new features, A/B testing, or specific environments.
    * Examples of feature flags (which may or may not be present, check the code):
        * `reports`:  Enables/disables report generation.
        * `mixpanel`: Enables/disables data collection for analytics.
        * `test_processors`: Enables/disables the use of test payment processors.
        * `recon`: Enables/disables reconciliation features.
* **Authentication and Authorization:**
    * Configuration related to user authentication (login, signup) and authorization (access control to different parts of the Control Center).
    * This often involves interaction with the Hyperswitch backend's user management system.
* **Environment Variables:**
     * The Control Center, being a web application, may use environment variables to configure settings that vary between development, testing, and production environments.  Examples:
         * API endpoint.
         * Base URL.
         * Authentication settings.

## Where to Find Configuration

The specific location and format of configuration may vary. Here are some common places to look:

* **Environment variables:** These are often set in the shell environment where the Control Center is run.
* **Configuration files:** There might be a dedicated configuration file (e.g., `.env`, `config.js`, or a file within the Hyperswitch backend) that stores settings.  Check the Control Center's codebase and documentation for specifics.
* **Hyperswitch backend configuration:** Some Control Center settings might be tied to the overall Hyperswitch backend configuration.

**Important:** Always consult the official Hyperswitch Control Center documentation and codebase for the most accurate and up-to-date information on configuration.
