open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

@react.component
let make = (~currentStep: selfServeStep, ~state: selfServeState, ~onStepClick) => {
  let steps = [AccountSetup, IngestionSetup, TransformationSetup, RuleSetup]

  <div className="flex flex-col w-72 pr-6 border-r border-gray-200 min-h-[60vh]">
    <h2 className="text-xs font-semibold text-gray-400 uppercase tracking-widest mb-5 px-3">
      {"Setup Progress"->React.string}
    </h2>
    <div className="flex flex-col">
      {steps
      ->Array.mapWithIndex((step, index) => {
        let stepNum = step->getStepNumber
        let currentStepNum = currentStep->getStepNumber
        let isActive = step === currentStep
        let isCompleted = step->isStepComplete(state)
        let isPast = stepNum < currentStepNum
        let isClickable = isPast || isCompleted
        let isLast = index === steps->Array.length - 1

        <div key={stepNum->Int.toString} className="flex flex-col">
          <div
            className={`flex items-start gap-3 px-3 py-3 rounded-lg transition-all duration-200 ${isClickable
                ? "cursor-pointer"
                : "cursor-default"} ${isActive
                ? "bg-blue-50 border border-blue-200 shadow-sm"
                : isClickable
                ? "hover:bg-gray-50"
                : ""}`}
            onClick={_ =>
              if isClickable {
                onStepClick(step)
              }}>
            // Step circle
            <div
              className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0 transition-all duration-300 ${if isCompleted ||
                  isPast {
                  "bg-green-500 text-white shadow-sm"
                } else if isActive {
                  "bg-blue-600 text-white shadow-md ring-4 ring-blue-100"
                } else {
                  "bg-gray-100 text-gray-400 border border-gray-200"
                }}`}>
              {if isCompleted || isPast {
                <span className="text-sm"> {`\u{2713}`->React.string} </span>
              } else {
                stepNum->Int.toString->React.string
              }}
            </div>
            // Step text
            <div className="flex flex-col gap-0.5 pt-0.5">
              <span
                className={`text-sm font-semibold ${if isActive {
                    "text-blue-700"
                  } else if isPast || isCompleted {
                    "text-gray-800"
                  } else {
                    "text-gray-400"
                  }}`}>
                {step->getStepTitle->React.string}
              </span>
              <span
                className={`text-xs leading-relaxed ${isActive
                    ? "text-blue-600"
                    : "text-gray-400"}`}>
                {step->getStepDescription->React.string}
              </span>
            </div>
          </div>
          // Connecting line
          <RenderIf condition={!isLast}>
            <div className="flex justify-start pl-[22px] py-0.5">
              <div
                className={`w-0.5 h-4 rounded-full ${if isPast || isCompleted {
                    "bg-green-300"
                  } else if isActive {
                    "bg-blue-200"
                  } else {
                    "bg-gray-200"
                  }}`}
              />
            </div>
          </RenderIf>
        </div>
      })
      ->React.array}
    </div>
    // Live summary at bottom
    <div className="mt-auto pt-6 px-3 border-t border-gray-100">
      <h3 className="text-xs font-semibold text-gray-400 uppercase mb-3">
        {"Created so far"->React.string}
      </h3>
      <div className="flex flex-col gap-2 text-xs">
        <div className="flex justify-between">
          <span className="text-gray-500"> {"Accounts"->React.string} </span>
          <span
            className={`font-semibold ${state.accounts->Array.length >= 2
                ? "text-green-600"
                : "text-gray-400"}`}>
            {state.accounts->Array.length->Int.toString->React.string}
          </span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-500"> {"Ingestion Sources"->React.string} </span>
          <span
            className={`font-semibold ${state.ingestions->Array.length > 0
                ? "text-green-600"
                : "text-gray-400"}`}>
            {state.ingestions->Array.length->Int.toString->React.string}
          </span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-500"> {"Transformations"->React.string} </span>
          <span
            className={`font-semibold ${state.transformations->Array.length > 0
                ? "text-green-600"
                : "text-gray-400"}`}>
            {state.transformations->Array.length->Int.toString->React.string}
          </span>
        </div>
      </div>
    </div>
  </div>
}
