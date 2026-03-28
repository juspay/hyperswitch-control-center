open LogicUtils
open CurrencyFormatUtils

type connectorDeclineCols =
  | Connector
  | Standardised_Code
  | Error_Category
  | Count
  | Percentage

type connectorDeclineObject = {
  connector: string,
  standardised_code: string,
  error_category: string,
  count: int,
  percentage: float,
}

let getStringFromVariant = value => {
  switch value {
  | Connector => "connector"
  | Standardised_Code => "standardised_code"
  | Error_Category => "error_category"
  | Count => "failure_reason_count"
  | Percentage => "percentage"
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => connectorDeclineObject = dict => {
  {
    connector: dict->getString(Connector->getStringFromVariant, ""),
    standardised_code: dict->getString(Standardised_Code->getStringFromVariant, ""),
    error_category: dict->getString(Error_Category->getStringFromVariant, ""),
    count: dict->getInt(Count->getStringFromVariant, 0),
    percentage: 0.0,
  }
}

let getObjects: JSON.t => array<connectorDeclineObject> = json => {
  let items =
    json
    ->getArrayFromJson([])
    ->Array.map(item => {
      tableItemToObjMapper(item->getDictFromJsonObject)
    })
  let total = items->Array.reduce(0, (acc, item) => acc + item.count)->Int.toFloat
  items->Array.map(item => {
    ...item,
    percentage: if total > 0.0 {
      item.count->Int.toFloat /. total *. 100.0
    } else {
      0.0
    },
  })
}

let getColor = index => NewAnalyticsUtils.getColor(index)

let connectorDeclineMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): BarGraphTypes.barGraphPayload => {
  open BarGraphTypes
  let {data} = params
  let items = data->getArrayFromJson([])

  // Get unique connectors (X-axis categories)
  let connectors =
    items
    ->Array.map(item => item->getDictFromJsonObject->getString("connector", ""))
    ->Array.filter(c => c !== "")
    ->Belt.SortArray.stableSortBy((a, b) => String.compare(a, b)->Belt.Float.toInt)
  // Deduplicate
  let uniqueConnectors = connectors->Array.reduce([], (acc, c) => {
    if acc->Array.includes(c) {
      acc
    } else {
      acc->Array.concat([c])
    }
  })

  // Get unique standardised_codes (one series per code)
  let codes =
    items
    ->Array.map(item => item->getDictFromJsonObject->getString("standardised_code", ""))
    ->Array.filter(c => c !== "")
  let uniqueCodes = codes->Array.reduce([], (acc, c) => {
    if acc->Array.includes(c) {
      acc
    } else {
      acc->Array.concat([c])
    }
  })

  // Build one series per standardised_code
  let seriesData = uniqueCodes->Array.mapWithIndex((code, idx) => {
    let dataPoints = uniqueConnectors->Array.map(connector => {
      // Find count for this connector + code combination
      let matchingItem = items->Array.find(
        item => {
          let dict = item->getDictFromJsonObject
          dict->getString("connector", "") === connector &&
            dict->getString("standardised_code", "") === code
        },
      )
      switch matchingItem {
      | Some(item) => item->getDictFromJsonObject->getInt("failure_reason_count", 0)->Int.toFloat
      | None => 0.0
      }
    })
    let color = getColor(idx)
    {
      showInLegend: true,
      name: code,
      data: dataPoints,
      color,
    }
  })

  let title = {text: ""}

  {
    categories: uniqueConnectors,
    data: seriesData,
    title,
    tooltipFormatter: InsightsUtils.bargraphTooltipFormatter(
      ~title="Connector vs Decline",
      ~metricType=Volume,
    ),
  }
}

let stackedTooltipFormatter = () => {
  open BarGraphTypes
  asTooltipPointFormatter(@this (this: pointFormatter) => {
    let defaultValue = {color: "", x: "", y: 0.0, point: {index: 0}}
    let firstPoint = this.points->LogicUtils.getValueFromArray(0, defaultValue)
    let connectorName = firstPoint.x

    let title = `<div style="font-size: 14px; font-weight: bold; margin-bottom: 8px;">${connectorName}</div>`

    let rows =
      this.points
      ->Array.filter(p => p.y > 0.0)
      ->Array.map(point => {
        let value = point.y->Float.toString
        `<div style="display: flex; align-items: center; gap: 8px;">
            <div style="width: 10px; height: 10px; background-color:${point.color}; border-radius: 3px;"></div>
            <div style="flex: 1;">${value}</div>
          </div>`
      })
      ->Array.joinWith("")

    `<div style="
        padding: 10px;
        border-radius: 7px;
        background-color: #FFFFFF;
        box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
        border: 1px solid #E5E5E5;
        min-width: 150px;">
        ${title}
        ${rows}
      </div>`
  })
}

// Custom stacked bar graph options
let getStackedBarGraphOptions = (barGraphOptions: BarGraphTypes.barGraphPayload) => {
  open BarGraphTypes
  let {categories, data} = barGraphOptions
  let tooltipFormatter = stackedTooltipFormatter()

  let fontFamily = "Arial, sans-serif"
  let darkGray = "#666666"
  let gridLineColor = "#e6e6e6"

  let style = {
    fontFamily,
    fontSize: "12px",
    color: darkGray,
  }

  {
    chart: {
      \"type": "bar",
      spacingLeft: 20,
      spacingRight: 20,
    },
    title: {
      text: "",
    },
    xAxis: {
      categories,
      labels: {
        align: "center",
        style,
      },
      tickWidth: 1,
      tickmarkPlacement: "on",
      endOnTick: false,
      startOnTick: false,
      gridLineWidth: 1,
      gridLineDashStyle: "Dash",
      gridLineColor,
      min: 0,
    },
    yAxis: {
      title: {text: "Count"},
      labels: {
        align: "center",
        style,
      },
      gridLineWidth: 1,
      gridLineDashStyle: "Solid",
      gridLineColor,
    },
    tooltip: {
      style: {
        padding: "0px",
        fontFamily,
        fontSize: "14px",
      },
      shape: "square",
      shadow: false,
      backgroundColor: "transparent",
      borderColor: "transparent",
      borderWidth: 0.0,
      formatter: tooltipFormatter,
      useHTML: true,
      shared: true,
    },
    plotOptions: {
      bar: {
        marker: {
          enabled: false,
        },
        pointPadding: 0.2,
        stacking: "normal",
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}

let getHeading = colType => {
  switch colType {
  | Connector =>
    Table.makeHeaderInfo(
      ~key=Connector->getStringFromVariant,
      ~title="Connector",
      ~dataType=TextType,
    )
  | Standardised_Code =>
    Table.makeHeaderInfo(
      ~key=Standardised_Code->getStringFromVariant,
      ~title="Standardised Code",
      ~dataType=TextType,
    )
  | Error_Category =>
    Table.makeHeaderInfo(
      ~key=Error_Category->getStringFromVariant,
      ~title="Error Category",
      ~dataType=TextType,
    )
  | Count =>
    Table.makeHeaderInfo(~key=Count->getStringFromVariant, ~title="Count", ~dataType=TextType)
  | Percentage =>
    Table.makeHeaderInfo(
      ~key=Percentage->getStringFromVariant,
      ~title="Percentage (%)",
      ~dataType=TextType,
    )
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | Connector => Text(obj.connector)
  | Standardised_Code => Text(obj.standardised_code)
  | Error_Category => Text(obj.error_category)
  | Count => Text(obj.count->Int.toString)
  | Percentage => Text(obj.percentage->valueFormatter(Rate))
  }
}

let getTableData = json => {
  getObjects(json)->Array.map(Nullable.make)
}

let visibleColumns = [Connector, Standardised_Code, Error_Category, Count, Percentage]
