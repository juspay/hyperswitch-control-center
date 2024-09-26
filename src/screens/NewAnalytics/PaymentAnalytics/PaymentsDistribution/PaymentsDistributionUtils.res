open NewPaymentAnalyticsUtils
open PaymentsDistributionTypes
open LogicUtils

let colMapper = (col: queryData) => {
  switch col {
  | PaymentsSuccessRate => "payments_success_rate"
  | Connector => "connector"
  | PaymentMethod => "payment_method"
  }
}

let paymentsDistributionMapper = (
  ~data: JSON.t,
  ~xKey: string,
  ~yKey: string,
): BarGraphTypes.barGraphPayload => {
  open BarGraphTypes
  let categories = getCategories(data, yKey)
  let data = getBarGraphData(data, xKey)
  let title = {
    text: "",
  }
  {categories, data, title}
}

let visibleColumns = [PaymentsSuccessRate, Connector]

let tableItemToObjMapper: Dict.t<JSON.t> => paymentsDistributionObject = dict => {
  {
    payments_success_rate: dict->getInt(PaymentsSuccessRate->colMapper, 0),
    connector: dict->getString(Connector->colMapper, ""),
    payment_method: dict->getString(PaymentMethod->colMapper, ""),
  }
}

let getObjects: JSON.t => array<paymentsDistributionObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  let key = colType->colMapper
  switch colType {
  | PaymentsSuccessRate =>
    Table.makeHeaderInfo(~key, ~title="Payments Success Rate", ~dataType=TextType)
  | Connector => Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=TextType)
  | PaymentMethod => Table.makeHeaderInfo(~key, ~title="Payment Method", ~dataType=TextType)
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | PaymentsSuccessRate => Text(obj.payments_success_rate->Int.toString)
  | Connector => Text(obj.connector)
  | PaymentMethod => Text(obj.payment_method)
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
