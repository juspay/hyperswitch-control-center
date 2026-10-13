open Typography
open ExplorerTypes
open ExplorerViewsUtils
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

module UnmeasuredNote = {
  @react.component
  let make = (~question: question, ~dataset: dataset, ~labelFor) =>
    <div className={`px-5 pb-4 ${body.sm.regular} text-nd_gray-500`}>
      {getUnmeasuredNote(question, dataset, ~labelFor)->React.string}
    </div>
}
