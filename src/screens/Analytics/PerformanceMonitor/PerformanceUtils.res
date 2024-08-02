open PerformanceMonitorTypes
open ConnectorPerformanceUtils

let getTimeRange = (startTime, endTime) => {
  [("startTime", startTime->JSON.Encode.string), ("endTimeVal", endTime->JSON.Encode.string)]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let getFilters = (performanceType, dimensions: dimensions) => {
  switch performanceType {
  | #ConnectorPerformance =>
    getFilterForConnectorPerformance(~dimensions, ~status=[#failure, #charged])
  }
}

let getMetric = performanceType => {
  switch performanceType {
  | #ConnectorPerformance => {
      let metrics = ["payment_count"->JSON.Encode.string]
      metrics->JSON.Encode.array
    }
  }
}
let getGroupBy = performanceType => {
  switch performanceType {
  | #ConnectorPerformance => getGroupByForConnectorPerformance(~dimensions=[#connector, #status])
  }
}

let connectorPerformanceBody = (startTime, endTime, dimensions: dimensions) => {
  let body = Dict.make()
  let timeRange = getTimeRange(startTime, endTime)
  let filters = getFilters(#ConnectorPerformance, dimensions)
  let metrics = getMetric(#ConnectorPerformance)
  let groupBy = getGroupBy(#ConnectorPerformance)

  body->Dict.set("timeRange", timeRange)
  body->Dict.set("filters", filters)
  body->Dict.set("metrics", metrics)
  body->Dict.set("groupByNames", groupBy)
  body->JSON.Encode.object
}

let getPerformanceMonitorBody = (performanceType: performance, dimensions: dimensions) => {
  switch performanceType {
  | #ConnectorPerformance => connectorPerformanceBody("", "", dimensions)
  | _ => JSON.Encode.null
  }
}
