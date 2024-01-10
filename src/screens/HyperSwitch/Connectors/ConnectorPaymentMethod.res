@react.component
let make = (
  ~setCurrentStep,
  ~connector,
  ~setInitialValues,
  ~initialValues,
  ~isUpdateFlow,
  ~isPayoutFlow,
) => {
  open ConnectorUtils
  open APIUtils
  open PageLoaderWrapper
  open LogicUtils
  let _showAdvancedConfiguration = false
  let (paymentMethodsEnabled, setPaymentMethods) = React.useState(_ =>
    Dict.make()->Js.Json.object_->getPaymentMethodEnabled
  )
  let (metaData, setMetaData) = React.useState(_ => Dict.make()->Js.Json.object_)
  let showToast = ToastState.useShowToast()
  let connectorID = initialValues->getDictFromJsonObject->getOptionString("merchant_connector_id")
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let updateAPIHook = useUpdateMethod(~showErrorToast=false, ())

  let updateDetails = value => {
    setPaymentMethods(_ => value->Array.copy)
  }

  React.useEffect1(() => {
    setScreenState(_ => Loading)
    initialValues
    ->ConnectorUtils.getConnectorPaymentMethodDetails(
      setPaymentMethods,
      setMetaData,
      setScreenState,
      isUpdateFlow,
      isPayoutFlow,
      connector,
      updateDetails,
    )
    ->ignore
    None
  }, [connector])

  let onSubmit = async () => {
    try {
      setScreenState(_ => Loading)
      let obj: ConnectorTypes.wasmRequest = {
        connector,
        payment_methods_enabled: paymentMethodsEnabled,
        metadata: metaData,
      }
      let body =
        constructConnectorRequestBody(obj, initialValues)->ignoreFields(
          connectorID->Belt.Option.getWithDefault(""),
          ConnectorUtils.connectorIgnoredField,
        )
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=connectorID, ())
      let response = await updateAPIHook(connectorUrl, body, Post)
      setInitialValues(_ => response)
      setScreenState(_ => Success)
      setCurrentStep(_ => ConnectorTypes.SummaryAndTest)
      showToast(
        ~message=!isUpdateFlow ? "Connector Created Successfully!" : "Details Updated!",
        ~toastType=ToastSuccess,
        (),
      )
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")

        if errorCode === "HE_01" {
          showToast(~message="Connector label already exist!", ~toastType=ToastError, ())
          setCurrentStep(_ => ConnectorTypes.IntegFields)
        } else {
          showToast(~message=errorMessage, ~toastType=ToastError, ())
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col">
      <div className="flex justify-between border-b p-2 md:px-10 md:py-6">
        <div className="flex gap-2 items-center">
          <GatewayIcon gateway={connector->String.toUpperCase} />
          <h2 className="text-xl font-semibold">
            {connector->LogicUtils.capitalizeString->React.string}
          </h2>
        </div>
        <div className="self-center">
          <Button text="Proceed" buttonType={Primary} onClick={_ => onSubmit()->ignore} />
        </div>
      </div>
      <div className="grid grid-cols-4 flex-1 p-2 md:p-10">
        <div className="flex flex-col gap-6 col-span-3">
          <h1 className="text-orange-950 bg-orange-100 border w-full p-2 rounded-md ">
            <span className="text-orange-950 font-bold text-fs-14 mx-2">
              {"NOTE:"->React.string}
            </span>
            {"Please verify if the payment methods are turned on at the processor end as well."->React.string}
          </h1>
          <PaymentMethod.PaymentMethodsRender
            _showAdvancedConfiguration
            connector
            paymentMethodsEnabled
            updateDetails
            metaData
            setMetaData
            isPayoutFlow
          />
        </div>
      </div>
    </div>
  </PageLoaderWrapper>
}
