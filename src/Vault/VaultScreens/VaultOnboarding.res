@react.component
let make = () => {
  open APIUtils
  open PageLoaderWrapper
  open LogicUtils

  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  Js.log2("connectorconnectorconnectorconnector", connector)
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)
  let {profileId} = getUserInfoData()

  let updatedInitialVal = React.useMemo(() => {
    let initialValuesToDict = initialValues->getDictFromJsonObject
    // TODO: Refactor for generic case
    initialValuesToDict->Dict.set("connector_name", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set("connector_label", `${connector}_hj`->JSON.Encode.string)
    initialValuesToDict->Dict.set("connector_type", "payment_processor"->JSON.Encode.string)
    initialValuesToDict->Dict.set("profile_id", profileId->JSON.Encode.string)
    initialValuesToDict->JSON.Encode.object
  }, [connector, profileId])

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=None)
      let response = await updateAPIHook(connectorUrl, values, Post)
      let connectorId = response->getDictFromJsonObject->getString("merchant_connector_id", "")
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(
          ~url=`/v2/vault/onboarding/${connectorId}?name=${connector}`,
        ),
      )
    } catch {
    | _ => ()
    }
    Nullable.null
  }

  <div>
    <p> {"Authenticate your processor"->React.string} </p>
    <p>
      {"Configure your credentials from your processor dashboard. Hyperswitch encrypts and stores these credentials securely."->React.string}
    </p>
    <Form onSubmit initialValues>
      <ConnectorAuthKeys initialValues={updatedInitialVal} setInitialValues showVertically=true />
      <FormValuesSpy />
      <FormRenderer.SubmitButton text="Submit" buttonSize={Small} />
    </Form>
  </div>
}
