@react.component
let make = (
  ~currentStep,
  ~setConnectorId,
  ~setConnectorName,
  ~onNextClick,
  ~setNextStep,
  ~profileId,
  ~merchantId,
  ~connector,
) => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=None)
      let response = await updateDetails(connectorUrl, values, Post)
      let connectorId = response->getDictFromJsonObject->getString("merchant_connector_id", "")
      setConnectorId(_ => connectorId)
      onNextClick(currentStep, setNextStep)
    } catch {
    | _ => ()
    }
    Nullable.null
  }

  let updatedInitialVal = React.useMemo(() => {
    let initialValuesToDict = initialValues->getDictFromJsonObject
    // TODO: Refactor for generic case
    initialValuesToDict->Dict.set("connector_name", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set("connector_label", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set("connector_type", "payment_processor"->JSON.Encode.string)
    initialValuesToDict->Dict.set("profile_id", profileId->JSON.Encode.string)
    initialValuesToDict->JSON.Encode.object
  }, [connector, profileId])

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

  <div>
    <Form onSubmit initialValues>
      {switch currentStep->RevenueRecoveryOnboardingUtils.getSectionVariant {
      | (#addAPlatform, #selectAPlatform) =>
        <>
          <BillingConnectorAuthKeys
            initialValues={updatedInitialVal}
            setInitialValues
            connectorDetails
            connector
            setConnectorName
          />
          <Button
            text="Next"
            buttonType=Primary
            onClick={_ => onNextClick(currentStep, setNextStep)->ignore}
            customButtonStyle="w-full"
          />
        </>
      | (#addAPlatform, #configureRetries) =>
        <>
          <BillingProcessorsConfigureRetry />
          <Button
            text="Next"
            buttonType=Primary
            onClick={_ => onNextClick(currentStep, setNextStep)->ignore}
            customButtonStyle="w-full"
          />
        </>
      | (#addAPlatform, #connectProcessor) =>
        <>
          <BillingProcessorsConnectProcessor connector />
          <Button
            text="Next"
            buttonType=Primary
            onClick={_ => onNextClick(currentStep, setNextStep)->ignore}
            customButtonStyle="w-full"
          />
        </>
      | (#addAPlatform, #setupWebhookPlatform) =>
        <>
          <BillingProcessorsWebhooks initialValues={updatedInitialVal} merchantId />
          <Button
            text="Next"
            buttonType=Primary
            onClick={_ => onNextClick(currentStep, setNextStep)->ignore}
            customButtonStyle="w-full"
          />
        </>
      | (#reviewDetails, _) =>
        <>
          <BillingProcessorsReviewDetails initialValues connectorDetails merchantId />
          <Button text="Done" buttonType=Primary onClick={_ => ()} customButtonStyle="w-full" />
        </>
      | _ => React.null
      }}
      //<FormValuesSpy />
    </Form>
  </div>
}
