@react.component
let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
  <div className="flex flex-col gap-8">
    <ReconEngineOverviewCardDetails ruleDetails />
    <ReconEngineOverviewColumnGraphs ruleDetails />
    <ReconEngineOverviewTransactions ruleDetails />
  </div>
}
