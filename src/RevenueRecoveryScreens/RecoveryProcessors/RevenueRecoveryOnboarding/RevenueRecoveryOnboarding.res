@react.component
let make = () => {
  open RevenueRecoveryOnboardingUtils

  let (currentStep, setNextStep) = React.useState(() => defaultStep)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)
  let {profileId} = getUserInfoData()
  let (_connectorId, setConnectorId) = React.useState(() => "")

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
      title="Setup Recovery"
      sections
      currentStep
      backClick={() => {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recovery/home"))
      }}
    />
    <div className="flex flex-row ml-14 mt-16">
      <RevenueRecoveryOnboardingPayments
        currentStep setConnectorId onNextClick setNextStep profileId onPreviousClick
      />
      <RevenueRecoveryOnboardingBilling
        currentStep setConnectorId onNextClick setNextStep profileId onPreviousClick
      />
    </div>
  </div>
}
