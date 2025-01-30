module Heading = {
  @react.component
  let make = (
    ~title,
    ~customTitleStyle="text-xl font-semibold text-grey-800",
    ~customHeadingStyle="",
  ) => {
    <div>
      <div className={`p-2 md:p-6 ${customHeadingStyle}`}>
        <div className={`${customTitleStyle}`}> {title->React.string} </div>
      </div>
      <div className="border-b border-grey-outline" />
    </div>
  }
}

module SubHeading = {
  @react.component
  let make = (~currentStepCount, ~title, ~subTitle) => {
    <div className="flex flex-col gap-1">
      <p className="text-base text-gray-500">
        {`STEP ${currentStepCount->Int.toString} / 3`->React.string}
      </p>
      <p className="text-lg font-semibold text-grey-800"> {title->React.string} </p>
      <p className="text-sm text-gray-500"> {subTitle->React.string} </p>
    </div>
  }
}

module ProgressBar = {
  @react.component
  let make = (~currentStep) => {
    open ReconConfigurationUtils
    let percentage = currentStep->getPercentage

    <div className="p-2 md:p-6">
      <p> {`${percentage->Int.toString}% Completed`->React.string} </p>
      <div className="w-full bg-blue-150 rounded h-2 mt-3">
        <div className="bg-blue-500 h-2 rounded" style={{width: `${percentage->Int.toString}%`}} />
      </div>
    </div>
  }
}

module ReconConfigurationCurrentStepIndicator = {
  @react.component
  let make = (~currentStep: ReconConfigurationTypes.steps) => {
    open ReconConfigurationUtils
    let rows = sectionsArr->Array.length->Int.toString
    let currIndex =
      sectionsArr->Array.findIndex(item =>
        item === currentStep->ReconConfigurationUtils.getSectionFromStep
      )
    <div className="w-full p-2 md:p-6">
      <div className={`grid grid-rows-${rows} relative gap-y-4`}>
        {sectionsArr
        ->Array.mapWithIndex((step, i) => {
          let isStepCompleted = i < currIndex
          let isCurrentStep = i == currIndex
          let subSectionsArr = step->ReconConfigurationUtils.getSubSections

          let stepNumberIndicator = if isCurrentStep {
            "bg-blue-500"
          } else {
            "border-blue-500 bg-white border"
          }

          let stepNameIndicator = if isCurrentStep {
            "text-blue-500 break-all font-semibold text-base"
          } else {
            "text-gray-500 break-all font-semibold text-base"
          }

          let textColor = isCurrentStep ? "text-white" : "text-blue-500"

          <div key={i->Int.toString} className="font-semibold flex flex-col gap-y-5">
            <div className="flex gap-x-3 items-center w-full">
              <div
                className={`h-6 w-6 flex items-center justify-center rounded ${stepNumberIndicator}`}>
                {if isStepCompleted {
                  <p className={`text-base ${textColor}`}>
                    {(i + 1)->Int.toString->React.string}
                  </p>
                } else {
                  <p className={`text-base ${textColor}`}>
                    {(i + 1)->Int.toString->React.string}
                  </p>
                }}
              </div>
              <div className={stepNameIndicator}>
                {step->ReconConfigurationUtils.getSectionName->React.string}
              </div>
              <div className="ml-auto">
                {if isStepCompleted || isCurrentStep {
                  <div />
                } else {
                  <Icon name="lock-outlined" customIconColor="gray" customHeight="20" />
                }}
              </div>
            </div>
            <div className="flex flex-col gap-y-1">
              {subSectionsArr
              ->Array.mapWithIndex((subSection, j) => {
                let subStepIndex =
                  subSectionsArr->Array.findIndex(
                    item => item === currentStep->ReconConfigurationUtils.getSubsectionFromStep,
                  )

                let isSubStepCompleted = isStepCompleted || j < subStepIndex
                let isCurrentSubStep = j == subStepIndex && isCurrentStep

                let subStepNameIndicator = if isCurrentSubStep {
                  "text-gray-700 break-all font-medium text-sm"
                } else {
                  "text-gray-500 break-all text-sm font-medium"
                }

                let subStepBackground = if isCurrentSubStep {
                  "bg-gray-100 p-2.5 rounded"
                } else {
                  "bg-white p-2.5 rounded"
                }

                <div
                  key={j->Int.toString}
                  className={`flex gap-x-3 items-center ${subStepBackground}`}>
                  <div className={`h-4 w-4 flex items-center justify-center ml-6 rounded`}>
                    {if isSubStepCompleted {
                      <Icon name="green-check" customIconColor="green" customHeight="14" />
                    } else {
                      <div className="h-3 w-3 rounded-full border-1.5 border-gray-700" />
                    }}
                  </div>
                  <div className={subStepNameIndicator}>
                    {subSection->ReconConfigurationUtils.getSubsectionName->React.string}
                  </div>
                </div>
              })
              ->React.array}
            </div>
          </div>
        })
        ->React.array}
      </div>
    </div>
  }
}

module StepCard = {
  @react.component
  let make = (~stepName, ~description, ~isSelected, ~onClick, ~iconName) => {
    let ringClass = switch isSelected {
    | true => "border-blue-811 ring-blue-811/20 ring-offset-0 ring-2"
    | false => "ring-grey-outline"
    }
    <div
      key={stepName}
      className={`flex items-center gap-x-2.5 border ${ringClass} rounded-lg p-4 transition-shadow cursor-pointer justify-between`}
      onClick={onClick}>
      <div className="flex items-center gap-x-2.5">
        <img alt={iconName} src={`/Recon/${iconName}.svg`} className="w-8 h-8" />
        <div className="flex flex-col gap-1">
          <h3 className="text-medium font-medium text-grey-900"> {stepName->React.string} </h3>
          <p className="text-sm text-gray-500"> {description->React.string} </p>
        </div>
      </div>
      {switch isSelected {
      | true => <Icon name="blue-circle" customHeight="20" />
      | false => <div />
      }}
    </div>
  }
}

module Footer = {
  @react.component
  let make = (~currentStep, ~buttonName, ~onSubmit) => {
    open ReconConfigurationUtils
    let isFirstStep = currentStep->isFirstStep
    let isLastStep = currentStep->isLastStep

    <div className="flex justify-end items-center p-4 bg-white w-full rounded-br-lg">
      {switch (isFirstStep, isLastStep) {
      | (true, false) =>
        <Button
          text="Continue"
          customButtonStyle="rounded w-90-px"
          buttonType={Primary}
          onClick={onSubmit}
        />
      | (false, true) =>
        <Button
          text="Done" customButtonStyle="rounded w-90-px" buttonType={Primary} onClick={onSubmit}
        />
      | (true, true) => <div />
      | (false, false) =>
        <div className="flex gap-4">
          // <Button
          //   text="Back"
          //   customButtonStyle="rounded w-90-px"
          //   buttonType={Secondary}
          //   onClick={_ => setCurrentStep(prev => getPreviousStep(prev))}
          // />
          <Button
            text={buttonName}
            customButtonStyle="w-90-px"
            buttonType={Primary}
            onClick={onSubmit}
          />
        </div>
      }}
    </div>
  }
}
