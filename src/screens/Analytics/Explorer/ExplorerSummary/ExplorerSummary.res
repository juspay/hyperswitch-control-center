open Typography
open LogicUtils
open ExplorerTypes
open ExplorerSelection
open ExplorerSummaryUtils
open ExplorerSummaryHelper

@react.component
let make = (~selection: selection, ~dataset: dataset, ~labelFor) => {
  let context: chartContext = {selection, dataset, labelFor}
  let chartKey = [selection->requestKey, dataset.amountCurrency]->Array.joinWith("|")
  <div className="flex flex-col gap-1.5 border-l-4 border-nd_primary_blue-400 pl-4">
    <div className={`${heading.sm.semibold} text-nd_gray-800`}>
      {context->getHeadline->React.string}
    </div>
    <OutcomeBar context chartKey />
    {[context->getCurrencyLine, context->getSplitLine]
    ->Array.filter(isNonEmptyString)
    ->Array.map(line =>
      <div key=line className={`${body.md.regular} text-nd_gray-600`}> {line->React.string} </div>
    )
    ->React.array}
  </div>
}
