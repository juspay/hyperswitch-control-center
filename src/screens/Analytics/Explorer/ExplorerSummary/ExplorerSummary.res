open Typography
open LogicUtils
open ExplorerTypes
open ExplorerSelection
open ExplorerSummaryUtils
open ExplorerSummaryHelper

@react.component
let make = (~selection: selection, ~dataset: dataset, ~labelFor) => {
  let context: chartContext = {selection, dataset, labelFor}
  let chartKey = [selection->requestKey, (selection.flow :> string)]->Array.joinWith("|")
  <div className="flex flex-col gap-1.5 border-l-4 border-nd_primary_blue-400 pl-4">
    <div className={`${heading.sm.semibold} text-nd_gray-800`}>
      {context->getHeadline->React.string}
    </div>
    <OutcomeBar context chartKey />
    {[CurrencyLine, SplitLine]
    ->Array.map(line => {
      let description = context->getSummaryLine(line)
      <RenderIf condition={description->isNonEmptyString}>
        <div key=description className={`${body.md.regular} text-nd_gray-600`}>
          {description->React.string}
        </div>
      </RenderIf>
    })
    ->React.array}
  </div>
}
