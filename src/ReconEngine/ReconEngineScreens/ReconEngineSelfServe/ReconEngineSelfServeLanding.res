@react.component
let make = () => {
  let navigateTo = url => RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url))

  <div className="flex flex-col items-center justify-center min-h-[70vh] gap-10 px-4 sm:px-6">
    // Header
    <div className="text-center max-w-2xl">
      <h1 className="text-2xl font-semibold text-nd_gray-800 mb-3">
        {"Set Up Your Reconciliation"->React.string}
      </h1>
      <p className="text-nd_gray-500 text-sm sm:text-base leading-relaxed">
        {"Connect your data sources, define how your data maps, and set up matching rules to automatically reconcile transactions across accounts."->React.string}
      </p>
    </div>
    // Pipeline visualization with numbered steps and descriptions
    <div className="w-full max-w-3xl hidden sm:block">
      <div className="flex items-start justify-between relative">
        // Connecting line
        <div
          className="absolute top-5 left-[12%] right-[12%] h-0.5 bg-gradient-to-r from-blue-200 via-blue-100 to-green-200"
        />
        {[
          (
            "1",
            "Accounts",
            "Create accounts for each data source (e.g., PSP, Bank)",
            "bg-blue-50 border-blue-200 text-blue-700",
          ),
          (
            "2",
            "Data Sources",
            "Configure how data enters — manual upload, webhook, or SFTP",
            "bg-blue-50 border-blue-200 text-blue-700",
          ),
          (
            "3",
            "Column Mapping",
            "Map CSV columns to system fields and define the schema",
            "bg-blue-50 border-blue-200 text-blue-700",
          ),
          (
            "4",
            "Rules",
            "Define how entries from different accounts get matched",
            "bg-green-50 border-green-200 text-green-700",
          ),
        ]
        ->Array.map(((num, title, desc, colors)) =>
          <div key={num} className="flex flex-col items-center text-center w-1/4 relative z-10">
            <div
              className={`w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold border-2 ${colors} bg-white mb-2`}>
              {num->React.string}
            </div>
            <p className="text-sm font-semibold text-nd_gray-800 mb-1"> {title->React.string} </p>
            <p className="text-[11px] text-nd_gray-500 leading-tight px-2">
              {desc->React.string}
            </p>
          </div>
        )
        ->React.array}
      </div>
    </div>
    // Mode selection cards
    <div className="flex flex-col sm:flex-row gap-4 sm:gap-6 w-full max-w-3xl">
      // Guided Setup Card
      <div
        className="flex-1 border-2 border-nd_gray-200 rounded-xl p-6 cursor-pointer hover:border-blue-400 hover:shadow-lg transition-all duration-200 group relative overflow-hidden"
        tabIndex=0
        role="button"
        onClick={_ => navigateTo("/v1/recon-engine/setup/guided")}
        onKeyDown={e =>
          if ReactEvent.Keyboard.key(e) === "Enter" || ReactEvent.Keyboard.key(e) === " " {
            ReactEvent.Keyboard.preventDefault(e)
            navigateTo("/v1/recon-engine/setup/guided")
          }}>
        // Recommended badge
        <div
          className="absolute top-0 right-0 bg-blue-600 text-white text-[10px] font-bold px-3 py-1 rounded-bl-lg">
          {"RECOMMENDED"->React.string}
        </div>
        <div
          className="w-12 h-12 rounded-xl bg-blue-50 flex items-center justify-center mb-4 group-hover:bg-blue-100 transition-colors">
          <Icon name="nd-overview" className="text-blue-600" customHeight="22" />
        </div>
        <h3 className="text-lg font-semibold text-nd_gray-900 mb-2">
          {"Guide me through setup"->React.string}
        </h3>
        <p className="text-sm text-nd_gray-500 mb-5 leading-relaxed">
          {"Step-by-step wizard that walks you through each stage. Best for first-time setup — we'll explain what everything means along the way."->React.string}
        </p>
        <div className="flex flex-col gap-1.5 mb-5">
          <div className="flex items-center gap-2 text-xs text-nd_gray-500">
            <Icon name="nd-check" customHeight="10" className="text-green-500" />
            {"Progressive step-by-step flow"->React.string}
          </div>
          <div className="flex items-center gap-2 text-xs text-nd_gray-500">
            <Icon name="nd-check" customHeight="10" className="text-green-500" />
            {"Contextual guidance at each step"->React.string}
          </div>
          <div className="flex items-center gap-2 text-xs text-nd_gray-500">
            <Icon name="nd-check" customHeight="10" className="text-green-500" />
            {"Data flows automatically between steps"->React.string}
          </div>
        </div>
        <div
          className="flex items-center gap-2 text-sm text-blue-600 font-semibold group-hover:gap-3 transition-all">
          {"Start guided setup"->React.string}
          <Icon name="nd-arrow-right" customHeight="12" />
        </div>
      </div>
      // Expert Setup Card
      <div
        className="flex-1 border-2 border-nd_gray-200 rounded-xl p-6 cursor-pointer hover:border-nd_gray-400 hover:shadow-lg transition-all duration-200 group"
        tabIndex=0
        role="button"
        onClick={_ => navigateTo("/v1/recon-engine/setup/expert")}
        onKeyDown={e =>
          if ReactEvent.Keyboard.key(e) === "Enter" || ReactEvent.Keyboard.key(e) === " " {
            ReactEvent.Keyboard.preventDefault(e)
            navigateTo("/v1/recon-engine/setup/expert")
          }}>
        <div
          className="w-12 h-12 rounded-xl bg-nd_gray-100 flex items-center justify-center mb-4 group-hover:bg-nd_gray-200 transition-colors">
          <Icon name="nd-reports" className="text-nd_gray-600" customHeight="22" />
        </div>
        <h3 className="text-lg font-semibold text-nd_gray-900 mb-2">
          {"I know what I'm doing"->React.string}
        </h3>
        <p className="text-sm text-nd_gray-500 mb-5 leading-relaxed">
          {"Jump between any section freely. All configuration options exposed in a tabbed interface. For users already familiar with reconciliation concepts."->React.string}
        </p>
        <div className="flex flex-col gap-1.5 mb-5">
          <div className="flex items-center gap-2 text-xs text-nd_gray-500">
            <span className="text-nd_gray-400 text-sm"> {"•"->React.string} </span>
            {"Non-linear — configure in any order"->React.string}
          </div>
          <div className="flex items-center gap-2 text-xs text-nd_gray-500">
            <span className="text-nd_gray-400 text-sm"> {"•"->React.string} </span>
            {"All options visible at once"->React.string}
          </div>
          <div className="flex items-center gap-2 text-xs text-nd_gray-500">
            <span className="text-nd_gray-400 text-sm"> {"•"->React.string} </span>
            {"For experienced reconciliation users"->React.string}
          </div>
        </div>
        <div
          className="flex items-center gap-2 text-sm text-nd_gray-600 font-semibold group-hover:gap-3 transition-all">
          {"Open configuration"->React.string}
          <Icon name="nd-arrow-right" customHeight="12" />
        </div>
      </div>
    </div>
  </div>
}
