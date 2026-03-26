open PlatformFeeRateByConnectorTypes
open LogicUtils
open CurrencyFormatUtils

let getStringFromVariant = value => {
  switch value {
  | Avg_Platform_Fee_Rate => "avg_platform_fee_rate"
  | Connector => "connector"
  }
}

let platformFeeRateByConnectorMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): BarGraphTypes.barGraphPayload => {
  open BarGraphTypes
  open InsightsUtils
  let {data, xKey, yKey} = params
  let categories = [data]->JSON.Encode.array->getCategories(0, yKey)

  let barGraphData = getBarGraphObj(
    ~array=data->getArrayFromJson([]),
    ~key=xKey,
    ~name="Avg Fee Rate",
    ~color=NewAnalyticsUtils.skyBlue,
  )

  let title = {
    text: "",
  }

  {
    categories,
    data: [barGraphData],
    title,
    tooltipFormatter: bargraphTooltipFormatter(
      ~title="Platform Fee Rate by Connector",
      ~metricType=Rate,
    ),
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => platformFeeRateByConnectorObject = dict => {
  {
    avg_platform_fee_rate: dict->getFloat(Avg_Platform_Fee_Rate->getStringFromVariant, 0.0),
    connector: dict->getString(Connector->getStringFromVariant, ""),
  }
}

let getObjects: JSON.t => array<platformFeeRateByConnectorObject> = json => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  switch colType {
  | Avg_Platform_Fee_Rate =>
    Table.makeHeaderInfo(
      ~key=Avg_Platform_Fee_Rate->getStringFromVariant,
      ~title="Avg Fee Rate",
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
  | Avg_Platform_Fee_Rate => Text(obj.avg_platform_fee_rate->valueFormatter(Rate))
  | Connector => Text(obj.connector->snakeToTitle)
  }
}

let getTableData = json => {
  json->getArrayDataFromJson(tableItemToObjMapper)->Array.map(Nullable.make)
}
