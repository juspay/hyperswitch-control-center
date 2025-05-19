# Steps to Add a New Connector

These are the steps to follow when adding a new connector to the Hyperswitch Control Center.

## 1. Gather Connector Details

Collect the following information about the new connector:

- **Connector Name:** (e.g., Stripe, Paypal, Adyen)
- **Connector Description:** (A brief description of the connector)
- **Connector Type:** (Choose one: Processors, PayoutProcessor, ThreeDsAuthenticator, FRM, PMAuthenticationProcessor, TaxProcessor, BillingProcessor. Default is 'Processors'.)

## 2. Code Implementation

1.  **Define Connector Variant in `ConnectorTypes.res`:**

    - Add the new connector as a variant to the appropriate connector type (e.g., `payoutProcessorTypes`, `processorTypes`).

2.  **Modify `ConnectorUtils.res`:**
    - **Add to Connector List:** Add the new connector to the appropriate connector list (e.g., `payoutConnectorList`, `connectorList`).
    - **Create Connector Info:** Define a new information record for the connector, including:
      - `name`: (connector name in lowercase)
      - `displayName`: (connector display name)
      - `description`: (connector description)
      - `logo`: (placeholder or connector logo)
    - **Update Utility Functions:** Update the following functions to include the new connector:
      - `getConnectorNameTypeFromString`
      - `getDisplayNameForConnector`
      - `getConnectorInfo`
      - `getConnectorNameString`

## 3. Memory Bank Update

1.  **Update `activeContext.md`:**
    - Describe the current work, including the connector details and the files modified.
2.  **Update `progress.md`:**
    - Log the addition of the new connector as a key milestone.

## Example

See the recent addition of `payoutTestConnector` for a practical example of these steps.
