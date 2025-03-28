open IntelligentRoutingTypes
let defaultTimeRange = {minDate: "", maxDate: ""}

let simulatorBanner =
  <div
    className="absolute z-10 top-76-px left-0 w-full py-4 px-10 bg-orange-50 flex justify-between items-center">
    <div className="flex gap-4 items-center">
      <Icon name="nd-information-triangle" size=24 />
      <p className="text-nd_gray-600 text-base leading-6 font-medium">
        {"You are in demo environment and this is sample setup."->React.string}
      </p>
    </div>
  </div>

let displayLegend = gatewayKeys => {
  let colors = ["#BCBD22", "#CB80DC", "#72BEF4", "#7856FF", "#4B6D8C"]
  let legendColor = index => colors->Array.get(index)->Option.getOr("")

  gatewayKeys->Array.mapWithIndex((key, index) => {
    <div className="flex gap-1 items-center" key={key}>
      <div
        className="w-3 h-3 rounded-sm"
        style={ReactDOM.Style.make(~backgroundColor=legendColor(index), ())}
      />
      <p className="text-grey-100 font-normal leading-3 !text-fs-13 text-nowrap">
        {key->React.string}
      </p>
    </div>
  })
}

let stepperHeading = (~title: string, ~subTitle: string) =>
  <div className="flex flex-col gap-y-1">
    <p className="text-2xl font-semibold text-nd_gray-700 leading-9"> {title->React.string} </p>
    <p className="text-sm text-nd_gray-400 font-medium leading-5"> {subTitle->React.string} </p>
  </div>

let displayDateRange = (~minDate, ~maxDate) => {
  let getDateObj = value => value->DayJs.getDayJsForString
  let date = value => {
    NewAnalyticsUtils.formatDateValue(value, ~includeYear=true)
  }

  let time = value => {
    let dateObj = getDateObj(value)
    dateObj.format("HH:mm")->NewAnalyticsUtils.formatTime
  }

  let diff = DateRangeUtils.getStartEndDiff(minDate, maxDate)

  if date(minDate) == date(maxDate) {
    `${time(minDate)} - ${time(maxDate)} ${date(minDate)}`
  } else if diff < (2->Int.toFloat *. 24. *. 60. *. 60. -. 1.) *. 1000. {
    `${time(minDate)}  ${date(minDate)} - ${time(maxDate)} ${date(maxDate)}`
  } else {
    `${date(minDate)} - ${date(maxDate)}`
  }
}

let getDateTime = value => {
  let dateObj = value->DayJs.getDayJsForString
  let _date = `${dateObj.month()->NewAnalyticsUtils.getMonthName} ${dateObj.format("DD")}`
  let time = dateObj.format("HH:mm")->NewAnalyticsUtils.formatTime
  `${time}`
}

let columnGraphOptions = (stats: JSON.t): ColumnGraphTypes.columnGraphPayload => {
  let statsData = stats->IntelligentRoutingUtils.responseMapper
  let timeSeriesData = statsData.time_series_data

  let baseLineData = timeSeriesData->Array.map(item => {
    let data: ColumnGraphTypes.dataObj = {
      name: getDateTime(item.time_stamp),
      y: item.revenue.baseline,
      color: "#B992DD",
    }
    data
  })
  let modelData = timeSeriesData->Array.map(item => {
    let data: ColumnGraphTypes.dataObj = {
      name: getDateTime(item.time_stamp),
      y: item.revenue.model,
      color: "#1E90FF",
    }
    data
  })

  {
    title: {
      text: "Revenue Uplift",
      align: "left",
      x: 10,
      y: 10,
    },
    data: [
      {
        showInLegend: true,
        name: "Without Intelligence",
        colorByPoint: false,
        data: baseLineData,
        color: "#B992DD",
      },
      {
        showInLegend: true,
        name: "With Intelligence",
        colorByPoint: false,
        data: modelData,
        color: "#1E90FF",
      },
    ],
    tooltipFormatter: ColumnGraphUtils.columnGraphTooltipFormatter(
      ~title="Revenue Uplift",
      ~metricType=FormattedAmount,
      ~comparison=Some(EnableComparison),
    ),
    yAxisFormatter: ColumnGraphUtils.columnGraphYAxisFormatter(
      ~statType=AmountWithSuffix,
      ~currency="$",
      ~suffix="M",
      ~scaleFactor=1000000.0,
    ),
  }
}

