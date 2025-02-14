@react.component
let make = (~initialValues, ~setInitialValues, ~profileId, ~connector, ~setConnectorName) => {
  open LogicUtils
  open ConnectorUtils
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let connectorDetails = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = Window.getConnectorConfig(connector)
        dict
      } else {
        Dict.make()->JSON.Encode.object
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        Dict.make()->JSON.Encode.object
      }
    }
  }, [connector])

  let (bodyType, _, _, _, _, _, _) = ConnectorFragmentUtils.getConnectorFields(connectorDetails)

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
      setConnectorName(_ => value)
    },
    onFocus: _ => (),
    value: connector->JSON.Encode.string,
    checked: true,
  }

  let connectorList = featureFlagDetails.isLiveMode ? connectorListForLive : connectorList

  let options = connectorList->PaymentProcessorsUtils.getOptions

  let updatedInitialVal = React.useMemo(() => {
    let initialValuesToDict = initialValues->getDictFromJsonObject
    // TODO: Refactor for generic case
    initialValuesToDict->Dict.set("connector_name", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set("connector_label", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set("connector_type", "payment_processor"->JSON.Encode.string)
    initialValuesToDict->Dict.set("profile_id", profileId->JSON.Encode.string)
    initialValuesToDict->JSON.Encode.object
  }, [connector, profileId])

  open RevenueRecoveryOnboardingUtils
  <PageWrapper
    title="Where do you process your payments?"
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
      <RenderIf condition={connector->LogicUtils.isNonEmptyString}>
        <ConnectorAuthKeys initialValues={updatedInitialVal} setInitialValues showVertically=true />
      </RenderIf>
    </div>
  </PageWrapper>
}
