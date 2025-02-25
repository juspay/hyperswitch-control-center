@react.component
let make = (~setShowOnBoarding, ~setShowSkeleton) => {
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
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon/onboarding"))
  }

  let reconTitleElement =
    <>
      <h1 className="text-medium font-semibold text-gray-600">
        {"Setup Reconciliation"->React.string}
      </h1>
    </>

  <div>
    <div className="flex flex-col gap-10 py-10 h-774-px overflow-y-hidden">
      <div className="flex h-full">
        <div className="flex flex-col">
          <VerticalStepIndicator titleElement=reconTitleElement sections currentStep backClick />
        </div>
        <div className="h-full p-12 overflow-hidden">
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
              <Final
                currentStep={currentStep}
                setCurrentStep={setCurrentStep}
                setShowOnBoarding
                setShowSkeleton
              />
            }}
          </div>
        </div>
      </div>
    </div>
  </div>
}
