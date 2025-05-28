open FormRenderer
open AcquirerConfigTypes

let makeTextInputField = (~label, ~name, ~placeholder, ~isRequired=true, ~isDisabled) =>
  FormRenderer.makeFieldInfo(
    ~label,
    ~name,
    ~placeholder,
    ~customInput=InputFields.textInput(~autoComplete="off", ~isDisabled),
    ~isRequired,
  )

let makeSelectInputField = (~label, ~name, ~placeholder, ~options, ~isDisabled) =>
  FormRenderer.makeFieldInfo(
    ~label,
    ~name,
    ~placeholder,
    ~isRequired=true,
    ~customInput=InputFields.selectInput(
      ~options,
      ~buttonText=placeholder,
      ~deselectDisable=true,
      ~disableSelect=isDisabled,
    ),
  )

let makeNumericInputField = (~label, ~name, ~placeholder, ~maxLength=6, ~isDisabled) =>
  FormRenderer.makeFieldInfo(
    ~label,
    ~name,
    ~placeholder,
    ~customInput=InputFields.numericTextInput(~removeLeadingZeroes=true, ~maxLength, ~isDisabled),
    ~isRequired=true,
  )

let merchantAcquirerId = (~isDisabled) =>
  makeTextInputField(
    ~label="Merchant Acquirer ID",
    ~name="merchant_acquirer_id",
    ~placeholder="Enter merchant acquirer ID",
    ~isDisabled,
  )

let acquirerAssignedMerchantId = (~isDisabled) =>
  makeTextInputField(
    ~label="Acquirer assigned merchant id",
    ~name="acquirer_assigned_merchant_id",
    ~placeholder="Enter acquirer assigned merchant id",
    ~isDisabled,
  )

let merchantName = (~isDisabled) =>
  makeTextInputField(
    ~label="Merchant name",
    ~name="merchant_name",
    ~placeholder="Enter merchant name",
    ~isDisabled,
  )

let mcc = (~isDisabled) =>
  makeTextInputField(
    ~label="Merchant category code",
    ~name="mcc",
    ~placeholder="Enter merchant category code",
    ~isDisabled,
  )

let merchantCountryCode = (~isDisabled) =>
  makeSelectInputField(
    ~label="Merchant country code",
    ~name="merchant_country_code",
    ~placeholder="Select merchant country code",
    ~options=AcquirerConfigHelpers.countryDropDownOptions,
    ~isDisabled,
  )

let acquirerBin = (~isDisabled) =>
  makeTextInputField(
    ~label="Acquirer BIN",
    ~name="acquirer_bin",
    ~placeholder="Enter acquirer BIN",
    ~isDisabled,
  )

let acquirerFraudRate = (~isDisabled) =>
  makeNumericInputField(
    ~label="Acquirer fraud rate",
    ~name="acquirer_fraud_rate",
    ~placeholder="Enter acquirer fraud rate",
    ~isDisabled,
  )

let network = (~isDisabled) =>
  makeSelectInputField(
    ~label="Network",
    ~name="network",
    ~placeholder="Select network",
    ~options=AcquirerConfigHelpers.networkDropDownOptions,
    ~isDisabled,
  )

module FieldRendererWithStyles = {
  @react.component
  let make = (~field, ~containerClass=?) => {
    let styles = AcquirerConfigHelpers.fieldStyles
    let errorClass = styles["errorClass"]
    let labelClass = styles["labelClass"]
    let fieldWrapperClass = styles["fieldWrapperClass"]
    let defaultContainerClass = styles["containerClass"]

    let finalContainerClass = containerClass->Option.getOr(defaultContainerClass)

    <div className=finalContainerClass>
      <FieldRenderer field errorClass labelClass fieldWrapperClass />
    </div>
  }
}

module AcquirerConfigInputs = {
  @react.component
  let make = (~isDisabled) => {
    <div>
      <DesktopRow wrapperClass="flex-1">
        <FieldRendererWithStyles field={merchantAcquirerId(~isDisabled)} />
        <FieldRendererWithStyles field={merchantName(~isDisabled)} />
      </DesktopRow>
      <DesktopRow wrapperClass="flex-1">
        <FieldRendererWithStyles field={mcc(~isDisabled)} />
        <FieldRendererWithStyles field={merchantCountryCode(~isDisabled)} />
      </DesktopRow>
      <DesktopRow wrapperClass="flex-1">
        <FieldRendererWithStyles field={acquirerAssignedMerchantId(~isDisabled)} />
        <FieldRendererWithStyles field={acquirerBin(~isDisabled)} />
      </DesktopRow>
      <DesktopRow wrapperClass="flex-1">
        <FieldRendererWithStyles field={acquirerFraudRate(~isDisabled)} />
        <FieldRendererWithStyles field={network(~isDisabled)} />
      </DesktopRow>
    </div>
  }
}

module AcquirerConfigTable = {
  open Table

  let getHeading = (colType: colType): header => {
    switch colType {
    | MerchantAcquirerId =>
      makeHeaderInfo(~key="merchant_acquirer_id", ~title="Merchant Acquirer ID", ~dataType=TextType)
    | AcquirerAssignedMerchantId =>
      makeHeaderInfo(
        ~key="acquirer_assigned_merchant_id",
        ~title="Acquirer Assigned Merchant ID",
        ~dataType=TextType,
      )
    | MerchantName =>
      makeHeaderInfo(~key="merchant_name", ~title="Merchant Name", ~dataType=TextType)
    | MCC => makeHeaderInfo(~key="mcc", ~title="Merchant Category Code", ~dataType=TextType)
    | MerchantCountryCode =>
      makeHeaderInfo(
        ~key="merchant_country_code",
        ~title="Merchant Country Code",
        ~dataType=TextType,
      )
    | Network => makeHeaderInfo(~key="network", ~title="Network", ~dataType=TextType)
    | AcquirerBin => makeHeaderInfo(~key="acquirer_bin", ~title="Acquirer BIN", ~dataType=TextType)
    | AcquirerFraudRate =>
      makeHeaderInfo(
        ~key="acquirer_fraud_rate",
        ~title="Acquirer Fraud Rate",
        ~dataType=NumericType,
      )
    }
  }

  let getCell = (data: acquirerConfig, colType: colType): cell => {
    switch colType {
    | MerchantAcquirerId => Text(data.merchant_acquirer_id)
    | AcquirerAssignedMerchantId => Text(data.acquirer_assigned_merchant_id)
    | MerchantName => Text(data.merchant_name)
    | MCC => Text(data.mcc)
    | MerchantCountryCode => Text(data.merchant_country_code)
    | Network => Text(data.network)
    | AcquirerBin => Text(data.acquirer_bin)
    | AcquirerFraudRate => Numeric(data.acquirer_fraud_rate, num => num->Float.toString ++ "%")
    }
  }

  let defaultColumns = [
    MerchantAcquirerId,
    AcquirerAssignedMerchantId,
    MerchantName,
    MCC,
    MerchantCountryCode,
    Network,
    AcquirerBin,
    AcquirerFraudRate,
  ]

  @react.component
  let make = (~acquirerConfigData: array<acquirerConfig>) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let resultsPerPage = 10

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

    let actualData = acquirerConfigData->Array.map(Nullable.make)
    let totalResults = acquirerConfigData->Array.length

    <LoadedTable
      title="Acquirer Configurations"
      hideTitle=true
      actualData
      totalResults
      resultsPerPage
      offset
      setOffset
      entity
      currrentFetchCount=totalResults
      showPagination={totalResults > resultsPerPage}
      tableLocalFilter=false
      showSerialNumber=false
    />
  }
}
