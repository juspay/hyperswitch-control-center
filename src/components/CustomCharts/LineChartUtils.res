external legendItemAsBool: Highcharts.legendItem => Highcharts.element = "%identity"

open LogicUtils
open Highcharts
open Identity
let defaultColor = "#7cb5ec"
let legendColor = [
  defaultColor,
  "#90ed7d",
  "#f7a35c",
  "#8085e9",
  "#f15c80",
  "#e4d354",
  "#2b908f",
  "#f45b5b",
  "#91e8e1",
]

let defaultLegendColorGradients = (topGradient, bottomGradient) => {
  {
    linearGradient: (0, 0, 0, 300),
    color: "#7cb5ec",
    stops: ((0, `rgba(124,181,236, ${topGradient})`), (1, `rgba(124,170,236, ${bottomGradient})`)),
  }
}

let legendColorGradients = (topGradient, bottomGradient) => {
  [
    defaultLegendColorGradients(topGradient, bottomGradient),
    {
      linearGradient: (0, 0, 0, 300),
      color: "#434348",
      stops: (
        (0, `rgba(141, 103, 203, ${topGradient})`),
        (1, `rgba(141, 93, 203, ${bottomGradient})`),
      ), //# 434348
    },
    {
      linearGradient: (0, 0, 0, 300),
      color: "#90ed7d",
      stops: (
        (0, `rgba(144, 237, 125, ${topGradient})`),
        (1, `rgba(144, 227, 125, ${bottomGradient})`),
      ), //# 90ed7d
    },
    {
      linearGradient: (0, 0, 0, 300),
      color: "#f7a35c",
      stops: ((0, `rgba(247,163,92, ${topGradient})`), (1, `rgba(247,153,92, ${bottomGradient})`)), //# f7a35c
    },
    {
      linearGradient: (0, 0, 0, 300),
      color: "#8085e9",
      stops: (
        (0, `rgba(128, 133, 233, ${topGradient})`),
        (1, `rgba(128, 123, 233, ${bottomGradient})`),
      ), //# 8085e9
    },
    {
      linearGradient: (0, 0, 0, 300),
      color: "#f15c80",
      stops: (
        (0, `rgba(241, 92, 128, ${topGradient})`),
        (1, `rgba(241, 82, 128, ${bottomGradient})`),
      ), //# f15c80
    },
    {
      linearGradient: (0, 0, 0, 300),
      color: "#e4d354",
      stops: (
        (0, `rgba(228, 211, 84, ${topGradient})`),
        (1, `rgba(228, 201, 84, ${bottomGradient})`),
      ), //# e4d354
    },
    {
      linearGradient: (0, 0, 0, 300),
      color: "#2b908f",
      stops: (
        (0, `rgba(43, 144, 143, ${topGradient})`),
        (1, `rgba(43, 134, 143, ${bottomGradient})`),
      ), //# 2b908f
    },
    {
      linearGradient: (0, 0, 0, 300),
      color: "#f45b5b",
      stops: (
        (0, `rgba(244, 91, 91, ${topGradient})`),
        (1, `rgba(244, 81, 91, ${bottomGradient})`),
      ), //# f45b5b
    },
    {
      linearGradient: (0, 0, 0, 300),
      color: "#91e8e1",
      stops: (
        (0, `rgba(145, 232, 225, ${topGradient})`),
        (1, `rgba(145, 222, 225, ${bottomGradient})`),
      ), //# 91e8e1
    },
  ]
}

type hexToRgb = {
  r: int,
  g: int,
  b: int,
}

//Takes rgba value and reduces opacity by 10
let reduceOpacity = str => {
  let match = str->Js.String2.match_(%re("/rgba\(\d+,\s*\d+,\s*\d+,\s*([\d.]+)\)/"))

  switch match {
  | Some(val) => {
      let opacity = val->Array.get(1)->Option.flatMap(a => a)->Option.getOr("0")
      let newOpacity = opacity->Float.fromString->Option.getOr(0.0) /. 10.0
      str->String.replace(opacity, newOpacity->Float.toString)
    }
  | None => "0"
  }
}
type chartData<'a> = {
  name: string,
  color: string,
  data: array<('a, float, option<float>)>,
  legendIndex: int,
  fillColor?: Highcharts.fillColorSeries,
}
let removeDuplicates = (arr: array<chartData<'a>>) => {
  let uniqueItemsMap = Dict.make()

  arr->Array.forEach(item => {
    let value = item.name
    if uniqueItemsMap->Dict.get(value)->Option.isNone {
      uniqueItemsMap->Dict.set(value, item)
    }
  })

  uniqueItemsMap->Dict.valuesToArray
}

