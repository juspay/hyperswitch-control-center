open FeesByChargeTypeTypes
open LogicUtils
open CurrencyFormatUtils

let getStringFromVariant = value => {
  switch value {
  | Total_Platform_Fees => "total_platform_fees"
  | Charge_Type => "charge_type"
  }
}

let feesByChargeTypeMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): BarGraphTypes.barGraphPayload => {
  open BarGraphTypes
  open InsightsUtils
  let {data, xKey, yKey} = params
  let categories = [data]->JSON.Encode.array->getCategories(0, yKey)

  let barGraphData = getBarGraphObj(
    ~array=data->getArrayFromJson([]),
    ~key=xKey,
    ~name="Platform Fees",
    ~color=NewAnalyticsUtils.turquoise,
  )

  let title = {
    text: "",
  }

  {
    categories,
    data: [barGraphData],
    title,
    tooltipFormatter: bargraphTooltipFormatter(
      ~title="Fees by Charge Type",
      ~metricType=Amount,
    ),
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => feesByChargeTypeObject = dict => {
  {
    total_platform_fees: dict->getFloat(Total_Platform_Fees->getStringFromVariant, 0.0),
    charge_type: dict->getString(Charge_Type->getStringFromVariant, ""),
  }
}

let getObjects: JSON.t => array<feesByChargeTypeObject> = json => {
  json->getArrayFromJson([])->Array.map(item => {
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
  | Charge_Type =>
    Table.makeHeaderInfo(
      ~key=Charge_Type->getStringFromVariant,
      ~title="Charge Type",
      ~dataType=TextType,
    )
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | Total_Platform_Fees => Text(obj.total_platform_fees->valueFormatter(Amount))
  | Charge_Type => Text(obj.charge_type->snakeToTitle)
  }
}

let getTableData = json => {
  json->getArrayDataFromJson(tableItemToObjMapper)->Array.map(Nullable.make)
}
