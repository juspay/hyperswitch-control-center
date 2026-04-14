open InsightsTypes
open HSwitchRemoteFilter
open DateRangeUtils
open InsightsContainerUtils
open NewAnalyticsUtils

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

  `<span style="color:${textColor};margin-left:7px;" >${icon}${value->CurrencyFormatUtils.valueFormatter(
      Rate,
    )}</span>`
}

open LogicUtils
open CurrencyFormatUtils
// removes the NA buckets
let filterQueryData = (query, key) => {
  query->Array.filter(data => {
    let valueDict = data->getDictFromJsonObject
    valueDict->getString(key, "")->isNonEmptyString
  })
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
        let time = dateObj.format("HH:mm")->NewAnalyticsUtils.formatTimeString
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

      let getRowsHtml = (~iconColor, ~date, ~value, ~comparisonComponent="") => {
        let valueString = valueFormatter(value, metricType)
        `<div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${date}${comparisonComponent}</div>
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

let getLineGraphData = (data, ~xKey, ~yKey, ~isAmount=false, ~currency) => {
  data
  ->getArrayFromJson([])
  ->Array.mapWithIndex((item, index) => {
    let name = getLabelName(~key=yKey, ~index, ~points=item)
    let color = index->getColor
    getLineGraphObj(
      ~array=item->getArrayFromJson([]),
      ~key=xKey,
      ~name,
      ~color,
      ~isAmount,
      ~currency,
    )
  })
}

let getTitleUI = (~title) => {`<div style="font-size: 16px; font-weight: bold;">${title}</div>`}

let getRowsHtml = (
  ~iconColor,
  ~date,
  ~name="",
  ~value,
  ~comparisonComponent="",
  ~metricType,
  ~currency,
  ~suffix,
  ~showNameInTooltip,
) => {
  let valueString = valueFormatter(value, metricType, ~currency, ~suffix)
  let key = showNameInTooltip ? name : date
  `<div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${key}${comparisonComponent}</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${valueString}</div>
        </div>`
}

let getContentsUI = (~title, ~tableItems) => {
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

      let tableItems = [
        getRowsHtml(
          ~iconColor=primartPoint.color,
          ~date=primartPoint.x,
          ~name=primartPoint.series.name,
          ~value=primartPoint.y,
          ~comparisonComponent={
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
          ~metricType,
          ~currency,
          ~suffix,
          ~showNameInTooltip,
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
                  ~metricType,
                  ~currency,
                  ~suffix,
                  ~showNameInTooltip,
                )
              : ""
          | None => ""
          }
        },
      ]->Array.joinWith("")

      getContentsUI(~title=getTitleUI(~title), ~tableItems)
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
  let existingTimeDict = extractTimeDict(
    ~data,
    ~granularity,
    ~granularityEnabled,
    ~isoStringToCustomTimeZone,
    ~timeKey,
  )

  let dateTimeRange = fillForMissingTimeRange(
    ~existingTimeDict,
    ~defaultValue,
    ~timeKey,
    ~endDate,
    ~startDate,
    ~granularity,
  )
  dateTimeRange->Dict.valuesToArray
}

let getSampleDateRange = (~useSampleDates, ~sampleDateRange) => {
  let defaultDateRange: filterBody = getDateFilteredObject(~range=7)
  let dates = useSampleDates ? sampleDateRange : defaultDateRange
  let comparison = useSampleDates ? (EnableComparison :> string) : (DisableComparison :> string)
  let (compareStart, compareEnd) = getComparisonTimePeriod(
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
