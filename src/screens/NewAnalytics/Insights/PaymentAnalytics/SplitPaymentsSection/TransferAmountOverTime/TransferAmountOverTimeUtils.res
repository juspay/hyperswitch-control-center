open TransferAmountOverTimeTypes
open LogicUtils
open CurrencyFormatUtils

let getStringFromVariant = value => {
  switch value {
  | Total_Transfer_Amount => "total_transfer_amount"
  | Time_Bucket => "time_bucket"
  | Connector => "connector"
  }
}

let transferAmountOverTimeMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  open InsightsUtils
  let {data, xKey, yKey} = params
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)
  let comparison = switch params.comparison {
  | Some(val) => Some(val)
  | None => None
  }

  let lineGraphData = data->getLineGraphData(~xKey, ~yKey, ~isAmount=true, ~currency="")

  let tooltipFormatter = tooltipFormatter(
    ~secondaryCategories,
    ~title="Transfer Amount Over Time",
    ~metricType=Amount,
    ~comparison,
  )

  {
    chartHeight: DefaultHeight,
    chartLeftSpacing: DefaultLeftSpacing,
    categories: primaryCategories,
    data: lineGraphData,
    title: {
      text: "",
    },
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

let visibleColumns = [Time_Bucket]

let tableItemToObjMapper: Dict.t<JSON.t> => transferAmountOverTimeObject = dict => {
  {
    total_transfer_amount: dict->getFloat(Total_Transfer_Amount->getStringFromVariant, 0.0),
    time_bucket: dict->getString(Time_Bucket->getStringFromVariant, "NA"),
    connector: dict->getString(Connector->getStringFromVariant, ""),
  }
}

let getObjects: JSON.t => array<transferAmountOverTimeObject> = json => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  switch colType {
  | Total_Transfer_Amount =>
    Table.makeHeaderInfo(
      ~key=Total_Transfer_Amount->getStringFromVariant,
      ~title="Transfer Amount",
      ~dataType=TextType,
    )
  | Time_Bucket =>
    Table.makeHeaderInfo(~key=Time_Bucket->getStringFromVariant, ~title="Date", ~dataType=TextType)
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
  | Total_Transfer_Amount => Text(obj.total_transfer_amount->valueFormatter(Amount))
  | Time_Bucket => Text(obj.time_bucket->NewAnalyticsUtils.formatDateValue(~includeYear=true))
  | Connector => Text(obj.connector->LogicUtils.snakeToTitle)
  }
}

let getTableData = json => {
  json->getArrayDataFromJson(tableItemToObjMapper)->Array.map(Nullable.make)
}
