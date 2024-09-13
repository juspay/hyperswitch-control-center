open NewAnalyticsTypes
open NewAnalyticsHelper
open LineGraphTypes
open OverViewAnalyticsEntity
open PaymentsProcessedUtils

module TableModule = {
  @react.component
  let make = (~data, ~className="") => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }
    let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

    let paymentsProcessed =
      data
      ->Belt.Array.keepMap(JSON.Decode.object)
      ->Array.map(PaymentsProcessedUtils.tableItemToObjMapper)
      ->Array.map(Nullable.make)

    <div className>
      <LoadedTable
        visibleColumns
        title=" "
        hideTitle=true
        actualData={paymentsProcessed}
        entity=tableEntity
        resultsPerPage=10
        totalResults={paymentsProcessed->Array.length}
        offset
        setOffset
        defaultSort
        currrentFetchCount={paymentsProcessed->Array.length}
        tableLocalFilter=false
        tableheadingClass=tableBorderClass
        tableBorderClass
        ignoreHeaderBg=true
        tableDataBorderClass=tableBorderClass
        isAnalyticsModule=true
      />
    </div>
  }
}

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<lineGraphPayload, lineGraphOptions>,
) => {
  let (paymentsProcessed, setpaymentsProcessed) = React.useState(_ => [])
  let (viewType, setViewType) = React.useState(_ => Graph)

  let getPaymentsProcessed = async () => {
    try {
      let data =
        getData
        ->LogicUtils.getDictFromJsonObject
        ->LogicUtils.getArrayFromDict("queryData", [])

      setpaymentsProcessed(_ => data)
    } catch {
    | _ => ()
    }
  }
  React.useEffect(() => {
    getPaymentsProcessed()->ignore
    None
  }, [])

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <GraphHeader title="165K USD" viewType setViewType />
      <div className="mb-5">
        {switch viewType {
        | Graph =>
          <LineGraph
            entity={chartEntity} data={paymentsProcessed->JSON.Encode.array} className="mr-3"
          />
        | Table => <TableModule data={paymentsProcessed} className="mx-7" />
        }}
      </div>
    </Card>
  </div>
}
