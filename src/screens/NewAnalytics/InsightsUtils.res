// colors
let redColor = "#BA3535"
let blue = "#1059C1B2"
let green = "#0EB025B2"
let barGreenColor = "#7CC88F"
let sankyBlue = "#E4EFFF"
let sankyRed = "#F7E0E0"
let sankyLightBlue = "#91B7EE"
let sankyLightRed = "#EC6262"

open InsightsTypes
open HSwitchRemoteFilter
open DateRangeUtils
open InsightsContainerUtils
let globalFilter: array<filters> = [#currency]
let globalExcludeValue = [(#all_currencies: defaultFilters :> string)]

let requestBody = (
  ~startTime: string,
  ~endTime: string,
  ~metrics: array<metrics>,
  ~groupByNames: option<array<string>>=None,
  ~filter: option<JSON.t>,
  ~delta: option<bool>=None,
  ~granularity: option<string>=None,
  ~distributionValues: option<JSON.t>=None,
  ~mode: option<string>=None,
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
      ~mode,
    )->JSON.Encode.object,
  ]->JSON.Encode.array
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
    `${startDate} - ${endDate}`
  } else {
    `Series ${(index + 1)->Int.toString}`
  }
}
let calculatePercentageChange = (~primaryValue, ~secondaryValue) => {
  open InsightsTypes
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

  `<span style="color:${textColor};margin-left:7px;" >${icon}${value->LogicUtils.valueFormatter(
      Rate,
    )}</span>`
}

open LogicUtils
// removes the NA buckets
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

let checkTimePresent = (options, key) => {
  options->Array.reduce(false, (flag, item) => {
    let value = item->getDictFromJsonObject->getString(key, "NA")
    if value->isNonEmptyString && key == "time_bucket" {
      let dateObj = value->DayJs.getDayJsForString
      dateObj.format("HH") != "00" || flag
    } else {
      false
    }
  })
}

let formatTime = time => {
  let hour =
    time->String.split(":")->Array.get(0)->Option.getOr("00")->Int.fromString->Option.getOr(0)
  let mimute =
    time->String.split(":")->Array.get(1)->Option.getOr("00")->Int.fromString->Option.getOr(0)

  let newHour = Int.mod(hour, 12)
  let newHour = newHour == 0 ? 12 : newHour

  let period = hour >= 12 ? "PM" : "AM"

  if mimute > 0 {
    `${newHour->Int.toString}:${mimute->Int.toString} ${period}`
  } else {
    `${newHour->Int.toString} ${period}`
  }
}

