open Typography

@react.component
let make = (~reconRulesList) => {
  open ReconEngineOverviewSummaryHelper
  open ReconEngineOverviewSummaryTypes

  let (viewType, setViewType) = React.useState(_ => Graph)

  <div className="flex flex-col gap-8 mt-8">
    <ReconEngineOverviewSummaryStackedBarGraphs reconRulesList />
    <div className="flex flex-row justify-between items-center">
      <div className="flex flex-col gap-2">
        <p className={`text-nd_gray-800 ${heading.sm.semibold}`}>
          {"Accounts View"->React.string}
        </p>
        <p className={`text-nd_gray-500 ${body.md.medium}`}>
          {"Quickly assess reconciliation health across your accounts, highlighting matched, pending and mismatched transactions"->React.string}
        </p>
      </div>
      <TabSwitch viewType setViewType />
    </div>
    {switch viewType {
    | Table => <ReconEngineOverviewSummaryAccountsView reconRulesList />
    | Graph => <ReconEngineOverviewSummaryFlowDiagram reconRulesList />
    }}
  </div>
}
