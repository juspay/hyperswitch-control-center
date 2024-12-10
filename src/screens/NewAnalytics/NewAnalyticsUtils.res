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
  ~startTime: string,
  ~endTime: string,
  ~metrics: array<metrics>,
  ~groupByNames: option<array<string>>=None,
  ~filter: option<JSON.t>=None,
  ~delta: option<bool>=None,
  ~granularity: option<string>=None,
  ~distributionValues: option<JSON.t>=None,
) => {
  let metrics = metrics->Array.map(v => (v: metrics :> string))

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

let getMonthName = month => {
  switch month {
  | 0 => "Jan"
  | 1 => "Feb"
  | 2 => "Mar"
  | 3 => "Apr"
  | 4 => "May"
  | 5 => "Jun"
  | 6 => "Jul"
  | 7 => "Aug"
  | 8 => "Sep"
  | 9 => "Oct"
  | 10 => "Nov"
  | 11 => "Dec"
  | _ => ""
  }
}

let formatDateValue = (value: string, ~includeYear=false) => {
  let dateObj = value->DayJs.getDayJsForString

  if includeYear {
    `${dateObj.month()->getMonthName} ${dateObj.format("DD")} ${dateObj.year()->Int.toString} `
  } else {
    `${dateObj.month()->getMonthName} ${dateObj.format("DD")}`
  }
}

let getLabelName = (~key, ~index, ~points) => {
  open LogicUtils
  let getDateObject = (array, index) => {
    array
    ->getValueFromArray(index, Dict.make()->JSON.Encode.object)
    ->getDictFromJsonObject
    ->getString(key, "")
  }

  if key === "time_bucket" {
    let pointsArray = points->getArrayFromJson([])
    let startPoint = pointsArray->getDateObject(0)
    let endPoint = pointsArray->getDateObject(pointsArray->Array.length - 1)

    let startDate = startPoint->formatDateValue
    let endDate = endPoint->formatDateValue
    `${startDate}-${endDate}`
  } else {
    `Series ${(index + 1)->Int.toString}`
  }
}
let calculatePercentageChange = (~primaryValue, ~secondaryValue) => {
  open NewAnalyticsTypes
  let change = primaryValue -. secondaryValue

  if secondaryValue === 0.0 || change === 0.0 {
    (0.0, No_Change)
  } else if change > 0.0 {
    let diff = change /. secondaryValue
    let percentage = diff *. 100.0
    (percentage, Upward)
  } else {
    let diff = change *. -1.0 /. secondaryValue
    let percentage = diff *. 100.0
    (percentage, Downward)
  }
}

let getToolTipConparision = (~primaryValue, ~secondaryValue) => {
  let (value, direction) = calculatePercentageChange(~primaryValue, ~secondaryValue)

  let (textColor, icon) = switch direction {
  | Upward => ("#12B76A", "▲")
  | Downward => ("#F04E42", "▼")
  | No_Change => ("#A0A0A0", "")
  }

  `<span style="color:${textColor};margin-left:7px;" >${icon}${value->valueFormatter(Rate)}</span>`
}

open LogicUtils
let filterQueryData = (query, key) => {
  query->Array.filter(data => {
    let valueDict = data->getDictFromJsonObject
    valueDict->getString(key, "")->isNonEmptyString
  })
}

let sortQueryDataByDate = query => {
  query->Array.sort((a, b) => {
    let valueA = a->getDictFromJsonObject->getString("time_bucket", "")
    let valueB = b->getDictFromJsonObject->getString("time_bucket", "")
    compareLogic(valueB, valueA)
  })
  query
}

let getMaxValue = (data: JSON.t, index: int, key: string) => {
  data
  ->getArrayFromJson([])
  ->getValueFromArray(index, []->JSON.Encode.array)
  ->getArrayFromJson([])
  ->Array.reduce(0.0, (acc, item) => {
    let value = item->getDictFromJsonObject->getFloat(key, 0.0)
    Math.max(acc, value)
  })
}

let isEmptyGraph = (data: JSON.t, key: string) => {
  let primaryMaxValue = data->getMaxValue(0, key)
  let secondaryMaxValue = data->getMaxValue(1, key)

  Math.max(primaryMaxValue, secondaryMaxValue) == 0.0
}

let getCategories = (data: JSON.t, index: int, key: string) => {
  data
  ->getArrayFromJson([])
  ->getValueFromArray(index, []->JSON.Encode.array)
  ->getArrayFromJson([])
  ->Array.map(item => {
    let value = item->getDictFromJsonObject->getString(key, "NA")

    if value->isNonEmptyString && key == "time_bucket" {
      let dateObj = value->DayJs.getDayJsForString
      `${dateObj.month()->getMonthName} ${dateObj.format("DD")}`
    } else {
      value
    }
  })
}

let getMetaDataValue = (~data, ~index, ~key) => {
  data
  ->getArrayFromJson([])
  ->getValueFromArray(index, Dict.make()->JSON.Encode.object)
  ->getDictFromJsonObject
  ->getFloat(key, 0.0)
}

let getBarGraphObj = (
  ~array: array<JSON.t>,
  ~key: string,
  ~name: string,
  ~color,
): BarGraphTypes.dataObj => {
  let data = array->Array.map(item => {
    item->getDictFromJsonObject->getFloat(key, 0.0)
  })
  let dataObj: BarGraphTypes.dataObj = {
    showInLegend: false,
    name,
    data,
    color,
  }
  dataObj
}

let bargraphTooltipFormatter = (~title, ~metricType) => {
  open BarGraphTypes

  (
    @this
    (this: pointFormatter) => {
      let title = `<div style="font-size: 16px; font-weight: bold;">${title}</div>`

      let defaultValue = {color: "", x: "", y: 0.0, point: {index: 0}}
      let primartPoint = this.points->getValueFromArray(0, defaultValue)

      let getRowsHtml = (~iconColor, ~date, ~value, ~comparisionComponent="") => {
        let valueString = valueFormatter(value, metricType)
        `<div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${date}${comparisionComponent}</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${valueString}</div>
        </div>`
      }

      let tableItems =
        [
          getRowsHtml(~iconColor=primartPoint.color, ~date=primartPoint.x, ~value=primartPoint.y),
        ]->Array.joinWith("")

      let content = `
          <div style=" 
          padding:5px 12px;
          display:flex;
          flex-direction:column;
          justify-content: space-between;
          gap: 7px;">
              ${title}
              <div style="
                margin-top: 5px;
                display:flex;
                flex-direction:column;
                gap: 7px;">
                ${tableItems}
              </div>
        </div>`

      `<div style="
    padding: 10px;
    width:fit-content;
    border-radius: 7px;
    background-color:#FFFFFF;
    padding:10px;
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
    border: 1px solid #E5E5E5;
    position:relative;">
        ${content}
    </div>`
    }
  )->asTooltipPointFormatter
}
