@react.component
let make = (~connector, ~closeAccordionFn, ~update, ~onCloseClickCustomFun) => {
  open LogicUtils
  open GooglePayUtils
  open GPayFlowTypes
  open GPayFlowMetadataHelper

  let (googlePayIntegrationType, setGooglePayIntegrationType) = React.useState(_ =>
    #payment_gateway
  )
  let (googlePayIntegrationStep, setGooglePayIntegrationStep) = React.useState(_ => Landing)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )

  let googlePayFields = React.useMemo(() => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let dict = if connector->isNonEmptyString {
        Window.getConnectorConfig(connector)
        ->getDictFromJsonObject
        ->getDictfromDict("metadata")
        ->getArrayFromDict("google_pay", [])
      } else {
        []
      }
      setScreenState(_ => PageLoaderWrapper.Success)
      dict
    } catch {
    | Exn.Error(e) => {
        setScreenState(_ => PageLoaderWrapper.Error("Failed to load connector configuration"))
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        []
      }
    }
  }, [connector])

  let initialGooglePayDict = React.useMemo(() => {
    formState.values->getDictFromJsonObject->getDictfromDict("metadata")
  }, [])

  let form = ReactFinalForm.useForm()
  React.useEffect(() => {
    if connector->isNonEmptyString {
      let value = googlePay(initialGooglePayDict->getDictfromDict("google_pay"), connector)
      switch value {
      | Standard(data) => form.change("metadata.google_pay", data->Identity.genericTypeToJson)
      | _ => ()
      }
    }
    None
  }, [connector])

  let closeModal = () => {
    onCloseClickCustomFun()
    closeAccordionFn()
  }

  <PageLoaderWrapper
    screenState={screenState}
    customLoader={<div className="mt-60 w-scrren flex flex-col justify-center items-center">
      <div className="animate-spin mb-1">
        <Icon name="spinner" size=20 />
      </div>
    </div>}
    sectionHeight="!h-screen">
    {switch googlePayIntegrationStep {
    | Landing =>
      <Landing
        googlePayIntegrationType
        closeModal
        setGooglePayIntegrationStep
        setGooglePayIntegrationType
        update
        closeAccordionFn
      />
    | Configure =>
      switch googlePayIntegrationType {
      | #payment_gateway =>
        <GpayMetadataFlowPaymentGateway
          googlePayFields connector closeAccordionFn update closeModal
        />
      | _ => React.null
      }
    }}
  </PageLoaderWrapper>
}