let calculateOpacity = (~length, ~originalOpacity) => {
  let reducedOpacity = originalOpacity *. Math.pow(0.4, ~exp=length->Int.toFloat /. 13.0)
  // Calculate the reduced opacity based on the formula: originalOpacity * (0.4 ^ (length / 13))

  Math.max(reducedOpacity, 0.0)->Float.toString
}

type dropDownMetricType = Latency | Volume | Rate | Amount | Traffic // traffic string can be any column which is of type Volume, Amount
type chartLegendStatsType =
  | GroupBY
  | Overall
  | Average
  | Current
  | Emoji
  | NO_COL

type legenedType = Heading | LegendData

type secondryMetrics = {
  metric_name_db: string,
  metric_label: string,
  metric_type: dropDownMetricType,
}
type metricsConfig = {
  metric_name_db: string,
  metric_label: string,
  metric_type: dropDownMetricType,
  thresholdVal: option<float>,
  step_up_threshold: option<float>,
  legendOption?: (chartLegendStatsType, chartLegendStatsType),
  secondryMetrics?: secondryMetrics,
  disabled?: bool,
  description?: string,
  data_transformation_func?: Dict.t<JSON.t> => Dict.t<JSON.t>,
}
type legendTableData = {
  groupByName: string,
  overall: float,
  average: float,
  current: float,
  index?: int,
}

let legendTypeBasedOnMetric = (metric_type: dropDownMetricType) => {
  switch metric_type {
  | Latency | Rate | Traffic => (Current, Average)
  | Volume => (Overall, Average)
  | Amount => (Average, Overall)
  }
}
let appendToDictValue = (dict, key, value) => {
  let updatedValue = switch dict->Dict.get(key) {
  | Some(val) => Array.concat(val, [value])
  | None => [value]
  }
  dict->Dict.set(key, updatedValue)
}

let addToDictValueFloat = (dict, key, value) => {
  let updatedValue = switch dict->Dict.get(key) {
  | Some(val) => val +. value
  | None => value
  }
  dict->Dict.set(key, updatedValue)
}

let chartDataSortBasedOnTime = (
  a: (float, float, option<float>),
  b: (float, float, option<float>),
) => {
  let (time, _, _) = a
  let (timeb, _, _) = b

  if time < timeb {
    -1.
  } else if time > timeb {
    1.
  } else {
    0.
  }
}

let sortBasedOnTimeLegend = (a: (string, float), b: (string, float)) => {
  let (time, _) = a
  let (timeb, _) = b

  if time < timeb {
    -1.
  } else if time > timeb {
    1.
  } else {
    0.
  }
}

let sortBasedOnArr = arr => {
  let func = (a: legendTableData, b: legendTableData) => {
    if arr->Array.indexOf(a.groupByName) < arr->Array.indexOf(b.groupByName) {
      -1.
    } else if arr->Array.indexOf(a.groupByName) > arr->Array.indexOf(b.groupByName) {
      1.
    } else {
      0.
    }
  }
  func
}

let legendIndexFunc = (name: string) => {
  let index = name === "Others" ? 30 : 0
  index
}

type timeSeriesDictWithSecondryMetrics<'a> = {
  color: option<string>,
  name: string,
  data: array<('a, float, option<float>)>,
  legendIndex: int,
  fillColor?: Highcharts.fillColorSeries,
}