let lineGraphOptions = (stats: JSON.t): LineGraphTypes.lineGraphPayload => {
  let statsData = stats->IntelligentRoutingUtils.responseMapper
  let timeSeriesData = statsData.time_series_data

  let timeSeriesArray = timeSeriesData->Array.map(item => {
    getDateTime(item.time_stamp)
  })

  let baselineSuccessRate = timeSeriesData->Array.map(item => item.success_rate.baseline)
  let modelSuccessRate = timeSeriesData->Array.map(item => item.success_rate.model)

  {
    title: {
      text: "Overall Authorization Rate",
      align: "left",
      x: 10,
      y: 10,
      style: {
        fontSize: "14px",
        color: "#525866",
      },
    },
    categories: timeSeriesArray,
    data: [
      {
        showInLegend: true,
        name: "Without Intelligence",
        data: baselineSuccessRate,
        color: "#B992DD",
      },
      {
        showInLegend: true,
        name: "With Intelligence",
        data: modelSuccessRate,
        color: "#1E90FF",
      },
    ],
    tooltipFormatter: NewAnalyticsUtils.tooltipFormatter(
      ~title="Authorization Rate",
      ~metricType=Rate,
      ~currency="",
      ~comparison=Some(EnableComparison),
      ~secondaryCategories=timeSeriesArray,
      ~reverse=true,
      ~suffix="%",
      ~showNameInTooltip=true,
    ),
    yAxisMaxValue: Some(100),
    yAxisFormatter: LineGraphUtils.lineGraphYAxisFormatter(
      ~statType=AmountWithSuffix,
      ~currency="",
      ~suffix="%",
    ),
  }
}

let lineColumnGraphOptions = (
  stats,
  ~processor="",
): LineAndColumnGraphTypes.lineColumnGraphPayload => {
  open LogicUtils
  let statsData = stats->IntelligentRoutingUtils.responseMapper
  let timeSeriesData = statsData.time_series_data

  let timeStampArray = timeSeriesData->Array.map(item => {
    getDateTime(item.time_stamp)
  })

  let mapPSPJson = (json): volDist => {
    let dict = json->getDictFromJsonObject
    {
      baseline_volume: dict->getInt("baseline_volume", 0),
      model_volume: dict->getInt("model_volume", 0),
      success_rate: dict->getFloat("success_rate", 0.0),
    }
  }

  let successData = timeSeriesData->Array.map(item => {
    let val = item.volume_distribution_as_per_sr
    let dict = val->getDictFromJsonObject
    let pspData = dict->Dict.get(processor)

    let data = switch pspData {
    | Some(pspData) => pspData->mapPSPJson
    | None => {
        baseline_volume: 0,
        model_volume: 0,
        success_rate: 0.0,
      }
    }
    data
  })

  let baseline = successData->Array.map(item => item.baseline_volume->Int.toFloat)
  let model = successData->Array.map(item => item.model_volume->Int.toFloat)
  let successRate = successData->Array.map(item => item.success_rate)

  let style: LineAndColumnGraphTypes.style = {
    fontFamily: LineAndColumnGraphUtils.fontFamily,
    color: LineAndColumnGraphUtils.darkGray,
    fontSize: "14px",
  }

  {
    titleObj: {
      chartTitle: {
        text: "Processor wise transaction distribution with Auth Rate",
        align: "left",
        x: 10,
        y: 10,
        style: {
          fontSize: "14px",
          color: "#525866",
        },
      },
      xAxisTitle: {
        text: "Time Range",
        style,
      },
      yAxisTitle: {
        text: "Transaction Count",
        style,
      },
      oppositeYAxisTitle: {
        text: "Authorization Rate",
        style,
      },
    },
    categories: timeStampArray,
    data: [
      {
        showInLegend: true,
        name: "Processor's Auth Rate",
        \"type": "column",
        data: successRate,
        color: "#93AACD",
        yAxis: 0,
      },
      {
        showInLegend: true,
        name: "Without Intelligence Transactions",
        \"type": "line",
        data: baseline,
        color: "#A785D8",
        yAxis: 1,
      },
      {
        showInLegend: true,
        name: "With Intelligence Transactions",
        \"type": "line",
        data: model,
        color: "#4185F4",
        yAxis: 1,
      },
    ],
    tooltipFormatter: LineAndColumnGraphUtils.lineColumnGraphTooltipFormatter(
      ~title="Metrics",
      ~metricType=Amount,
      ~currency="",
      ~showNameInTooltip=true,
    ),
    yAxisFormatter: LineAndColumnGraphUtils.lineColumnGraphYAxisFormatter(
      ~statType=AmountWithSuffix,
      ~currency="",
      ~suffix="%",
    ),
  }
}

