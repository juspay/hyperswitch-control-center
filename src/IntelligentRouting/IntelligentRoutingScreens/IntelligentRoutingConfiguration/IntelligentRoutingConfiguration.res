@react.component
let make = () => {
  open IntelligentRoutingUtils
  open VerticalStepIndicatorTypes
  open VerticalStepIndicatorUtils
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let (reviewFields, setReviewFields) = React.useState(_ =>
    Dict.make()->IntelligentRoutingReviewFieldsEntity.itemToObjMapper
  )
  let (isUpload, setIsUpload) = React.useState(() => false)
  let (fileUInt8Array, setFileUInt8Array) = React.useState(_ => Js.TypedArray2.Uint8Array.make([]))

  let (currentStep, setNextStep) = React.useState(() => {
    sectionId: (#analyze: IntelligentRoutingTypes.sections :> string),
    subSectionId: None,
  })

  let getNextStep = (currentStep: step): option<step> => {
    findNextStep(sections, currentStep)
  }

  let onNextClick = () => {
    switch getNextStep(currentStep) {
    | Some(nextStep) => setNextStep(_ => nextStep)
    | None => ()
    }
  }

  React.useEffect(() => {
    Window.dynamicRoutingWasmInit()->ignore
    setShowSideBar(_ => false)
    None
  }, [])

  let backClick = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/dynamic-routing"))
    setShowSideBar(_ => true)
  }

  let intelligentRoutingTitleElement =
    <>
      <h1 className="text-medium font-semibold text-gray-600">
        {`Simulate Intelligent Routing`->React.string}
      </h1>
    </>

  <div className="h-774-px w-full">
    <div className="flex flex-row h-890-px">
      <VerticalStepIndicator
        titleElement=intelligentRoutingTitleElement sections currentStep backClick
      />
      <div className="mx-12 mt-16 overflow-y-auto">
        {switch currentStep.sectionId->stringToSectionVariantMapper {
        | #analyze =>
          <AnalyzeData onNextClick setReviewFields setIsUpload fileUInt8Array setFileUInt8Array />
        | #review => <ReviewDataSummary reviewFields isUpload fileUInt8Array />
        | _ => React.null
        }}
      </div>
    </div>
  </div>
}
