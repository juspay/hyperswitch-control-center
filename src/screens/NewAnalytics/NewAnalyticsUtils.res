let getBucketSize = granularity => {
  switch granularity {
  | "hour_wise" => "hour"
  | "week_wise" => "week"
  | "day_wise" | _ => "day"
  }
}

let fillMissingDataPoints = (
  ~data,
  ~startDate,
  ~endDate,
  ~timeKey="time_bucket",
  ~defaultValue: JSON.t,
  ~granularity: string,
) => {
  open LogicUtils
  let dataPoints = Dict.make()
  let startingPoint = startDate->DayJs.getDayJsForString
  let endingPoint = endDate->DayJs.getDayJsForString
  let gap = granularity->getBucketSize

  for x in 1 to endingPoint.diff(startingPoint.toString(), gap) {
    let newDict = defaultValue->getDictFromJsonObject->Dict.copy
    let timeVal = startingPoint.add(x, gap).endOf(gap).format("YYYY-MM-DD")
    newDict->Dict.set(timeKey, timeVal->JSON.Encode.string)
    dataPoints->Dict.set(timeVal, newDict->JSON.Encode.object)
  }

  data->Array.forEach(value => {
    let dataDict = value->getDictFromJsonObject
    dataPoints->Dict.set(dataDict->getString(timeKey, ""), value)
  })

  dataPoints->Dict.valuesToArray
}

open NewAnalyticsTypes

// let getFilterForPerformance = (
//   ~dimensions: dimension,
//   ~filters: option<array<dimension>>,
//   ~custom: option<dimension>=None,
//   ~customValue: option<array<status>>=None,
//   ~excludeFilterValue: option<array<status>>=None,
// ) => {
//   let filtersDict = Dict.make()
//   let customFilter = custom->Option.getOr(#no_value)
//   switch filters {
//   | Some(val) => {
//       val->Array.forEach(filter => {
//         let data = if filter == customFilter {
//           customValue->Option.getOr([])->Array.map(v => (v: status :> string))
//         } else {
//           getSpecificDimension(dimensions, filter).values
//         }

//         let updatedFilters = switch excludeFilterValue {
//         | Some(excludeValues) =>
//           data->Array.filter(item => {
//             !(excludeValues->Array.map(v => (v: status :> string))->Array.includes(item))
//           })
//         | None => data
//         }->Array.map(str => str->JSON.Encode.string)

//         filtersDict->Dict.set((filter: dimension :> string), updatedFilters->JSON.Encode.array)
//       })
//       filtersDict->JSON.Encode.object->Some
//     }
//   | None => None
//   }
// }

let requestBody = (
  ~dimensions: array<dimension>,
  ~startTime: string,
  ~endTime: string,
  ~metrics: array<metrics>,
  ~groupBy: option<array<dimension>>=None,
  ~filters: option<array<dimension>>=[]->Some,
  ~customFilter: option<dimension>=None,
  ~excludeFilterValue: option<array<status>>=None,
  ~applyFilterFor: option<array<status>>=None,
  ~delta: option<bool>=None,
) => {
  let metrics = metrics->Array.map(v => (v: metrics :> string))
  let filter = Dict.make()->JSON.Encode.object->Some
  //  getFilterForPerformance(
  //   ~dimensions,
  //   ~filters,
  //   ~custom=customFilter,
  //   ~customValue=applyFilterFor,
  //   ~excludeFilterValue,
  // )

  let groupByNames = switch groupBy {
  | Some(vals) => vals->Array.map(v => (v: dimension :> string))->Some
  | None => None
  }

  [
    AnalyticsUtils.getFilterRequestBody(
      ~metrics=Some(metrics),
      ~delta=delta->Option.getOr(false),
      ~groupByNames,
      ~filter,
      ~startDateTime=startTime,
      ~endDateTime=endTime,
    )->JSON.Encode.object,
  ]->JSON.Encode.array
}
