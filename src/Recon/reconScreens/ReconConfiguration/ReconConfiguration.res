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
    <div
      className="absolute top-76-px left-0 w-full py-4 px-10 bg-orange-50 flex justify-start gap-4 items-center">
      <Icon name="nd-information-triangle" size=16 />
      <p className="text-nd_gray-600 text-base leading-6 font-medium">
        {"You are in demo environment and this is sample setup."->React.string}
      </p>
    </div>
    <div className="flex flex-col gap-10 py-10">
      <div className="rounded-lg h-774-px flex flex-col">
        <div className="flex h-full">
          <div className="flex flex-col">
            <VerticalStepIndicator titleElement=reconTitleElement sections currentStep backClick />
          </div>
          <div className="flex-[7] h-full p-12">
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
  </div>
}
