open ReconEngineSelfServeTypes
open VerticalStepIndicatorTypes

let sections: array<section> = [
  {
    id: "account",
    name: "Create Accounts",
    icon: "nd-connectors",
    subSections: None,
  },
  {
    id: "ingestion",
    name: "Connect Data Sources",
    icon: "nd-connectors",
    subSections: None,
  },
  {
    id: "transformation",
    name: "Map CSV Columns",
    icon: "nd-connectors",
    subSections: None,
  },
  {
    id: "rule",
    name: "Define Recon Rules",
    icon: "nd-reports",
    subSections: None,
  },
  {
    id: "complete",
    name: "Complete",
    icon: "nd-check",
    subSections: None,
  },
]

let stepToIndicatorStep = (step: selfServeStep): step => {
  {
    sectionId: step->ReconEngineSelfServeUtils.stepToString,
    subSectionId: None,
  }
}

@react.component
let make = (~currentStep: selfServeStep, ~onBack: unit => unit) => {
  let titleElement =
    <div className="flex items-center gap-2">
      <Icon name="nd-connectors" className="text-nd_gray-600" customHeight="20" />
      <h1 className="text-base font-semibold text-nd_gray-700"> {"Recon Setup"->React.string} </h1>
    </div>

  <VerticalStepIndicator
    titleElement sections currentStep={currentStep->stepToIndicatorStep} backClick=onBack
  />
}
