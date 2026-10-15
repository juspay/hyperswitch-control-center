open ExplorerTypes
open ExplorerCatalog

let metricCardMeasures = question => {
  let offered = sourceConfig(question.source).measures
  let headlineMeasures: array<measure> = [#success_rate, #volume, #successful, #failed]
  [question.measure]->Array.concat(
    headlineMeasures
    ->Array.filter(measure => measure != question.measure && offered->Array.includes(measure))
    ->Array.slice(~start=0, ~end=3),
  )
}
