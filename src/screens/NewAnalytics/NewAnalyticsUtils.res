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
