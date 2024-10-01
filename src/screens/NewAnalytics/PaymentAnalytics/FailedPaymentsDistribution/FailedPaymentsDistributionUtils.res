open NewPaymentAnalyticsUtils
open FailedPaymentsDistributionTypes
open LogicUtils

let colMapper = (col: col) => {
  switch col {
  | ErrorReason => "reason"
  | Count => "count"
  | Ratio => "percentage"
  | Connector => "connector"
  | PaymentsFailureRate => "payments_failure_rate"
  }
}

let failedPaymentsDistributionMapper = (
  ~data: JSON.t,
  ~xKey: string,
  ~yKey: string,
): BarGraphTypes.barGraphPayload => {
  open BarGraphTypes
  let categories = getCategories(data, yKey)
  let data = getBarGraphData(data, xKey, "#BA3535")
  let title = {
    text: "",
  }
  {categories, data, title}
}

let visibleColumns = [ErrorReason, Count, Ratio, Connector]

let tableItemToObjMapper: Dict.t<JSON.t> => failedPaymentsDistributionObject = dict => {
  {
    reason: dict->getString(ErrorReason->colMapper, ""),
    count: dict->getInt(Count->colMapper, 0),
    connector: dict->getString(Connector->colMapper, ""),
    percentage: dict->getInt(Ratio->colMapper, 0),
  }
}

let getObjects: JSON.t => array<failedPaymentsDistributionObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  let key = colType->colMapper
  switch colType {
  | ErrorReason => Table.makeHeaderInfo(~key, ~title="Error Reason", ~dataType=TextType)
  | Count => Table.makeHeaderInfo(~key, ~title="Count", ~dataType=TextType)
  | Ratio => Table.makeHeaderInfo(~key, ~title="Ratio", ~dataType=TextType)
  | Connector => Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=TextType)
  | _ => Table.makeHeaderInfo(~key, ~title="", ~dataType=TextType)
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | ErrorReason => Text(obj.reason)
  | Count => Text(obj.count->Int.toString)
  | Ratio => Text(obj.percentage->Int.toString)
  | Connector => Text(obj.connector)
  | _ => Text("")
  }
}

let getTableData = json =>
  json
  ->getArrayFromJson([])
  ->getValueFromArray(0, []->JSON.Encode.array)
  ->getDictFromJsonObject
  ->getArrayFromDict("queryData", [])
  ->JSON.Encode.array
  ->getArrayDataFromJson(tableItemToObjMapper)
  ->Array.map(Nullable.make)

open NewAnalyticsTypes
let tabs = [
  {
    label: "Connector",
    value: (#connector: dimension :> string),
  },
  {
    label: "Payment Method",
    value: (#payment_method: dimension :> string),
  },
  {
    label: "Payment Method Type",
    value: (#payment_method_type: dimension :> string),
  },
  {
    label: "Card Network",
    value: (#card_network: dimension :> string),
  },
  {
    label: "Authentication Type",
    value: (#authentication_type: dimension :> string),
  },
]

let defaulGroupBy = {
  label: "Connector",
  value: (#connector: dimension :> string),
}
