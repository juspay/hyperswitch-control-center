open NewPaymentAnalyticsUtils
open PaymentsDistributionTypes
open LogicUtils

let getPaymentQueryDataString = queryData =>
  switch queryData {
  | PaymentsSuccessRate => "payments_success_rate"
  | Connector => "connector"
  }

let paymentsDistributionMapper = (json: JSON.t): BarGraphTypes.barGraphPayload => {
  open BarGraphTypes
  let categories = getCategories(json, (#connector: PaymentsDistributionTypes.categories :> string))
  let data = getBarGraphData(json, getPaymentQueryDataString(PaymentsSuccessRate))
  let title = {
    text: "",
  }
  {categories, data, title}
}

let visibleColumns = [PaymentsSuccessRate, Connector]

let colMapper = (col: queryData) => {
  switch col {
  | PaymentsSuccessRate => "payments_success_rate"
  | Connector => "connector"
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => paymentsDistributionObject = dict => {
  {
    payments_success_rate: dict->getInt(PaymentsSuccessRate->colMapper, 0),
    connector: dict->getString(Connector->colMapper, ""),
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
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | PaymentsSuccessRate => Text(obj.payments_success_rate->Int.toString)
  | Connector => Text(obj.connector)
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
