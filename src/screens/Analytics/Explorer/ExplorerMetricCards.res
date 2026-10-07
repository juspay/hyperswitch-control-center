open ExplorerTypes
open ExplorerUtils
open ExplorerData
open ExplorerDescriptions

let metricCardMeasures = question => {
  let offered = ExplorerCatalog.sourceConfig(question.source).measures
  [question.measure]->Array.concat(
    [SuccessRate, Volume, Successful, Failed]
    ->Array.filter(measure => measure != question.measure && offered->Array.includes(measure))
    ->Array.slice(~start=0, ~end=3),
  )
}

@react.component
let make = (~question: question, ~dataset: dataset) => {
  let source = question.source
  let hasPrevious = dataset.overallPrevious.total > 0.0
  <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-4">
    {question
    ->metricCardMeasures
    ->Array.mapWithIndex((measure, index) => {
      let current = getMeasureValue(source, measure, dataset.overall)
      let previous =
        hasPrevious && measurable(source, measure, dataset.overallPrevious)
          ? Some(getMeasureValue(source, measure, dataset.overallPrevious))
          : None
      let isMeasurable = measurable(source, measure, dataset.overall)
      <ExplorerHelper.MetricCard
        key={measure->measureToString}
        label={measureLabel(source, measure)}
        definition={measureDefinition(source, measure)}
        value={formatValue(source, measure, dataset.overall, ~currency=dataset.amountCurrency)}
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
