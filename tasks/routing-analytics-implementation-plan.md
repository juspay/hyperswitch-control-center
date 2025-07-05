# Implementation Plan

Below is a detailed, step-by-step plan to implement the "Routing Analytics" module in the Hyperswitch Control Center. Each step is designed to be atomic and manageable for a code generation AI, modifying a small number of files and building logically on previous steps.

## Project Setup
- [x] Step 1: Set Up Directory Structure for Routing Analytics Module
  - **Task**: Create a directory for the Routing Analytics module and initialize the page component and types files with basic structures.
  - **Files**:
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsPage.res`: Create an empty ReScript component with a basic `make` function returning a placeholder `<div>`.
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsTypes.res`: Create an empty file for type definitions.
  - **Step Dependencies**: None
  - **User Instructions**: Ensure the project uses ReScript and all dependencies (e.g., React, Recoil) are installed via `npm install`.

## Navigation and Routing
- [x] Step 2: Add Routing Analytics to Sidebar
  - **Task**: Add a "Routing Analytics" sub-item under the Analytics section in the sidebar configuration.
  - **Files**:
    - `src/entryPoints/SidebarValues.res`: Add a `SubLevelLink` for "Routing Analytics" with `name: "Routing Analytics"`, `link: "/analytics-routing"`, appropriate `access` check, and include it in the `analytics` section's `links` array.
  - **Step Dependencies**: None
  - **User Instructions**: None

- [x] Step 3: Add Route for Routing Analytics
  - **Task**: Define a new route `/analytics-routing` in the main router, wrapping the page in access control and filter context.
  - **Files**:
    - `src/Orchestration/OrchestrationApp.res`: Add a case in the router's `switch` statement for `list{"analytics-routing"}`, including `<AccessControl>` and `<FilterContext>` with `RoutingAnalyticsPage`.
  - **Step Dependencies**: Step 1 (requires `RoutingAnalyticsPage.res`)
  - **User Instructions**: None

## Data Layer
- [x] Step 4: Define Data Types for Routing Analytics
  - **Task**: Define ReScript types for summary stats, distribution data, table rows, time series data, and the `RoutingApproach` enum.
  - **Files**:
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsTypes.res`: Add types (e.g., `summaryStats`, `distributionData`, `tableRow`, `timeSeriesData`) and `RoutingApproach` enum with values like `success_rate_exploitation`, `volume_based_routing`, etc.
  - **Step Dependencies**: Step 1
  - **User Instructions**: None

- [x] Step 5: Set Up API Entity for Routing Analytics
  - **Task**: Add a new API entity `ANALYTICS_ROUTING_V1` and map it to the routing analytics endpoints.
  - **Files**:
    - `src/APIUtils/APIUtilsTypes.res`: Add `ANALYTICS_ROUTING_V1` to the entity type definition.
    - `src/APIUtils/APIUtils.res`: Map `ANALYTICS_ROUTING_V1` to `/analytics/v1/org/metrics/routing` (POST) and `/analytics/v1/org/routing/info` (GET).
  - **Step Dependencies**: None
  - **User Instructions**: None

- [x] Step 6: Implement API Data Fetching Hooks
  - **Task**: Add hooks in the page component to fetch initial data, filter options, and chart/table data using API utilities.
  - **Files**:
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsPage.res`: Implement hooks with `APIUtils.useGetURL`, `useGetMethod`, and `useUpdateMethod` to fetch data from `ANALYTICS_ROUTING_V1`.
  - **Step Dependencies**: Step 4, Step 5
  - **User Instructions**: Ensure backend endpoints `/analytics/v1/org/metrics/routing` and `/analytics/v1/org/routing/info` are available and return expected data.

## State Management
- [x] Step 7: Set Up Filter State Management
  - **Task**: Configure `FilterContext` to manage filter state for Payment Method, Payment Method Type, Routing Logic, and Time Range.
  - **Files**:
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsPage.res`: Wrap the page content in `FilterContext` and define filter state variables.
  - **Step Dependencies**: Step 6
  - **User Instructions**: None

- [x] Step 8: Set Up Table Column State
  - **Task**: Add a Recoil atom for table column state and create the RoutingAnalyticsEntity for table management.
  - **Files**:
    - `src/Recoils/TableAtoms.res`: Define a new atom for routing analytics table column state.
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsEntity.res`: Create entity definition for routing analytics table with column types, mappers, and table configuration.
  - **Step Dependencies**: None
  - **User Instructions**: None

## UI Components
- [x] Step 9: Implement Summary Stats Cards
  - **Task**: Create four stat cards (Overall Auth Rate, First Attempt Auth Rate, Total Successful, Total Failure) using `DynamicSingleStat`.
  - **Files**:
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsEntity.res`: Add single stat types, data mappers, and entity configuration for summary stats.
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsPage.res`: Add `DynamicSingleStat` component to render the summary stats cards.
  - **Step Dependencies**: Step 6, Step 7, Step 8
  - **User Instructions**: None

