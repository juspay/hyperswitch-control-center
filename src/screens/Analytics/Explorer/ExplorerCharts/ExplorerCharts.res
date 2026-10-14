open ExplorerTypes
open ExplorerSelection
open ExplorerChartsUtils

@react.component
let make = (~selection: selection, ~dataset: dataset, ~labelFor) => {
  let context: chartContext = {selection, dataset, labelFor}
  let chartKey =
    [
      (selection.view :> string),
      selection->requestKey,
      (selection.measure :> string),
      dataset.amountCurrency,
    ]->Array.joinWith("|")

  switch (selection.view, selection.split->LogicUtils.isNonEmptyArray) {
  | (#trend, _) => <LineGraph key=chartKey options={context->getTrendChartOptions} />
  | (#mix, _) => <ColumnGraph key=chartKey options={context->getMixChartOptions} />
  | (#breakdown, true) => <ColumnGraph key=chartKey options={context->getBreakdownChartOptions} />
  | (#breakdown, false) => <ColumnGraph key=chartKey options={context->getOutcomeChartOptions} />
  | (#table, _) => React.null
  }
}
