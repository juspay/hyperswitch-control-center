open NewAnalyticsTypes
open NewAnalyticsHelper
open LineGraphTypes
open NewPaymentAnalyticsEntity
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
      ->LogicUtils.getArrayDataFromJson(tableItemToObjMapper)
      ->Array.map(Nullable.make)

    <div className>
      <LoadedTable
        visibleColumns
        title=" "
        hideTitle=true
        actualData={paymentsProcessed}
        entity=paymentsProcessedTableEntity
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
  let (paymentsProcessed, setpaymentsProcessed) = React.useState(_ => JSON.Encode.array([]))
  let (viewType, setViewType) = React.useState(_ => Graph)

  let getPaymentsProcessed = async () => {
    try {
      let response = [
        {
          "queryData": [
            {"count": 24, "amount": 952, "time_bucket": "2024-08-13 18:30:00"},
            {"count": 28, "amount": 1020, "time_bucket": "2024-08-14 18:30:00"},
            {"count": 35, "amount": 1450, "time_bucket": "2024-08-15 18:30:00"},
            {"count": 30, "amount": 1150, "time_bucket": "2024-08-16 18:30:00"},
            {"count": 40, "amount": 1600, "time_bucket": "2024-08-17 18:30:00"},
            {"count": 29, "amount": 1200, "time_bucket": "2024-08-18 18:30:00"},
            {"count": 31, "amount": 1300, "time_bucket": "2024-08-19 18:30:00"},
          ],
          "metaData": [{"count": 217, "amount": 8672, "currency": "USD"}],
        },
      ]->Identity.genericTypeToJson

      setpaymentsProcessed(_ => response)
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
      <GraphHeader title={graphTitle(paymentsProcessed)} viewType setViewType showTabSwitch=true />
      <div className="mb-5">
        {switch viewType {
        | Graph => <LineGraph entity={chartEntity} data={paymentsProcessed} className="mr-3" />
        | Table => <TableModule data={paymentsProcessed} className="mx-7" />
        }}
      </div>
    </Card>
  </div>
}
