@react.component
let make = (
  ~initialValues,
  ~setInitialValues,
  ~connectorDetails,
  ~setConnectorName,
  ~connector,
) => {
  // open LogicUtils
  // open ConnectorAuthKeysHelper
  // open BillingProcessorsUtils

  let connectorTypeFromName = connector->ConnectorUtils.getConnectorNameTypeFromString

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->ConnectorUtils.getConnectorInfo
  }, [connector])

  //   let (bodyType, connectorAccountFields, _, _, _, _, _) = ConnectorFragmentUtils.getConnectorFields(
  //     connectorDetails,
  //   )

  //   React.useEffect(() => {
  //     let updatedValues = initialValues->JSON.stringify->safeParse->getDictFromJsonObject
  //     let acc =
  //       [("auth_type", bodyType->JSON.Encode.string)]
  //       ->Dict.fromArray
  //       ->JSON.Encode.object

  //     let _ = updatedValues->Dict.set("connector_account_details", acc)
  //     setInitialValues(_ => updatedValues->Identity.genericTypeToJson)
  //     None
  //   }, [connector])

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: ev => {
      let value = ev->Identity.formReactEventToString
      setConnectorName(_ => value)
    },
    onFocus: _ => (),
    value: connector->JSON.Encode.string,
    checked: true,
  }

  let options =
    RevenueRecoveryOnboardingUtils.billingConnectorList->RevenueRecoveryOnboardingUtils.getOptions

  open RevenueRecoveryOnboardingUtils
  <PageWrapper
    title="Choose your Billing Platform"
    subTitle="Choose one processor for now. You can connect more processors later">
    <div className="-m-1 mb-10 flex flex-col gap-7">
      <SelectBox.BaseDropdown
        allowMultiSelect=false
        buttonText="Select Platform"
        input
        deselectDisable=true
        customButtonStyle="!rounded-xl h-[45px] pr-2"
        options
        hideMultiSelectButtons=true
        addButton=false
        searchable=true
        customStyle="!w-full"
        customDropdownOuterClass="!border-none"
        fullLength=true
        shouldDisplaySelectedOnTop=true
      />
      //   <RenderIf condition={connector->LogicUtils.isNonEmptyString}>
      //     <ConnectorConfigurationFields
      //       connector={connectorTypeFromName} connectorAccountFields selectedConnector
      //     />
      //   </RenderIf>
    </div>
  </PageWrapper>
}
