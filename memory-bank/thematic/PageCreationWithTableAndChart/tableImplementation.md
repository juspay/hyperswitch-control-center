# Table Implementation Pattern

This document outlines the implementation patterns for data tables in ReScript React applications, providing a reusable reference for similar implementations across the application.

## Overview

Modern dashboard pages typically include data tables for displaying structured information. This document explains how to implement tables with proper entity definitions, column configurations, and data transformations.

## Key Components

### 1. Table Entity Definition

Define an entity type to represent the table structure and behavior:

```rescript
// In YourModuleEntity.res
let defaultColumns = [
  Table.makeColumn(~key="id", ~title="ID", ~dataIndex="id", ~fixed=false, ()),
  Table.makeColumn(~key="name", ~title="Name", ~dataIndex="name", ~fixed=false, ()),
  // Additional columns...
]

let allColumns = defaultColumns

let getCell = (data, colKey) => {
  switch colKey {
  | "id" => data.id->Table.makeCell
  | "name" => data.name->Table.makeCell
  | _ => ""->Table.makeCell
  }
}

let getHeading = (colKey, _columns) => {
  switch colKey {
  | "id" => "ID"
  | "name" => "Name"
  | _ => ""
  }
}

// Define how to fetch data (for real API endpoints)
let getTableData = (_, ~offset, ~limit, ~searchText as _, ~filters as _, ~sortBy as _, ~sortType as _) => {
  Fetch.Result.map(
    callYourApiHere(~offset, ~limit),
    response => {
      totalCount: response.totalCount,
      data: response.data,
    },
  )
}

// Create the entity definition
let tableEntity = EntityType.makeEntity(
  ~uri="your-api-endpoint",
  ~getObjects=getTableData,
  ~defaultColumns,
  ~allColumns,
  ~getHeading,
  ~getCell,
)
```

### 2. Table Mapping Function

Define a function to map your data model to the table format:

```rescript
let yourDataMapDefaultCols = (rawData: Nullable.t<yourDataType>) => {
  switch rawData->Nullable.toOption {
  | Some(row) => {
      "id": row.id,
      "name": row.name,
      // Map other fields as needed
    }
  | None => Dict.make()->JSON.Encode.object
  }
}
```

### 3. Dashboard Component

The main component that manages state and renders the table:

```rescript
@react.component
let make = () => {
  // State variables
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (tableData, setTableData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let resultsPerPage = 20

  // Fetch or prepare data
  React.useEffect(() => {
    // Transform your data into table format
    setTableData(_ => yourTransformedData)
    None
  }, [dependencies])

  <PageLoaderWrapper screenState>
    <div className="p-6 bg-jp-gray-50 dark:bg-jp-gray-950 min-h-screen">
      <div className="bg-white dark:bg-jp-gray-950 rounded-lg shadow-md p-4">
        <h2 className="text-lg font-medium mb-4 text-jp-gray-900 dark:text-jp-gray-100">
          {"Your Table Title"->React.string}
        </h2>
        <LoadedTableWithCustomColumns
          title="Your Table Title"
          hideTitle=true
          actualData={tableData->Array.map(Nullable.make)}
          entity=tableEntity
          resultsPerPage
          showSerialNumber=true
          totalResults={tableData->Array.length}
          offset
          setOffset
          currentFetchCount={tableData->Array.length}
          defaultColumns
          customColumnMapper=yourDataMapDefaultCols
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
```

## Implementation Patterns

### 1. Table Column Configuration

Define columns with appropriate properties:

```rescript
Table.makeColumn(
  ~key="columnKey",
  ~title="Column Title",
  ~dataIndex="columnKey",
  ~fixed=false,
  ~render=row => {
    // Custom rendering logic
    <div className="custom-formatting">
      {row["columnKey"]->React.string}
    </div>
  },
  (),
)
```

### 2. Data Transformation

Transform your application data model to the format expected by the table component:

```rescript
// Convert from your data model to table data
let transformData = (sourceData) => {
  sourceData->Array.map(item => {
    {
      id: item.id,
      name: item.name,
      // Transform other fields
      status: getStatusLabel(item.statusCode),
      date: formatDate(item.timestamp),
    }
  })
}
```

### 3. Custom Cell Rendering

Implement custom rendering for specific column types:

```rescript
let getCell = (data, colKey) => {
  switch colKey {
  | "status" =>
    switch data.status {
    | "Active" => <div className="text-green-600 font-medium">{data.status->React.string}</div>->Table.makeReactElementCell
    | "Inactive" => <div className="text-red-600 font-medium">{data.status->React.string}</div>->Table.makeReactElementCell
    | _ => data.status->Table.makeCell
    }
  | "date" => data.date->DateUtils.formatTableDate->Table.makeCell
  | _ => ""->Table.makeCell
  }
}
```

## Common Pitfalls & Troubleshooting

### Type Issues with Table.header

When defining headers, ensure you're using the correct type:

```rescript
// Incorrect
let headers = ["ID", "Name", "Status"]

// Correct
let headers = [
  Table.makeColumn(~key="id", ~title="ID", ~dataIndex="id", ~fixed=false, ()),
  Table.makeColumn(~key="name", ~title="Name", ~dataIndex="name", ~fixed=false, ()),
  Table.makeColumn(~key="status", ~title="Status", ~dataIndex="status", ~fixed=false, ()),
]
```

### ItemToObjMapper Signature

When using `LogicUtils.getArrayDataFromJson`, ensure your mapper function has the correct signature:

```rescript
// Correct signature
let itemToObjMapper = (json: JSON.t): yourDataType => {
  {
    id: json->LogicUtils.getStringFromJson("id", ""),
    name: json->LogicUtils.getStringFromJson("name", ""),
    // Other fields...
  }
}
```

### Module Routing References

Ensure correct module referencing in routes:

```rescript
// Incorrect
ReactRouter.push(`/yourModule/${item.id}`)

// Correct - use the defined route constants
ReactRouter.push(Route.yourModule(item.id))
```

## Real Implementation Example: WebsiteTraffic Module

The WebsiteTraffic module provides a concrete example of this pattern:

```rescript
// In WebsiteTrafficEntity.res
let defaultColumns = [
  Table.makeColumn(~key="month", ~title="Month", ~dataIndex="month", ~fixed=false, ()),
  Table.makeColumn(~key="visitors2024", ~title="2024 Visitors", ~dataIndex="visitors2024", ~fixed=false, ()),
  Table.makeColumn(~key="visitors2025", ~title="2025 Visitors", ~dataIndex="visitors2025", ~fixed=false, ()),
  Table.makeColumn(~key="growth", ~title="Growth (%)", ~dataIndex="growth", ~fixed=false, ()),
]

// In WebsiteTrafficDashboard.res
<LoadedTableWithCustomColumns
  title="Website Traffic Data"
  hideTitle=true
  actualData={tableData->Array.map(Nullable.make)}
  entity=websiteTrafficEntity
  resultsPerPage
  showSerialNumber=true
  totalResults={tableData->Array.length}
  offset
  setOffset
  currentFetchCount={tableData->Array.length}
  defaultColumns
  customColumnMapper=websiteTrafficMapDefaultCols
/>
```

## Related Components

- `LoadedTableWithCustomColumns` component from the core library
- `TableAtoms` for table state management
