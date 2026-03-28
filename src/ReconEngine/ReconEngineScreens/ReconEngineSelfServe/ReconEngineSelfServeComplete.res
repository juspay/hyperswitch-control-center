open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

@react.component
let make = (~wizardState: wizardState) => {
  <div className="flex flex-col items-center justify-center min-h-[60vh] gap-8 px-6">
    // Success icon
    <div className="w-16 h-16 rounded-full bg-green-50 flex items-center justify-center">
      <Icon name="nd-check" customHeight="32" className="text-green-500" />
    </div>
    // Header
    <div className="flex flex-col items-center gap-2 text-center max-w-lg">
      <h1 className="text-2xl font-semibold text-nd_gray-800">
        {"Reconciliation Setup Complete!"->React.string}
      </h1>
      <p className="text-sm text-nd_gray-500 leading-relaxed">
        {"Your recon engine is configured and ready to process transactions. Upload your CSV files through the Sources page to start reconciling."->React.string}
      </p>
    </div>
    // Summary cards
    <div className="grid grid-cols-2 gap-4 w-full max-w-xl">
      // Accounts summary
      <div className="flex flex-col gap-3 p-4 rounded-xl border border-nd_gray-200 bg-white">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center">
            <span className="text-sm font-semibold text-blue-600">
              {wizardState.accounts->Array.length->Int.toString->React.string}
            </span>
          </div>
          <span className="text-sm font-semibold text-nd_gray-700">
            {"Accounts"->React.string}
          </span>
        </div>
        <div className="flex flex-col gap-1">
          {wizardState.accounts
          ->Array.map(account => {
            let badgeColor =
              isCreditAccount(account)
                ? "bg-blue-50 text-blue-600"
                : "bg-green-50 text-green-600"
            <div key={account.account_id} className="flex items-center gap-2">
              <span className={`text-xs px-2 py-0.5 rounded-full ${badgeColor}`}>
                {account.account_type->React.string}
              </span>
              <span className="text-xs text-nd_gray-600">
                {account.account_name->React.string}
              </span>
            </div>
          })
          ->React.array}
        </div>
      </div>
      // Ingestions summary
      <div className="flex flex-col gap-3 p-4 rounded-xl border border-nd_gray-200 bg-white">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center">
            <span className="text-sm font-semibold text-blue-600">
              {wizardState.ingestions->Array.length->Int.toString->React.string}
            </span>
          </div>
          <span className="text-sm font-semibold text-nd_gray-700">
            {"Data Sources"->React.string}
          </span>
        </div>
        <div className="flex flex-col gap-1">
          {wizardState.ingestions
          ->Array.map(ing =>
            <div key={ing.ingestion_id} className="text-xs text-nd_gray-600">
              {ing.name->React.string}
            </div>
          )
          ->React.array}
        </div>
      </div>
      // Transformations summary
      <div className="flex flex-col gap-3 p-4 rounded-xl border border-nd_gray-200 bg-white">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center">
            <span className="text-sm font-semibold text-blue-600">
              {wizardState.transformations->Array.length->Int.toString->React.string}
            </span>
          </div>
          <span className="text-sm font-semibold text-nd_gray-700">
            {"Column Mappings"->React.string}
          </span>
        </div>
        <div className="flex flex-col gap-1">
          {wizardState.transformations
          ->Array.map(t =>
            <div key={t.transformation_id} className="text-xs text-nd_gray-600">
              {t.name->React.string}
            </div>
          )
          ->React.array}
        </div>
      </div>
      // Rules summary
      <div className="flex flex-col gap-3 p-4 rounded-xl border border-nd_gray-200 bg-white">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center">
            <span className="text-sm font-semibold text-blue-600">
              {wizardState.rules->Array.length->Int.toString->React.string}
            </span>
          </div>
          <span className="text-sm font-semibold text-nd_gray-700">
            {"Recon Rules"->React.string}
          </span>
        </div>
        <div className="flex flex-col gap-1">
          {wizardState.rules
          ->Array.map(rule =>
            <div key={rule.rule_id} className="text-xs text-nd_gray-600">
              {rule.rule_name->React.string}
            </div>
          )
          ->React.array}
        </div>
      </div>
    </div>
    // Next steps
    <div
      className="flex flex-col gap-3 w-full max-w-xl p-4 bg-blue-50 rounded-xl border border-blue-100">
      <p className="text-sm font-medium text-blue-700"> {"What's Next?"->React.string} </p>
      <div className="flex flex-col gap-2">
        <div className="flex items-start gap-2">
          <span className="text-xs font-semibold text-blue-600 mt-0.5"> {"1."->React.string} </span>
          <p className="text-xs text-blue-600">
            {"Go to Sources and upload your CSV files for each data source"->React.string}
          </p>
        </div>
        <div className="flex items-start gap-2">
          <span className="text-xs font-semibold text-blue-600 mt-0.5"> {"2."->React.string} </span>
          <p className="text-xs text-blue-600">
            {"The engine will automatically transform and process your entries"->React.string}
          </p>
        </div>
        <div className="flex items-start gap-2">
          <span className="text-xs font-semibold text-blue-600 mt-0.5"> {"3."->React.string} </span>
          <p className="text-xs text-blue-600">
            {"Check the Transactions page to see reconciliation results"->React.string}
          </p>
        </div>
      </div>
    </div>
    // Action buttons
    <div className="flex gap-3">
      <Button
        text="Go to Sources"
        buttonType=Primary
        buttonSize=Small
        onClick={_ =>
          RescriptReactRouter.replace(
            GlobalVars.appendDashboardPath(~url="/v1/recon-engine/sources"),
          )}
      />
      <Button
        text="View Transactions"
        buttonType=Secondary
        buttonSize=Small
        onClick={_ =>
          RescriptReactRouter.replace(
            GlobalVars.appendDashboardPath(~url="/v1/recon-engine/transactions"),
          )}
      />
    </div>
  </div>
}
