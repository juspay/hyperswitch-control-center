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
  let dataDict = Dict.make()
  data->Array.forEach(item => {
    let time = item->getDictFromJsonObject->getString(timeKey, "")
    dataDict->Dict.set(time, item)
  })
  let dataPoints = Dict.make()
  let startingPoint = startDate->DayJs.getDayJsForString
  let endingPoint = endDate->DayJs.getDayJsForString
  let gap = granularity->getBucketSize
  for x in 0 to endingPoint.diff(startingPoint.toString(), gap) {
    let newDict = defaultValue->getDictFromJsonObject->Dict.copy
    let timeVal = startingPoint.add(x, gap).endOf(gap).format("YYYY-MM-DD 00:00:00")
    switch dataDict->Dict.get(timeVal) {
    | Some(val) => {
        newDict->Dict.set(timeKey, timeVal->JSON.Encode.string)
        dataPoints->Dict.set(timeVal, val)
      }
    | None => {
        newDict->Dict.set(timeKey, timeVal->JSON.Encode.string)
        dataPoints->Dict.set(timeVal, newDict->JSON.Encode.object)
      }
    }
  }
  dataPoints->Dict.valuesToArray
}

open NewAnalyticsTypes

let requestBody = (
  ~dimensions as _: array<dimension>,
  ~startTime: string,
  ~endTime: string,
  ~metrics: array<metrics>,
  ~groupByNames: option<array<string>>=None,
  ~filters as _: option<array<dimension>>=[]->Some,
  ~customFilter as _: option<dimension>=None,
  ~excludeFilterValue as _: option<array<status>>=None,
  ~applyFilterFor as _: option<array<status>>=None,
  ~delta: option<bool>=None,
  ~granularity: option<string>=None,
  ~distributionValues: option<JSON.t>=None,
) => {
  let metrics = metrics->Array.map(v => (v: metrics :> string))
  let filter = Dict.make()->JSON.Encode.object->Some

  [
    AnalyticsUtils.getFilterRequestBody(
      ~metrics=Some(metrics),
      ~delta=delta->Option.getOr(false),
      ~groupByNames,
      ~filter,
      ~startDateTime=startTime,
      ~endDateTime=endTime,
      ~granularity,
      ~distributionValues,
    )->JSON.Encode.object,
  ]->JSON.Encode.array
}

let valueFormatter = (value, statType: valueType) => {
  open LogicUtils

  let percentFormat = value => {
    `${Float.toFixedWithPrecision(value, ~digits=2)}%`
  }

  switch statType {
  | Amount => value->indianShortNum
  | Rate => value->Js.Float.isNaN ? "-" : value->percentFormat
  | Volume => value->indianShortNum
  | Latency => latencyShortNum(~labelValue=value)
  | LatencyMs => latencyShortNum(~labelValue=value, ~includeMilliseconds=true)
  | No_Type => value->Float.toString
  }
}
let getComparisionTimePeriod = (~startDate, ~endDate) => {
  let startingPoint = startDate->DayJs.getDayJsForString
  let endingPoint = endDate->DayJs.getDayJsForString
  let gap = endingPoint.diff(startingPoint.toString(), "millisecond") // diff between points

  let startTimeValue = startingPoint.subtract(gap, "millisecond").toDate()->Date.toISOString
  let endTimeVal = endingPoint.subtract(gap, "millisecond").toDate()->Date.toISOString

  (startTimeValue, endTimeVal)
}
