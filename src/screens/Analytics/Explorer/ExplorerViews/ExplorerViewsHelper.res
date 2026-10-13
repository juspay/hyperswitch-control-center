open Typography
open LogicUtils
open ExplorerTypes
open ExplorerDescriptions
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
  let make = (~question: question, ~dataset: dataset, ~labelFor) => {
    let {source, measure} = question
    let names =
      dataset.unmeasured
      ->Array.map(((values, counts)) =>
        `${values
          ->Array.mapWithIndex((value, index) =>
            question.split
            ->Array.get(index)
            ->mapOptionOrDefault(value, key => labelFor(key, value))
          )
          ->Array.joinWith(" · ")} (${counts.total->formatNumberWithCommas} ${sourceNoun(
            source,
          )}, ${unmeasurableReason(source, measure)})`
      )
      ->Array.joinWith("; ")
    <div className={`px-5 pb-4 ${body.sm.regular} text-nd_gray-500`}>
      {`Excluded from the ${measureLabel(
          source,
          measure,
        )->String.toLowerCase}: ${names}.`->React.string}
    </div>
  }
}
