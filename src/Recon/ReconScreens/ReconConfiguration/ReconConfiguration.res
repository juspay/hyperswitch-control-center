@react.component
let make = (~setShowOnBoarding) => {
  open ReconConfigurationTypes
  open OrderDataConnectionTypes
  open VerticalStepIndicatorTypes
  open ReconConfigurationUtils

  let (currentStep, setCurrentStep) = React.useState(() => {
    sectionId: (#orderDataConnection: sections :> string),
    subSectionId: None,
  })

  let (selectedOrderSource, setSelectedOrderSource) = React.useState(_ => UploadFile)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  let backClick = () => {
    setShowSideBar(_ => true)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon"))
  }

  let reconTitleElement =
    <>
      <h1 className="text-medium font-semibold text-gray-600">
        {"Setup Reconciliation"->React.string}
      </h1>
    </>

  <div>
    <div className="flex flex-col gap-10 py-10 h-774-px overflow-y-hidden">
      <div className="flex h-full mt-10">
        <div className="flex flex-col">
          <VerticalStepIndicator titleElement=reconTitleElement sections currentStep backClick />
        </div>
        <div className="h-full p-12 overflow-hidden">
          <div
            className="absolute z-10 top-76-px left-0 w-full py-4 px-10 bg-orange-50 flex justify-between items-center">
            <div className="flex gap-4 items-center">
              <Icon name="nd-information-triangle" size=24 />
              <p className="text-nd_gray-600 text-base leading-6 font-medium">
                {"You're viewing sample analytics to help you understand how the reports will look with real data"->React.string}
              </p>
            </div>
          </div>
          <div className="w-500-px">
            {switch currentStep.sectionId->getSectionVariantFromString {
            | #orderDataConnection =>
              <OrderDataConnection
                currentStep={currentStep}
                setCurrentStep={setCurrentStep}
                selectedOrderSource
                setSelectedOrderSource
              />
            | #connectProcessors =>
              <ConnectProcessors currentStep={currentStep} setCurrentStep={setCurrentStep} />
            | #finish =>
              <Final currentStep={currentStep} setCurrentStep={setCurrentStep} setShowOnBoarding />
            }}
          </div>
        </div>
      </div>
    </div>
  </div>
}
