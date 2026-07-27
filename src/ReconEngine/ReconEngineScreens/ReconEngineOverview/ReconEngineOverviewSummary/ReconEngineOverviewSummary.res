open Typography

@react.component
let make = (~reconRulesList, ~onRuleClick) => {
  open ReconEngineOverviewSummaryHelper
  open ReconEngineOverviewSummaryTypes

  let (viewType, setViewType) = React.useState(_ => Graph)

  <div className="flex flex-col gap-4 mt-8 pb-40">
    <ReconEngineOverviewSummaryStatCards />
    <ReconEngineOverviewSummaryReconciliationVolume />
    <div className="flex flex-col lg:flex-row gap-4">
      <div className="w-full lg:w-2/5">
        <ReconEngineOverviewSummaryExceptionAging />
      </div>
      <div className="w-full lg:w-3/5">
        <ReconEngineOverviewSummaryExceptionTriage />
      </div>
    </div>
    <ReconEngineOverviewSummaryRulesActivity onRuleClick />
    <div className="flex flex-row justify-between items-center">
      <div className="flex flex-col gap-2">
        <p className={`text-nd_gray-800 ${heading.sm.semibold}`}>
          {"Account Balance Breakdown"->React.string}
        </p>
      </div>
      <div className="flex flex-row items-center gap-4">
        <TabSwitch viewType setViewType />
      </div>
    </div>
    {switch viewType {
    | Table => <ReconEngineOverviewSummaryAccountsView />
    | Graph => <ReconEngineOverviewSummaryFlowDiagram reconRulesList />
    }}
  </div>
}
