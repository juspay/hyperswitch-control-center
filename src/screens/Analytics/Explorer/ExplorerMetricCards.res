open ExplorerTypes
open ExplorerUtils
open ExplorerData
open ExplorerDescriptions

@react.component
let make = (~question: question, ~dataset: dataset) => {
  let source = question.source
  <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-4">
    {question
    ->metricCardMeasures
    ->Array.mapWithIndex((measure, index) => {
      let (counts, previousCounts) = dataset->getMeasureCounts(measure)
      let current = getMeasureValue(source, measure, counts)
      let previous =
        previousCounts.total > 0.0 && measurable(source, measure, previousCounts)
          ? Some(getMeasureValue(source, measure, previousCounts))
          : None
      let isMeasurable = measurable(source, measure, counts)
      <ExplorerHelper.MetricCard
        key={(measure :> string)}
        label={measureLabel(source, measure)}
        definition={measureDefinition(source, measure)}
        value={formatValue(source, measure, counts, ~currency=dataset.amountCurrency)}
        change={isMeasurable
          ? formatChange(measure, current, previous)
          : unmeasurableNote(source, measure)}
        impact={isMeasurable ? getChangeImpact(measure, current, previous) : Neutral}
        primary={index == 0}
      />
    })
    ->React.array}
  </div>
}
