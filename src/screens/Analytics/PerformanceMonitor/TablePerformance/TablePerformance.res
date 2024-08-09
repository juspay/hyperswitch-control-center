@react.component
let make = (
  ~startTimeVal,
  ~endTimeVal,
  ~entity: PerformanceMonitorTypes.entity<'t>,
  ~domain="payments",
) => {
  open APIUtils
  open LogicUtils
  open Highcharts
  open PerformanceMonitorTypes
  open TablePerformanceUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (offset, setOffset) = React.useState(_ => 0)
  let (tableData, setTableData) = React.useState(_ => [])
  let defaultSort: Table.sortedObject = {
    key: "",
    order: Table.INC,
  }

  let _ = bubbleChartModule(highchartsModule)

  let chartFetch = async () => {
    try {
      let url = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Post, ~id=Some(domain))

      let metrics = entity.requestBodyConfig.metrics->Array.map(v => (v: metrics :> string))

      let distribution =
        [
          ("distributionFor", "payment_error_message"->JSON.Encode.string),
          ("distributionCardinality", "TOP_5"->JSON.Encode.string),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object

      let body =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~metrics=Some(metrics),
            ~delta=true,
            ~distributionValues=distribution->Some,
            ~groupByNames=["connector"]->Some,
            ~startDateTime=startTimeVal,
            ~endDateTime=endTimeVal,
          )->JSON.Encode.object,
        ]->JSON.Encode.array

      let res = await updateDetails(url, body, Post)
      let arr =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])

      let items = getTableData(arr)

      let tableData = if items->Array.length > 0 {
        items->Array.map(Nullable.make)
      } else {
        []
      }

      setTableData(_ => tableData)
    } catch {
    | _ => ()
    }
  }
  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      chartFetch()->ignore
    }
    None
  }, [])

  <PerformanceUtils.Card title="Payment Failures" description="Payment Failures">
    <LoadedTable
      visibleColumns
      title=" "
      hideTitle=true
      actualData={tableData}
      entity=tableEntity
      resultsPerPage=5
      totalResults={tableData->Array.length}
      offset
      setOffset
      defaultSort
      currrentFetchCount={tableData->Array.length}
      tableLocalFilter=false
      tableheadingClass=tableBorderClass
      ignoreHeaderBg=true
      tableDataBorderClass=tableBorderClass
      isAnalyticsModule=true
    />
  </PerformanceUtils.Card>
}
