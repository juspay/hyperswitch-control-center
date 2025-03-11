open VerticalStepIndicatorTypes
open IntelligentRoutingTypes

let fileTypes = [Sample, Upload]

let sections = [
  {
    id: "analyze",
    name: "Analyze Your Transaction History",
    icon: "nd-shield",
    subSections: None,
  },
  {
    id: "review",
    name: "Review Data Summary",
    icon: "nd-flag",
    subSections: None,
  },
]

let getFileTypeHeading = fileType => {
  switch fileType {
  | Sample => "Try our sample file"
  | Upload => "Upload File"
  }
}

let getFileTypeDescription = fileType => {
  switch fileType {
  | Sample => "Use our pre-generated sample file"
  | Upload => "This feature is available in production only"
  }
}

let getFileTypeIconName = fileType => {
  switch fileType {
  | Sample => "SAMPLEFILE"
  | Upload => "UPLOADFILE"
  }
}

module StepCard = {
  @react.component
  let make = (~stepName, ~description, ~isSelected, ~onClick, ~iconName, ~isDisabled=false) => {
    let ringClass = switch isSelected {
    | true => "border-blue-811 ring-blue-811/20 ring-offset-0 ring-2"
    | false => "ring-grey-outline"
    }
    <div
      key={stepName}
      className={`flex items-center gap-x-2.5 border ${ringClass} rounded-lg p-4 transition-shadow  ${isDisabled
          ? "opacity-50"
          : "cursor-pointer"} justify-between`}
      onClick={!isDisabled ? onClick : _ => ()}>
      <div className="flex items-center gap-x-2.5">
        <img alt={iconName} src={`/IntelligentRouting/${iconName}.svg`} className="w-8 h-8" />
        <div className="flex flex-col gap-1">
          <h3 className="text-medium font-medium text-grey-900"> {stepName->React.string} </h3>
          <p className="text-sm text-gray-500"> {description->React.string} </p>
        </div>
      </div>
      {switch isSelected {
      | true => <Icon name="blue-circle" customHeight="20" />
      | false => <Icon name="hollow-circle" customHeight="20" />
      }}
    </div>
  }
}
