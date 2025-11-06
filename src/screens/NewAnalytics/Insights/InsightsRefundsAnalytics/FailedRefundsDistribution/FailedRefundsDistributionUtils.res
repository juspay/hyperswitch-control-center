open InsightsUtils
open LogicUtils
open CurrencyFormatUtils
open FailedRefundsDistributionTypes

let getStringFromVariant = value => {
  switch value {
  | Refunds_Failure_Rate => "refunds_failure_rate"
  | Refund_Count => "refund_count"
  | Connector => "connector"
  }
}

let failedRefundsDistributionMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): BarGraphTypes.barGraphPayload => {
  open BarGraphTypes
  let {data, xKey, yKey} = params
  let categories = [data]->JSON.Encode.array->getCategories(0, yKey)

  let barGraphData = getBarGraphObj(
    ~array=data->getArrayFromJson([]),
    ~key=xKey,
    ~name=xKey->snakeToTitle,
    ~color=NewAnalyticsUtils.redColor,
  )
  let title = {
    text: "",
  }

  {
    categories,
    data: [barGraphData],
    title,
    tooltipFormatter: bargraphTooltipFormatter(
      ~title="Failed Refunds Distribution",
      ~metricType=Rate,
    ),
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => failedRefundsDistributionObject = dict => {
  {
    refund_count: dict->getInt(Refund_Count->getStringFromVariant, 0),
    refunds_failure_rate: dict->getFloat(Refunds_Failure_Rate->getStringFromVariant, 0.0),
    connector: dict->getString(Connector->getStringFromVariant, ""),
  }
}

let getObjects: JSON.t => array<failedRefundsDistributionObject> = json => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  switch colType {
  | Refunds_Failure_Rate =>
    Table.makeHeaderInfo(
      ~key=Refunds_Failure_Rate->getStringFromVariant,
      ~title="Refunds Failure Rate",
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
  | Refunds_Failure_Rate => Text(obj.refunds_failure_rate->valueFormatter(Rate))
  | Connector => Text(obj.connector)
  | _ => Text("")
  }
}

let getTableData = json => {
  json->getArrayDataFromJson(tableItemToObjMapper)->Array.map(Nullable.make)
}

let modifyQuery = (totalCountArr, failureCountArr) => {
  let mapper = Dict.make()

  totalCountArr->Array.forEach(item => {
    let valueDict = item->getDictFromJsonObject
    let key = valueDict->getString(Connector->getStringFromVariant, "")

    if key->isNonEmptyString {
      mapper->Dict.set(key, item)
    }
  })

  failureCountArr->Array.forEach(item => {
    let itemDict = item->getDictFromJsonObject
    let key = itemDict->getString(Connector->getStringFromVariant, "")

    switch mapper->Dict.get(key) {
    | Some(value) => {
        let valueDict = value->getDictFromJsonObject

        let failureCount = itemDict->getInt(Refund_Count->getStringFromVariant, 0)->Int.toFloat
        let totalCount = valueDict->getInt(Refund_Count->getStringFromVariant, 0)->Int.toFloat

        let failureRate = totalCount > 0.0 ? failureCount /. totalCount *. 100.0 : 0.0

        valueDict->Dict.set(
          Refunds_Failure_Rate->getStringFromVariant,
          failureRate->JSON.Encode.float,
        )

        mapper->Dict.set(key, valueDict->JSON.Encode.object)
      }
    | _ => ()
    }
  })

  mapper->Dict.valuesToArray
}
