# Modules and Fragments

This document details specific module implementations like the Authentication module and the use of Fragments for reusable UI snippets.

## Authentication Module

The `src/entryPoints/AuthModule/` directory contains components and logic related to user authentication.

### Example: `AuthEntry.res`

The `src/entryPoints/AuthModule/AuthEntry.res` file defines the entry point for the authentication module.

- It uses `React.component` to define a functional React component.
- It uses `Recoil.useRecoilValueFromAtom` to access the `featureFlagAtom` Recoil state, specifically the `downTime` property.
- It uses `RenderIf` components to conditionally render content based on the `downTime` value.
  - If `downTime` is true, it renders the `UnderMaintenance` component.
  - If `downTime` is false, it renders a nested structure of providers and the `HyperSwitchApp` component.
- It uses nested providers to provide context values to the application:
  - `AuthInfoProvider` to provide authentication-related context.
  - `AuthWrapper` to handle authentication logic and UI.
  - `GlobalProvider` to provide global application context.
  - `UserInfoProvider` to provide user information context.
  - `ProductSelectionProvider` to provide product selection context.
- This component demonstrates a pattern of using feature flags to control the rendering of different parts of the application.
- It also demonstrates a pattern of using nested providers to manage and provide context values to different parts of the application.

## Fragments

The `src/fragments/` directory contains reusable UI snippets or partial components.

### Example: Structure

The `src/fragments/` directory contains the following:

- `ConnectorFragments/`: This directory likely contains fragments related to connectors.
- `FragmentUtils.res`: This file might contain utility functions for working with fragments.
- `VerticalStepIndicator/`: This directory likely contains a component for displaying a vertical step indicator.

This directory structure suggests a pattern of organizing reusable UI elements into a dedicated `fragments` directory.

### Example: `ConnectorFragments/`

The `src/fragments/ConnectorFragments/` directory contains components and logic related to connector fragments.

- `ConnectorAuthKeys/`: This directory likely contains components for displaying and managing connector authentication keys.
- `ConnectorFragmentUtils.res`: This file contains utility functions for working with connector fragments, such as `connectorLabelDetailField`. Currently, it only defines `connectorLabelDetailField`, which is a dictionary that maps "connector_label" to "Connector label".
- `ConnectorHelperV2.res`: This file contains helper functions and components for rendering connector-related UI elements. It includes functions for creating text inputs, select inputs, toggle inputs, and radio inputs. It also includes React components for displaying connector credentials (`CredsInfoField`, `CashtoCodeCredsInfo`, `PreviewCreds`) and processor status (`ProcessorStatus`).
- `ConnectorLabel/`: This directory likely contains components for displaying connector labels.
- `ConnectorMetadataV2/`: This directory likely contains components for displaying and managing connector metadata.
- `ConnectorPaymentMethodv2/`: This directory likely contains components for displaying and managing connector payment methods.
- `ConnectorWebhookDetails/`: This directory likely contains components for displaying connector webhook details.

This directory structure suggests a pattern of organizing reusable UI elements related to connectors into a dedicated `ConnectorFragments` directory.
