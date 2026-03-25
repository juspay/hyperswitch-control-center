@react.component
let make = (~onSelectMode) => {
  open ReconEngineSelfServeTypes

  <div className="flex flex-col items-center justify-center min-h-[70vh] gap-8 px-4">
    <div className="text-center max-w-2xl">
      <h1 className="text-2xl font-semibold text-gray-900 mb-3">
        {"Set Up Your Reconciliation"->React.string}
      </h1>
      <p className="text-gray-500 text-base">
        {"Connect your data sources, define how your data maps, and set up matching rules to automatically reconcile transactions."->React.string}
      </p>
    </div>
    <div className="flex gap-6 w-full max-w-3xl">
      // Guided Setup Card
      <div
        className="flex-1 border border-gray-200 rounded-xl p-6 cursor-pointer hover:border-blue-500 hover:shadow-md transition-all duration-200 group"
        onClick={_ => onSelectMode(GuidedSetup)}>
        <div
          className="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center mb-4 group-hover:bg-blue-100 transition-colors">
          <span className="text-blue-600 text-lg"> {`\u{1F9ED}`->React.string} </span>
        </div>
        <h3 className="text-lg font-semibold text-gray-900 mb-2">
          {"Guide me through setup"->React.string}
        </h3>
        <p className="text-sm text-gray-500 mb-4">
          {"Step-by-step wizard that walks you through creating accounts, configuring data sources, mapping fields, and setting up rules."->React.string}
        </p>
        <div className="flex items-center gap-2 text-sm text-blue-600 font-medium">
          {"Recommended for first-time setup"->React.string}
          <span> {`\u{2192}`->React.string} </span>
        </div>
      </div>
      // Expert Setup Card
      <div
        className="flex-1 border border-gray-200 rounded-xl p-6 cursor-pointer hover:border-gray-400 hover:shadow-md transition-all duration-200 group"
        onClick={_ => onSelectMode(ExpertSetup)}>
        <div
          className="w-10 h-10 rounded-lg bg-gray-50 flex items-center justify-center mb-4 group-hover:bg-gray-100 transition-colors">
          <span className="text-gray-600 text-lg"> {`\u{2699}\u{FE0F}`->React.string} </span>
        </div>
        <h3 className="text-lg font-semibold text-gray-900 mb-2">
          {"I know what I'm doing"->React.string}
        </h3>
        <p className="text-sm text-gray-500 mb-4">
          {"Separate configuration pages for each entity. Full control over every setting with all options exposed."->React.string}
        </p>
        <div className="flex items-center gap-2 text-sm text-gray-600 font-medium">
          {"For experienced users"->React.string}
          <span> {`\u{2192}`->React.string} </span>
        </div>
      </div>
    </div>
    // Pipeline diagram
    <div className="flex items-center gap-3 mt-4 text-sm text-gray-400">
      <div
        className="px-3 py-1.5 rounded-md bg-gray-50 text-gray-600 font-medium border border-gray-200">
        {"Accounts"->React.string}
      </div>
      <span> {`\u{2192}`->React.string} </span>
      <div
        className="px-3 py-1.5 rounded-md bg-gray-50 text-gray-600 font-medium border border-gray-200">
        {"Ingestion"->React.string}
      </div>
      <span> {`\u{2192}`->React.string} </span>
      <div
        className="px-3 py-1.5 rounded-md bg-gray-50 text-gray-600 font-medium border border-gray-200">
        {"Transformation"->React.string}
      </div>
      <span> {`\u{2192}`->React.string} </span>
      <div
        className="px-3 py-1.5 rounded-md bg-gray-50 text-gray-600 font-medium border border-gray-200">
        {"Rules"->React.string}
      </div>
    </div>
  </div>
}
