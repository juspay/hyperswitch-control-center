open LogicUtils
open ExplorerTypes
open ExplorerDescriptions
open ExplorerCharts
open ExplorerEntity
open InsightsHelper
open NewAnalyticsHelper

module ViewTable = {
  @react.component
  let make = (~title, ~rows, ~entity, ~visibleColumns, ~onEntityClick=?) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {key: "", order: Table.INC}
    <LoadedTable
      visibleColumns
      title
      hideTitle=true
      actualData={rows->Array.map(Nullable.make)}
      entity
      resultsPerPage=10
      totalResults={rows->Array.length}
      offset
      setOffset
      defaultSort
      currentFetchCount={rows->Array.length}
      tableLocalFilter=false
      tableheadingClass=tableBorderClass
      tableBorderClass
      ignoreHeaderBg=true
      tableDataBorderClass=tableBorderClass
      isAnalyticsModule=true
      ?onEntityClick
    />
  }
}

@react.component
let make = (~viewContext: viewContext) => {
  let {question, dataset, chartKey} = viewContext
  let isSplit = question.split->isNonEmptyArray
  let title = question->viewTitle
  let noGroups =
    <NoData
      height="h-32" message="No groups have a value for this measure in the selected dates."
    />
  switch (question.view, isSplit) {
  | (Trend, _) =>
    <LineGraph key={`trend|${chartKey}`} options={viewContext->getTrendChartOptions} />
  | (Mix, _) => <ColumnGraph key={`mix|${chartKey}`} options={viewContext->getMixChartOptions} />
  | (Breakdown | Table, true) if dataset.sorted->isEmptyArray => noGroups
  | (Breakdown, true) =>
    <ColumnGraph key={`breakdown|${chartKey}`} options={viewContext->getBreakdownChartOptions} />
  | (Breakdown, false) =>
    <ColumnGraph key={`outcomes|${chartKey}`} options={viewContext->getOutcomeChartOptions} />
  | (Table, true) =>
    <ViewTable
      title
      rows={viewContext->getGroupRows}
      entity={question->getGroupTableEntity}
      visibleColumns={question->getGroupColumns}
      onEntityClick={(row: groupRow) => viewContext.onFocus(row.group)}
    />
  | (Table, false) =>
    <ViewTable
      title
      rows={viewContext->getOutcomeRows}
      entity={question.source->getOutcomeTableEntity}
      visibleColumns=outcomeColumns
    />
  }
}
