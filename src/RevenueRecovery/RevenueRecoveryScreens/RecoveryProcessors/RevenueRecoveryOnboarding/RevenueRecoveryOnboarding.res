@react.component
let make = () => {
  open RevenueRecoveryOnboardingUtils
  open LogicUtils

  let (currentStep, setNextStep) = React.useState(() => defaultStep)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)

  let {profileId, merchantId} = getUserInfoData()
  let (_, getNameForId) = OMPSwitchHooks.useOMPData()

  let activeBusinessProfile = getNameForId(#Profile)

  let (paymentConnectorName, setPaymentConnectorName) = React.useState(() => "")
  let (paymentConnectorID, setPaymentConnectorID) = React.useState(() => "")
  let (billingConnectorName, setBillingConnectorName) = React.useState(() => "")

  React.useEffect(() => {
    if paymentConnectorName->isNonEmptyString {
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url=`/v2/recovery/onboarding?name=${paymentConnectorName}`),
      )
    }

    if billingConnectorName->isNonEmptyString {
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url=`/v2/recovery/onboarding?name=${billingConnectorName}`),
      )
    }

    None
  }, [paymentConnectorName, billingConnectorName])

  React.useEffect(() => {
    setShowSideBar(_ => false)

    (
      () => {
        setShowSideBar(_ => true)
      }
    )->Some
  }, [])

  <div className="flex flex-col gap-10 h-923-px">
    <div className="flex h-full">
      <div className="flex flex-col">
        <VerticalStepIndicator
          titleElement={"Setup Recovery"->React.string}
          sections
          currentStep
          backClick={() => {
            RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recovery/home"))
          }}
        />
      </div>
      <div className="flex flex-row ml-14 mt-16 w-540-px overflow-y-auto">
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
  </div>
}
