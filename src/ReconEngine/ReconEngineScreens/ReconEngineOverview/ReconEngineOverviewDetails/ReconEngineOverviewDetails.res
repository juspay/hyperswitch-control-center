@react.component
let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
  <div className="flex flex-col gap-8">
    <ReconEngineOverviewCardDetails ruleDetails />
    <ReconEngineOverviewStackedBarGraph ruleDetails />
    <ReconEngineOverviewLineGraph ruleDetails />
    <ReconEngineOverviewTransactions ruleDetails />
  </div>
}
