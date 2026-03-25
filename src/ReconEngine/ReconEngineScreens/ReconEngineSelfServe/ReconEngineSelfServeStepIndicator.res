open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

@react.component
let make = (~currentStep: selfServeStep, ~state: selfServeState, ~onStepClick) => {
  let steps = [AccountSetup, IngestionSetup, TransformationSetup, RuleSetup]

  <div className="flex flex-col gap-1 w-64 pr-6 border-r border-gray-200 min-h-[60vh]">
    <h2 className="text-sm font-semibold text-gray-400 uppercase tracking-wider mb-4 px-3">
      {"Setup Progress"->React.string}
    </h2>
    {steps
    ->Array.map(step => {
      let stepNum = step->getStepNumber
      let currentStepNum = currentStep->getStepNumber
      let isActive = step === currentStep
      let isCompleted = step->isStepComplete(state)
      let isPast = stepNum < currentStepNum
      let isClickable = isPast || isCompleted

      <div
        key={stepNum->Int.toString}
        className={`flex items-start gap-3 px-3 py-3 rounded-lg cursor-${isClickable
            ? "pointer"
            : "default"} ${isActive
            ? "bg-blue-50 border border-blue-200"
            : "hover:bg-gray-50"} transition-colors`}
        onClick={_ =>
          if isClickable {
            onStepClick(step)
          }}>
        <div
          className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-semibold flex-shrink-0 mt-0.5 ${if isCompleted || isPast {
              "bg-green-100 text-green-700"
            } else if isActive {
              "bg-blue-600 text-white"
            } else {
              "bg-gray-100 text-gray-400"
            }}`}>
          {if isCompleted || isPast {
            <span> {`\u{2713}`->React.string} </span>
          } else {
            stepNum->Int.toString->React.string
          }}
        </div>
        <div className="flex flex-col gap-0.5">
          <span
            className={`text-sm font-medium ${if isActive {
                "text-blue-700"
              } else if isPast || isCompleted {
                "text-gray-700"
              } else {
                "text-gray-400"
              }}`}>
            {step->getStepTitle->React.string}
          </span>
          {if isActive {
            <span className="text-xs text-gray-500">
              {step->getStepDescription->React.string}
            </span>
          } else {
            React.null
          }}
        </div>
      </div>
    })
    ->React.array}
  </div>
}