let timeSeriesDataMaker = (
  ~data: array<JSON.t>,
  ~groupKey,
  ~xAxis,
  ~metricsConfig: metricsConfig,
  ~commonColors: option<array<chartData<'a>>>=?,
  ~selectedTab: option<array<string>>=?,
  (),
) => {
  let colors = switch commonColors {
  | Some(value) => value
  | None => []
  }
  let yAxis = metricsConfig.metric_name_db
  let metrixType = metricsConfig.metric_type
  let secondryMetrics = metricsConfig.secondryMetrics
  let timeSeriesDict = Dict.make() // { name : groupByName, data: array<(value1, value2)>}
  let groupedByTime = Dict.make() // {time : [values at that time]}
  let _ = data->Array.map(item => {
    let dict = item->getDictFromJsonObject

    let groupByName = switch selectedTab {
    | Some(keys) =>
      keys
      ->Array.map(key =>
        dict->getString(
          key,
          Dict.get(dict, key)->Option.getOr(""->JSON.Encode.string)->JSON.stringify,
        )
      )
      ->Array.map(LogicUtils.snakeToTitle)
      ->Array.joinWith(" : ")
    | None =>
      dict->getString(
        groupKey,
        Dict.get(dict, groupKey)->Option.getOr(""->JSON.Encode.string)->JSON.stringify,
      )
    }

    let xAxisDataPoint = dict->getString(xAxis, "")->String.split(" ")->Array.joinWith("T") ++ "Z" // right now it is time string
    let yAxisDataPoint = dict->getFloat(yAxis, 0.)

    let secondryAxisPoint = switch secondryMetrics {
    | Some(secondryMetrics) => Some(dict->getFloat(secondryMetrics.metric_name_db, 0.))
    | None => None
    }
    if dict->getString(xAxis, "")->LogicUtils.isNonEmptyString {
      timeSeriesDict->appendToDictValue(
        groupByName,
        (xAxisDataPoint->DateTimeUtils.parseAsFloat, yAxisDataPoint, secondryAxisPoint),
      )
      groupedByTime->addToDictValueFloat(
        xAxisDataPoint->DateTimeUtils.parseAsFloat->Float.toString,
        yAxisDataPoint,
      )
    }
  })

  let timeSeriesArr = timeSeriesDict->Dict.toArray

  let chartOverlapping = timeSeriesArr->Array.length

  let topGradient = calculateOpacity(~length=chartOverlapping, ~originalOpacity=0.50)
  let bottomGradient = calculateOpacity(~length=chartOverlapping, ~originalOpacity=0.05)

  timeSeriesArr->Array.mapWithIndex((item, index) => {
    let (key, value) = item
    let sortedValBasedOnTime = switch metrixType {
    | Traffic =>
      value
      ->Array.map(item => {
        let (key, value, secondryMetrix) = item
        let trafficValue =
          value *. 100. /. groupedByTime->Dict.get(key->Float.toString)->Option.getOr(1.)
        (key, trafficValue, secondryMetrix)
      })
      ->Array.toSorted(chartDataSortBasedOnTime)
    | _ => value->Array.toSorted(chartDataSortBasedOnTime)
    }
    let color = switch colors->Array.find(item => item.name == key) {
    | Some(val) => val.color
    | None => legendColor[mod(index, legendColor->Array.length)]->Option.getOr(defaultColor)
    }

    let fillColor = switch legendColorGradients(topGradient, bottomGradient)->Array.find(item =>
      item.color->Option.getOr("#000000") == color
    ) {
    | Some(val) => val
    | None =>
      legendColorGradients(topGradient, bottomGradient)[
        mod(index, legendColor->Array.length)
      ]->Option.getOr(defaultLegendColorGradients(topGradient, bottomGradient))
    }
    let value: timeSeriesDictWithSecondryMetrics<float> = {
      color: Some(color),
      name: key,
      data: sortedValBasedOnTime,
      legendIndex: legendIndexFunc(key),
      fillColor,
    }
    value
  })
}

