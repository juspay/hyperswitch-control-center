open LogicUtils
open InsightsUtils
open SuccessfulSmartRetryDistributionTypes
open CurrencyFormatUtils
let getStringFromVariant = value => {
  switch value {
  | Payments_Success_Rate_Distribution_With_Only_Retries => "payments_success_rate_distribution_with_only_retries"
  | Connector => "connector"
  | Payment_Method => "payment_method"
  | Payment_Method_Type => "payment_method_type"
  | Authentication_Type => "authentication_type"
  }
}

let getColumn = string => {
  switch string {
  | "connector" => Connector
  | "payment_method" => Payment_Method
  | "payment_method_type" => Payment_Method_Type
  | "authentication_type" => Authentication_Type
  | _ => Connector
  }
}

let successfulSmartRetryDistributionMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): BarGraphTypes.barGraphPayload => {
  open BarGraphTypes
  let {data, xKey, yKey} = params
  let categories = [data]->JSON.Encode.array->getCategories(0, yKey)

  let barGraphData = getBarGraphObj(
    ~array=data->getArrayFromJson([]),
    ~key=xKey,
    ~name=xKey->snakeToTitle,
    ~color="#7CC88F",
  )
  let title = {
    text: "",
  }

  {
    categories,
    data: [barGraphData],
    title,
    tooltipFormatter: bargraphTooltipFormatter(
      ~title="Successful Smart Retry Distribution",
      ~metricType=Rate,
    ),
  }
}

open NewAnalyticsTypes

let tableItemToObjMapper: Dict.t<JSON.t> => successfulSmartRetryDistributionObject = dict => {
  {
    payments_success_rate_distribution_with_only_retries: dict->getFloat(
      Payments_Success_Rate_Distribution_With_Only_Retries->getStringFromVariant,
      0.0,
    ),
    connector: dict->getString(Connector->getStringFromVariant, ""),
    payment_method: dict->getString(Payment_Method->getStringFromVariant, ""),
    payment_method_type: dict->getString(Payment_Method_Type->getStringFromVariant, ""),
    authentication_type: dict->getString(Authentication_Type->getStringFromVariant, ""),
  }
}

let getObjects: JSON.t => array<successfulSmartRetryDistributionObject> = json => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  switch colType {
  | Payments_Success_Rate_Distribution_With_Only_Retries =>
    Table.makeHeaderInfo(
      ~key=Payments_Success_Rate_Distribution_With_Only_Retries->getStringFromVariant,
      ~title="Smart Retry Payments Success Rate",
      ~dataType=TextType,
    )
  | Connector =>
    Table.makeHeaderInfo(
      ~key=Connector->getStringFromVariant,
      ~title="Connector",
      ~dataType=TextType,
    )
  | Payment_Method =>
    Table.makeHeaderInfo(
      ~key=Payment_Method->getStringFromVariant,
      ~title="Payment Method",
      ~dataType=TextType,
    )
  | Payment_Method_Type =>
    Table.makeHeaderInfo(
      ~key=Payment_Method_Type->getStringFromVariant,
      ~title="Payment Method Type",
      ~dataType=TextType,
    )
  | Authentication_Type =>
    Table.makeHeaderInfo(
      ~key=Authentication_Type->getStringFromVariant,
      ~title="Authentication Type",
      ~dataType=TextType,
    )
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | Payments_Success_Rate_Distribution_With_Only_Retries =>
    Text(obj.payments_success_rate_distribution_with_only_retries->valueFormatter(Rate))
  | Connector => Text(obj.connector)
  | Payment_Method => Text(obj.payment_method)
  | Payment_Method_Type => Text(obj.payment_method_type)
  | Authentication_Type => Text(obj.authentication_type)
  }
}

let getTableData = json => {
  json->getArrayDataFromJson(tableItemToObjMapper)->Array.map(Nullable.make)
}

let tabs = [
  {
    label: "Connector",
    value: Connector->getStringFromVariant,
  },
  {
    label: "Payment Method",
    value: Payment_Method->getStringFromVariant,
  },
  {
    label: "Payment Method Type",
    value: Payment_Method_Type->getStringFromVariant,
  },
  {
    label: "Authentication Type",
    value: Authentication_Type->getStringFromVariant,
  },
]

let defaultGroupBy = {
  label: "Connector",
  value: Connector->getStringFromVariant,
}
