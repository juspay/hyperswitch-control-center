@react.component
let make = () => {
  open RevenueRecoveryOnboardingUtils

  let (currentStep, setNextStep) = React.useState(() => defaultStep)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)

  let {profileId, merchantId} = getUserInfoData()
  let (_, getNameForId) = OMPSwitchHooks.useOMPData()

  let activeBusinessProfile = getNameForId(#Profile)

  let (paymentConnectorName, setPaymentConnectorName) = React.useState(() => "")
  let (paymentConnectorID, setPaymentConnectorID) = React.useState(() => "")
  let (billingConnectorName, setBillingConnectorName) = React.useState(() => "")
  let (billingConnectorID, setBillingConnectorID) = React.useState(() => "")

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
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recovery"))
      }}
    />
    <div className="flex flex-row ml-14 mt-16 w-[540px]">
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
        setConnectorId={setPaymentConnectorID}
        onNextClick
        setNextStep
        profileId
        merchantId
        connector=paymentConnectorName
      />
    </div>
  </div>
}
