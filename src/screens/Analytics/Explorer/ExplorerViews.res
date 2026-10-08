open LogicUtils
open ExplorerTypes
open ExplorerDescriptions
open ExplorerEntity
open InsightsHelper

module ViewTable = {
  @react.component
  let make = (~title, ~rows, ~entity, ~visibleColumns) => {
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
    />
  }
}

@react.component
let make = (~viewContext: viewContext) => {
  let {question} = viewContext
  let title = question->viewTitle
  question.split->isNonEmptyArray
    ? <ViewTable
        title
        rows={viewContext->getGroupRows}
        entity={question->getGroupTableEntity}
        visibleColumns={question->getGroupColumns}
      />
    : <ViewTable
        title
        rows={viewContext->getOutcomeRows}
        entity={question.source->getOutcomeTableEntity}
        visibleColumns=outcomeColumns
      />
}
