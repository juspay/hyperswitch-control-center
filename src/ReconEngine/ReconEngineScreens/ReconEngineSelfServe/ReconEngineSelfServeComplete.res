open ReconEngineSelfServeTypes

@react.component
let make = (~state: selfServeState) => {
  <div className="flex flex-col items-center justify-center min-h-[50vh] gap-6 px-4">
    <div
      className="w-16 h-16 rounded-full bg-green-100 flex items-center justify-center text-2xl">
      <span> {`\u{2713}`->React.string} </span>
    </div>
    <div className="text-center max-w-lg">
      <h1 className="text-2xl font-semibold text-gray-900 mb-2">
        {"Setup Complete!"->React.string}
      </h1>
      <p className="text-gray-500">
        {"Your reconciliation pipeline is configured. You can now upload data files and start reconciling transactions."->React.string}
      </p>
    </div>
    // Summary
    <div className="w-full max-w-md border border-gray-200 rounded-lg p-5">
      <h3 className="text-sm font-semibold text-gray-700 mb-4">
        {"Configuration Summary"->React.string}
      </h3>
      <div className="flex flex-col gap-3">
        <div className="flex justify-between items-center">
          <span className="text-sm text-gray-600"> {"Accounts"->React.string} </span>
          <span className="text-sm font-medium text-gray-900">
            {state.accounts->Array.length->Int.toString->React.string}
          </span>
        </div>
        <div className="border-t border-gray-100" />
        <div className="flex justify-between items-center">
          <span className="text-sm text-gray-600"> {"Ingestion Sources"->React.string} </span>
          <span className="text-sm font-medium text-gray-900">
            {state.ingestions->Array.length->Int.toString->React.string}
          </span>
        </div>
        <div className="border-t border-gray-100" />
        <div className="flex justify-between items-center">
          <span className="text-sm text-gray-600"> {"Transformations"->React.string} </span>
          <span className="text-sm font-medium text-gray-900">
            {state.transformations->Array.length->Int.toString->React.string}
          </span>
        </div>
        <div className="border-t border-gray-100" />
        <div className="flex justify-between items-center">
          <span className="text-sm text-gray-600"> {"Recon Rules"->React.string} </span>
          <span className="text-sm font-medium text-green-700"> {"Created"->React.string} </span>
        </div>
      </div>
    </div>
    // Action buttons
    <div className="flex gap-3">
      <button
        type_="button"
        onClick={_ =>
          RescriptReactRouter.replace(
            GlobalVars.appendDashboardPath(~url="/v1/recon-engine/sources"),
          )}
        className="px-5 py-2.5 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors">
        {"Upload Data Files"->React.string}
      </button>
      <button
        type_="button"
        onClick={_ =>
          RescriptReactRouter.replace(
            GlobalVars.appendDashboardPath(~url="/v1/recon-engine/overview"),
          )}
        className="px-5 py-2.5 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors">
        {"Go to Overview"->React.string}
      </button>
    </div>
  </div>
}