- [x] Step 10: Implement Donut Charts for Distribution
  - **Task**: Create "Volume Distribution" and "Routing Logic Distribution" donut charts using `DynamicChart` with `SemiDonut`.
  - **Files**:
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsPage.res`: Add a section with two `DynamicChart` components, formatting data as `{ name, y }` objects.
  - **Step Dependencies**: Step 6, Step 7
  - **User Instructions**: Confirm with the design team if chart types beyond `SemiDonut` are required.

- [x] Step 11: Implement Summary Table
  - **Task**: Build a table with columns (Routing Logic, Traffic %, # of Payments, Auth Rate %, Processed Amount) using `LoadedTableWithCustomColumns`.
  - **Files**:
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsPage.res`: Add a table section with `LoadedTableWithCustomColumns` and column definitions.
  - **Step Dependencies**: Step 6, Step 7, Step 8 (if table state is used)
  - **User Instructions**: None

- [ ] Step 12: Implement Time Series Charts
  - **Task**: Create "Success Over Time" and "Volume Over Time" line charts using `DynamicChart`.
  - **Files**:
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsPage.res`: Add a section with two `DynamicChart` components configured as line charts.
  - **Step Dependencies**: Step 6, Step 7
  - **User Instructions**: None

- [ ] Step 13: Implement Filter Bar
  - **Task**: Add a filter bar with dropdowns for Payment Method, Payment Method Type, Routing Logic, and Time Range, integrated with `FilterContext`.
  - **Files**:
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsPage.res`: Add a filter bar section using `FilterContext` for state management.
  - **Step Dependencies**: Step 7
  - **User Instructions**: None

## Page Assembly
- [ ] Step 14: Assemble Routing Analytics Page
  - **Task**: Combine all UI components into the final page layout with `PageLoaderWrapper` and `PageUtils.PageHeading`.
  - **Files**:
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsPage.res`: Structure the page with a heading, filter bar, stats, charts, and table.
  - **Step Dependencies**: Step 9, Step 10, Step 11, Step 12, Step 13
  - **User Instructions**: None

## Testing
- [ ] Step 15: Add Manual Testing Steps
  - **Task**: Document steps to manually test navigation, data loading, filters, and UI rendering.
  - **Files**:
    - `tasks/routing-analytics-module-spec.md`: Add a "Manual Testing" section with instructions.
  - **Step Dependencies**: Step 14
  - **User Instructions**: Test by navigating to `/analytics-routing` via sidebar and URL, applying filters, and verifying all components.

- [ ] Step 16: Add Automated Tests (Optional)
  - **Task**: Add unit tests for data mappers and API calls if testing infrastructure exists.
  - **Files**:
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsPage_test.res`: Create a test file with unit tests.
  - **Step Dependencies**: Step 14
  - **User Instructions**: Ensure a test framework (e.g., Jest) is configured.

## Final Integration and Review
- [ ] Step 18: Ensure Accessibility and Responsiveness
  - **Task**: Add ARIA labels to charts and tables, and verify responsiveness across screen sizes.
  - **Files**:
    - `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsPage.res`: Update components with ARIA labels and responsive styles.
  - **Step Dependencies**: Step 14
  - **User Instructions**: Test with a screen reader and on various devices.

- [ ] Step 19: Resolve Open Questions
  - **Task**: Confirm chart types, `RoutingApproach` composability, and backward compatibility with relevant teams.
  - **Files**: None
  - **Step Dependencies**: Step 14
  - **User Instructions**: Contact the backend team to verify `RoutingApproach` behavior and older payment handling; confirm chart types with the design team.

---

### Summary of Approach and Key Considerations

This plan provides a clear roadmap for implementing the Routing Analytics module, starting with project setup and navigation, then building the data layer, state management, and UI components incrementally. The final steps assemble the page, add tests, and ensure quality through accessibility and reviews.

- **Logical Sequence**: Navigation and data are established first, as they're prerequisites for UI components. UI sections are built separately for modularity before final assembly.
- **Dependencies**: Each step relies only on completed prior steps, ensuring a smooth progression.
- **Modularity**: Reusing existing components (`DynamicSingleStat`, `DynamicChart`, etc.) aligns with the spec and reduces complexity.
- **Open Questions**: Steps to resolve uncertainties prevent future rework.
- **Testing**: Manual testing ensures functionality, with optional automated tests for robustness.
- **File Management**: Each step modifies 1-5 files, well below the 20-file limit, keeping changes manageable.

This plan fully addresses the technical specification and screenshot requirements, preparing the project for code generation while maintaining clarity and feasibility.