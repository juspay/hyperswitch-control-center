open ExplorerTypes
open ExplorerCatalog

let metricCardMeasures = selection => {
  let offered = sourceConfig(selection.source).measures
  let headlineMeasures: array<measure> = [#success_rate, #volume, #successful, #failed]
  [selection.measure]->Array.concat(
    headlineMeasures
    ->Array.filter(measure => measure != selection.measure && offered->Array.includes(measure))
    ->Array.slice(~start=0, ~end=3),
  )
}
