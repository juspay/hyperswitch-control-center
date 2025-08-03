@react.component
let make = () => {
  open RevenueRecoveryOnboardingUtils

  let connectorList = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=PaymentProcessor,
  )
  let hasConfiguredPaymentConnector = connectorList->Array.length > 0
  let (connectorID, connectorName) = connectorList->BillingProcessorsUtils.getConnectorDetails
  let (currentStep, setNextStep) = React.useState(() =>
    hasConfiguredPaymentConnector ? defaultStepBilling : defaultStep
  )
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)

  let {profileId, merchantId} = getUserInfoData()
  let (_, getNameForId) = OMPSwitchHooks.useOMPData()

  let activeBusinessProfile = getNameForId(#Profile)

  let (paymentConnectorName, setPaymentConnectorName) = React.useState(() => connectorName)
  let (paymentConnectorID, setPaymentConnectorID) = React.useState(() => connectorID)
  let (billingConnectorName, setBillingConnectorName) = React.useState(() => "")
  let defaultPath = RecoveryConnectorContainerUtils.useGetDefaultPath()

  React.useEffect(() => {
    setShowSideBar(_ => false)

    (
      () => {
        setShowSideBar(_ => true)
      }
    )->Some
  }, [])

  <div className="flex flex-row">
    <VerticalStepIndicator
      titleElement={"Setup Recovery"->React.string}
      sections
      currentStep
      backClick={() => {
        RescriptReactRouter.replace(defaultPath)
      }}
    />
    <div className="flex flex-row ml-14 mt-16 w-540-px">
      <RecoveryOnboardingPayments
        currentStep
        setConnectorID={setPaymentConnectorID}
        connector={paymentConnectorName}
        setConnectorName={setPaymentConnectorName}
        setNextStep
        profileId
        merchantId
        activeBusinessProfile
      />
      <RecoveryOnboardingBilling
        currentStep
        connectorID={paymentConnectorID}
        connector=billingConnectorName
        paymentConnectorName={paymentConnectorName}
        setConnectorName=setBillingConnectorName
        setNextStep
        profileId
        merchantId
        activeBusinessProfile
      />
    </div>
  </div>
}
