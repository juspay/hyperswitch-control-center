@react.component
let make = (~ruleDetails: ReconEngineRulesTypes.rulePayload) => {
  <div className="flex flex-col gap-8 mt-8">
    <ReconEngineOverviewDetailsStatCards ruleDetails />
    <ReconEngineOverviewAccountDetails ruleDetails />
    <ReconEngineOverviewDetailsReconciliationVolume ruleDetails />
    <ReconEngineOverviewTransactions ruleDetails />
  </div>
}
