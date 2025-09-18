@react.component
let make = (~ruleDetails: ReconEngineTypes.reconRuleType) => {
  <div className="flex flex-col gap-8 mt-8">
    <ReconEngineOverviewStackedBarGraph ruleDetails />
    <ReconEngineOverviewColumnGraphs ruleDetails />
    <ReconEngineOverviewAccountDetails ruleDetails />
    <ReconEngineOverviewTransactions ruleDetails />
  </div>
}
