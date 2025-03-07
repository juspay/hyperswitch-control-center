@react.component
let make = () => {
  open AlternatePaymentMethodsUtils
  open AlternatePaymentMethodsTypes
  open VerticalStepIndicatorTypes

  let (currentStep, _setNextStep) = React.useState(() => {
    sectionId: (#ConfigureProcessor: sectionType :> string),
    subSectionId: None,
  })
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let (_screenState, _setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let backClick = () => {
    RescriptReactRouter.replace(
      GlobalVars.appendDashboardPath(~url="/v2/alt-payment-methods/onboarding"),
    )
    setShowSideBar(_ => true)
  }

  let apmTitleElement = <div> {"Setup Alternative Payment Methods"->React.string} </div>

  <div className="flex flex-row gap-x-6">
    <VerticalStepIndicator titleElement=apmTitleElement sections currentStep backClick />
    {switch currentStep->getSectionVariant {
    | #ConfigureProcessor =>
      <div className="flex flex-col w-1/2 px-10">
        <PageUtils.PageHeading
          title="Where do you process your payments?"
          subTitle="Choose one processor for now. You can connect more processors later"
          customSubTitleStyle="font-500 font-normal text-nd_gray-700"
        />
      </div>
    | #ReviewAndConnect => <div> {"Review and Connect"->React.string} </div>
    }}
  </div>
}
