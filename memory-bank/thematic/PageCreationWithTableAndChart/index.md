# Page Creation with Tables and Charts

This guide provides comprehensive patterns and best practices for creating dashboard pages with tables and charts in the Hyperswitch Control Center application.

## Overview

Modern dashboard pages typically include both tabular data displays and visual representations in the form of charts. This guide explains how to implement such pages following the application's architecture and patterns.

## Key Components

A typical dashboard page with tables and charts consists of:

1. **Dashboard Component** - The main React component that:
   - Manages state for data
   - Handles data fetching and transformations
   - Renders UI components including tables and charts
   - Provides user interaction handlers

2. **Entity Definition** - Defines the structure of the data and how it relates to table columns

3. **Utility Functions** - For data transformations and chart configurations

4. **Types** - Type definitions for the component's data model

## Implementation Guide

### Step 1: Define Data Types

Begin by defining the data types that will be used throughout the component:

```rescript
// In YourModuleTypes.res
type dataItem = {
  id: string,
  name: string,
  value: int,
  // Additional fields...
}

type yourModuleData = {
  title: string,
  items: array<dataItem>,
}
```

### Step 2: Create Entity for Table

Define the entity for the table component:

```rescript
// In YourModuleEntity.res
let defaultColumns = [
  Table.makeColumn(~key="id", ~title="ID", ~dataIndex="id", ~fixed=false, ()),
  Table.makeColumn(~key="name", ~title="Name", ~dataIndex="name", ~fixed=false, ()),
  // Additional columns...
]

// See tableImplementation.md for detailed implementation
```

### Step 3: Create Chart Utility Functions

Create utility functions to generate chart configurations:

```rescript
// In YourModuleGraphUtils.res
let getChartOptions = (data: yourModuleData) => {
  // See chartImplementation.md for detailed implementation
}
```

### Step 4: Implement Dashboard Component

Create the main dashboard component that brings everything together:

```rescript
// In YourModuleApp/YourModuleDashboard.res
@react.component
let make = () => {
  // State variables
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (data, setData) = React.useState(_ => initialData)
  let (tableData, setTableData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let resultsPerPage = 20

  // Fetch or prepare data
  React.useEffect(() => {
    // Transform data for table
    setTableData(_ => transformedData)
    None
  }, [data])

  <PageLoaderWrapper screenState>
    <div className="p-6 bg-jp-gray-50 dark:bg-jp-gray-950 min-h-screen">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-semibold text-jp-gray-900 dark:text-jp-gray-100">
          {data.title->React.string}
        </h1>
        <p className="text-gray-600 dark:text-gray-400 mt-1">
          {"Description of the dashboard"->React.string}
        </p>
      </div>
      
      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <div className="bg-white dark:bg-jp-gray-950 rounded-lg shadow-md p-4">
          <h2 className="text-lg font-medium mb-4 text-jp-gray-900 dark:text-jp-gray-100">
            {"First Chart"->React.string}
          </h2>
          <div className="h-80">
            <LineGraph
              options={YourModuleGraphUtils.getLineChartOptions(data)->Obj.magic}
            />
          </div>
        </div>
        <div className="bg-white dark:bg-jp-gray-950 rounded-lg shadow-md p-4">
          <h2 className="text-lg font-medium mb-4 text-jp-gray-900 dark:text-jp-gray-100">
            {"Second Chart"->React.string}
          </h2>
          <div className="h-80">
            <BarGraph
              options={YourModuleGraphUtils.getBarChartOptions(data)->Obj.magic}
            />
          </div>
        </div>
      </div>
      
      {/* Table */}
      <div className="bg-white dark:bg-jp-gray-950 rounded-lg shadow-md p-4">
        <h2 className="text-lg font-medium mb-4 text-jp-gray-900 dark:text-jp-gray-100">
          {"Data Table"->React.string}
        </h2>
        <LoadedTableWithCustomColumns
          title="Data Table"
          hideTitle=true
          actualData={tableData->Array.map(Nullable.make)}
          entity=yourModuleEntity
          resultsPerPage
          showSerialNumber=true
          totalResults={tableData->Array.length}
          offset
          setOffset
          currrentFetchCount={tableData->Array.length}
          defaultColumns
          customColumnMapper=yourDataMapDefaultCols
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
```

## Detailed Implementation Guides

For more detailed information about specific implementations:

- [Chart Implementation Guide](./chartImplementation.md) - Detailed guide for implementing charts
- [Table Implementation Guide](./tableImplementation.md) - Detailed guide for implementing tables
- [Tooltip Implementation Guide](./tooltipImplementation.md) - Guide for implementing chart tooltips with proper formatting and data access patterns

## Real-World Example

The WebsiteTraffic module provides a complete example of this pattern:

- `src/WebsiteTraffic/WebsiteTrafficTypes.res` - Data types
- `src/WebsiteTraffic/WebsiteTrafficEntity.res` - Table entity definition
- `src/WebsiteTraffic/WebsiteTrafficGraphUtils.res` - Chart configuration utilities
- `src/WebsiteTraffic/WebsiteTrafficApp/WebsiteTrafficDashboard.res` - Main dashboard component

## Best Practices

1. **Separation of Concerns**
   - Keep data types, entity definitions, and utility functions in separate files
   - Extract reusable logic into utility functions

2. **Type Safety**
   - Use proper type annotations for all functions and data structures
   - Handle type casting carefully, especially for chart configurations

3. **Component Structure**
   - Use a common layout structure for dashboards for consistency
   - Group related charts together
   - Place tables below charts for a natural information flow

4. **Error Handling**
   - Use PageLoaderWrapper for handling loading states
   - Provide fallback UI for error states

5. **Performance**
   - Avoid unnecessary re-renders with proper React dependency arrays
   - Use memoization for expensive computations
