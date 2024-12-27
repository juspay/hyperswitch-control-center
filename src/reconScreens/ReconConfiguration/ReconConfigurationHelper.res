module ReconConfigurationCurrentStepIndicator = {
  @react.component
  let make = (~currentStep: ReconConfigurationTypes.steps, ~stepsArr) => {
    let cols = stepsArr->Array.length->Int.toString
    let currIndex = stepsArr->Array.findIndex(item => item === currentStep)
    <div className="w-full">
      <div className={`grid grid-cols-${cols} relative gap-2`}>
        {stepsArr
        ->Array.mapWithIndex((step, i) => {
          let isStepCompleted = i <= currIndex
          let isPreviousStepCompleted = i < currIndex
          let isCurrentStep = i == currIndex

          let stepNumberIndicator = if isPreviousStepCompleted {
            "border-black bg-white"
          } else if isCurrentStep {
            "bg-black"
          } else {
            "border-gray-300 bg-white"
          }

          let stepNameIndicator = isStepCompleted
            ? "text-grey-900 break-all font-semibold"
            : "text-grey-200 break-all font-medium"

          let textColor = isCurrentStep ? "text-white" : "text-grey-700"

          let stepLineIndicator = isPreviousStepCompleted ? "bg-gray-700" : "bg-gray-300"

          <div key={i->Int.toString} className="font-semibold">
            <div className="flex gap-x-3 items-center w-full">
              <div
                className={`h-8 w-8 flex items-center justify-center border rounded-full ${stepNumberIndicator}`}>
                {if isPreviousStepCompleted {
                  <Icon name="check-black" size=20 />
                } else {
                  <p className=textColor> {(i + 1)->Int.toString->React.string} </p>
                }}
              </div>
              <div className={stepNameIndicator}>
                {step->ReconConfigurationUtils.getStepName->React.string}
              </div>
              <RenderIf condition={i !== stepsArr->Array.length - 1}>
                <div className={`h-0.5 ${stepLineIndicator} ml-2 flex-1`} />
              </RenderIf>
            </div>
          </div>
        })
        ->React.array}
      </div>
    </div>
  }
}

module Heading = {
  @react.component
  let make = (
    ~title,
    ~subTitle=?,
    ~customTitleStyle="text-xl font-semibold text-grey-800",
    ~customSubTitleStyle="text-sm font-normal",
    ~customHeadingStyle="gap-4",
  ) => {
    <div className="flex flex-col">
      <div className={`h-3/4 p-2 md:p-7 ${customHeadingStyle}`}>
        <div className={`${customTitleStyle}`}> {title->React.string} </div>
        <div className={`opacity-50 mt-1 ${customSubTitleStyle}`}>
          {switch subTitle {
          | Some(subTitle) => subTitle->React.string
          | None => ""->React.string
          }}
        </div>
      </div>
      <div className="border-b border-grey-outline" />
    </div>
  }
}

// StepCard Component
module StepCard = {
  @react.component
  let make = (~stepName, ~isSelected, ~onClick, ~iconName) => {
    let ringClass = switch isSelected {
    | true => "border-blue-811 ring-blue-811/20 ring-offset-0 ring-2"
    | false => "ring-grey-outline"
    }

    <div
      key={stepName}
      className={`flex items-center gap-x-3 border ${ringClass} rounded-lg p-4 transition-shadow cursor-pointer`}
      onClick={onClick}>
      <img alt={iconName} src={`/Recon/${iconName}.svg`} className="w-8 h-8" />
      <h3 className="text-medium font-medium text-grey-900"> {stepName->React.string} </h3>
    </div>
  }
}
