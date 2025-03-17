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

let stepperHeading = (~title: string, ~subTitle: string) =>
  <div className="flex flex-col gap-y-1">
    <p className="text-2xl font-semibold text-nd_gray-700 leading-9"> {title->React.string} </p>
    <p className="text-sm text-nd_gray-400 font-medium leading-5"> {subTitle->React.string} </p>
  </div>

let getDateTime = value => {
  let dateObj = value->DayJs.getDayJsForString
  let date = `${dateObj.month()->NewAnalyticsUtils.getMonthName} ${dateObj.format("DD")}`
  let time = dateObj.format("HH:mm")->NewAnalyticsUtils.formatTime
  `${date}, ${time}`
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
        name: "Actual",
        colorByPoint: false,
        data: baseLineData,
        color: "#B992DD",
      },
      {
        showInLegend: true,
        name: "Simulated",
        colorByPoint: false,
        data: modelData,
        color: "#1E90FF",
      },
    ],
    tooltipFormatter: ColumnGraphUtils.columnGraphTooltipFormatter(
      ~title="Revenue Uplift",
      ~metricType=FormattedAmount,
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
    },
    categories: timeSeriesArray,
    data: [
      {
        showInLegend: true,
        name: "Actual",
        data: baselineSuccessRate,
        color: "#B992DD",
      },
      {
        showInLegend: true,
        name: "Simulated",
        data: modelSuccessRate,
        color: "#1E90FF",
      },
    ],
    tooltipFormatter: NewAnalyticsUtils.tooltipFormatter(
      ~title="Authorization Rate",
      ~metricType=Amount,
      ~currency="",
      ~comparison=Some(EnableComparison),
      ~secondaryCategories=timeSeriesArray,
      ~reverse=true,
    ),
    yAxisMaxValue: None,
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

  let mapPSPJson = (json): IntelligentRoutingTypes.volDist => {
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

  {
    title: {
      text: "Processor wise transaction distribution with Auth Rate",
      align: "left",
      x: 10,
      y: 10,
    },
    categories: timeStampArray,
    data: [
      {
        showInLegend: true,
        name: "Processor's Auth Rate",
        \"type": "column",
        data: successRate,
        color: "#B5B28E",
        yAxis: 0,
      },
      {
        showInLegend: true,
        name: "Actual Transactions",
        \"type": "line",
        data: baseline,
        color: "#A785D8",
        yAxis: 1,
      },
      {
        showInLegend: true,
        name: "Simulated Transactions",
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
    ),
  }
}
