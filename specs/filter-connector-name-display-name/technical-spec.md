# Technical Spec: Filter Connectors by Name and Display Name

## Overview

Extend the connector search functionality in processor cards to filter by both the internal connector name and the user-friendly display name. This improves discoverability when users search for connectors using common names (e.g., "Stripe") rather than technical identifiers (e.g., "stripe").

## Problem Statement

Currently, when users type in the search box on processor cards, the filter only matches against the connector's internal name (lowercase technical identifier). Users who type "Stripe" won't find the connector because its internal name is "stripe".

## Technical Approach

### Solution

Modify the `connectorListFiltered` computation in processor card components to:

1. Get both the connector name and display name for each connector
2. Convert both to lowercase for case-insensitive matching
3. Check if either the connector name OR display name contains the search query

### Files to Modify

1. **`src/screens/Processors/ProcessorCards.res`** (lines 199-211)
   - Update `connectorListFiltered` to filter by both name and display name

2. **`src/OrchestrationV2/OrchestrationV2Screens/Connectors/PaymentProcessorCards.res`** (lines 184-196)
   - Update `connectorListFiltered` to filter by both name and display name

3. **`src/RevenueRecovery/RevenueRecoveryScreens/RecoveryProcessors/RecoveryProcessorsPaymentProcessors/RecoveryProcessorCards.res`** (lines 174-186)
   - Update `connectorListFiltered` to filter by both name and display name

### Implementation Details

Each file has a similar pattern that needs updating:

**Current Pattern:**

```rescript
let connectorListFiltered = {
  if searchedConnector->LogicUtils.isNonEmptyString {
    connectorsAvailableForIntegration->Array.filter(item =>
      item->getConnectorNameString->String.includes(searchedConnector->String.toLowerCase)
    )
  } else {
    connectorsAvailableForIntegration
  }
}
```

**New Pattern:**

```rescript
let connectorListFiltered = {
  if searchedConnector->LogicUtils.isNonEmptyString {
    connectorsAvailableForIntegration->Array.filter(item => {
      let connectorName = item->getConnectorNameString
      let displayName = connectorName->getDisplayNameForConnector(~connectorType)
      let searchLower = searchedConnector->String.toLowerCase
      connectorName->String.toLowerCase->String.includes(searchLower) ||
      displayName->String.toLowerCase->String.includes(searchLower)
    })
  } else {
    connectorsAvailableForIntegration
  }
}
```

### Dependencies

- `ConnectorUtils.getConnectorNameString` - Extracts connector name from connector type
- `ConnectorUtils.getDisplayNameForConnector` - Maps connector name to display name
- `LogicUtils.isNonEmptyString` - Checks if search string is non-empty

## Data Flow

1. User types in search box → triggers `handleSearch`
2. `searchedConnector` state updates with input value
3. `connectorListFiltered` recomputes based on new search value
4. Filter function checks each connector:
   - Get connector name (e.g., "stripe")
   - Get display name (e.g., "Stripe")
   - Check if either contains search query (case-insensitive)
5. Filtered list passed to `descriptedConnectors` for rendering

## Edge Cases

### Case Sensitivity

- Both connector name and display name are converted to lowercase before comparison
- Search query is also lowercased
- Example: "STRIPE", "stripe", "Stripe" all match

### Partial Matches

- Uses `String.includes` for substring matching
- Example: "str" matches "stripe" and "Stripe"

### Empty Search

- When search is empty, all connectors are shown (no filtering)

### Unknown Connectors

- If `getDisplayNameForConnector` returns the input string for unknown connectors, the OR condition ensures the connector name match still works

## Testing Considerations

1. **Search by display name**: Type "Stripe" should show stripe connector
2. **Search by internal name**: Type "stripe" should still show stripe connector
3. **Partial search**: Type "Str" should match "Stripe" and "stripe"
4. **Case insensitivity**: Type "STRIPE" should match
5. **No results**: Type "xyz" should show "Request a processor" state
6. **Empty search**: Clear search should show all connectors
