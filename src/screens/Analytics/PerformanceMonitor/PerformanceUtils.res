open PerformanceMonitorTypes
open LogicUtils
let paymentDistributionInitialValue = {
  payment_count: 0,
  status: "",
  connector: "",
  payment_method: "",
}
let distributionObjMapper = dict => {
  {
    payment_count: dict->getDictFromJsonObject->getInt("payment_count", 0),
    status: dict->getDictFromJsonObject->getString("status", ""),
    connector: dict->getDictFromJsonObject->getString("connector", ""),
    payment_method: dict->getDictFromJsonObject->getString("payment_method", ""),
  }
}
let paymentDistributionObjMapper = json => {
  json
  ->getDictFromJsonObject
  ->getArrayFromDict("queryData", [])
  ->Array.map(dict => dict->distributionObjMapper)
}

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
  [
    ("startTime", startTime->JSON.Encode.string),
    ("endTimeVal", endTime->JSON.Encode.string),
  ]->getJsonFromArrayOfJson
}

let requestBody = (
  ~dimensions: dimensions,
  ~startTime: string,
  ~endTime: string,
  ~metrics: array<metrics>,
  ~groupBy: array<dimension>,
  ~filters: array<dimension>,
  ~customFilter: option<dimension>,
  ~applyFilterFor: option<array<string>>,
) => {
  let timeRange = getTimeRange(startTime, endTime)
  let metrics = getMetricForPerformance(~metrics)
  let filters = getFilterForPerformance(
    ~dimensions,
    ~filters,
    ~custom=customFilter,
    ~customValue=applyFilterFor,
  )
  let groupByNames = getGroupByForPerformance(~dimensions=groupBy)
  let body = [
    {
      "timeRange": timeRange,
      "groupByNames": groupByNames,
      "filters": filters,
      "metrics": metrics,
    },
  ]->Identity.genericTypeToJson
  body
}

let getGroupByKey = (dict, keys: array<dimension>) => {
  let key =
    keys
    ->Array.map(key => {
      dict->getDictFromJsonObject->getString((key: dimension :> string), "")
    })
    ->Array.joinWith(":")
  key
}

let getGroupByDataForStatusAndPaymentCount = (array, keys: array<dimension>) => {
  let result = Dict.make()
  array->Array.forEach(entry => {
    let key = getGroupByKey(entry, keys)
    let connectorResult = Dict.get(result, key)
    switch connectorResult {
    | None => {
        let newConnectorResult = Dict.make()
        let st = entry->getDictFromJsonObject->getString("status", "")
        let pc = entry->getDictFromJsonObject->getInt("payment_count", 0)
        Dict.set(result, key, newConnectorResult)
        Dict.set(newConnectorResult, st, pc)
      }
    | Some(connectorResult) => {
        let st = entry->getDictFromJsonObject->getString("status", "")
        let pc = entry->getDictFromJsonObject->getInt("payment_count", 0)
        let currentCount = Dict.get(connectorResult, st)->Belt.Option.getWithDefault(0)
        Dict.set(connectorResult, st, currentCount + pc)
      }
    }
  })

  result
}
