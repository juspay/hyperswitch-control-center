@react.component
let make = () => {
  open APIUtils
  open PageLoaderWrapper
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)

  let getConnectorDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Get, ~id=Some(connectorID))
      let json = await fetchDetails(connectorUrl)
      setInitialValues(_ => json)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch details"))
    }
  }

  React.useEffect(() => {
    getConnectorDetails()->ignore
    None
  }, [])

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=None)
    let _response = await updateAPIHook(connectorUrl, values, Post)

    // let connectorId = response->getDictFromJsonObject->getString("merchant_connector_id", "")
    Nullable.null
  }
  <>
    <PageLoaderWrapper screenState>
      <Form onSubmit initialValues>
        <PaymentProcessorSummary initialValues setInitialValues />
        <FormValuesSpy />
      </Form>
    </PageLoaderWrapper>
  </>
}
