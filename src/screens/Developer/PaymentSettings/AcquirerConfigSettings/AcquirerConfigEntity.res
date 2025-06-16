open FormRenderer
open AcquirerConfigTypes

let makeTextInputField = (~label, ~name, ~placeholder, ~isRequired=true) =>
  makeFieldInfo(
    ~label,
    ~name,
    ~placeholder,
    ~customInput=InputFields.textInput(~autoComplete="off"),
    ~isRequired,
  )

let makeSelectInputField = (~label, ~name, ~placeholder, ~options) =>
  makeFieldInfo(
    ~label,
    ~name,
    ~placeholder,
    ~isRequired=true,
    ~customInput=InputFields.selectInput(~options, ~buttonText=placeholder, ~deselectDisable=true),
  )

let makeNumericInputField = (~label, ~name, ~placeholder, ~maxLength=6) =>
  makeFieldInfo(
    ~label,
    ~name,
    ~placeholder,
    ~customInput=InputFields.numericTextInput(~removeLeadingZeroes=true, ~maxLength),
    ~isRequired=true,
  )

let acquirerAssignedMerchantId = makeTextInputField(
  ~label="Acquirer Assigned Merchant Id",
  ~name="acquirer_assigned_merchant_id",
  ~placeholder="Enter Acquirer Assigned Merchant Id",
)

let merchantName = makeTextInputField(
  ~label="Merchant Name",
  ~name="merchant_name",
  ~placeholder="Enter Merchant Name",
)

let merchantCountryCode = makeSelectInputField(
  ~label="Merchant Country",
  ~name="merchant_country_code",
  ~placeholder="Select Merchant Country",
  ~options=AcquirerConfigUtils.countryDropDownOptions,
)

let acquirerBin = makeTextInputField(
  ~label="Acquirer Bin",
  ~name="acquirer_bin",
  ~placeholder="Enter Acquirer Bin",
)

let acquirerFraudRate = makeNumericInputField(
  ~label="Acquirer Fraud Rate",
  ~name="acquirer_fraud_rate",
  ~placeholder="Enter Acquirer Fraud Rate",
)

let network = makeSelectInputField(
  ~label="Network",
  ~name="network",
  ~placeholder="Select Network",
  ~options=AcquirerConfigUtils.networkDropDownOptions,
)

open Table
let getHeading = (colType: colType): header => {
  switch colType {
  | AcquirerAssignedMerchantId =>
    makeHeaderInfo(
      ~key="acquirer_assigned_merchant_id",
      ~title="Acquirer Assigned Merchant ID",
      ~dataType=TextType,
    )
  | MerchantName => makeHeaderInfo(~key="merchant_name", ~title="Merchant Name", ~dataType=TextType)
  | MerchantCountryCode =>
    makeHeaderInfo(~key="merchant_country_code", ~title="Merchant Country Code", ~dataType=TextType)
  | Network => makeHeaderInfo(~key="network", ~title="Network", ~dataType=TextType)
  | AcquirerBin => makeHeaderInfo(~key="acquirer_bin", ~title="Acquirer BIN", ~dataType=TextType)
  | AcquirerFraudRate =>
    makeHeaderInfo(~key="acquirer_fraud_rate", ~title="Acquirer Fraud Rate", ~dataType=NumericType)
  }
}

let getCell = (data: acquirerConfig, colType: colType): cell => {
  switch colType {
  | AcquirerAssignedMerchantId => Text(data.acquirer_assigned_merchant_id)
  | MerchantName => Text(data.merchant_name)
  | MerchantCountryCode => Text(data.merchant_country_code)
  | Network => Text(data.network)
  | AcquirerBin => Text(data.acquirer_bin)
  | AcquirerFraudRate => Numeric(data.acquirer_fraud_rate, num => num->Float.toString ++ "%")
  }
}

let defaultColumns = [
  AcquirerAssignedMerchantId,
  MerchantName,
  MerchantCountryCode,
  Network,
  AcquirerBin,
  AcquirerFraudRate,
]

let entity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=_ => [],
  ~defaultColumns,
  ~getHeading,
  ~getCell,
  ~dataKey="",
  ~searchFields=[],
  ~searchUrl="",
)
