open Typography
open LogicUtils
open ExplorerTypes
open ExplorerUtils
open ExplorerSelection
open ExplorerDescriptions
open ExplorerViewsEntity
open ExplorerViewsHelper
open NewAnalyticsHelper

@react.component
let make = (~selection: selection, ~dataset: dataset, ~onUpdate: Dict.t<string> => unit) => {
  let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
  let labelFor = (key, value) => getDimensionValueLabel(key, value, ~profileList)
  let grouping = selection.split->getGrouping
  let title = selection->viewTitle(~currency=dataset.amountCurrency)
  let setView = view => [(#view, view)]->selectionUpdate->onUpdate

  <div className="rounded-xl border border-nd_br_gray-200 bg-nd_gray-0">
    <div
      className="flex flex-wrap items-center justify-between gap-3 border-b border-nd_br_gray-150 px-5 py-3">
      <div className="flex flex-col">
        <div className={`${body.lg.semibold} text-nd_gray-800`}> {title->React.string} </div>
        <div className={`${body.sm.regular} text-nd_gray-500`}>
          {`${periodLabel(
              selection.startTime,
              selection.endTime,
            )} · ${selection->viewNote}`->React.string}
        </div>
      </div>
      <ViewTabs view=selection.view onViewChange=setView />
    </div>
    <div className="px-3 py-4">
      {switch (selection.view, grouping) {
      | (#trend | #breakdown | #table, Split) if dataset.groups->isEmptyArray =>
        <NoData
          height="h-32" message="No groups have a value for this measure in the selected dates."
        />
      | (#table, Split) =>
        <ViewTable
          title
          rows={getGroupRows(selection, dataset, ~labelFor)}
          entity={selection->getGroupTableEntity(~currency=dataset.amountCurrency)}
          visibleColumns={selection->getGroupColumns}
        />
      | (#table, Overall) =>
        <ViewTable
          title
          rows={getOutcomeRows(selection, dataset)}
          entity={selection.source->getOutcomeTableEntity}
          visibleColumns=outcomeColumns
        />
      | (#trend | #mix | #breakdown, _) => <ExplorerCharts selection dataset labelFor />
      }}
    </div>
    <RenderIf condition={grouping == Split && dataset.unmeasured->isNonEmptyArray}>
      <UnmeasuredNote selection dataset labelFor />
    </RenderIf>
  </div>
}
