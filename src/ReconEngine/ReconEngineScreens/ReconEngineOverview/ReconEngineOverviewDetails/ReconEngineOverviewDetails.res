@react.component
let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
  open ReconEngineOverviewHelper

  <div className="flex flex-col gap-8">
    <OverviewCardDetails ruleDetails />
    <StackedBarGraph ruleDetails />
    <ReconRuleLineGraph ruleDetails />
    <ReconRuleTransactions ruleDetails />
  </div>
}
