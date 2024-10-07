open NewPaymentAnalyticsUtils
open FailedPaymentsDistributionTypes
open LogicUtils

let getDimentionType = string => {
  switch string {
  | "connector" => #connector
  | "payment_method" => #payment_method
  | "payment_method_type" => #payment_method_type
  | "card_network" => #card_network
  | "authentication_type" | _ => #authentication_type
  }
}

let getXKey = (~isSmartRetry) => {
  switch isSmartRetry {
  | true => "payments_failure_rate_distribution"
  | false => "payments_failure_rate_distribution_without_smart_retries"
  }
}

let failedPaymentsDistributionMapper = (
  ~data: JSON.t,
  ~xKey: string,
  ~yKey: string,
): BarGraphTypes.barGraphPayload => {
  open BarGraphTypes
  let categories =
    data
    ->getArrayFromJson([])
    ->getCategories(yKey)
  let barGraphData = getBarGraphObj(
    ~array=data->getArrayFromJson([]),
    ~key=xKey,
    ~name=xKey->snakeToTitle,
    ~color="#BA3535",
  )
  let title = {
    text: "",
  }
  {categories, data: [barGraphData], title}
}

open NewAnalyticsTypes
let visibleColumns: array<metrics> = [#payment_failed_rate]

let tableItemToObjMapper: Dict.t<JSON.t> => failedPaymentsDistributionObject = dict => {
  {
    payments_failure_rate_distribution: dict->getInt("payments_failure_rate_distribution", 0),
    connector: dict->getString((#connector: metrics :> string), ""),
    payment_method: dict->getString((#payment_method: metrics :> string), ""),
  }
}

let getObjects: JSON.t => array<failedPaymentsDistributionObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = (colType: metrics) => {
  switch colType {
  | #payment_failed_rate =>
    Table.makeHeaderInfo(
      ~key=(#payment_failed_rate: metrics :> string),
      ~title="Payments Failed Rate",
      ~dataType=TextType,
    )
  | #connector =>
    Table.makeHeaderInfo(
      ~key=(#connector: metrics :> string),
      ~title="Connector",
      ~dataType=TextType,
    )
  | #payment_method | _ =>
    Table.makeHeaderInfo(
      ~key=(#payment_method: metrics :> string),
      ~title="Payment Method",
      ~dataType=TextType,
    )
  }
}

let getCell = (obj, colType: metrics): Table.cell => {
  switch colType {
  | #payment_failed_rate => Text(obj.payments_failure_rate_distribution->Int.toString)
  | #connector => Text(obj.connector)
  | #payment_method | _ => Text(obj.payment_method)
  }
}

let getTableData = json => {
  json->getArrayDataFromJson(tableItemToObjMapper)->Array.map(Nullable.make)
}

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
    label: "Authentication Type",
    value: (#authentication_type: dimension :> string),
  },
]

let defaulGroupBy = {
  label: "Connector",
  value: (#connector: dimension :> string),
}
