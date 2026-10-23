open Typography
open LogicUtils
open ExplorerTypes
open ExplorerDescriptions
open ExplorerSummaryUtils

module OutcomeBar = {
  @react.component
  let make = (~context: chartContext, ~chartKey) => {
    let {selection, dataset} = context
    <div className="flex flex-col gap-1 pt-2">
      <div className={`${body.sm.medium} uppercase text-nd_gray-400`}>
        {`${dataset.overall.total->formatNumberWithCommas} ${sourceNoun(
            selection.source,
          )} by outcome`->React.string}
      </div>
      <StackedBarGraph
        key={`summary|${chartKey}`}
        options={StackedBarGraphUtils.getStackedBarGraphOptions(
          {
            categories: [sourceNoun(selection.source)],
            data: context->getOutcomeParts->Array.toReversed,
            labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Volume),
          },
          ~yMax=dataset.overall.total->Float.toInt,
          ~labelItemDistance=32,
          ~pointWidth=16,
        )}
      />
      <RenderIf condition={context->isExcludedFromRate}>
        <div className={`${body.sm.regular} text-nd_gray-500`}>
          {`Payments awaiting customer or merchant action are excluded from the ${measureLabel(
              selection.source,
              selection.measure,
            )->String.toLowerCase}.`->React.string}
        </div>
      </RenderIf>
    </div>
  }
}
