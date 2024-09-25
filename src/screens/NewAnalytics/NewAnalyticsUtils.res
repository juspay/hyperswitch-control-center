//Logic utils

open NewAnalyticsTypes
let getBucketSize = (granularity: granularity) => {
  switch granularity {
  | #hour_wise => "hour"
  | #day_wise => "day"
  | #week_wise => "week"
  }
}

let fillMissingDataPoints = (
  ~data,
  ~startDate,
  ~endDate,
  ~timeKey="time_bucket",
  ~defaultValue: Dict.t<JSON.t>,
  ~granularity: granularity,
) => {
  open LogicUtils
  let dataPoints = Dict.make()
  let startingPoint = startDate->DayJs.getDayJsForString
  let endingPoint = endDate->DayJs.getDayJsForString
  let gap = granularity->getBucketSize

  for x in 1 to endingPoint.diff(startingPoint.toString(), gap) {
    let newDict = defaultValue->Dict.copy
    let timeVal = startingPoint.add(x, gap).endOf(gap).format("YYYY-MM-DD HH:MM:SS")
    newDict->Dict.set(timeKey, timeVal->JSON.Encode.string)
    dataPoints->Dict.set(timeVal, newDict->JSON.Encode.object)
  }

  data->Array.forEach(value => {
    let dataDict = value->getDictFromJsonObject
    dataPoints->Dict.set(dataDict->getString(timeKey, ""), value)
  })

  dataPoints->Dict.valuesToArray
}
