open LogicUtils
open InsightsUtils
open NewAnalyticsUtils

let getLineGraphObj = (
  ~array: array<JSON.t>,
  ~key: string,
  ~name: string,
  ~color: string,
  ~isAmount=false,
  ~currency="",
): LineGraphTypes.dataObj => {
  let data = array->Array.map(item => {
    let value = item->getDictFromJsonObject->getFloat(key, 0.0)
    if isAmount {
      let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(currency)
      value /. conversionFactor
    } else {
      value
    }
  })
  {
    showInLegend: true,
    name,
    data,
    color,
  }
}

let buildLineGraphPayload = (
  ~data: JSON.t,
  ~xKey: string,
  ~yKey: string,
  ~title: string,
): LineGraphTypes.lineGraphPayload => {
  let categories = data->getCategories(0, yKey)

  let lineData =
    data
    ->getArrayFromJson([])
    ->Array.mapWithIndex((item, index) => {
      let name = getLabelName(~key=yKey, ~index, ~points=item)
      let color = index->getColor
      getLineGraphObj(~array=item->getArrayFromJson([]), ~key=xKey, ~name, ~color)
    })

  let tooltipFormatter = tooltipFormatter(
    ~secondaryCategories=[],
    ~title,
    ~metricType=Volume,
  )

  {
    chartHeight: Custom(280),
    chartLeftSpacing: DefaultLeftSpacing,
    categories,
    data: lineData,
    title: {text: ""},
    yAxisMaxValue: None,
    yAxisMinValue: Some(0),
    tooltipFormatter,
    yAxisFormatter: LineGraphUtils.lineGraphYAxisFormatter(
      ~statType=Default,
      ~currency="",
      ~suffix="",
    ),
    legend: {
      useHTML: true,
      labelFormatter: LineGraphUtils.valueFormatter,
    },
  }
}

let buildBarGraphPayload = (
  ~data: array<JSON.t>,
  ~xKey: string,
  ~yKey: string,
  ~title: string,
): BarGraphTypes.barGraphPayload => {
  let categories = data->Array.map(item => {
    item->getDictFromJsonObject->getString(yKey, "NA")
  })

  let barData: BarGraphTypes.dataObj = {
    showInLegend: false,
    name: title,
    data: data->Array.map(item => item->getDictFromJsonObject->getFloat(xKey, 0.0)),
    color: 0->getColor,
  }

  {
    categories,
    data: [barData],
    title: {text: ""},
    tooltipFormatter: bargraphTooltipFormatter(~title, ~metricType=Volume),
  }
}
