open NewPaymentAnalyticsUtils
open SuccessfulPaymentsDistributionTypes
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | Payments_Success_Rate_Distribution => "payments_success_rate_distribution"
  | Payments_Success_Rate_Distribution_Without_Smart_Retries => "payments_success_rate_distribution_without_smart_retries"
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

let successfulPaymentsDistributionMapper = (
  ~data: JSON.t,
  ~xKey: string,
  ~yKey: string,
): BarGraphTypes.barGraphPayload => {
  open BarGraphTypes
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

  {categories, data: [barGraphData], title}
}

open NewAnalyticsTypes

let tableItemToObjMapper: Dict.t<JSON.t> => successfulPaymentsDistributionObject = dict => {
  {
    payments_success_rate_distribution: dict->getFloat(
      Payments_Success_Rate_Distribution->getStringFromVariant,
      0.0,
    ),
    payments_success_rate_distribution_without_smart_retries: dict->getFloat(
      Payments_Success_Rate_Distribution_Without_Smart_Retries->getStringFromVariant,
      0.0,
    ),
    connector: dict->getString(Connector->getStringFromVariant, ""),
    payment_method: dict->getString(Payment_Method->getStringFromVariant, ""),
    payment_method_type: dict->getString(Payment_Method_Type->getStringFromVariant, ""),
    authentication_type: dict->getString(Authentication_Type->getStringFromVariant, ""),
  }
}

let getObjects: JSON.t => array<successfulPaymentsDistributionObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  switch colType {
  | Payments_Success_Rate_Distribution =>
    Table.makeHeaderInfo(
      ~key=Payments_Success_Rate_Distribution->getStringFromVariant,
      ~title="Payments Success Rate",
      ~dataType=TextType,
    )
  | Payments_Success_Rate_Distribution_Without_Smart_Retries =>
    Table.makeHeaderInfo(
      ~key=Payments_Success_Rate_Distribution_Without_Smart_Retries->getStringFromVariant,
      ~title="Payments Success Rate",
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
  open NewAnalyticsUtils
  switch colType {
  | Payments_Success_Rate_Distribution =>
    Text(obj.payments_success_rate_distribution->valueFormatter(Amount))
  | Payments_Success_Rate_Distribution_Without_Smart_Retries =>
    Text(obj.payments_success_rate_distribution_without_smart_retries->valueFormatter(Amount))
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
  | (Payments_Success_Rate_Distribution, Smart_Retry) => Payments_Success_Rate_Distribution
  | (Payments_Success_Rate_Distribution, Default) | _ =>
    Payments_Success_Rate_Distribution_Without_Smart_Retries
  }->getStringFromVariant
}

let isSmartRetryEnbldForSuccessPmtDist = isEnabled => {
  switch isEnabled {
  | Smart_Retry => Payments_Success_Rate_Distribution
  | Default => Payments_Success_Rate_Distribution_Without_Smart_Retries
  }
}

let getMetricsForSmartRetry = isEnabled => {
  switch isEnabled {
  | Smart_Retry => [#payments_distribution]
  | Default => [#sessionized_payments_distribution]
  }
}