let getLegendDataForCurrentMetrix = (
  ~yAxis: string,
  ~timeSeriesData: array<JSON.t>,
  ~groupedData: array<JSON.t>,
  ~activeTab: string,
  ~xAxis: string,
  ~metrixType: dropDownMetricType,
) => {
  let currentAvgDict = Dict.make()
  let orderedDims = groupedData->Array.map(item => {
    let dict = item->getDictFromJsonObject
    getString(
      dict,
      activeTab,
      Dict.get(dict, activeTab)->Option.getOr(""->JSON.Encode.string)->JSON.stringify,
    )
  })
  timeSeriesData->Array.forEach(item => {
    let dict = item->getDictFromJsonObject
    let time_overall_statsAtTime = (getString(dict, xAxis, ""), getFloat(dict, yAxis, 0.)) // time_bucket // current value of the metrics will be used for calculation of avg and the current
    currentAvgDict->appendToDictValue(
      getString(
        dict,
        activeTab,
        Dict.get(dict, activeTab)->Option.getOr(""->JSON.Encode.string)->JSON.stringify,
      ),
      time_overall_statsAtTime,
    )
  })

  let currentAvgSortedDict =
    currentAvgDict
    ->Dict.toArray
    ->Array.map(item => {
      let (key, value) = item
      (key, value->Array.toSorted(sortBasedOnTimeLegend))
    })
  let currentValueOverallSum =
    currentAvgSortedDict
    ->Array.map(item => {
      let (_, value) = item
      let (_, currentVal) = value->Array.get(value->Array.length - 1)->Option.getOr(("", 0.))
      currentVal
    })
    ->AnalyticsUtils.sumOfArrFloat
  let currentAvgDict = if groupedData->Array.length === 0 {
    currentAvgDict
    ->Dict.toArray
    ->Array.map(item => {
      let (key, value) = item
      let sortedValueBasedOnTime = value->Array.toSorted(sortBasedOnTimeLegend)
      let arrLen = sortedValueBasedOnTime->Array.length
      let (_, currentVal) = sortedValueBasedOnTime->Array.get(arrLen - 1)->Option.getOr(("", 1.0))

      let overall =
        sortedValueBasedOnTime
        ->Array.map(item => {
          let (_, value) = item
          value
        })
        ->Array.reduce(0., (acc, value) => acc +. value)

      let value: legendTableData = {
        groupByName: key,
        overall,
        average: overall /. arrLen->Int.toFloat,
        current: currentVal,
      }
      value
    })
  } else {
    let currentOverall = Dict.make()
    groupedData->Array.forEach(item => {
      let dict = item->getDictFromJsonObject
      currentOverall->Dict.set(getString(dict, activeTab, ""), getFloat(dict, yAxis, 0.))
    })
    let totalOverall =
      currentOverall
      ->Dict.toArray
      ->Array.map(item => {
        let (_, value) = item
        value
      })
      ->AnalyticsUtils.sumOfArrFloat
    currentAvgDict
    ->Dict.toArray
    ->Array.map(item => {
      let (metricsName, value) = item
      let sortedValueBasedOnTime = value->Array.toSorted(sortBasedOnTimeLegend)
      let arrLen = sortedValueBasedOnTime->Array.length
      let (_, currentVal) = sortedValueBasedOnTime[arrLen - 1]->Option.getOr(("", 0.))
      // the avg stat won't work correct for Sr case have to find another way or avoid using the avg for Sr
      let overall = if metrixType === Traffic {
        (currentOverall->Dict.get(metricsName)->Option.getOr(0.) *.
        100. /.
        Math.max(totalOverall, 1.))
        ->Float.toFixedWithPrecision(~digits=2)
        ->removeTrailingZero
        ->Float.fromString
        ->Option.getOr(0.)
      } else {
        currentOverall->Dict.get(metricsName)->Option.getOr(0.)
      }
      let currentVal = if metrixType === Traffic {
        currentVal *. 100. /. currentValueOverallSum
      } else {
        currentVal
      }

      let value: legendTableData = {
        groupByName: metricsName,
        overall,
        average: overall /. arrLen->Int.toFloat,
        current: currentVal,
      }
      value
    })
  }
  let sortBasedOnArr = sortBasedOnArr(orderedDims)

  currentAvgDict
  ->Array.toSorted(sortBasedOnArr)
  ->Array.mapWithIndex((item, index) => {
    {...item, index}
  })
}

let barChartDataMaker = (~yAxis: string, ~rawData: array<JSON.t>, ~activeTab: string) => {
  let value = rawData->Belt.Array.keepMap(item => {
    let dict = item->getDictFromJsonObject

    let selectedSegmentVal = getString(
      dict,
      activeTab,
      Dict.get(dict, activeTab)->Option.getOr(""->JSON.Encode.string)->JSON.stringify,
    ) // groupby/ selected segment

    let stats = getFloat(dict, yAxis, 0.) // overall metrics
    selectedSegmentVal->LogicUtils.isNonEmptyString ? Some(selectedSegmentVal, stats) : None
  })

  let val: Highcharts.barChartSeries = {
    color: "#4C8CFB",
    data: value->Array.map(item => {
      let (_, data) = item

      data
    }),
  }
  (
    value->Array.map(item => {
      let (categories, _) = item
      categories
    }),
    [val],
  )
}

