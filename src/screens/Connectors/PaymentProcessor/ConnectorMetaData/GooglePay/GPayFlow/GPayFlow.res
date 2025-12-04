@react.component
let make = (~connector, ~setShowWalletConfigurationModal, ~update, ~onCloseClickCustomFun) => {
  open GPayFlowTypes
  open LogicUtils
  open GPayFlowHelper
  open GPayFlowUtils
  open AdditionalDetailsSidebarHelper

  let (googlePayIntegrationType, setGooglePayIntegrationType) = React.useState(_ =>
    #payment_gateway
  )
  let (googlePayIntegrationStep, setGooglePayIntegrationStep) = React.useState(_ => Landing)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let integrationType = React.useMemo(() => {
    let connectorWalletDict =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("connector_wallets_details")
    let googlePayDict = connectorWalletDict->getDictfromDict("google_pay")
    if (
      connector->ConnectorUtils.getConnectorNameTypeFromString == Processors(TESOURO) &&
        googlePayDict->Dict.keysToArray->Array.length <= 0
    ) {
      "DIRECT"
    } else {
      connectorWalletDict->getIntegrationTypeFromConnectorWalletDetailsGooglePay
    }
  }, [])

  let googlePayFields = React.useMemo(() => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      if connector->isNonEmptyString {
        let dict =
          Window.getConnectorConfig(connector)
          ->getDictFromJsonObject
          ->getDictfromDict("connector_wallets_details")
          ->getArrayFromDict("google_pay", [])
        setScreenState(_ => PageLoaderWrapper.Success)

        dict
      } else {
        setScreenState(_ => PageLoaderWrapper.Success)
        []
      }
    } catch {
    | Exn.Error(e) => {
        setScreenState(_ => PageLoaderWrapper.Error("Failed to load connector configuration"))
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        []
      }
    }
  }, [connector])

  let setIntegrationType = () => {
    if connector->isNonEmptyString {
      setGooglePayIntegrationType(_ => integrationType->getGooglePayIntegrationTypeFromName)
    }
  }

  React.useEffect(() => {
    setIntegrationType()
    None
  }, [connector])

  let closeModal = () => {
    onCloseClickCustomFun()
    setShowWalletConfigurationModal(_ => false)
  }

  <PageLoaderWrapper
    screenState={screenState}
    customLoader={<div className="mt-60 w-scrren flex flex-col justify-center items-center">
      <div className="animate-spin mb-1">
        <Icon name="spinner" size=20 />
      </div>
    </div>}
    sectionHeight="!h-screen">
    <Heading title="Google Pay" iconName="google_pay" />
    {switch googlePayIntegrationStep {
    | Landing =>
      <Landing
        googlePayIntegrationType
        closeModal
        setGooglePayIntegrationStep
        setGooglePayIntegrationType
        connector
      />
    | Configure =>
      <>
        {switch googlePayIntegrationType {
        | #payment_gateway =>
          <GPayPaymentGatewayFlow
            googlePayFields
            googlePayIntegrationType
            closeModal
            connector
            setShowWalletConfigurationModal
            update
          />
        | #direct =>
          <GPayDirectFlow
            googlePayFields
            googlePayIntegrationType
            closeModal
            connector
            setShowWalletConfigurationModal
            update
          />
        }}
      </>
    }}
  </PageLoaderWrapper>
}
