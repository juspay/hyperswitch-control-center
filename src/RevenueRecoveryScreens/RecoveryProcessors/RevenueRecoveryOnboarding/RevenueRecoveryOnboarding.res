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
      {switch currentStep {
      | {sectionId: "payment-processor"} =>
        <Form onSubmit initialValues>
          <ConnectorAuthKeys
            initialValues={updatedInitialVal} setInitialValues showVertically=true
          />
          <FormValuesSpy />
          <FormRenderer.SubmitButton text="Submit" buttonSize={Small} />
        </Form>
      | {sectionId: "success"} =>
        <div>
          <p> {"Success"->React.string} </p>
          <p> {"Your processor has been successfully authenticated."->React.string} </p>
          <Button text="Next" buttonType=Primary onClick={_ => onSucessClick()->ignore} />
        </div>
      | _ => React.null
      }}
    </div>
  </div>
}

/*
<Button text="Previous" onClick={_ => onPreviousClick()->ignore} />
<Button text="Next" buttonType=Primary onClick={_ => onNextClick()->ignore} />
 */
