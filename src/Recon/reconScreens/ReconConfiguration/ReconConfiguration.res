@react.component
let make = (~setShowOnBoarding, ~setShowSkeleton) => {
  open ReconConfigurationTypes
  open ConnectOrderDataTypes
  open VerticalStepIndicatorTypes
  open ReconConfigurationUtils

  let (currentStep, setCurrentStep) = React.useState(() => {
    sectionId: (#connectOrderData: sections :> string),
    subSectionId: Some((#selectSource: connectOrderDataSubSections :> string)),
  })
  let (selectedOrderSource, setSelectedOrderSource) = React.useState(_ => UploadFile)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  let backClick = () => {
    setShowSideBar(_ => true)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon/onboarding"))
  }

  let vaultTitleElement =
    <>
      <h1 className="text-medium font-semibold text-gray-600">
        {"Setup Reconciliation"->React.string}
      </h1>
    </>

  <div className="flex flex-col gap-10">
    <div className="rounded-lg h-774-px flex flex-col">
      <div className="flex h-full">
        <div className="flex flex-col">
          <VerticalStepIndicator titleElement=vaultTitleElement sections currentStep backClick />
        </div>
        <div className="flex-[7] h-full p-12">
          <div className="w-500-px">
            {switch currentStep.sectionId->getSectionVariantFromString {
            | #connectOrderData =>
              <ConnectOrderData
                currentStep={currentStep}
                setCurrentStep={setCurrentStep}
                selectedOrderSource
                setSelectedOrderSource
              />
            | #connectProcessorData =>
              <ConnectProcessorData currentStep={currentStep} setCurrentStep={setCurrentStep} />
            | #manualMapping =>
              <ManualMapping currentStep={currentStep} setCurrentStep={setCurrentStep} setShowOnBoarding setShowSkeleton />
            }}
          </div>
        </div>
      </div>
    </div>
  </div>
}