let getTypedData = (stats: JSON.t) => {
  open LogicUtils
  let statsData = stats->IntelligentRoutingUtils.responseMapper
  let timeSeriesData = statsData.time_series_data

  let gatewayData = switch timeSeriesData->Array.get(0) {
  | Some(statsData) => statsData.volume_distribution_as_per_sr
  | None => JSON.Encode.null
  }
  let gatewayKeys =
    gatewayData
    ->LogicUtils.getDictFromJsonObject
    ->Dict.keysToArray
  gatewayKeys->Array.sort((key1, key2) => {
    key1 <= key2 ? -1. : 1.
  })

  let mapPSPJson = (json): volDist => {
    let dict = json->getDictFromJsonObject
    {
      baseline_volume: dict->getInt("baseline_volume", 0),
      model_volume: dict->getInt("model_volume", 0),
      success_rate: dict->getFloat("success_rate", 0.0),
    }
  }

  let successData = processor =>
    timeSeriesData->Array.map(item => {
      let val = item.volume_distribution_as_per_sr
      let dict = val->getDictFromJsonObject
      let pspData = dict->Dict.get(processor)

      let data = switch pspData {
      | Some(pspData) => pspData->mapPSPJson
      | None => {
          baseline_volume: 0,
          model_volume: 0,
          success_rate: 0.0,
        }
      }
      data
    })

  successData
}

let getKeys = (stats: JSON.t) => {
  let statsData = stats->IntelligentRoutingUtils.responseMapper
  let timeSeriesData = statsData.time_series_data

  let gatewayData = switch timeSeriesData->Array.get(0) {
  | Some(statsData) => statsData.volume_distribution_as_per_sr
  | None => JSON.Encode.null
  }
  let gatewayKeys =
    gatewayData
    ->LogicUtils.getDictFromJsonObject
    ->Dict.keysToArray
  gatewayKeys->Array.sort((key1, key2) => {
    key1 <= key2 ? -1. : 1.
  })
  gatewayKeys
}

