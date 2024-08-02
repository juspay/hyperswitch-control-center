open PerformanceMonitorTypes

let defaultDimesions = {
  dimension: #no_value,
  values: [],
}

let getSpecificDimension = (dimensions: dimensions, dimension: dimension) => {
  dimensions
  ->Array.filter(ele => ele.dimension == dimension)
  ->Array.at(0)
  ->Option.getOr(defaultDimesions)
}

let getGroupByForPerformance = (~dimensions: array<dimension>) => {
  dimensions->Array.map(v => (v: dimension :> string)->JSON.Encode.string)->JSON.Encode.array
}

let getMetricForPerformance = (~metrics: array<metrics>) =>
  metrics->Array.map(v => (v: metrics :> string)->JSON.Encode.string)->JSON.Encode.array

let getFilterForPerformance = (
  ~dimensions: dimensions,
  ~filters: array<dimension>,
  ~custom: option<dimension>=None,
  ~customValue: option<array<string>>=None,
) => {
  let filtersDict = Dict.make()
  let customFilter = custom->Option.getOr(#no_value)
  filters->Array.forEach(filter => {
    let data = if filter == customFilter {
      customValue->Option.getOr([])->Array.map(v => v->JSON.Encode.string)
    } else {
      getSpecificDimension(dimensions, filter).values->Array.map(v => v->JSON.Encode.string)
    }
    filtersDict->Dict.set((filter: dimension :> string), data->JSON.Encode.array)
  })
  filtersDict->JSON.Encode.object
}

let getTimeRange = (startTime, endTime) => {
  [("startTime", startTime->JSON.Encode.string), ("endTimeVal", endTime->JSON.Encode.string)]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let getGroupBy = performanceType => {
  switch performanceType {
  | #ConnectorPerformance => getGroupByForPerformance(~dimensions=[#connector, #status])
  }
}

let getFilters = (performanceType, dimensions: dimensions) => {
  switch performanceType {
  | #ConnectorPerformance =>
    getFilterForPerformance(
      ~dimensions,
      ~filters=[#connector, #status],
      ~custom=Some(#status),
      ~customValue=Some(["charged", "failure"]),
    )
  }
}

let getMetric = performanceType => {
  switch performanceType {
  | #ConnectorPerformance => getMetricForPerformance(~metrics=[#payment_count])
  }
}

let connectorPerformanceBody = (startTime, endTime, dimensions: dimensions) => {
  let body = [
    {
      "timeRange": getTimeRange(startTime, endTime),
      "groupByNames": getGroupBy(#ConnectorPerformance),
      "filters": getFilters(#ConnectorPerformance, dimensions),
      "metrics": getMetric(#ConnectorPerformance),
    },
  ]->Identity.genericTypeToJson
  body
}
