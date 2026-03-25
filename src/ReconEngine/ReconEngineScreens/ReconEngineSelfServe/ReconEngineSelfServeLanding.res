@react.component
let make = (~onSelectMode) => {
  open ReconEngineSelfServeTypes

  <div className="flex flex-col items-center justify-center min-h-[70vh] gap-10 px-4">
    // Header
    <div className="text-center max-w-2xl">
      <h1 className="text-2xl font-semibold text-gray-900 mb-3">
        {"Set Up Your Reconciliation"->React.string}
      </h1>
      <p className="text-gray-500 text-base leading-relaxed">
        {"Connect your data sources, define how your data maps, and set up matching rules to automatically reconcile transactions across accounts."->React.string}
      </p>
    </div>
    // Pipeline visualization with descriptions
    <div className="w-full max-w-3xl">
      <div className="flex items-start justify-between relative">
        // Connecting line
        <div
          className="absolute top-5 left-[12%] right-[12%] h-0.5 bg-gradient-to-r from-blue-200 via-purple-200 to-green-200"
        />
        {[
          ("1", "Accounts", "Create accounts for each data source (e.g., PSP, Bank)", "bg-blue-50 border-blue-200 text-blue-700"),
          ("2", "Ingestion", "Configure how data enters — manual upload, webhook, or SFTP", "bg-indigo-50 border-indigo-200 text-indigo-700"),
          ("3", "Transformation", "Map CSV columns to system fields and define the schema", "bg-purple-50 border-purple-200 text-purple-700"),
          ("4", "Rules", "Define how entries from different accounts get matched", "bg-green-50 border-green-200 text-green-700"),
        ]
        ->Array.map(((num, title, desc, colors)) =>
          <div key={num} className="flex flex-col items-center text-center w-1/4 relative z-10">
            <div
              className={`w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold border-2 ${colors} bg-white mb-2`}>
              {num->React.string}
            </div>
            <p className="text-sm font-semibold text-gray-800 mb-1"> {title->React.string} </p>
            <p className="text-[11px] text-gray-500 leading-tight px-2">
              {desc->React.string}
            </p>
          </div>
        )
        ->React.array}
      </div>
    </div>
    // Mode selection cards
    <div className="flex gap-6 w-full max-w-3xl">
      // Guided Setup Card
      <div
        className="flex-1 border-2 border-gray-200 rounded-xl p-6 cursor-pointer hover:border-blue-400 hover:shadow-lg transition-all duration-200 group relative overflow-hidden"
        onClick={_ => onSelectMode(GuidedSetup)}>
        // Recommended badge
        <div
          className="absolute top-0 right-0 bg-blue-600 text-white text-[10px] font-bold px-3 py-1 rounded-bl-lg">
          {"RECOMMENDED"->React.string}
        </div>
        <div
          className="w-12 h-12 rounded-xl bg-blue-50 flex items-center justify-center mb-4 group-hover:bg-blue-100 transition-colors">
          <span className="text-blue-600 text-xl"> {`\u{1F9ED}`->React.string} </span>
        </div>
        <h3 className="text-lg font-semibold text-gray-900 mb-2">
          {"Guide me through setup"->React.string}
        </h3>
        <p className="text-sm text-gray-500 mb-5 leading-relaxed">
          {"Step-by-step wizard that walks you through each stage. Best for first-time setup — we'll explain what everything means along the way."->React.string}
        </p>
        <ul className="text-xs text-gray-500 space-y-1.5 mb-5">
          <li className="flex items-center gap-2">
            <span className="text-green-500"> {`\u{2713}`->React.string} </span>
            {"Progressive step-by-step flow"->React.string}
          </li>
          <li className="flex items-center gap-2">
            <span className="text-green-500"> {`\u{2713}`->React.string} </span>
            {"Contextual guidance at each step"->React.string}
          </li>
          <li className="flex items-center gap-2">
            <span className="text-green-500"> {`\u{2713}`->React.string} </span>
            {"Data flows automatically between steps"->React.string}
          </li>
        </ul>
        <div
          className="flex items-center gap-2 text-sm text-blue-600 font-semibold group-hover:gap-3 transition-all">
          {"Start guided setup"->React.string}
          <span> {`\u{2192}`->React.string} </span>
        </div>
      </div>
      // Expert Setup Card
      <div
        className="flex-1 border-2 border-gray-200 rounded-xl p-6 cursor-pointer hover:border-gray-400 hover:shadow-lg transition-all duration-200 group"
        onClick={_ => onSelectMode(ExpertSetup)}>
        <div
          className="w-12 h-12 rounded-xl bg-gray-50 flex items-center justify-center mb-4 group-hover:bg-gray-100 transition-colors">
          <span className="text-gray-600 text-xl"> {`\u{2699}\u{FE0F}`->React.string} </span>
        </div>
        <h3 className="text-lg font-semibold text-gray-900 mb-2">
          {"I know what I'm doing"->React.string}
        </h3>
        <p className="text-sm text-gray-500 mb-5 leading-relaxed">
          {"Jump between any section freely. All configuration options exposed in a tabbed interface. For users already familiar with reconciliation concepts."->React.string}
        </p>
        <ul className="text-xs text-gray-500 space-y-1.5 mb-5">
          <li className="flex items-center gap-2">
            <span className="text-gray-400"> {`\u{2022}`->React.string} </span>
            {"Non-linear — configure in any order"->React.string}
          </li>
          <li className="flex items-center gap-2">
            <span className="text-gray-400"> {`\u{2022}`->React.string} </span>
            {"All options visible at once"->React.string}
          </li>
          <li className="flex items-center gap-2">
            <span className="text-gray-400"> {`\u{2022}`->React.string} </span>
            {"For experienced reconciliation users"->React.string}
          </li>
        </ul>
        <div
          className="flex items-center gap-2 text-sm text-gray-600 font-semibold group-hover:gap-3 transition-all">
          {"Open configuration"->React.string}
          <span> {`\u{2192}`->React.string} </span>
        </div>
      </div>
    </div>
  </div>
}
