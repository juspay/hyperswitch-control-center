@react.component
let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
  <div className="flex flex-col gap-8 mt-8">
    <ReconEngineOverviewStackedBarGraph ruleDetails />
    <ReconEngineOverviewColumnGraphs ruleDetails />
    <ReconEngineOverviewTransactions ruleDetails />
  </div>
}
