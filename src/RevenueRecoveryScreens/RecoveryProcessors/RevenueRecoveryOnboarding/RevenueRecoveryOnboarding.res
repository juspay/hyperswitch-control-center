@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open RevenueRecoveryOnboardingUtils
  open VerticalStepIndicatorTypes

  let getURL = useGetURL()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let {profileId} = getUserInfoData()
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let (connectorId, setConnectorId) = React.useState(() => "")

  let (currentStep, setNextStep) = React.useState(() => defaultStep)

  let updatedInitialVal = React.useMemo(() => {
    let initialValuesToDict = initialValues->getDictFromJsonObject
    // TODO: Refactor for generic case
    initialValuesToDict->Dict.set("connector_name", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set("connector_label", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set("connector_type", "payment_processor"->JSON.Encode.string)
    initialValuesToDict->Dict.set("profile_id", profileId->JSON.Encode.string)
    initialValuesToDict->JSON.Encode.object
  }, [connector, profileId])

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=None)
      let response = await updateAPIHook(connectorUrl, values, Post)
      let connectorId = response->getDictFromJsonObject->getString("merchant_connector_id", "")
      setConnectorId(_ => connectorId)
      onNextClick(currentStep, setNextStep)
    } catch {
    | _ => ()
    }
    Nullable.null
  }

  let onSucessClick = () => {
    setShowSideBar(_ => true)
    RescriptReactRouter.replace(
      GlobalVars.appendDashboardPath(
        ~url=`/v2/recovery/onboarding/${connectorId}?name=${connector}`,
      ),
    )
  }

  <div className="flex flex-row">
    <VerticalStepIndicator
      title="Setup Recovery"
      sections
      currentStep
      backClick={() => {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recovery/home"))
      }}
    />
    <div className="flex flex-row gap-x-4">
      <Form onSubmit initialValues>
        {switch currentStep {
        | {sectionId: "connectProcessor", subSectionId: Some("selectProcessor")} =>
          <div>
            <ConnectorAuthKeys
              initialValues={updatedInitialVal} setInitialValues showVertically=true
            />
            <FormValuesSpy />
            <FormRenderer.SubmitButton text="Submit" buttonSize={Small} />
          </div>
        | {sectionId: "connectProcessor", subSectionId: Some("activePaymentMethods")}
        | {sectionId: "connectProcessor", subSectionId: Some("setupWebhookProcessor")} =>
          <div>
            <Button
              text="Previous" onClick={_ => onPreviousClick(currentStep, setNextStep)->ignore}
            />
            <Button
              text="Next"
              buttonType=Primary
              onClick={_ => onNextClick(currentStep, setNextStep)->ignore}
            />
            {"payment"->React.string}
          </div>
        | {sectionId: "addAPlatform", subSectionId: Some("selectAPlatform")}
        | {sectionId: "addAPlatform", subSectionId: Some("configureRetries")}
        | {sectionId: "addAPlatform", subSectionId: Some("connectProcessor")}
        | {sectionId: "addAPlatform", subSectionId: Some("setupWebhookPlatform")} =>
          <div>
            <Button
              text="Previous" onClick={_ => onPreviousClick(currentStep, setNextStep)->ignore}
            />
            <Button
              text="Next"
              buttonType=Primary
              onClick={_ => onNextClick(currentStep, setNextStep)->ignore}
            />
            {"billing"->React.string}
          </div>
        | {sectionId: "reviewDetails"} => "Review"->React.string
        | _ => React.null
        }}
      </Form>
    </div>
  </div>
}
