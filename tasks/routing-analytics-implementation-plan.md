# Implementation Plan: Routing Analytics Module

This plan breaks down the technical specification for the Routing Analytics module into actionable steps. Each step has a checkbox for tracking progress.

---

## 1. Sidebar & Navigation Integration

- [x] Add "Routing Analytics" as a sub-item under the Analytics section in the sidebar (`src/entryPoints/SidebarValues.res`)
- [x] Add a new route for Routing Analytics in the main router file (likely `src/Orchestration/OrchestrationApp.res`)

## 2. Page & Component Structure

- [x] Create the main page component: `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsPage.res`
- [x] Set up the page layout using `PageLoaderWrapper` and `PageUtils.PageHeading`
- [ ] Integrate reusable analytics components (stats cards, charts, tables, filters)

## 3. API Integration

- [ ] Add a new API entity for routing analytics in `src/APIUtils/APIUtilsTypes.res`
- [ ] Map the new entity to the backend endpoint in `src/APIUtils/APIUtils.res`
- [ ] Implement API calls for summary stats, distribution, and time series data using `APIUtils.useGetURL`, `useGetMethod`, and `useUpdateMethod`
- [ ] Implement API call for fetching available filter options

## 4. Data Modeling

- [ ] Define types for routing analytics data in `src/screens/Analytics/RoutingAnalytics/RoutingAnalyticsTypes.res`
- [ ] Implement entity mappers (`itemToObjMapper`, table entity, chart entity)
- [ ] Add the `RoutingApproach` enum and ensure all values are covered

## 5. Component Implementation

- [ ] Implement stats cards using `DynamicSingleStat`
- [ ] Implement pie/donut and other charts using `DynamicChart` (ensure `SemiDonut` is supported)
- [ ] Implement summary and distribution tables using `LoadedTableWithCustomColumns` or `TableWrapper`
- [ ] Implement filter bar and connect to `FilterContext`

## 6. State Management

- [ ] Add Recoil atoms for table column state if needed (`src/Recoils/TableAtoms.res`)
- [ ] Ensure filter state is managed via `FilterContext`

## 7. UI/UX Polish

- [ ] Match layout, spacing, and responsiveness to existing analytics modules
- [ ] Ensure consistent chart colors, legends, and filter dropdowns
- [ ] Add ARIA labels and ensure accessibility for charts/tables

## 8. Testing

- [ ] Manually test navigation, data loading, filters, and rendering
- [ ] Add unit tests for data mappers and API calls (if test infra exists)

## 9. Documentation & Handover

- [ ] Update or create documentation for the new module
- [ ] Handover to QA or product for review

---

**File Location:** `tasks/routing-analytics-implementation-plan.md` 