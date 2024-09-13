open NewAnalyticsTypes
open NewAnalyticsHelper
open LineGraphTypes
open OverViewAnalyticsEntity
open PaymentsProcessedUtils
@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<lineGraphPayload, lineGraphOptions>,
) => {
  let (paymentsProcessed, setpaymentsProcessed) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let defaultSort: Table.sortedObject = {
    key: "",
    order: Table.INC,
  }
  let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

  //   let tableData = if paymentsProcessed->Array.length > 0 {
  //     errors->Array.map(item => {
  //       {
  //         count: int,
  //         amount: float,
  //         currency: string,
  //         time_bucket: string,
  //       }->Nullable.make
  //     })
  //   } else {
  //     []
  //   }

  let getPaymentsProcessed = async () => {
    try {
      let data =
        getData
        ->LogicUtils.getDictFromJsonObject
        ->LogicUtils.getArrayFromDict("queryData", [])
        ->Belt.Array.keepMap(JSON.Decode.object)
        ->Array.map(PaymentsProcessedUtils.tableItemToObjMapper)
        ->Array.map(Nullable.make)

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
      <GraphHeader title="165K USD" />
      <div className="mx-7 mb-5">
        //<LineGraph entity={chartEntity} data={paymentsProcessed} />
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
    </Card>
  </div>
}
