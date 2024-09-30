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
    let timeVal = startingPoint.add(x, gap).endOf(gap).format("YYYY-MM-DD 00:00:00")
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

let requestBody = (
  ~dimensions as _: array<dimension>,
  ~startTime: string,
  ~endTime: string,
  ~metrics: array<metrics>,
  ~groupBy: option<array<dimension>>=None,
  ~filters as _: option<array<dimension>>=[]->Some,
  ~customFilter as _: option<dimension>=None,
  ~excludeFilterValue as _: option<array<status>>=None,
  ~applyFilterFor as _: option<array<status>>=None,
  ~delta: option<bool>=None,
  ~granularity: option<string>=None,
) => {
  let metrics = metrics->Array.map(v => (v: metrics :> string))
  let filter = Dict.make()->JSON.Encode.object->Some

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
      ~granularity,
    )->JSON.Encode.object,
  ]->JSON.Encode.array
}
