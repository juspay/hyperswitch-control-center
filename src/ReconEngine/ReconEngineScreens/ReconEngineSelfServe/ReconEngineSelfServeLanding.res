open ReconEngineSelfServeTypes

@react.component
let make = () => {
  <div className="flex flex-col items-center justify-center min-h-[70vh] gap-10 px-6">
    // Header
    <div className="flex flex-col items-center gap-3 text-center max-w-2xl">
      <h1 className="text-2xl font-semibold text-nd_gray-800">
        {"Set Up Reconciliation"->React.string}
      </h1>
      <p className="text-sm text-nd_gray-500 leading-relaxed">
        {"Connect your data sources, map your columns, and define matching rules. The engine will automatically reconcile your transactions."->React.string}
      </p>
    </div>
    // Visual pipeline
    <div
      className="hidden sm:flex items-center gap-2 text-xs text-nd_gray-400 font-medium flex-wrap justify-center">
      <div
        className="flex items-center gap-1.5 px-3 py-1.5 bg-nd_gray-100 text-nd_gray-500 rounded-full">
        <Icon name="nd-connectors" customHeight="12" />
        {"Account"->React.string}
      </div>
      <Icon name="nd-arrow-right" customHeight="10" className="text-nd_gray-300" />
      <div
        className="flex items-center gap-1.5 px-3 py-1.5 bg-nd_gray-100 text-nd_gray-500 rounded-full">
        <Icon name="nd-connectors" customHeight="12" />
        {"Data Source"->React.string}
      </div>
      <Icon name="nd-arrow-right" customHeight="10" className="text-nd_gray-300" />
      <div
        className="flex items-center gap-1.5 px-3 py-1.5 bg-nd_gray-100 text-nd_gray-500 rounded-full">
        <Icon name="nd-connectors" customHeight="12" />
        {"Mapping"->React.string}
      </div>
      <Icon name="nd-arrow-right" customHeight="10" className="text-nd_gray-300" />
      <div
        className="flex items-center gap-1.5 px-3 py-1.5 bg-nd_gray-100 text-nd_gray-500 rounded-full">
        <Icon name="nd-reports" customHeight="12" />
        {"Rules"->React.string}
      </div>
    </div>
    // Mode selection cards
    <div className="flex flex-col sm:flex-row gap-4 sm:gap-6 w-full max-w-3xl">
      // Guided mode card
      <div
        className="flex-1 flex flex-col gap-4 p-6 rounded-xl border border-nd_gray-200 hover:border-blue-400 hover:shadow-md cursor-pointer transition-all duration-200 group"
        tabIndex=0
        role="button"
        onClick={_ => RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v1/recon-engine/setup/guided"))}
        onKeyDown={e =>
          if ReactEvent.Keyboard.key(e) === "Enter" || ReactEvent.Keyboard.key(e) === " " {
            ReactEvent.Keyboard.preventDefault(e)
            RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v1/recon-engine/setup/guided"))
          }}>
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center">
            <Icon name="nd-overview" className="text-blue-500" customHeight="20" />
          </div>
          <div className="flex flex-col">
            <h3
              className="text-base font-semibold text-nd_gray-800 group-hover:text-blue-600 transition-colors">
              {"Guide me through setup"->React.string}
            </h3>
            <p className="text-xs text-nd_gray-400">
              {"Recommended for first-time users"->React.string}
            </p>
          </div>
        </div>
        <p className="text-sm text-nd_gray-500 leading-relaxed">
          {"Step-by-step wizard that walks you through each stage of reconciliation setup with explanations and examples."->React.string}
        </p>
        <div className="flex items-center gap-2 text-xs text-nd_gray-400">
          <Icon name="nd-check" customHeight="10" className="text-green-500" />
          {"Visual progress tracking"->React.string}
          <span className="text-nd_gray-200"> {"|"->React.string} </span>
          <Icon name="nd-check" customHeight="10" className="text-green-500" />
          {"Contextual help"->React.string}
          <span className="text-nd_gray-200"> {"|"->React.string} </span>
          <Icon name="nd-check" customHeight="10" className="text-green-500" />
          {"Data flows between steps"->React.string}
        </div>
      </div>
      // Expert mode card
      <div
        className="flex-1 flex flex-col gap-4 p-6 rounded-xl border border-nd_gray-200 hover:border-nd_gray-400 hover:shadow-md cursor-pointer transition-all duration-200 group"
        tabIndex=0
        role="button"
        onClick={_ => RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v1/recon-engine/setup/expert"))}
        onKeyDown={e =>
          if ReactEvent.Keyboard.key(e) === "Enter" || ReactEvent.Keyboard.key(e) === " " {
            ReactEvent.Keyboard.preventDefault(e)
            RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v1/recon-engine/setup/expert"))
          }}>
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-lg bg-nd_gray-100 flex items-center justify-center">
            <Icon name="nd-reports" className="text-nd_gray-600" customHeight="20" />
          </div>
          <div className="flex flex-col">
            <h3
              className="text-base font-semibold text-nd_gray-800 group-hover:text-nd_gray-600 transition-colors">
              {"I know what I'm doing"->React.string}
            </h3>
            <p className="text-xs text-nd_gray-400"> {"For experienced users"->React.string} </p>
          </div>
        </div>
        <p className="text-sm text-nd_gray-500 leading-relaxed">
          {"Tabbed interface with all sections accessible. Create accounts, data sources, column mappings, and rules."->React.string}
        </p>
        <div className="flex items-center gap-2 text-xs text-nd_gray-400">
          <Icon name="nd-check" customHeight="10" className="text-green-500" />
          {"All sections at once"->React.string}
          <span className="text-nd_gray-200"> {"|"->React.string} </span>
          <Icon name="nd-check" customHeight="10" className="text-green-500" />
          {"Flexible order"->React.string}
          <span className="text-nd_gray-200"> {"|"->React.string} </span>
          <Icon name="nd-check" customHeight="10" className="text-green-500" />
          {"Inline guidance"->React.string}
        </div>
      </div>
    </div>
  </div>
}
