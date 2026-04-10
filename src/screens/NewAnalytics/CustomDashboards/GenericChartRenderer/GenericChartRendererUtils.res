open LogicUtils
open InsightsUtils
open NewAnalyticsUtils

let buildLineGraphPayload = (
  ~data: JSON.t,
  ~xKey: string,
  ~yKey: string,
  ~title: string,
  ~chartHeight: int=280,
): LineGraphTypes.lineGraphPayload => {
  let categories = data->getCategories(0, yKey)

  // Reuse existing InsightsUtils.getLineGraphData
  let lineData = data->getLineGraphData(~xKey, ~yKey, ~currency="")

  let tooltipFormatter = tooltipFormatter(~secondaryCategories=[], ~title, ~metricType=Volume)

  {
    chartHeight: Custom(chartHeight),
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
    item->getDictFromJsonObject->getString(yKey, "NA")->snakeToTitle
  })

  let barData: BarGraphTypes.dataObj = {
    showInLegend: false,
    name: title,
    data: data->Array.map(item => item->getDictFromJsonObject->getFloat(xKey, 0.0)),
    color: getColor(0),
  }

  {
    categories,
    data: [barData],
    title: {text: ""},
    tooltipFormatter: bargraphTooltipFormatter(~title, ~metricType=Volume),
  }
}

let buildColumnGraphPayload = (
  ~data: array<JSON.t>,
  ~xKey: string,
  ~yKey: string,
  ~title: string,
): ColumnGraphTypes.columnGraphPayload => {
  let columnData = data->Array.mapWithIndex((item, index) => {
    let dict = item->getDictFromJsonObject
    let dataPoint: ColumnGraphTypes.dataObj = {
      name: dict->getString(yKey, "NA")->snakeToTitle,
      y: dict->getFloat(xKey, 0.0),
      color: getColor(index),
    }
    dataPoint
  })

  let seriesObj: ColumnGraphTypes.seriesObj = {
    showInLegend: true,
    name: title,
    colorByPoint: true,
    data: columnData,
    color: getColor(0),
  }

  let tooltipFormatter = (
    @this
    (this: ColumnGraphTypes.pointFormatter) => {
      let point = this.points->Array.get(0)
      switch point {
      | Some(p) =>
        `<div style="padding:8px;background:#fff;border-radius:6px;box-shadow:0 2px 8px rgba(0,0,0,0.15);border:1px solid #e5e7eb;">
          <div style="font-weight:600;margin-bottom:4px;">${p.key}</div>
          <div style="color:${p.color};">${p.y->Js.Float.toFixedWithPrecision(~digits=2)}</div>
        </div>`
      | None => ""
      }
    }
  )->ColumnGraphTypes.asTooltipPointFormatter

  let yAxisFormatter = (
    @this
    (_this: ColumnGraphTypes.yAxisFormatter) => {
      ""
    }
  )->ColumnGraphTypes.asTooltipPointFormatter

  {
    data: [seriesObj],
    title: {text: ""},
    tooltipFormatter,
    yAxisFormatter,
  }
}

let buildStackedBarGraphPayload = (
  ~data: array<JSON.t>,
  ~xKey: string,
  ~yKey: string,
  ~_title: string,
): StackedBarGraphTypes.stackedBarGraphPayload => {
  let categories =
    data->Array.map(item => item->getDictFromJsonObject->getString(yKey, "NA")->snakeToTitle)

  let stackedData: StackedBarGraphTypes.dataObj = {
    name: xKey->snakeToTitle,
    data: data->Array.map(item => item->getDictFromJsonObject->getFloat(xKey, 0.0)),
    color: getColor(0),
  }

  let labelFormatter = (
    @this
    (this: StackedBarGraphTypes.labelFormatter) => {
      `<span style="font-size:11px;">${this.name}</span>`
    }
  )->StackedBarGraphTypes.asLabelFormatter

  {
    categories,
    data: [stackedData],
    labelFormatter,
  }
}

