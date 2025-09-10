@react.component
let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
  <div className="flex flex-col gap-8 mt-8">
    <ReconEngineOverviewCardDetails ruleDetails />
    <ReconEngineOverviewStackedBarGraph ruleDetails />
    <ReconEngineOverviewColumnGraphs ruleDetails />
    <ReconEngineOverviewAccountDetails ruleDetails />
    <ReconEngineOverviewTransactions ruleDetails />
  </div>
}
