@react.component
let make = () => {
  open RevenueRecoveryOnboardingUtils
  open LogicUtils

  let connectorList = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV2,
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

  React.useEffect(() => {
    let (mainSection, _) = currentStep->RevenueRecoveryOnboardingUtils.getSectionVariant

    let url = switch mainSection {
    | #connectProcessor =>
      paymentConnectorName->isNonEmptyString
        ? `/v2/recovery/onboarding?name=${paymentConnectorName}`
        : `/v2/recovery/onboarding`
    | #addAPlatform =>
      billingConnectorName->isNonEmptyString
        ? `/v2/recovery/onboarding?name=${billingConnectorName}`
        : `/v2/recovery/onboarding`
    | #reviewDetails => `/v2/recovery/onboarding`
    }

    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url))

    None
  }, (paymentConnectorName, billingConnectorName, currentStep))

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
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recovery/home"))
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
