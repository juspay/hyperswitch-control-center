open PlatformFeesByConnectorTypes
open LogicUtils
open CurrencyFormatUtils

let getStringFromVariant = value => {
  switch value {
  | Total_Platform_Fees => "total_platform_fees"
  | Connector => "connector"
  }
}

let platformFeesByConnectorPieMapper = (data: JSON.t) => {
  let queryData = data->getArrayFromJson([])
  let feesKey = Total_Platform_Fees->getStringFromVariant
  let connectorKey = Connector->getStringFromVariant

  let pieData: array<PieGraphTypes.pieGraphDataType> = queryData->Array.map(item => {
    let dict = item->getDictFromJsonObject
    let dataObj: PieGraphTypes.pieGraphDataType = {
      name: dict->getString(connectorKey, "")->snakeToTitle,
      y: dict->getFloat(feesKey, 0.0),
    }
    dataObj
  })

  let payload: PieGraphTypes.pieGraphPayload<int> = {
    chartSize: "80%",
    title: {text: ""},
    data: [
      {
        \"type": "",
        name: "",
        showInLegend: true,
        data: pieData,
        innerSize: "70%",
      },
    ],
    tooltipFormatter: PieGraphUtils.pieGraphTooltipFormatter(
      ~title="Platform Fees by Connector",
      ~valueFormatterType=Amount,
    ),
    legendFormatter: (
      @this
      (this: PieGraphTypes.legendLabelFormatter) => {
        let name = this.name->snakeToTitle
        `<div style="font-size: 14px; font-weight: 600; padding: 4px 0;">${name} | ${this.y->valueFormatter(
            Amount,
          )}</div>`
      }
    )->PieGraphTypes.asLegendPointFormatter,
    startAngle: 0,
    endAngle: 360,
    legend: {
      align: "right",
      verticalAlign: "middle",
      enabled: true,
      layout: "vertical",
    },
  }

  let defaultOptions = payload->PieGraphUtils.getPieChartOptions

  {
    ...defaultOptions,
    chart: {
      ...defaultOptions.chart,
      width: 600,
      height: 300,
    },
    plotOptions: {
      pie: {
        ...defaultOptions.plotOptions.pie,
        center: ["30%", "50%"],
      },
    },
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => platformFeesByConnectorObject = dict => {
  {
    total_platform_fees: dict->getFloat(Total_Platform_Fees->getStringFromVariant, 0.0),
    connector: dict->getString(Connector->getStringFromVariant, ""),
  }
}

let getObjects: JSON.t => array<platformFeesByConnectorObject> = json => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  switch colType {
  | Total_Platform_Fees =>
    Table.makeHeaderInfo(
      ~key=Total_Platform_Fees->getStringFromVariant,
      ~title="Platform Fees",
      ~dataType=TextType,
    )
  | Connector =>
    Table.makeHeaderInfo(
      ~key=Connector->getStringFromVariant,
      ~title="Connector",
      ~dataType=TextType,
    )
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | Total_Platform_Fees => Text(obj.total_platform_fees->valueFormatter(Amount))
  | Connector => Text(obj.connector->snakeToTitle)
  }
}

let getTableData = json => {
  json->getArrayDataFromJson(tableItemToObjMapper)->Array.map(Nullable.make)
}
