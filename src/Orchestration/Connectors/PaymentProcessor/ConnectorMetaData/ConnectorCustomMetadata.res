@react.component
let make = (~setCurrentStep, ~connector, ~setInitialValues, ~initialValues, ~isUpdateFlow) => {
  open APIUtils
  open LogicUtils
  open ConnectorUtils
  let url = RescriptReactRouter.useUrl()
  // id required in case of update flow
  let connectorID = switch HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "") {
  | "new" => None
  | id => Some(id)
  }

  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let fetchConnectorList = ConnectorListHook.useFetchConnectorList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()

  let connectorDetails = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = Window.getConnectorConfig(connector)
        setScreenState(_ => Success)
        dict
      } else {
        Dict.make()->JSON.Encode.object
      }
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        setScreenState(_ => PageLoaderWrapper.Error(err))
        Dict.make()->JSON.Encode.object
      }
    }
  }, [connector])
  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => Loading)
      let connectorUrl = getURL(~entityName=V1(CONNECTOR), ~methodType=Post, ~id=connectorID)
      let response = await updateAPIHook(
        connectorUrl,
        values->ignoreFields(connectorID->Option.getOr(""), connectorIgnoredField),
        Post,
      )
      let _ = await fetchConnectorList()
      setInitialValues(_ => response)
      setScreenState(_ => Success)
      setCurrentStep(_ => ConnectorTypes.SummaryAndTest)
      showToast(
        ~message=!isUpdateFlow ? "Connector Created Successfully!" : "Details Updated!",
        ~toastType=ToastSuccess,
      )
      setInitialValues(_ => values)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        if errorCode === "HE_01" {
          showToast(~message="Connector label already exist!", ~toastType=ToastError)
          setCurrentStep(_ => ConnectorTypes.IntegFields)
        } else {
          showToast(~message=errorMessage, ~toastType=ToastError)
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }
    Nullable.null
  }
  let {connectorMetaDataFields} = getConnectorFields(connectorDetails)

  let validDateMetaDataMandatoryFields = values => {
    ConnectorMetaDataUtils.validateMetadataRequiredFields(
      ~connector=connector->getConnectorNameTypeFromString,
      ~values,
    )->JSON.Encode.object
  }
  <PageLoaderWrapper screenState>
    <div className="flex flex-col">
      <Form onSubmit initialValues={initialValues} validate={validDateMetaDataMandatoryFields}>
        <div className="flex justify-between border-b p-2 md:px-10 md:py-6">
          <div className="flex gap-2 items-center">
            <GatewayIcon gateway={connector->String.toUpperCase} />
            <h2 className="text-xl font-semibold">
              {connector->getDisplayNameForConnector->React.string}
            </h2>
          </div>
          <div className="self-center">
            <FormRenderer.SubmitButton text="Proceed" />
          </div>
        </div>
        {switch connector->getConnectorNameTypeFromString {
        | Processors(PAYSAFE) => <PaySafe connectorMetaDataFields />
        | _ => React.null
        }}
      </Form>
    </div>
  </PageLoaderWrapper>
}
