module SubHeading = {
  @react.component
  let make = (~title, ~subTitle) => {
    <div className="flex flex-col gap-y-1">
      <p className="text-xl font-semibold text-gray-700 leading-9"> {title->React.string} </p>
      <p className="text-base text-gray-400 font-medium"> {subTitle->React.string} </p>
    </div>
  }
}

module RecoveryConfigurationCurrentStepIndicator = {
  @react.component
  let make = (~currentStep: ConnectorTypes.steps, ~stepsArr) => {
    let cols = stepsArr->Array.length->Int.toString
    let currIndex = stepsArr->Array.findIndex(item => item === currentStep)

    <div className="w-full p-2 md:p-6">
      <div className={`grid grid-rows-${cols} relative gap-y-7`}>
        {stepsArr
        ->Array.mapWithIndex((step, i) => {
          let isStepCompleted = i < currIndex
          let isCurrentStep = i == currIndex
          //let subSectionsArr = []
          let stepNameIndicator = if isCurrentStep {
            "text-gray-700 break-all font-semibold"
          } else {
            "text-gray-400 break-all font-medium"
          }
          let iconColor = if isCurrentStep {
            "text-gray-700"
          } else {
            "text-gray-400"
          }
          let sectionLineHeight = isCurrentStep ? "h-5" : "h-6"
          <div key={i->Int.toString} className="font-semibold flex flex-col gap-y-2.5">
            <div className="flex gap-x-3 items-center w-full relative z-10">
              {if isStepCompleted {
                <div className="flex items-center justify-center rounded-full p-2 w-8 h-8 border">
                  <Icon className={`${iconColor}`} name="nd-check" />
                </div>
              } else {
                <div className="flex items-center justify-center rounded-full p-2 w-8 h-8 border">
                  <Icon className={`${iconColor} pl-1 pt-1`} name={"nd-inbox"} />
                </div>
              }}
              {if i == stepsArr->Array.length - 1 {
                React.null
              } else {
                <div
                  className={`absolute top-8 ${sectionLineHeight} left-4 border-l border-gray-150 z-0`}
                />
              }}
              <div className={stepNameIndicator}>
                {step->RecoveryPaymentProcessorsUtils.getStepName->React.string}
              </div>
            </div>
            // <div className="flex flex-col gap-y-2.5">
            //   {isCurrentStep
            //     ? {
            //         subSectionsArr
            //         ->Array.mapWithIndex((subSection, j) => {
            //           let subStepIndex =
            //             subSectionsArr->Array.findIndex(
            //               item =>
            //                 item === currentStep->ReconConfigurationUtils.getSubsectionFromStep,
            //             )
            //           let isSubStepCompleted = isStepCompleted || j < subStepIndex
            //           let isCurrentSubStep = j == subStepIndex && isCurrentStep
            //           let subSectionLineHeight = isCurrentSubStep ? "h-7" : "h-6"
            //           let subStepNameIndicator = if isCurrentSubStep {
            //             "text-blue-500 break-all font-semibold text-base pl-5"
            //           } else {
            //             "text-gray-400 break-all text-base font-medium pl-5"
            //           }
            //           <div
            //             key={j->Int.toString}
            //             className="flex gap-x-3 items-center p-2 rounded relative z-10">
            //             <div className="h-4 w-4 flex items-center justify-center rounded">
            //               {if isSubStepCompleted {
            //                 <Icon name="nd-small-check" customHeight="12" />
            //               } else if isCurrentSubStep {
            //                 <Icon name="nd-radio" className="text-blue-500" customHeight="8" />
            //               } else {
            //                 <Icon name="nd-radio" className="text-gray-500" customHeight="8" />
            //               }}
            //             </div>
            //             <div className={subStepNameIndicator}>
            //               {subSection->ReconConfigurationUtils.getSubsectionName->React.string}
            //             </div>
            //             {if (
            //               i == sectionsArr->Array.length - 1 &&
            //                 j == subSectionsArr->Array.length - 1
            //             ) {
            //               <div />
            //             } else {
            //               <div
            //                 className={`absolute top-7 left-4 ${subSectionLineHeight} border-l border-gray-150 z-0`}
            //               />
            //             }}
            //           </div>
            //         })
            //         ->React.array
            //       }
            //     : React.null}
            // </div>
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
    | true => "border-blue-500"
    | false => "ring-gray-200"
    }
    <div
      key={stepName}
      className={`flex items-center gap-x-2.5 border ${ringClass} rounded-xl p-3 transition-shadow cursor-pointer justify-between`}
      onClick={onClick}>
      <div className="flex items-center gap-x-2.5">
        <img alt={iconName} src={`/Recon/${iconName}.svg`} className="w-8 h-8" />
        <div className="flex flex-col gap-1">
          <h3 className="text-medium font-semibold text-gray-600"> {stepName->React.string} </h3>
          <p className="text-sm font-medium text-gray-400"> {description->React.string} </p>
        </div>
      </div>
      {switch isSelected {
      | true => <Icon name="nd-circle-dot" customHeight="20" />
      | false => <div />
      }}
    </div>
  }
}
