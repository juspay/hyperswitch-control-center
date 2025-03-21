@react.component
let make = (~connector, ~setShowWalletConfigurationModal, ~update, ~onCloseClickCustomFun) => {
  open GooglePayDecryptionFlowTypes
  open LogicUtils
  open GooglePayDecryptionFlowHelper

  let (googlePayIntegrationType, setGooglePayIntegrationType) = React.useState(_ =>
    #payment_gateway
  )
  let (googlePayIntegrationStep, setGooglePayIntegrationStep) = React.useState(_ => Landing)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

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

  let closeModal = () => {
    onCloseClickCustomFun()
    setShowWalletConfigurationModal(_ => false)
  }

  <PageLoaderWrapper
    screenState={screenState}
    customLoader={<div className="mt-60 w-scrren flex flex-col justify-center items-center">
      <div className={`animate-spin mb-1`}>
        <Icon name="spinner" size=20 />
      </div>
    </div>}
    sectionHeight="!h-screen">
    {switch googlePayIntegrationStep {
    | Landing =>
      <Landing
        googlePayIntegrationType closeModal setGooglePayIntegrationStep setGooglePayIntegrationType
      />
    | Configure =>
      <>
        {switch googlePayIntegrationType {
        | #payment_gateway =>
          <GooglePayDecryptionFlowPaymentGateway
            googlePayFields
            googlePayIntegrationType
            closeModal
            connector
            setShowWalletConfigurationModal
            update
          />
        | #direct =>
          <GooglePayDecryptionFlowDirect
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
