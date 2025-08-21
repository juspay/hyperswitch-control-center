@react.component
let make = (~reconRulesList) => {
  <div className="flex flex-col gap-8 mt-8">
    <ReconEngineOverviewSummaryStackedBarGraphs reconRulesList />
    <ReconEngineOverviewSummaryAccountsView />
  </div>
}
