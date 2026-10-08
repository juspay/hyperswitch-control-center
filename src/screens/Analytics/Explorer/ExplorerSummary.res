open Typography
open LogicUtils
open ExplorerTypes
open ExplorerSummaryUtils

@react.component
let make = (~viewContext: viewContext) =>
  <div className="flex flex-col gap-1.5 border-l-4 border-nd_primary_blue-400 pl-4">
    <div className={`${heading.sm.semibold} text-nd_gray-800`}>
      {viewContext->getHeadline->React.string}
    </div>
    <ExplorerHelper.OutcomeBar viewContext />
    {[viewContext->getCurrencyLine, viewContext->getSplitLine]
    ->Array.filter(isNonEmptyString)
    ->Array.map(line =>
      <div key=line className={`${body.md.regular} text-nd_gray-600`}> {line->React.string} </div>
    )
    ->React.array}
  </div>