let chartLegendTypeToStr = (chartLegendType: chartLegendStatsType) => {
  switch chartLegendType {
  | Overall => "Overall"
  | Average => "Average"
  | Current => "Current"
  | _ => "" // this is not been used
  }
}

let legendClickItem = (s: Highcharts.legendItem, e, setState) => {
  open ReactEvent.Keyboard
  e->preventDefault

  // cases
  // add the selected item in the array and update the array i.e
  // if item is already present remove it from array
  // if not add the item to the array
  // whatever is there in selected array make it visible
  // edge case when nothing is selected make everyone visible

  Array.forEach(s.chart.series, x => {
    if x === legendItemAsBool(s) {
      setState(prev => {
        let value =
          prev->Array.includes(x) ? prev->Array.filter(item => item !== x) : Array.concat(prev, [x])

        if value->Array.length === 0 {
          Array.forEach(
            s.chart.series,
            y => {
              y->Highcharts.show
            },
          )
        } else {
          Array.forEach(
            s.chart.series,
            y => {
              value->Array.includes(y) ? y->Highcharts.show : y->Highcharts.hide
            },
          )
        }
        value
      })
    }
  })
}
let formatStatsAccToMetrix = (metric: dropDownMetricType, value: float) => {
  switch metric {
  | Latency => latencyShortNum(~labelValue=value)
  | Volume => shortNum(~labelValue=value, ~numberFormat=getDefaultNumberFormat())
  | Rate | Traffic => value->Float.toFixedWithPrecision(~digits=2)->removeTrailingZero ++ "%"
  | Amount => shortNum(~labelValue=value, ~numberFormat=getDefaultNumberFormat())
  }
}

let formatLabels = (metric: metricsConfig, value: float) => {
  let formattedValue = formatStatsAccToMetrix(metric.metric_type, value)

  switch metric.thresholdVal {
  | Some(val) =>
    val === value
      ? `<span style="font-size: 11px; color: white; cursor: default;  background-color: #EE6E73;padding: 2px 10px;border-radius: 10px; display: flex">
    ${formattedValue}
   </span>`
      : formattedValue
  | None => formattedValue
  }
}

let getTooltipHTML = (metrics, data, onCursorName, index, length) => {
  let metric_type = metrics.metric_type
  let (name, color, y_axis, secondry_metrix) = data
  let secondry_metrix_val = switch metrics.secondryMetrics {
  | Some(secondryMetrics) =>
    `${formatStatsAccToMetrix(secondryMetrics.metric_type, secondry_metrix->Option.getOr(0.))}`
  | None => ""
  }

  let spacing = index !== length - 1 ? "<tr style='height: 10px;'></tr>" : ""

  let highlight = onCursorName == name ? "font-weight:500;font-size:13px;" : "opacity:60%;"

  `<tr>
      <td><span style='height:10px; width:10px;margin-top:5px;display:inline-block; background-color:${color};border-radius:3px;margin-right:3px;fontFamily:"Inter"'/></td>
      <td><span style='${highlight};padding-right: 10px;'>${name->LogicUtils.snakeToTitle}</span></td>
      <td><span style=${highlight}>${formatStatsAccToMetrix(metric_type, y_axis)}</span></td>
      <td><span style=${highlight}>${secondry_metrix_val}</span></td>
  </tr>
  ${spacing}`
}

let tooltipFormatter = (
  metrics: metricsConfig,
  xAxisMapInfo: Dict.t<array<(Js_string.t, string, float, option<float>)>>,
  groupKey: string,
) => @this
(points: JSON.t) => {
  let points = points->getDictFromJsonObject
  let series = points->getJsonObjectFromDict("series")->getDictFromJsonObject

  let dataArr = if ["run_date", "run_month", "run_week"]->Array.includes(groupKey) {
    let x = points->getString("name", "")
    xAxisMapInfo->Dict.get(x)->Option.getOr([])
  } else {
    let x = points->getFloat("x", 0.)
    xAxisMapInfo->Dict.get(x->Float.toString)->Option.getOr([])
  }

  let onCursorName = series->getString("name", "")
  let htmlStr =
    dataArr
    ->Array.mapWithIndex((data, i) => {
      getTooltipHTML(metrics, data, onCursorName, i, dataArr->Array.length)
    })
    ->Array.joinWith("")
  `<table>${htmlStr}</table>`
}

