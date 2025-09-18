open InsightsUtils
open NewAnalyticsUtils
open LogicUtils
open SuccessfulRefundsDistributionTypes

let getStringFromVariant = value => {
  switch value {
  | Refunds_Success_Rate => "refunds_success_rate"
  | Refund_Count => "refund_count"
  | Refund_Success_Count => "refund_success_count"
  | Connector => "connector"
  }
}

let successfulRefundsDistributionMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): BarGraphTypes.barGraphPayload => {
  open BarGraphTypes
  let {data, xKey, yKey} = params
  let categories = [data]->JSON.Encode.array->getCategories(0, yKey)

  let barGraphData = getBarGraphObj(
    ~array=data->getArrayFromJson([]),
    ~key=xKey,
    ~name=xKey->snakeToTitle,
    ~color=barGreenColor,
  )

  let title = {
    text: "",
  }

  let tooltipFormatter = bargraphTooltipFormatter(
    ~title="Successful Refunds Distribution",
    ~metricType=Rate,
  )

  {
    categories,
    data: [barGraphData],
    title,
    tooltipFormatter,
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => successfulRefundsDistributionObject = dict => {
  {
    refund_count: dict->getInt(Refund_Count->getStringFromVariant, 0),
    refund_success_count: dict->getInt(Refund_Success_Count->getStringFromVariant, 0),
    refunds_success_rate: dict->getFloat(Refunds_Success_Rate->getStringFromVariant, 0.0),
    connector: dict->getString(Connector->getStringFromVariant, ""),
  }
}

let getObjects: JSON.t => array<successfulRefundsDistributionObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  switch colType {
  | Refunds_Success_Rate =>
    Table.makeHeaderInfo(
      ~key=Refunds_Success_Rate->getStringFromVariant,
      ~title="Refunds Success Rate",
      ~dataType=TextType,
    )
  | Connector =>
    Table.makeHeaderInfo(
      ~key=Connector->getStringFromVariant,
      ~title="Connector",
      ~dataType=TextType,
    )
  | _ => Table.makeHeaderInfo(~key="", ~title="", ~dataType=TextType)
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | Refunds_Success_Rate => Text(obj.refunds_success_rate->valueFormatter(Rate))
  | Connector => Text(obj.connector)
  | _ => Text("")
  }
}

let getTableData = json => {
  json->getArrayDataFromJson(tableItemToObjMapper)->Array.map(Nullable.make)
}

let modifyQuery = query => {
  query->Array.map(value => {
    let valueDict = value->getDictFromJsonObject
    let refund_count = valueDict->getInt(Refund_Count->getStringFromVariant, 0)->Int.toFloat
    let refund_success_count =
      valueDict->getInt(Refund_Success_Count->getStringFromVariant, 0)->Int.toFloat

    let refunds_success_rate = refund_success_count /. refund_count *. 100.0

    valueDict->Dict.set(
      Refunds_Success_Rate->getStringFromVariant,
      refunds_success_rate->JSON.Encode.float,
    )

    valueDict->JSON.Encode.object
  })
}
