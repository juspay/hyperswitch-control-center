@react.component
let make = () => {
  open APIUtils
  open PageLoaderWrapper
  open LogicUtils
  open VerticalStepIndicatorTypes
  open VerticalStepIndicatorUtils

  let sections = [
    {
      id: "payment-processor",
      name: "Payment Processor",
      icon: "nd-inbox",
      subSections: None,
    },
    {
      id: "success",
      name: "Success",
      icon: "nd-plugin",
      subSections: None,
    },
  ]

  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)
  let {profileId} = getUserInfoData()
  let (connectorId, setConnectorId) = React.useState(() => "")
  let (currentStep, setNextStep) = React.useState(() => {
    sectionId: "payment-processor",
    subSectionId: None,
  })

  let getNextStep = (currentStep: step): option<step> => {
    findNextStep(sections, currentStep)
  }

  let getPreviousStep = (currentStep: step): option<step> => {
    findPreviousStep(sections, currentStep)
  }

  let onPreviousClick = () => {
    switch getPreviousStep(currentStep) {
    | Some(previousStep) => setNextStep(_ => previousStep)
    | None => ()
    }
  }

  let updatedInitialVal = React.useMemo(() => {
    let initialValuesToDict = initialValues->getDictFromJsonObject
    // TODO: Refactor for generic case
    initialValuesToDict->Dict.set("connector_name", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set("connector_label", `${connector}_dakjfhsod`->JSON.Encode.string)
    initialValuesToDict->Dict.set("connector_type", "payment_processor"->JSON.Encode.string)
    initialValuesToDict->Dict.set("profile_id", profileId->JSON.Encode.string)
    initialValuesToDict->JSON.Encode.object
  }, [connector, profileId])

  let onNextClick = () => {
    switch getNextStep(currentStep) {
    | Some(nextStep) => setNextStep(_ => nextStep)
    | None => ()
    }
  }

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=None)
      let response = await updateAPIHook(connectorUrl, values, Post)
      let connectorId = response->getDictFromJsonObject->getString("merchant_connector_id", "")
      setConnectorId(_ => connectorId)
      onNextClick()
    } catch {
    | _ => ()
    }
    Nullable.null
  }

  let onSucessClick = () => {
    setShowSideBar(_ => true)
    RescriptReactRouter.replace(
      GlobalVars.appendDashboardPath(~url=`/v2/vault/onboarding/${connectorId}?name=${connector}`),
    )
  }

  let backClick = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recovery/home"))
  }

  <div className="flex flex-row gap-x-6">
    <VerticalStepIndicator title="Configure Vault" sections currentStep backClick />
    <div>
      <p>
        {"Configure your credentials from your processor dashboard. Hyperswitch encrypts and stores these credentials securely."->React.string}
      </p>
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