let legendItemStyle = legendFontSizeClass => {
  {
    "color": "rgba(53, 64, 82, 0.8)",
    "cursor": "pointer",
    "fontSize": legendFontSizeClass,
    "fontWeight": "500",
    "fontFamily": "InterDisplay",
    "fontStyle": "normal",
  }->genericObjectOrRecordToJson
}

let legendHiddenStyle = (theme: ThemeProvider.theme) => (
  legendFontFamilyClass,
  legendFontSizeClass,
) => {
  switch theme {
  | Dark =>
    {
      "color": "#c7cad020",
      "cursor": "pointer",
      "fontSize": legendFontSizeClass,
      "fontWeight": "500",
      "fontFamily": legendFontFamilyClass,
      "fontStyle": "normal",
    }->genericObjectOrRecordToJson
  | Light =>
    {
      "color": "rgba(53, 64, 82, 0.2)",
      "cursor": "pointer",
      "fontSize": legendFontSizeClass,
      "fontWeight": "500",
      "fontFamily": legendFontFamilyClass,
      "fontStyle": "normal",
    }->genericObjectOrRecordToJson
  }
}

let chartTitleStyle = (theme: ThemeProvider.theme) => {
  switch theme {
  | Dark =>
    {
      "color": "#f6f8f9",
      "fontSize": "13px",
      "fontWeight": "500",
      "fontStyle": "normal",
    }->genericObjectOrRecordToJson
  | Light =>
    {
      "color": "#474D59",
      "fontSize": "16px",
      "fontWeight": "500",
      "fontStyle": "normal",
    }->genericObjectOrRecordToJson
  }
}

let getGranularityNew = (~startTime, ~endTime) => {
  let diff =
    (endTime->DateTimeUtils.parseAsFloat -. startTime->DateTimeUtils.parseAsFloat) /. (1000. *. 60.) // in minutes

  // can be improved a lot we can have flexibitlity to show data 3 hour wise as well so some kind of adhoc logic we can have
  // second | minute | hour | day | week | month
  // less than 6 hour
  if diff < 60. *. 6. {
    [(15, "minute"), (5, "minute")]
  } else if diff < 60. *. 24. {
    // Smaller than 1 day
    [(1, "hour"), (30, "minute"), (15, "minute")]
  } else if diff < 60. *. 24. *. 7. {
    // Smaller than 7 day
    [(1, "day"), (3, "hour")]
  } else if diff <= 60. *. 24. *. 62. {
    // Smaller than 60 day
    [(1, "week"), (1, "day")]
  } else {
    [(1, "week")]
  }
}

let getGranularityNewStr = (~startTime, ~endTime) => {
  getGranularityNew(~startTime, ~endTime)->Array.map(item => {
    let (val, unit) = item
    if val === 1 {
      if unit === "day" {
        "Daily"
      } else if unit === "week" {
        "Weekly"
      } else if unit === "hour" {
        "Hourly"
      } else {
        unit
      }
    } else {
      `${val->Int.toString} ${unit}`
    }
  })
}

let chartDataMaker = (~filterNull=false, rawData, groupKey, metric) => {
  let sortDescending = (obj1, obj2) => {
    let (_key, val1) = obj1
    let (_key, val2) = obj2
    if val1 > val2 {
      -1.
    } else if val1 === val2 {
      0.
    } else {
      1.
    }
  }
  rawData
  ->Array.filter(dataPoint => {
    !filterNull || {
      let dataPointDict = dataPoint->getDictFromJsonObject
      dataPointDict->getString(groupKey, "") !== "NA"
    }
  })
  ->Array.map(dataPoint => {
    let dataPointDict = dataPoint->getDictFromJsonObject
    (
      dataPointDict->getString(groupKey, "")->String.toLowerCase->snakeToTitle,
      dataPointDict->getString(metric, "")->Js.Float.fromString,
    )
  })
  ->Array.toSorted(sortDescending)
}
