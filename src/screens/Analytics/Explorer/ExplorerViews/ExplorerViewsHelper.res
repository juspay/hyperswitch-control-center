open Typography
open ExplorerTypes
open ExplorerCatalog
open ExplorerDescriptions
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
  let make = (~selection: selection, ~dataset: dataset, ~labelFor) =>
    <div className={`px-5 pb-4 ${body.sm.regular} text-nd_gray-500`}>
      {getUnmeasuredNote(selection, dataset, ~labelFor)->React.string}
    </div>
}

module ViewTabs = {
  @react.component
  let make = (~view: view, ~onViewChange) =>
    <TabsBinding value={(view :> string)} onValueChange=onViewChange variant=Floating size=Md>
      <TabsBinding.List variant=Floating size=Md fitContent=true>
        {views
        ->Array.map(view =>
          <TabsBinding.Trigger
            key={(view :> string)} value={(view :> string)} variant=Floating size=Md>
            {viewLabel(view)->React.string}
          </TabsBinding.Trigger>
        )
        ->React.array}
      </TabsBinding.List>
    </TabsBinding>
}