let getCategories = (data: JSON.t, index: int, key: string) => {
  let options =
    data
    ->getArrayFromJson([])
    ->getValueFromArray(index, []->JSON.Encode.array)
    ->getArrayFromJson([])

  let isShowTime = options->checkTimePresent(key)

  options->Array.map(item => {
    let value = item->getDictFromJsonObject->getString(key, "NA")

    if value->isNonEmptyString && key == "time_bucket" {
      let dateObj = value->DayJs.getDayJsForString
      let date = `${dateObj.month()->getMonthName} ${dateObj.format("DD")}`
      if isShowTime {
        let time = dateObj.format("HH:mm")->formatTime
        `${date}, ${time}`
      } else {
        date
      }
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

let getColor = index => {
  [blue, green]->Array.get(index)->Option.getOr(blue)
}

let getAmountValue = (data, ~id) => {
  switch data->getOptionFloat(id) {
  | Some(value) => value /. 100.0
  | _ => 0.0
  }
}

let getLineGraphObj = (
  ~array: array<JSON.t>,
  ~key: string,
  ~name: string,
  ~color,
  ~isAmount=false,
): LineGraphTypes.dataObj => {
  let data = array->Array.map(item => {
    let dict = item->getDictFromJsonObject
    if isAmount {
      dict->getAmountValue(~id=key)
    } else {
      dict->getFloat(key, 0.0)
    }
  })
  let dataObj: LineGraphTypes.dataObj = {
    showInLegend: true,
    name,
    data,
    color,
  }
  dataObj
}

let getLineGraphData = (data, ~xKey, ~yKey, ~isAmount=false) => {
  data
  ->getArrayFromJson([])
  ->Array.mapWithIndex((item, index) => {
    let name = getLabelName(~key=yKey, ~index, ~points=item)
    let color = index->getColor
    getLineGraphObj(~array=item->getArrayFromJson([]), ~key=xKey, ~name, ~color, ~isAmount)
  })
}

let tooltipFormatter = (
  ~secondaryCategories,
  ~title,
  ~metricType,
  ~comparison: option<DateRangeUtils.comparison>=None,
  ~currency="",
  ~reverse=false,
  ~suffix="",
  ~showNameInTooltip=false,
) => {
  open LineGraphTypes

  (
    @this
    (this: pointFormatter) => {
      let title = `<div style="font-size: 16px; font-weight: bold;">${title}</div>`

      let defaultValue = {color: "", x: "", y: 0.0, point: {index: 0}, series: {name: ""}}

      let primaryIndex = reverse ? 1 : 0
      let secondaryIndex = reverse ? 0 : 1

      let primartPoint = this.points->getValueFromArray(primaryIndex, defaultValue)
      let secondaryPoint = this.points->getValueFromArray(secondaryIndex, defaultValue)

      let getRowsHtml = (~iconColor, ~date, ~name="", ~value, ~comparisionComponent="") => {
        let valueString = valueFormatter(value, metricType, ~currency, ~suffix)
        let key = showNameInTooltip ? name : date
        `<div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${key}${comparisionComponent}</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${valueString}</div>
        </div>`
      }

      let tableItems = [
        getRowsHtml(
          ~iconColor=primartPoint.color,
          ~date=primartPoint.x,
          ~name=primartPoint.series.name,
          ~value=primartPoint.y,
          ~comparisionComponent={
            switch comparison {
            | Some(value) =>
              value == DateRangeUtils.EnableComparison
                ? getToolTipConparision(
                    ~primaryValue=primartPoint.y,
                    ~secondaryValue=secondaryPoint.y,
                  )
                : ""
            | None => ""
            }
          },
        ),
        {
          switch comparison {
          | Some(value) =>
            value == DateRangeUtils.EnableComparison
              ? getRowsHtml(
                  ~iconColor=secondaryPoint.color,
                  ~date=secondaryCategories->getValueFromArray(secondaryPoint.point.index, ""),
                  ~value=secondaryPoint.y,
                  ~name=secondaryPoint.series.name,
                )
              : ""
          | None => ""
          }
        },
      ]->Array.joinWith("")

      let content = `
          <div style=" 
          padding:5px 12px;
          border-left: 3px solid #0069FD;
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

let generateFilterObject = (~globalFilters, ~localFilters=None) => {
  let filters = Dict.make()

  let globalFiltersList = globalFilter->Array.map(filter => {
    (filter: filters :> string)
  })

  let parseStringValue = string => {
    string
    ->JSON.Decode.string
    ->Option.getOr("")
    ->String.split(",")
    ->Array.filter(value => {
      !(globalExcludeValue->Array.includes(value))
    })
    ->Array.map(JSON.Encode.string)
  }

  globalFilters
  ->Dict.toArray
  ->Array.forEach(item => {
    let (key, value) = item
    if globalFiltersList->Array.includes(key) && value->parseStringValue->Array.length > 0 {
      filters->Dict.set(key, value->parseStringValue->JSON.Encode.array)
    }
  })

  switch localFilters {
  | Some(dict) =>
    dict
    ->Dict.toArray
    ->Array.forEach(item => {
      let (key, value) = item
      filters->Dict.set(key, value)
    })
  | None => ()
  }

  filters->JSON.Encode.object
}

let getGranularityLabel = option => {
  switch option {
  | #G_ONEDAY => "Day-wise"
  | #G_ONEHOUR => "Hour-wise"
  | #G_THIRTYMIN => "30min-wise"
  | #G_FIFTEENMIN => "15min-wise"
  }
}

let defaulGranularity = {
  label: #G_ONEDAY->getGranularityLabel,
  value: (#G_ONEDAY: granularity :> string),
}

let getGranularityOptions = (~startTime, ~endTime) => {
  let startingPoint = startTime->DayJs.getDayJsForString
  let endingPoint = endTime->DayJs.getDayJsForString
  let gap = endingPoint.diff(startingPoint.toString(), "hour") // diff between points

  let options = if gap < 1 {
    [#G_THIRTYMIN, #G_FIFTEENMIN]
  } else if gap < 24 {
    [#G_ONEHOUR, #G_THIRTYMIN, #G_FIFTEENMIN]
  } else if gap < 168 {
    [#G_ONEDAY, #G_ONEHOUR]
  } else {
    [#G_ONEDAY]
  }

  options->Array.map(option => {
    label: option->getGranularityLabel,
    value: (option: granularity :> string),
  })
}

let getDefaultGranularity = (~startTime, ~endTime, ~granularity) => {
  let options = getGranularityOptions(~startTime, ~endTime)
  if granularity {
    options->Array.get(options->Array.length - 1)->Option.getOr(defaulGranularity)
  } else {
    defaulGranularity
  }
}

let getGranularityGap = option => {
  switch option {
  | "G_ONEHOUR" => 60
  | "G_THIRTYMIN" => 30
  | "G_FIFTEENMIN" => 15
  | "G_ONEDAY" | _ => 1440
  }
}

let fillMissingDataPoints = (
  ~data,
  ~startDate,
  ~endDate,
  ~timeKey="time_bucket",
  ~defaultValue: JSON.t,
  ~granularity: string,
  ~isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
  ~granularityEnabled,
) => {
  let dataDict = Dict.make()

  data->Array.forEach(item => {
    let time = switch (granularityEnabled, granularity != (#G_ONEDAY: granularity :> string)) {
    | (true, true) => {
        let value =
          item
          ->getDictFromJsonObject
          ->getObj("time_range", Dict.make())

        let time = value->getString("start_time", "")

        let {year, month, date, hour, minute} = isoStringToCustomTimeZone(time)

        if (
          granularity == (#G_THIRTYMIN: granularity :> string) ||
            granularity == (#G_FIFTEENMIN: granularity :> string)
        ) {
          (`${year}-${month}-${date} ${hour}:${minute}`->DayJs.getDayJsForString).format(
            "YYYY-MM-DD HH:mm:ss",
          )
        } else {
          (`${year}-${month}-${date} ${hour}:${minute}`->DayJs.getDayJsForString).format(
            "YYYY-MM-DD HH:00:00",
          )
        }
      }
    | _ =>
      item
      ->getDictFromJsonObject
      ->getString(timeKey, "")
    }

    let newItem = item->getDictFromJsonObject
    newItem->Dict.set("time_bucket", time->JSON.Encode.string)

    dataDict->Dict.set(time, newItem->JSON.Encode.object)
  })

  let dataPoints = Dict.make()
  let startingPoint = startDate->DayJs.getDayJsForString
  let startingPoint = startingPoint.format("YYYY-MM-DD HH:00:00")->DayJs.getDayJsForString
  let endingPoint = endDate->DayJs.getDayJsForString
  let gap = "minute"
  let devider = granularity->getGranularityGap
  let limit =
    (endingPoint.diff(startingPoint.toString(), gap)->Int.toFloat /. devider->Int.toFloat)
    ->Math.floor
    ->Float.toInt

  let format =
    granularity != (#G_ONEDAY: granularity :> string)
      ? "YYYY-MM-DD HH:mm:ss"
      : "YYYY-MM-DD 00:00:00"

  for x in 0 to limit {
    let newDict = defaultValue->getDictFromJsonObject->Dict.copy
    let timeVal = startingPoint.add(x * devider, gap).format(format)
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

let getSampleDateRange = (~useSampleDates) => {
  let defaultDateRange: filterBody = getDateFilteredObject(~range=7)
  let sampleDateRange: filterBody = {
    start_time: "2024-09-05T00:00:00.000Z",
    end_time: "2024-10-03T00:00:00.000Z",
  }
  let dates = useSampleDates ? sampleDateRange : defaultDateRange
  let comparison = useSampleDates ? (EnableComparison :> string) : (DisableComparison :> string)
  let (compareStart, compareEnd) = getComparisionTimePeriod(
    ~startDate=dates.start_time,
    ~endDate=dates.end_time,
  )
  let values =
    [
      (startTimeFilterKey, dates.start_time),
      (endTimeFilterKey, dates.end_time),
      (compareToStartTimeKey, compareStart),
      (compareToEndTimeKey, compareEnd),
      (comparisonKey, comparison),
    ]->Dict.fromArray
  values
}
