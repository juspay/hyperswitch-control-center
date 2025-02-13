@react.component
let make = (~initialValues, ~setInitialValues, ~showVertically=true) => {
  open LogicUtils
  open ConnectorAuthKeysHelper
  open BillingProcessorsUtils

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

  let (bodyType, connectorAccountFields, _, _, _, _, _) = ConnectorFragmentUtils.getConnectorFields(
    connectorDetails,
  )

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

  let options = RevenueRecoveryOnboardingUtils.billingConnectorList->getOptions

  open RevenueRecoveryOnboardingUtils
  <PageWrapper
    title="Choose your Billing Platform"
    subTitle="Choose one processor for now. You can connect more processors later">
    <div className="-m-1 mt-5 mb-10 flex flex-col gap-7">
      <SelectBox.BaseDropdown
        allowMultiSelect=false
        buttonText="Select Platform"
        input
        deselectDisable=true
        customButtonStyle="!rounded-xl h-[40px] pr-2"
        options
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
          connector={connectorTypeFromName} connectorAccountFields selectedConnector showVertically
        />
      </RenderIf>
    </div>
  </PageWrapper>
}
