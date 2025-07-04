# Technical Specification: Routing Analytics Module

## 1. Overview

**Goal:**  
Add a new "Routing Analytics" module to the Hyperswitch Control Center, accessible via the sidebar, with a dedicated route and analytics dashboard UI as shown in the provided screenshot.

---

## 2. Sidebar & Navigation Integration

### 2.1. Sidebar Addition

- **Sidebar Configuration File:**  
  `src/entryPoints/SidebarValues.res`
- **Pattern:**  
  Analytics modules are grouped under an "Analytics" section using `Section` and `SubLevelLink`.
- **Action:**  
  - Add a new `SubLevelLink` for "Routing Analytics" under the Analytics section.
  - Example:
    ```rescript
    let routingAnalytics = SubLevelLink({
      name: "Routing Analytics",
      link: `/analytics-routing`,
      access: userHasResourceAccess(~resourceAccess=Analytics),
      searchOptions: [("View routing analytics", "")]
    })
    ```
  - Add `routingAnalytics` to the `links` array in the `analytics` section.

### 2.2. Route Addition

- **Router File:**  
  Likely `src/Orchestration/OrchestrationApp.res` (for orchestration product) or a similar main router file.
- **Pattern:**  
  Add a new case to the main router's `switch` statement for the new route.
- **Action:**  
  - Import the new page component (e.g., `RoutingAnalyticsPage`).
  - Add a route:
    ```rescript
    | list{"analytics-routing"} =>
      <AccessControl authorization={userHasAccess(~groupAccess=AnalyticsView)}>
        <FilterContext key="RoutingAnalytics" index="RoutingAnalytics">
          <RoutingAnalyticsPage />
        </FilterContext>
      </AccessControl>
    ```

---

## 3. Page & Component Structure

### 3.1. Page Component

- **Location:**  
  `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsPage.res` (suggested)
- **Structure:**  
  - Use a combination of:
    - `PageLoaderWrapper` for loading/error states
    - `PageUtils.PageHeading` for the title/subtitle
    - Reusable analytics components for stats, charts, tables, and filters

### 3.2. Reusable Components

- **Stats Cards:**  
  Use `DynamicSingleStat` (as in other analytics modules)
- **Charts:**  
  - Use `DynamicChart` for rendering analytics charts.
  - To support pie/donut charts, ensure the chart entity's `chartTypes` array includes `SemiDonut` (or the appropriate enum for pie/donut).
  - The actual pie chart is rendered using components like `HighchartPieChart` or `PieGraph`, which are invoked by the main chart rendering logic when the selected chart type is pie/donut.
  - Data for pie charts should be an array of objects with `name` and `y` fields (e.g., `{ name: "Logic A", y: 120 }`).
  - The chart type is selected via filter/context and mapped internally, not by a direct prop on `DynamicChart`.
- **Tables:**  
  Use `LoadedTableWithCustomColumns` or `TableWrapper` for summary and distribution tables
- **Filters:**  
  Use the standard filter bar and filter context (`FilterContext`)

#### Pie Chart Implementation

- To implement a pie or donut chart:
  - Add `SemiDonut` (or the appropriate enum) to the chart entity's `chartTypes` array.
  - Ensure the data is formatted as an array of `{ name, y }` objects.
  - The rendering logic will use `HighchartPieChart` or `PieGraph` to display the chart when the selected chart type is pie/donut.
  - The chart type is controlled by filter/context, not a direct prop.

### 3.3. Component Reuse

- **From:**  
  - `src/screens/Analytics/AnalyticsNew.res` (primary reference) for layout and logic
  - `src/screens/Analytics/Analytics.res` (fallback only if needed)
  - `src/screens/NewAnalytics/PaymentAnalytics/` and `src/screens/NewAnalytics/NewAuthenticationAnalytics/` for chart/table/filter patterns
- **How:**  
  - Copy and adapt the structure of `AnalyticsNew.res` for the new module, as its API response structure matches the expected routing analytics endpoints
  - Only refer to `Analytics.res` if a required pattern or component is not present in `AnalyticsNew.res`
  - Reuse chart/table/filter components by providing new entity/data definitions for routing analytics

---

## 4. API Integration

### 4.1. API Call Patterns

- **API Utility:**  
  Use `APIUtils.useGetURL`, `useGetMethod`, and `useUpdateMethod` hooks
- **Analytics Data:**  
  - For summary stats: Use a POST call to a metrics endpoint (see `ANALYTICS_PAYMENTS_V2`, `ANALYTICS_AUTHENTICATION_V2` in `AnalyticsNew`)
- For routing analytics:
  - **Summary stats, distribution, and time series data:**
    - `POST /analytics/v1/org/metrics/routing` — Returns summary stats, distribution, and time series data for routing analytics, filtered/grouped as per request body.
    - **Request structure:**
      ```json
      {
        "metrics": ["payment_success_rate", "payment_count", ...],
        "groupBy": ["routing_approach", ...],
        "filters": { ... },
        "startTime": "...",
        "endTime": "..."
      }
      ```
    - **Response structure:**
      - `metrics`: Array of available metric objects (`name`, `desc`)
      - `dimensions`: Array of available dimensions (including `routing_approach`)
      - `queryData`: Array of data points (for tables/charts)
      - `metaData`: Array of metadata for the query
  - **Available metrics include:**
    - `payment_success_rate`, `payment_count`, `payment_success_count`, `payment_processed_amount`, `avg_ticket_size`, `retries_count`, `connector_success_rate`, and sessionized variants
  - **Available dimension:**
    - `routing_approach` (newly added)
