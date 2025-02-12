@react.component
let make = (~initialValues, ~setInitialValues, ~showVertically=true) => {
  open LogicUtils
  open ConnectorAuthKeyUtils
  open ConnectorAuthKeysHelper

  let (connector, setConnector) = React.useState(() => "")
  let connectorTypeFromName = connector->ConnectorUtils.getConnectorNameTypeFromString

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->ConnectorUtils.getConnectorInfo
  }, [connector])

  let connectorDetails = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = BillingProcessorsUtils.getConnectorConfig(connector)
        dict
      } else {
        Dict.make()->JSON.Encode.object
      }
    } catch {
    | Exn.Error(_e) => Dict.make()->JSON.Encode.object
    }
  }, [connector])

  let (
    bodyType,
    connectorAccountFields,
    connectorMetaDataFields,
    _isVerifyConnector,
    connectorWebHookDetails,
    connectorLabelDetailField,
    connectorAdditionalMerchantData,
  ) = getConnectorFields(connectorDetails)

  React.useEffect(() => {
    let updatedValues = initialValues->JSON.stringify->safeParse->getDictFromJsonObject
    let acc =
      [("auth_type", bodyType->JSON.Encode.string)]
      ->Dict.fromArray
      ->JSON.Encode.object

    let _ = updatedValues->Dict.set("connector_account_details", acc)
    setInitialValues(_ => updatedValues->Identity.genericTypeToJson)
    None
  }, [connector])

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: ev => {
      let value = ev->Identity.formReactEventToString
      setConnector(_ => value)
    },
    onFocus: _ => (),
    value: connector->JSON.Encode.string,
    checked: true,
  }

  let getOptions: array<string> => array<SelectBox.dropdownOption> = dropdownList => {
    let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
      item
    ): SelectBox.dropdownOption => {
      {
        label: item,
        value: item,
      }
    })
    options
  }

  open RevenueRecoveryOnboardingUtils
  <PageWrapper
    title="Choose your Billing Platform"
    subTitle="Choose one processor for now. You can connect more processors later">
    <div className="-m-1 mt-5 mb-10">
      <SelectBox.BaseDropdown
        allowMultiSelect=false
        buttonText="Select Platform"
        input
        deselectDisable=true
        customButtonStyle="!rounded-lg h-[40px] pr-2"
        options={["Charbee"]->getOptions}
        hideMultiSelectButtons=true
        addButton=false
        searchable=true
        customStyle="!w-full"
        customDropdownOuterClass="!border-none w-full"
        fullLength=true
        shouldDisplaySelectedOnTop=true
      />
      <RenderIf condition={connector->LogicUtils.isNonEmptyString}>
        <ConnectorConfigurationFields
          connector={connectorTypeFromName}
          connectorAccountFields
          selectedConnector
          connectorMetaDataFields
          connectorWebHookDetails
          connectorLabelDetailField
          connectorAdditionalMerchantData
          showVertically
        />
      </RenderIf>
    </div>
  </PageWrapper>
}