let buildSankeyGraphPayload = (
  ~data: array<JSON.t>,
  ~xKey: string,
  ~yKey: string,
  ~title: string,
): SankeyGraphTypes.sankeyPayload => {
  // Build flow data: source → category → value
  // Each grouped data point becomes a flow from "Total" to the category
  let sankeyData: SankeyGraphTypes.data = data->Array.map(item => {
    let dict = item->getDictFromJsonObject
    let category = dict->getString(yKey, "Unknown")->snakeToTitle
    let value = dict->getFloat(xKey, 0.0)->Float.toInt
    ("Total", category, value, "")
  })

  let nodes: SankeyGraphTypes.nodes = [
    (
      {
        id: "Total",
        dataLabels: {align: "left", x: -10, name: 0},
      }: SankeyGraphTypes.node
    ),
  ]->Array.concat(
    data->Array.mapWithIndex((item, index) => {
      let category = item->getDictFromJsonObject->getString(yKey, "Unknown")->snakeToTitle

      (
        {
          id: category,
          dataLabels: {align: "right", x: 10, name: index + 1},
        }: SankeyGraphTypes.node
      )
    }),
  )

  let colors = data->Array.mapWithIndex((_, index) => getColor(index))

  {
    title: {text: title},
    data: sankeyData,
    nodes,
    colors,
  }
}

let buildFunnelData = (
  ~data: array<JSON.t>,
  ~xKey: string,
  ~yKey: string,
  ~title: string,
): ColumnGraphTypes.columnGraphPayload => {
  // Sort data descending by value for funnel effect
  let sorted =
    data
    ->Array.map(item => {
      let dict = item->getDictFromJsonObject
      (dict->getString(yKey, "NA")->snakeToTitle, dict->getFloat(xKey, 0.0))
    })
    ->Array.toSorted((a, b) => {
      let (_, va) = a
      let (_, vb) = b
      if vb > va {
        1.0
      } else if vb < va {
        -1.0
      } else {
        0.0
      }
    })

  let columnData = sorted->Array.mapWithIndex(((name, value), index) => {
    let dataPoint: ColumnGraphTypes.dataObj = {
      name,
      y: value,
      color: getColor(index),
    }
    dataPoint
  })

  let seriesObj: ColumnGraphTypes.seriesObj = {
    showInLegend: false,
    name: title,
    colorByPoint: true,
    data: columnData,
    color: getColor(0),
  }

  let tooltipFormatter = (
    @this
    (this: ColumnGraphTypes.pointFormatter) => {
      let point = this.points->Array.get(0)
      switch point {
      | Some(p) =>
        `<div style="padding:8px;background:#fff;border-radius:6px;box-shadow:0 2px 8px rgba(0,0,0,0.15);border:1px solid #e5e7eb;">
          <div style="font-weight:600;margin-bottom:4px;">${p.key}</div>
          <div style="color:${p.color};">${p.y->Js.Float.toFixedWithPrecision(~digits=2)}</div>
        </div>`
      | None => ""
      }
    }
  )->ColumnGraphTypes.asTooltipPointFormatter

  let yAxisFormatter = (
    @this
    (_this: ColumnGraphTypes.yAxisFormatter) => {
      ""
    }
  )->ColumnGraphTypes.asTooltipPointFormatter

  {
    data: [seriesObj],
    title: {text: ""},
    tooltipFormatter,
    yAxisFormatter,
  }
}

let buildPieGraphPayload = (
  ~data: array<JSON.t>,
  ~xKey: string,
  ~yKey: string,
  ~title: string,
): PieGraphTypes.pieGraphPayload<'t> => {
  // Calculate total for percentage display
  let total = data->Array.reduce(0.0, (acc, item) => {
    acc +. item->getDictFromJsonObject->getFloat(xKey, 0.0)
  })

  let pieData = data->Array.mapWithIndex((item, index) => {
    let dict = item->getDictFromJsonObject
    let value = dict->getFloat(xKey, 0.0)
    let name = dict->getString(yKey, "Unknown")->snakeToTitle
    let pct = if total > 0.0 {
      value /. total *. 100.0
    } else {
      0.0
    }
    let pctStr = pct->Js.Float.toFixedWithPrecision(~digits=0)
    let dataPoint: PieGraphTypes.pieGraphDataType = {
      name: `${name} ${pctStr}%`,
      y: value,
      color: getColor(index),
    }
    dataPoint
  })

  let pieDataObj: PieGraphTypes.dataObj<'t> = {
    \"type": "pie",
    innerSize: "55%",
    showInLegend: true,
    name: title,
    data: pieData,
  }

  // Pie size 60% leaves bottom 40% for legend (200px container → 120px pie + 80px legend)
  {
    data: [pieDataObj],
    title: {text: ""},
    tooltipFormatter: PieGraphUtils.pieGraphTooltipFormatter(~title, ~valueFormatterType=Volume),
    legendFormatter: PieGraphUtils.pieGraphLegendFormatter(),
    chartSize: "60%",
    startAngle: 0,
    endAngle: 360,
    legend: {
      enabled: true,
      layout: "horizontal",
      align: "center",
      verticalAlign: "bottom",
      y: 0,
      itemMarginBottom: 2,
    },
  }
}
