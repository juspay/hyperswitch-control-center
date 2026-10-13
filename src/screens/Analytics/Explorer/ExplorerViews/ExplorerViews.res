open Typography
open LogicUtils
open ExplorerTypes
open ExplorerUtils
open ExplorerDescriptions
open ExplorerViewsEntity
open ExplorerViewsHelper

@react.component
let make = (~question: question, ~dataset: dataset) => {
  let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
  let labelFor = (key, value) => getDimensionValueLabel(key, value, ~profileList)
  let isSplit = question.split->isNonEmptyArray
  let title = question->viewTitle

  <div className="rounded-xl border border-nd_br_gray-200 bg-nd_gray-0">
    <div className="flex flex-col border-b border-nd_br_gray-150 px-5 py-3">
      <div className={`${body.lg.semibold} text-nd_gray-800`}> {title->React.string} </div>
      <div className={`${body.sm.regular} text-nd_gray-500`}>
        {`${periodLabel(
            question.startTime,
            question.endTime,
          )} · ${question->viewNote}`->React.string}
      </div>
    </div>
    <div className="px-3 py-4">
      <RenderIf condition=isSplit>
        <ViewTable
          title
          rows={getGroupRows(question, dataset, ~labelFor)}
          entity={question->getGroupTableEntity(~currency=dataset.amountCurrency)}
          visibleColumns={question->getGroupColumns}
        />
      </RenderIf>
      <RenderIf condition={!isSplit}>
        <ViewTable
          title
          rows={getOutcomeRows(question, dataset)}
          entity={question.source->getOutcomeTableEntity}
          visibleColumns=outcomeColumns
        />
      </RenderIf>
    </div>
    <RenderIf condition={isSplit && dataset.unmeasured->isNonEmptyArray}>
      <UnmeasuredNote question dataset labelFor />
    </RenderIf>
  </div>
}
