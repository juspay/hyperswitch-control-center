# Chart Tooltip Implementation

This document outlines best practices and patterns for implementing tooltips in charts for ReScript applications, focusing on the specific challenges and solutions encountered during development.

## Overview

Tooltips are crucial for interactive data visualization components, providing additional context and information when users hover over chart elements. However, they can be particularly challenging to implement correctly in ReScript due to typing issues and the way they interact with underlying JavaScript charting libraries.

## Key Challenges

When implementing tooltips for charts, several challenges commonly arise:

1. **Type Safety vs. JavaScript Interop**: Chart libraries like Highcharts expect specific JavaScript callback structures that can be difficult to type precisely in ReScript.

2. **Accessing Context Data**: Tooltip formatters need access to the current hover point data, which is typically provided via the JavaScript `this` context.

3. **Different Point Structures**: Line graphs and bar graphs often have different point structures, requiring different handling approaches.

4. **Error Handling**: Robust error handling is necessary as tooltip data access can be unpredictable, especially with complex or sparse datasets.

## Correct Implementation Pattern

### 1. Using the `@this` Annotation

The most critical aspect of tooltip implementation is using the `@this` annotation to properly access the tooltip context:

```rescript
let tooltipFormatter = () => {
  open ChartTypes
  open LogicUtils

  (
    @this
    (formatter: pointFormatter) => {
      // Access tooltip data through 'formatter'
      // Create and return HTML
    }
  )->asTooltipPointFormatter
}
```

The `@this` annotation allows direct access to the JavaScript context that Highcharts provides, containing information about the points being hovered over.

### 2. Safe Data Access

Always implement safe data access patterns when working with tooltip data:

```rescript
// Define default values for safety
let defaultValue = {
  color: "", 
  x: "", 
  y: 0.0, 
  point: {index: 0},
  series: {name: ""}
}

// Safely access point data
let primaryPoint = formatter.points->getValueFromArray(0, defaultValue)
```

### 3. Processing Multiple Points

For charts with multiple series (like comparing 2024 vs 2025 data), iterate through all points to display complete information:

```rescript
// Process all points to show multiple series data
let pointRows = formatter.points->Array.map(point => {
  // Extract data and format HTML for each point
})->Array.joinWith("")
```

## Line Graph vs. Bar Graph Differences

### Line Graph Points

Line graph points typically include:
- `point.x`: The x-axis category/value
- `point.y`: The y-axis value
- `point.series.name`: The series name
- `point.color`: The line color

```rescript
// Line graph point access
let seriesName = point.series.name
let value = point.y->Int.fromFloat
```

### Bar Graph Points

Bar graph points may have a different structure. In particular, series information may not be directly accessible:

```rescript
// Bar graph point handling using index to determine series
formatter.points->Array.mapWithIndex((point, index) => {
  // Use index to determine series name since it might not be available on the point
  let seriesName = if index == 0 {
    "2024 Visitors"
  } else {
    "2025 Visitors"
  }
})
```

## Error Handling Techniques

Implement multiple layers of error handling to ensure tooltip stability:

1. **Default Values**: Always provide default values when accessing potentially undefined properties.

2. **Array Length Checks**: Check array lengths before accessing elements.

```rescript
let pointRows = if formatter.points->Array.length === 0 {
  `<div style="margin: 8px 0;">No data available</div>`
} else {
  // Process points
}
```

3. **Option Pattern**: Use ReScript's Option type for safer data access.

```rescript
// Using Option pattern
switch point.series {
  | {name} => name  // Extract name if available
  | _ => "Unknown"  // Fallback value
}
```

## Real-World Example: WebsiteTraffic Dashboard

In the WebsiteTraffic dashboard implementation, we faced and resolved the following issues:

### Line Graph Tooltip Challenge

**Issue**: The tooltip formatter wasn't showing the actual values for data points when hovering.

**Solution**: Implemented a proper formatter using `@this` annotation that accesses all points and displays each series value:

```rescript
let lineGraphTooltipFormatter = () => {
  open LineGraphTypes
  open LogicUtils

  (
    @this
    (formatter: pointFormatter) => {
      // Extract and format data from formatter.points
      // ...
    }
  )->asTooltipPointFormatter
}
```

### Bar Graph Tooltip Challenge

**Issue**: The bar graph tooltip only showed one series (2024 visitors) but not the other (2025 visitors).

**Solution**: Modified the formatter to process all points in the tooltip context, using the array index to identify which series each point belongs to:

```rescript
formatter.points->Array.mapWithIndex((point, index) => {
  // Use dataset names from our data structure since bar points don't have series.name
  let seriesName = if index == 0 {
    "2024 Visitors"
  } else {
    "2025 Visitors"
  }
  // Continue formatting point data
})
```

## Best Practices

1. **Use `@this` Annotation**: Always use this for tooltip formatters to access the context.

2. **Safe Access Patterns**: Use utility functions like `getValueFromArray` with default values.

3. **Process All Points**: Iterate through all points to display complete information.

4. **Consistent Styling**: Maintain consistent styling between different chart tooltips.

5. **Error Handling**: Implement comprehensive error handling for edge cases.

6. **Chart Type Awareness**: Be aware of the differences between chart types (line, bar, etc.) and handle them accordingly.

## Related Resources

- For general chart implementation patterns: See `chartImplementation.md`
- For chart type definitions: Refer to `src/components/Graphs/LineGraph/LineGraphTypes.res` and `src/components/Graphs/BarGraph/BarGraphTypes.res`
- For reference implementations: See `src/screens/NewAnalytics/NewAnalyticsUtils.res`
