# Chart Implementation Pattern

This document outlines the implementation patterns for charts in ReScript React applications, which can serve as a reference for similar implementations across the application.

## Overview

Modern dashboard pages often include visualizations using chart components like LineGraph and BarGraph. This document explains how to properly implement charts with a focus on maintainability by extracting chart configurations into separate utility files.

## Key Components

### 1. Dashboard Component

The main dashboard component that:

- Manages state for data
- Transforms data for table display
- Renders chart components
- Uses utility functions for chart options

```rescript
// Dashboard chart rendering example
<LineGraph
  options={GraphUtils.getLineChartOptions(data)->Obj.magic}
/>

<BarGraph
  options={GraphUtils.getBarChartOptions(data)->Obj.magic}
/>
```

Note the use of `Obj.magic` to handle type compatibility between the JSON configuration and the expected component types.

### 2. Chart Utility File

A dedicated utility file containing functions to generate chart configurations:

```rescript
// Helper functions to generate options for charts used in dashboards
open DataTypes

// Create line chart options
let getLineChartOptions = (data: dataType) => {
  // Implementation details...
}

// Create bar chart options
let getBarChartOptions = (data: dataType) => {
  // Implementation details...
}
```

## Implementation Patterns

### 1. JSON Configuration Building

The chart configuration is built using ReScript's Dict API and JSON.Encode module:

```rescript
// Create options dict
let options = Dict.make()

// Chart settings
let chartDict = Dict.make()
chartDict->Dict.set("type", JSON.Encode.string("line"))
chartDict->Dict.set("height", JSON.Encode.int(400))
// More settings...
options->Dict.set("chart", chartDict->JSON.Encode.object)

// Return the options as JSON
options->JSON.Encode.object
```

This pattern allows for dynamic construction of complex nested JSON configurations required by charting libraries like Highcharts.

### 2. Data Transformation

Data from the application's typed model is transformed into the format required by the charts:

```rescript
// For series data
let lineSeries = data.datasets->Array.map(dataset => {
  let seriesDict = Dict.make()
  seriesDict->Dict.set("showInLegend", JSON.Encode.bool(true))
  seriesDict->Dict.set("name", JSON.Encode.string(dataset.label))
  // Convert int array to float array
  let floatData = dataset.data->Array.map(Float.fromInt)
  // Convert each float to JSON
  let jsonData = floatData->Array.map(JSON.Encode.float)
  // Set the data
  seriesDict->Dict.set("data", JSON.Encode.array(jsonData))
  seriesDict->Dict.set("color", JSON.Encode.string(dataset.borderColor))
  seriesDict->JSON.Encode.object
})
```

### 3. JavaScript Interop for Formatters

Chart formatters use raw JavaScript for compatibility with charting libraries' callback expectations:

```rescript
// This formatter function is written in JavaScript for compatibility
let formatterFunction = %raw(`
  function() {
    var points = this.points;
    var pointsHtml = points.map(function(point) {
      // HTML generation logic...
    }).join('');

    return '<div>...</div>';
  }
`)

tooltipDict->Dict.set("formatter", formatterFunction->Obj.magic)
```

The `%raw` syntax allows embedding JavaScript directly, and `Obj.magic` is used for type casting.

## Type Handling

Due to the complex nature of chart configuration options and the way ReScript handles types, there are a few type compatibility considerations:

1. The chart utility functions return `JSON.t` (pure JSON) while the chart components expect specific typed options.
2. `Obj.magic` is used in the dashboard to bridge this type gap.

This approach maintains type safety within the utility functions while allowing flexibility in the JSON structure required by charting libraries.

## Best Practices

1. **Separation of Concerns**:

   - Keep chart configuration logic separate from display components
   - Use utility functions for generating complex chart options

2. **Type Handling**:

   - Use proper type annotations for function parameters and returns
   - When necessary, use `Obj.magic` at the interface boundary between JSON and typed components

3. **JavaScript Interop**:

   - Use `%raw` for JavaScript code that doesn't easily translate to ReScript
   - Keep raw JavaScript minimal and focused on specific functionality (like formatters)

4. **Data Transformation**:
   - Transform application data to chart format in utility functions
   - Handle type conversions explicitly (e.g., int to float)

## Real Implementation Example: WebsiteTraffic Module

The WebsiteTraffic module provides a concrete example of this pattern:

```rescript
// In WebsiteTrafficApp/WebsiteTrafficDashboard.res
<LineGraph
  options={WebsiteTrafficGraphUtils.getVisitorsTrendOptions(websiteTrafficData)->Obj.magic}
/>

<BarGraph
  options={WebsiteTrafficGraphUtils.getMonthlyComparisonOptions(websiteTrafficData)->Obj.magic}
/>
```

With utilities defined in a separate file:

```rescript
// In WebsiteTrafficGraphUtils.res
let getVisitorsTrendOptions = (websiteTrafficData: websiteTrafficData) => {
  // Create data series with proper JSON encoding
  let lineSeries = websiteTrafficData.datasets->Array.map(dataset => {
    let seriesDict = Dict.make()
    // Set chart series properties...
    seriesDict->JSON.Encode.object
  })

  // Build chart options with Dict API
  let options = Dict.make()
  // Add chart configuration...

  // Return options as JSON
  options->JSON.Encode.object
}
```

## Related Components

- LineGraph component in `src/components/Graphs/LineGraph`
- BarGraph component in `src/components/Graphs/BarGraph`
