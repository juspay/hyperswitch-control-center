open NewAnalyticsTypes
open NewAnalyticsHelper
open LineGraphTypes
open NewPaymentAnalyticsEntity
open PaymentsProcessedUtils
open LogicUtils

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
            {"count": 24, "amount": 952, "currency": "USD", "time_bucket": "2024-08-13 18:30:00"},
            {"count": 28, "amount": 1020, "currency": "USD", "time_bucket": "2024-08-14 18:30:00"},
            {"count": 35, "amount": 1450, "currency": "USD", "time_bucket": "2024-08-15 18:30:00"},
            {"count": 30, "amount": 1150, "currency": "USD", "time_bucket": "2024-08-16 18:30:00"},
            {"count": 40, "amount": 1600, "currency": "USD", "time_bucket": "2024-08-17 18:30:00"},
            {"count": 29, "amount": 1200, "currency": "USD", "time_bucket": "2024-08-18 18:30:00"},
            {"count": 31, "amount": 1300, "currency": "USD", "time_bucket": "2024-08-19 18:30:00"},
            {"count": 56, "amount": 3925, "currency": "EUR", "time_bucket": "2024-08-13 18:30:00"},
            {"count": 50, "amount": 3750, "currency": "EUR", "time_bucket": "2024-08-14 18:30:00"},
            {"count": 42, "amount": 3150, "currency": "EUR", "time_bucket": "2024-08-15 18:30:00"},
            {"count": 38, "amount": 2900, "currency": "EUR", "time_bucket": "2024-08-16 18:30:00"},
            {"count": 44, "amount": 3300, "currency": "EUR", "time_bucket": "2024-08-17 18:30:00"},
            {"count": 50, "amount": 3750, "currency": "EUR", "time_bucket": "2024-08-18 18:30:00"},
            {"count": 60, "amount": 4500, "currency": "EUR", "time_bucket": "2024-08-19 18:30:00"},
            {"count": 48, "amount": 3600, "currency": "GBP", "time_bucket": "2024-08-13 18:30:00"},
            {"count": 45, "amount": 3400, "currency": "GBP", "time_bucket": "2024-08-14 18:30:00"},
            {"count": 40, "amount": 3000, "currency": "GBP", "time_bucket": "2024-08-15 18:30:00"},
            {"count": 43, "amount": 3200, "currency": "GBP", "time_bucket": "2024-08-16 18:30:00"},
            {"count": 46, "amount": 3500, "currency": "GBP", "time_bucket": "2024-08-17 18:30:00"},
            {"count": 50, "amount": 3800, "currency": "GBP", "time_bucket": "2024-08-18 18:30:00"},
            {"count": 52, "amount": 4000, "currency": "GBP", "time_bucket": "2024-08-19 18:30:00"},
          ],
          "metaData": [
            {"count": 217, "amount": 8672, "currency": "USD"},
            {"count": 340, "amount": 25575, "currency": "EUR"},
            {"count": 324, "amount": 24500, "currency": "GBP"},
          ],
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

  let totalAmount =
    paymentsProcessed
    ->getArrayFromJson([])
    ->getValueFromArray(0, JSON.Encode.array([]))
    ->getDictFromJsonObject
    ->getInt("amount", 0)

  let currency =
    paymentsProcessed
    ->getArrayFromJson([])
    ->getValueFromArray(0, JSON.Encode.array([]))
    ->getDictFromJsonObject
    ->getString("currency", "")

  let graphTitle = totalAmount->Int.toString ++ " " ++ currency

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <GraphHeader title={graphTitle} viewType setViewType showTabSwitch=true />
      <div className="mb-5">
        {switch viewType {
        | Graph => <LineGraph entity={chartEntity} data={paymentsProcessed} className="mr-3" />
        | Table => <TableModule data={paymentsProcessed} className="mx-7" />
        }}
      </div>
    </Card>
  </div>
}
