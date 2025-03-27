open VerticalStepIndicatorTypes
@react.component
let make = (
  ~titleElement: React.element,
  ~sections: array<section>,
  ~currentStep: step,
  ~backClick,
) => {
  open VerticalStepIndicatorUtils

  let rows = sections->Array.length->Int.toString
  let currIndex = sections->findSectionIndex(currentStep.sectionId)
  <div className="flex flex-col gap-y-6 h-774-px w-334-px sticky overflow-y-auto py-5">
    <div className="flex items-center gap-x-3 px-6">
      <Icon
        name="nd-arrow-left"
        className="text-nd_gray-600 cursor-pointer"
        onClick={_ => backClick()}
        customHeight="20"
      />
      {titleElement}
    </div>
    <div className="w-full h-full p-2 md:p-6 border-r">
      <div className={`grid grid-rows-${rows} relative gap-y-3.5`}>
        {sections
        ->Array.mapWithIndex((section, sectionIndex) => {
          let isStepCompleted = sectionIndex < currIndex
          let isCurrentStep = sectionIndex == currIndex

          let stepNameIndicator = if isCurrentStep {
            `text-nd_gray-700 break-all font-semibold`
          } else {
            ` text-nd_gray-400 font-medium`
          }

          let iconColor = if isCurrentStep {
            "text-gray-700"
          } else {
            "text-gray-400"
          }

          let sectionLineHeight = isCurrentStep && currentStep.subSectionId != None ? "h-5" : "h-6"

          <div key={section.id} className="font-semibold flex flex-col gap-y-2.5">
            <div className="flex gap-x-3 items-center w-full relative z-10">
              {if isStepCompleted {
                <div className="flex items-center justify-center rounded-full p-2 w-8 h-8 border">
                  <Icon className={`${iconColor}`} name="nd-check" />
                </div>
              } else {
                <div className="flex items-center justify-center rounded-full p-2 w-8 h-8 border">
                  <Icon className={`${iconColor} pl-1 pt-1`} name={section.icon} />
                </div>
              }}
              <RenderIf condition={sectionIndex != sections->Array.length - 1}>
                <div
                  className={`absolute top-8 ${sectionLineHeight} left-4 border-l border-gray-150 z-0`}
                />
              </RenderIf>
              <div className={stepNameIndicator}> {section.name->React.string} </div>
            </div>
            <div className="flex flex-col gap-y-2.5">
              <RenderIf condition={isCurrentStep}>
                {switch section.subSections {
                | Some(subSections) =>
                  subSections
                  ->Array.mapWithIndex((subSection, subSectionIndex) => {
                    switch currentStep.subSectionId {
                    | Some(subSectionId) => {
                        let subStepIndex = subSections->findSubSectionIndex(subSectionId)

                        let isSubStepCompleted = isStepCompleted || subSectionIndex < subStepIndex
                        let isCurrentSubStep = subSectionIndex == subStepIndex && isCurrentStep
                        let subSectionLineHeight = isCurrentSubStep ? "h-7" : "h-6"

                        let subStepNameIndicator = if isCurrentSubStep {
                          "text-blue-500 break-all font-semibold text-base pl-5"
                        } else {
                          "text-gray-400 break-all text-base font-medium pl-5"
                        }

                        <div
                          key={subSection.id}
                          className="flex gap-x-3 items-center p-2 rounded relative z-10">
                          <div className="h-4 w-4 flex items-center justify-center rounded">
                            {if isSubStepCompleted {
                              <Icon name="nd-small-check" customHeight="12" />
                            } else if isCurrentSubStep {
                              <Icon name="nd-radio" className="text-blue-500" customHeight="8" />
                            } else {
                              <Icon name="nd-radio" className="text-gray-500" customHeight="8" />
                            }}
                          </div>
                          <div className={subStepNameIndicator}>
                            {subSection.name->React.string}
                          </div>
                          <RenderIf
                            condition={sectionIndex != sections->Array.length - 1 ||
                              subSectionIndex != subSections->Array.length - 1}>
                            <div
                              className={`absolute top-7 left-4 ${subSectionLineHeight} border-l border-gray-150 z-0`}
                            />
                          </RenderIf>
                        </div>
                      }
                    | None => React.null
                    }
                  })
                  ->React.array
                | None => React.null
                }}
              </RenderIf>
            </div>
          </div>
        })
        ->React.array}
      </div>
    </div>
  </div>
}
