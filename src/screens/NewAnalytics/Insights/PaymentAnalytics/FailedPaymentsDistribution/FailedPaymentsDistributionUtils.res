open FailedPaymentsDistributionTypes
open LogicUtils
open CurrencyFormatUtils

let getStringFromVariant = value => {
  switch value {
  | Payments_Failure_Rate_Distribution => "payments_failure_rate_distribution"
  | Payments_Failure_Rate_Distribution_Without_Smart_Retries => "payments_failure_rate_distribution_without_smart_retries"
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

let failedPaymentsDistributionMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): BarGraphTypes.barGraphPayload => {
  open BarGraphTypes
  open InsightsUtils
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
      ~title="Failed Payments Distribution",
      ~metricType=Rate,
    ),
  }
}

open InsightsTypes
open NewAnalyticsTypes

let tableItemToObjMapper: Dict.t<JSON.t> => failedPaymentsDistributionObject = dict => {
  {
    payments_failure_rate_distribution: dict->getFloat(
      Payments_Failure_Rate_Distribution->getStringFromVariant,
      0.0,
    ),
    payments_failure_rate_distribution_without_smart_retries: dict->getFloat(
      Payments_Failure_Rate_Distribution_Without_Smart_Retries->getStringFromVariant,
      0.0,
    ),
    connector: dict->getString(Connector->getStringFromVariant, ""),
    payment_method: dict->getString(Payment_Method->getStringFromVariant, ""),
    payment_method_type: dict->getString(Payment_Method_Type->getStringFromVariant, ""),
    authentication_type: dict->getString(Authentication_Type->getStringFromVariant, ""),
  }
}

let getObjects: JSON.t => array<failedPaymentsDistributionObject> = json => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  switch colType {
  | Payments_Failure_Rate_Distribution =>
    Table.makeHeaderInfo(
      ~key=Payments_Failure_Rate_Distribution->getStringFromVariant,
      ~title="Payments Failure Rate Distribution",
      ~dataType=TextType,
    )
  | Payments_Failure_Rate_Distribution_Without_Smart_Retries =>
    Table.makeHeaderInfo(
      ~key=Payments_Failure_Rate_Distribution_Without_Smart_Retries->getStringFromVariant,
      ~title="Payments Failure Rate Distribution",
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
  | Payments_Failure_Rate_Distribution =>
    Text(obj.payments_failure_rate_distribution->valueFormatter(Rate))
  | Payments_Failure_Rate_Distribution_Without_Smart_Retries =>
    Text(obj.payments_failure_rate_distribution_without_smart_retries->valueFormatter(Rate))
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

let defaulGroupBy = {
  label: "Connector",
  value: Connector->getStringFromVariant,
}

let getKeyForModule = (field, ~isSmartRetryEnabled) => {
  switch (field, isSmartRetryEnabled) {
  | (Payments_Failure_Rate_Distribution, Smart_Retry) => Payments_Failure_Rate_Distribution
  | (Payments_Failure_Rate_Distribution, Default) | _ =>
    Payments_Failure_Rate_Distribution_Without_Smart_Retries
  }->getStringFromVariant
}

let isSmartRetryEnbldForFailedPmtDist = isEnabled => {
  switch isEnabled {
  | Smart_Retry => Payments_Failure_Rate_Distribution
  | Default => Payments_Failure_Rate_Distribution_Without_Smart_Retries
  }
}
