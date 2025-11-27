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

let defaultDimensions = {
  dimension: #no_value,
  values: [],
}

let getSpecificDimension = (dimensions: dimensions, dimension: dimension) => {
  dimensions
  ->Array.filter(ele => ele.dimension == dimension)
  ->Array.at(0)
  ->Option.getOr(defaultDimensions)
}

let getGroupByForPerformance = (~dimensions: array<dimension>) => {
  dimensions->Array.map(v => (v: dimension :> string))
}

let getMetricForPerformance = (~metrics: array<metrics>) =>
  metrics->Array.map(v => (v: metrics :> string))

let getFilterForPerformance = (
  ~dimensions: dimensions,
  ~filters: option<array<dimension>>,
  ~custom: option<dimension>=None,
  ~customValue: option<array<status>>=None,
  ~excludeFilterValue: option<array<status>>=None,
) => {
  let filtersDict = Dict.make()
  let customFilter = custom->Option.getOr(#no_value)
  switch filters {
  | Some(val) => {
      val->Array.forEach(filter => {
        let data = if filter == customFilter {
          customValue->Option.getOr([])->Array.map(v => (v: status :> string))
        } else {
          getSpecificDimension(dimensions, filter).values
        }

        let updatedFilters = switch excludeFilterValue {
        | Some(excludeValues) =>
          data->Array.filter(item => {
            !(excludeValues->Array.map(v => (v: status :> string))->Array.includes(item))
          })
        | None => data
        }->Array.map(str => str->JSON.Encode.string)

        filtersDict->Dict.set((filter: dimension :> string), updatedFilters->JSON.Encode.array)
      })
      filtersDict->JSON.Encode.object->Some
    }
  | None => None
  }
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
  ~groupBy: option<array<dimension>>=None,
  ~filters: option<array<dimension>>=[]->Some,
  ~customFilter: option<dimension>=None,
  ~excludeFilterValue: option<array<status>>=None,
  ~applyFilterFor: option<array<status>>=None,
  ~distribution: option<distributionType>=None,
  ~delta: option<bool>=None,
) => {
  let metrics = getMetricForPerformance(~metrics)
  let filter = getFilterForPerformance(
    ~dimensions,
    ~filters,
    ~custom=customFilter,
    ~customValue=applyFilterFor,
    ~excludeFilterValue,
  )
  let groupByNames = switch groupBy {
  | Some(vals) => getGroupByForPerformance(~dimensions=vals)->Some
  | None => None
  }
  let distributionValues = distribution->Identity.genericTypeToJson->Some

  [
    AnalyticsUtils.getFilterRequestBody(
      ~metrics=Some(metrics),
      ~delta=delta->Option.getOr(false),
      ~distributionValues,
      ~groupByNames,
      ~filter,
      ~startDateTime=startTime,
      ~endDateTime=endTime,
    )->JSON.Encode.object,
  ]->JSON.Encode.array
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

module Card = {
  @react.component
  let make = (~title, ~children) => {
    <div
      className={`h-full flex flex-col justify-between border rounded-lg dark:border-jp-gray-850 bg-white dark:bg-jp-gray-lightgray_background overflow-hidden singlestatBox px-7 py-5`}>
      <div className={"flex gap-2 items-center text-jp-gray-700 font-bold self-start mb-5"}>
        <div className="font-semibold text-base text-black dark:text-white">
          {title->React.string}
        </div>
      </div>
      {children}
    </div>
  }
}

let customUI = (title, ~height="h-96") =>
  <Card title>
    <div
      className={`w-full ${height} border-2 flex justify-center items-center border-dashed opacity-70 rounded-lg p-5`}>
      {"No Data"->React.string}
    </div>
  </Card>