let pieGraphOptionsActual = (stats: JSON.t): PieGraphTypes.pieGraphPayload<int> => {
  let gatewayKeys = getKeys(stats)
  let successData = getTypedData(stats)
  let distribution = gatewayKeys->Array.map(processor =>
    successData(processor)
    ->Array.map(item => {
      item.baseline_volume
    })
    ->Array.reduce(0, (acc, val) => {
      acc + val
    })
  )

  let colors = ["#D9DA98", "#EAB9F5", "#6BBDF6", "#AC9EE7", "#498FD0"]

  let data: array<PieGraphTypes.pieGraphDataType> = gatewayKeys->Array.mapWithIndex((
    key,
    index,
  ) => {
    let dataObj: PieGraphTypes.pieGraphDataType = {
      name: key,
      y: distribution->Array.get(index)->Option.getOr(0)->Int.toFloat,
      color: colors->Array.get(index)->Option.getOr(""),
    }
    dataObj
  })

  let data: PieGraphTypes.pieCartData<int> = [
    {
      \"type": "",
      name: "",
      showInLegend: false,
      data,
      innerSize: "70%",
    },
  ]

  {
    chartSize: "80%",
    title: {
      text: "Without Intelligence",
    },
    data,
    tooltipFormatter: PieGraphUtils.pieGraphTooltipFormatter(
      ~title="Transactions",
      ~valueFormatterType=Amount,
    ),
    legendFormatter: PieGraphUtils.pieGraphLegendFormatter(),
    startAngle: 0,
    endAngle: 360,
    legend: {
      enabled: false,
    },
  }
}

let pieGraphOptionsSimulated = (stats: JSON.t): PieGraphTypes.pieGraphPayload<int> => {
  let gatewayKeys = getKeys(stats)
  let successData = getTypedData(stats)
  let distribution = gatewayKeys->Array.map(processor =>
    successData(processor)
    ->Array.map(item => item.model_volume)
    ->Array.reduce(0, (acc, val) => {
      acc + val
    })
  )

  let colors = ["#D9DA98", "#EAB9F5", "#6BBDF6", "#AC9EE7", "#498FD0"]

  let data: array<PieGraphTypes.pieGraphDataType> = gatewayKeys->Array.mapWithIndex((
    key,
    index,
  ) => {
    let dataObj: PieGraphTypes.pieGraphDataType = {
      name: key,
      y: distribution->Array.get(index)->Option.getOr(0)->Int.toFloat,
      color: colors->Array.get(index)->Option.getOr(""),
    }
    dataObj
  })

  let data: PieGraphTypes.pieCartData<int> = [
    {
      \"type": "",
      name: "",
      showInLegend: false,
      data,
      innerSize: "70%",
    },
  ]

  {
    chartSize: "80%",
    title: {
      text: "With Intelligence",
    },
    data,
    tooltipFormatter: PieGraphUtils.pieGraphTooltipFormatter(
      ~title="Transactions",
      ~valueFormatterType=Amount,
    ),
    legendFormatter: PieGraphUtils.pieGraphLegendFormatter(),
    startAngle: 0,
    endAngle: 360,
    legend: {
      enabled: false,
    },
  }
}

let columnGraphOptionsAuthRate = (stats: JSON.t): ColumnGraphTypes.columnGraphPayload => {
  let statsData = stats->IntelligentRoutingUtils.responseMapper
  let timeSeriesData = statsData.time_series_data

  let colors = ["#CFB430", "#D9A3E6", "#97CFF7", "#A18AFF", "#4B6C8B"]

  let baseLineData = timeSeriesData->Array.mapWithIndex((item, index) => {
    let data: ColumnGraphTypes.dataObj = {
      name: getDateTime(item.time_stamp),
      y: item.revenue.baseline,
      color: colors->Array.get(index)->Option.getOr(""),
    }
    data
  })

  {
    title: {
      text: "Auth Rate based on Acquirers",
      align: "left",
      x: 10,
      y: 10,
    },
    data: [
      {
        showInLegend: false,
        name: "Actual",
        colorByPoint: false,
        data: baseLineData,
        color: "#B992DD",
      },
    ],
    tooltipFormatter: ColumnGraphUtils.columnGraphTooltipFormatter(
      ~title="Revenue Uplift",
      ~metricType=FormattedAmount,
      ~comparison=Some(EnableComparison),
    ),
    yAxisFormatter: ColumnGraphUtils.columnGraphYAxisFormatter(
      ~statType=AmountWithSuffix,
      ~currency="$",
      ~suffix="M",
      ~scaleFactor=1000000.0,
    ),
  }
}
