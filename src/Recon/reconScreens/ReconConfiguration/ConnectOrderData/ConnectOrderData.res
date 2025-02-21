open VerticalStepIndicatorTypes

@react.component
let make = (~currentStep: step, ~setCurrentStep, ~selectedOrderSource, ~setSelectedOrderSource) => {
  open ReconConfigurationUtils
  open ConnectOrderDataUtils
  open VerticalStepIndicatorUtils

  let (showDummyFile, setShowDummyFile) = React.useState(_ => false)
  let (isLoading, setIsLoading) = React.useState(_ => false)

  let getNextStep = (currentStep: step): option<step> => {
    findNextStep(sections, currentStep)
  }

  let onNextClick = () => {
    switch getNextStep(currentStep) {
    | Some(nextStep) => setCurrentStep(_ => nextStep)
    | None => ()
    }
  }

  let onUploadFileClick = () => {
    setIsLoading(_ => true)
    setShowDummyFile(_ => true)
    let _ = Js.Global.setTimeout(() => setIsLoading(_ => false), 2000)
  }

  let customSelectionComponent = {
    switch isLoading {
    | true =>
      <div className="relative">
        <div
          className="w-4 h-4 rounded-full absolute right-2 -top-2 border-2 border-solid border-nd_primary_blue-100"
        />
        <div
          className="w-4 h-4 rounded-full animate-spin absolute right-2 -top-2 border-2 border-solid border-nd_primary_blue-300 border-t-transparent"
        />
      </div>

    | false =>
      <Icon
        name="nd-delete-dustbin" className="cursor-pointer" onClick={_ => setShowDummyFile(_ => false)} customHeight="16"
      />
    }
  }

  <div className="flex flex-col h-full gap-y-10">
    <ReconConfigurationHelper.SubHeading
      title="Connect Order Data Source"
      subTitle="Link your order data source to streamline the reconciliation process"
    />
    <div className="flex flex-col h-full gap-y-10">
      <div className="flex flex-col gap-y-4">
        <p className="text-sm text-nd_gray-700 font-semibold">
          {"Where do you want to fetch your data from?"->React.string}
        </p>
        <div className="flex flex-col gap-y-4">
          {orderDataStepsArr
          ->Array.map(step => {
            let stepName = step->getSelectedStepName
            let description = step->getSelectedStepDescription
            let isSelected = selectedOrderSource === step
            <ReconConfigurationHelper.StepCard
              key={stepName}
              stepName={stepName}
              description={description}
              isSelected={isSelected}
              iconName={step->ConnectOrderDataUtils.getIconName}
              onClick={_ => setSelectedOrderSource(_ => step)}
              customSelectionComponent={<Icon name="nd-circle-dot" customHeight="16" />}
              customOuterClass="cursor-pointer"
            />
          })
          ->React.array}
        </div>
        {switch selectedOrderSource {
        | UploadFile =>
          <div
            className="bg-nd_gray-25 border rounded-lg flex flex-col gap-4 items-center justify-center px-4 pt-3 pb-4 w-full">
            <RenderIf condition={showDummyFile}>
              <ReconConfigurationHelper.StepCard
                isLoading
                key="Dummy_order_data.csv"
                stepName="Dummy_order_data.csv"
                description="3.4 MB"
                isSelected=true
                iconName="nd-file"
                onClick={_ => ()}
                customSelectionComponent
                customSelectionBorderClass="border-nd_br_gray-500"
              />
            </RenderIf>
            <div className="flex flex-col items-center gap-4">
              <p className="text-sm font-medium leading-5 text-nd_gray-400">
                {"Add your data as per the sample file and upload "->React.string}
                <span
                  className="text-sm font-semibold text-nd_primary_blue-500 leading-5 underline">
                  {"Sample file"->React.string}
                </span>
              </p>
              <Button
                leftIcon={CustomIcon(<Icon name="nd-upload" />)}
                buttonType={Secondary}
                text="Upload File"
                onClick={_ => onUploadFileClick()}
                customButtonStyle="w-298-px"
              />
            </div>
          </div>
        | _ => React.null
        }}
      </div>
      <div className="flex justify-end items-center">
        <Button
          text="Next"
          customButtonStyle="rounded w-full"
          buttonType={Primary}
          buttonState={isLoading || !showDummyFile ? Disabled : Normal}
          onClick={_ => onNextClick()->ignore}
        />
      </div>
    </div>
  </div>
}
