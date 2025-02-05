@react.component
let make = () => {
  open APIUtils
  open PageLoaderWrapper

  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let profileIdFromUrl =
    UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getOptionString("profile_id")
  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)

  let getConnectorDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Get, ~id=Some(connectorID))
      let json = await fetchDetails(connectorUrl)
      Js.log(json)
      setInitialValues(_ => json)
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to update!")
        Exn.raiseError(err)
      }
    | _ => Exn.raiseError("Something went wrong")
    }
  }

  React.useEffect(() => {
    getConnectorDetails()->ignore
    None
  }, [])

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
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
