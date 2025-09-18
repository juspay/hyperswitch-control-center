@react.component
let make = (~setCurrentStep, ~connector, ~setInitialValues, ~initialValues, ~isUpdateFlow) => {
  open ConnectorUtils
  open APIUtils
  open PageLoaderWrapper
  open LogicUtils
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let _showAdvancedConfiguration = false
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let fetchConnectorList = ConnectorListHook.useFetchConnectorList()
  let (paymentMethodsEnabled, setPaymentMethods) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->getPaymentMethodEnabled
  )
  let (_metaData, setMetaData) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let showToast = ToastState.useShowToast()
  // id required in case of update flow
  let connectorID = switch HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "") {
  | "new" => None
  | id => Some(id)
  }
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)

  let updateDetails = value => {
    setPaymentMethods(_ => value->Array.copy)
  }

  let setPaymentMethodDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let _ = getConnectorPaymentMethodDetails(
        ~initialValues,
        ~setPaymentMethods,
        ~setMetaData,
        ~isUpdateFlow,
        ~isPayoutFlow=false,
        ~connector,
        ~updateDetails,
      )
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }
  }

  React.useEffect(() => {
    setPaymentMethodDetails()->ignore
    None
  }, [connector])

  let mixpanelEventName = isUpdateFlow ? "processor_step2_onUpdate" : "processor_step2"

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    mixpanelEvent(~eventName=mixpanelEventName)
    try {
      setScreenState(_ => Loading)
      let obj: ConnectorTypes.wasmRequest = {
        connector,
        payment_methods_enabled: paymentMethodsEnabled,
      }
      let body = constructConnectorRequestBody(obj, values)
      if connector->getConnectorNameTypeFromString == Processors(PAYSAFE) {
        setInitialValues(_ => body)
        setCurrentStep(_ => ConnectorTypes.CustomMetadata)
      } else {
        let connectorUrl = getURL(~entityName=V1(CONNECTOR), ~methodType=Post, ~id=connectorID)
        let response = await updateAPIHook(
          connectorUrl,
          body->ignoreFields(connectorID->Option.getOr(""), connectorIgnoredField),
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
      }
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
  <PageLoaderWrapper screenState>
    <Form onSubmit initialValues={initialValues}>
      <div className="flex flex-col">
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
        <div className="grid grid-cols-4 flex-1 p-2 md:p-10">
          <div className="flex flex-col gap-6 col-span-3">
            <HSwitchUtils.AlertBanner
              bannerContent={<p>
                {"Please verify if the payment methods are turned on at the processor end as well."->React.string}
              </p>}
              bannerType=Warning
            />
            <PaymentMethod.PaymentMethodsRender
              _showAdvancedConfiguration
              connector
              paymentMethodsEnabled
              updateDetails
              setMetaData
              isPayoutFlow=false
              initialValues
              setInitialValues
            />
          </div>
        </div>
      </div>
    </Form>
  </PageLoaderWrapper>
}
