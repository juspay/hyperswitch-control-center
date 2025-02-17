@react.component
let make = () => {
  open CommonAuthHooks
  open RevenueRecoveryOnboardingUtils

  let (currentStep, setNextStep) = React.useState(() => defaultStep)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)

  let {profileId} = getUserInfoData()
  let {merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)

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
      <RevenueRecoveryOnboardingPayments
        currentStep
        setConnectorID={setPaymentConnectorID}
        connector={paymentConnectorName}
        setConnectorName={setPaymentConnectorName}
        onNextClick
        setNextStep
        profileId
        onPreviousClick
      />
      <RevenueRecoveryOnboardingBilling
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