- For charts/tables: Use POST calls with filters, date ranges, and groupBy parameters, following the patterns in `AnalyticsNew`
- **API Entity Setup:**
  - Add a new entity (e.g., `ANALYTICS_ROUTING_V1`) in `src/APIUtils/APIUtilsTypes.res`
  - Map the entity to the backend endpoint in `src/APIUtils/APIUtils.res`
  - Example endpoint mapping:
    ```rescript
    | ANALYTICS_ROUTING_V1 =>
      switch methodType {
      | Post => `analytics/v1/org/metrics/routing`
      | Get => `analytics/v1/org/routing/info`
      | _ => ""
      }
    ```

### 4.2. Data Fetching

- **Initial Data:**  
  On mount, fetch available metrics, dimensions, and summary stats
- **Filters:**  
  Fetch available filter options (payment method, type, time range, etc.) using a filters endpoint
- **Charts/Tables:**  
  Fetch data for each chart/table based on current filters and time range

---

## 5. Data Modeling

### 5.1. Entity & Types

- **Define types for:**  
  - Routing analytics summary stats
  - Distribution data (volume, logic, etc.)
  - Table rows (routing logic, traffic %, payments, etc.)
  - Time series data for charts
  - **New dimension:**
    - `routing_approach` (enum, see below)
- **Location:**  
  `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsTypes.res` (suggested)

- **RoutingApproach enum values:**
  - `success_rate_exploitation`
  - `success_rate_exploration`
  - `contract_based_routing`
  - `debit_routing`
  - `rule_based_routing`
  - `volume_based_routing`
  - `default_fallback`

### 5.2. Entity Mappers

- **Implement:**  
  - `itemToObjMapper` for each data type
  - Table entity using `EntityType.makeEntity`
  - Chart entity for each chart type

---

## 6. State Management

- **Recoil Atoms:**  
  Add atoms for table column state in `src/Recoils/TableAtoms.res` if needed
- **Filter State:**  
  Use `FilterContext` for filter values and updates

---

## 7. UI/UX

- **Follow:**  
  - Existing analytics modules for layout, spacing, and responsiveness
  - Use consistent chart colors, legends, and filter dropdowns
- **Accessibility:**  
  - Ensure all charts/tables are keyboard accessible and have ARIA labels where needed

---

## 8. Testing

- **Manual:**  
  - Navigate via sidebar and direct URL
  - Verify data loads, filters work, and charts/tables render as expected
- **Automated:**  
  - Add unit tests for data mappers and API calls if test infra exists

---

## 9. Open Questions / Clarifications Needed

1. **API Endpoints:**  
   - **Resolved:** There is a dedicated backend endpoint for routing analytics.
   - **Paths:**
     - `GET /analytics/v1/org/routing/info` — Returns available metrics, filters, and dimensions for routing analytics.
     - `POST /analytics/v1/org/metrics/routing` — Returns summary stats, distribution, and time series data for routing analytics, filtered/grouped as per request body.
   - **Request/Response:**
     - Request and response structures follow the same pattern as other analytics modules (see above for details).
     - Example metrics: `payment_success_rate`, `payment_count`, `payment_success_count`, `payment_processed_amount`, `avg_ticket_size`, `retries_count`, `connector_success_rate`, and sessionized variants.
     - Example dimension: `routing_approach` (newly added, see below).
   - **Reference:** [PR #8408](https://github.com/juspay/hyperswitch/pull/8408)

2. **Data Model:**  
   - **Resolved:**
     - All standard payment analytics metrics are available, with the addition of the `routing_approach` dimension.
     - The `routing_approach` field is now present in the `payment_attempt` table and can be used for filtering and grouping.
     - **RoutingApproach enum values:**
       - `success_rate_exploitation`, `success_rate_exploration`, `contract_based_routing`, `debit_routing`, `rule_based_routing`, `volume_based_routing`, `default_fallback`
   - **Additional filters/dimensions unique to routing analytics:**
     - The main new dimension is `routing_approach`, which can be used as a filter or groupBy in analytics queries.

3. **Access Control:**  
   - **Resolved:** Routing analytics uses the same access control as the general analytics module. No additional restrictions or feature flags are required.

4. **Sidebar Placement:**  
   - **Resolved:** As per the spec and existing sidebar patterns, "Routing Analytics" should be a sub-item under the "Analytics" section.

5. **Chart Types:**  
   - **Unresolved:** Are there any custom chart types or visualizations not present in existing analytics modules?  
     - **Action:** Confirm with product/design if any new chart types are needed beyond those already supported (e.g., pie/donut, line, bar).

---

### Additional Open Questions

- **Composability of RoutingApproach:**  
  The PR discussion mentions future support for multiple routing algorithms per payment (composability).  
  - **Question:** Will the API/data model change soon to support multiple `routing_approach` values per attempt, or is it always a single value for now?
- **Backward Compatibility:**  
  - How are older payment attempts (before this column was added) handled in analytics queries?
- **API Versioning:**  
  - Routing analytics is only available in v1 endpoints. The frontend should use `/v1/` endpoints for all routing analytics queries.

---

### References

- [PR #8408: feat(analytics): Add RoutingApproach filter in payment analytics](https://github.com/juspay/hyperswitch/pull/8408)

---

**Next Steps:**  
- Clarify open questions with backend/API and product teams.
- Once API and data model are confirmed, proceed with implementation as per this spec.

---

**File Location:**  
This spec should be saved as `tasks/routing-analytics-module-spec.md`. 