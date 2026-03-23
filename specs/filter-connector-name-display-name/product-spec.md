# Product Spec: Filter Connectors by Name and Display Name

## Problem

In the processor cards, when users search for connectors, the filter only matches against the internal connector name (technical identifier). This creates a poor user experience because:

- Users typically think of connectors by their brand names (e.g., "Stripe", "Adyen")
- The internal names are lowercase technical identifiers (e.g., "stripe", "adyen")
- Users typing "Stripe" won't find the connector, even though that's how it's displayed

## Goals

1. Improve connector discoverability through search
2. Allow users to find connectors using either technical names or display names
3. Maintain case-insensitive search behavior
4. Ensure consistent experience across all processor card implementations

## User Stories

### Story 1: Search by Display Name

As a merchant admin, I want to type "Stripe" in the search box and see the Stripe connector card, so that I can quickly find and connect to Stripe using the familiar brand name.

**Acceptance Criteria:**

- Given I am on the connectors page with processor cards visible
- When I type "Stripe" in the search box
- Then I see the Stripe connector card displayed

### Story 2: Search by Internal Name Still Works

As a merchant admin, I want to type "stripe" (lowercase) and still find the Stripe connector, so that my existing search habits continue to work.

**Acceptance Criteria:**

- Given I am on the connectors page with processor cards visible
- When I type "stripe" in the search box
- Then I see the Stripe connector card displayed

### Story 3: Partial Search Matches

As a merchant admin, I want to type partial names like "Str" and see matching connectors, so that I can find connectors quickly without typing full names.

**Acceptance Criteria:**

- Given I am on the connectors page with processor cards visible
- When I type "Str" in the search box
- Then I see Stripe and any other connectors with "Str" in their name or display name

## Acceptance Criteria

### Functional Requirements

1. **Dual Search Support**
   - Search matches both `connectorName` (e.g., "stripe") and `displayName` (e.g., "Stripe")
   - Search is case-insensitive for both fields

2. **Partial Matching**
   - Substring matches are supported (e.g., "str" matches "stripe")
   - Works for both connector name and display name

3. **Empty Search State**
   - When search box is empty, all unconfigured connectors are displayed
   - No filtering is applied

4. **No Results State**
   - When no connectors match the search, show "Request a processor" prompt
   - Current behavior is preserved

### Non-Functional Requirements

1. **Performance**
   - Search filtering should be instantaneous (<100ms)
   - No debouncing required as dataset is small (<100 connectors)

2. **Consistency**
   - Same search behavior across all processor card implementations:
     - Main processors page
     - Orchestration V2 connectors
     - Revenue Recovery processors

3. **Accessibility**
   - Search input remains accessible with proper ARIA labels
   - Keyboard navigation continues to work

## Out of Scope

1. **Fuzzy Search**: Exact substring matching only, no fuzzy matching (e.g., "strpe" won't match "stripe")
2. **Search History**: No saving of previous searches
3. **Advanced Filters**: No additional filter criteria (country, payment methods, etc.)
4. **Search Analytics**: No tracking of search queries
5. **Description Search**: Not searching connector descriptions

## Success Metrics

1. **User Task Completion**: Users can find and connect to desired processors without requesting new ones due to search failures
2. **Reduced "Request Connector" Submissions**: Fewer unnecessary connector requests because users couldn't find existing connectors
3. **Search Success Rate**: Percentage of searches that return at least one result increases
