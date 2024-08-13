@react.component
let make = (
  ~startTimeVal,
  ~endTimeVal,
  ~entity: PerformanceMonitorTypes.entity<'t>,
  ~domain="payments",
) => {
  open APIUtils
  open LogicUtils
  open PerformanceMonitorTypes
  open TablePerformanceUtils
  let getURL = useGetURL()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let updateDetails = useUpdateMethod()
  let (offset, setOffset) = React.useState(_ => 0)
  let (tableData, setTableData) = React.useState(_ => [])
  let defaultSort: Table.sortedObject = {
    key: "",
    order: Table.INC,
  }

  let chartFetch = async () => {
    try {
      let url = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Post, ~id=Some(domain))

      let body = PerformanceUtils.requestBody(
        ~dimensions=[],
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~filters=entity.requestBodyConfig.filters,
        ~metrics=entity.requestBodyConfig.metrics,
        ~groupBy=entity.requestBodyConfig.groupBy,
        ~customFilter=entity.requestBodyConfig.customFilter,
        ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
        ~distribution=entity.requestBodyConfig.distribution,
      )

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
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load data"))
    }
  }
  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      chartFetch()->ignore
    }
    None
  }, [])

  <PerformanceUtils.Card title="Payment Failures">
    <PageLoaderWrapper screenState>
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
    </PageLoaderWrapper>
  </PerformanceUtils.Card>
}
