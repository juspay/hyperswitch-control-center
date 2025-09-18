let tableBorderClass = "border-collapse border border-jp-gray-940 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

@react.component
let make = (
  ~startTimeVal,
  ~endTimeVal,
  ~entity: PerformanceMonitorTypes.entity<'t, 't1>,
  ~domain="payments",
  ~getTableData,
  ~visibleColumns,
  ~tableEntity,
) => {
  open APIUtils
  open LogicUtils
  open PerformanceMonitorTypes
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
      let url = getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Post, ~id=Some(domain))

      let body = PerformanceUtils.requestBody(
        ~dimensions=[],
        ~excludeFilterValue=entity.requestBodyConfig.excludeFilterValue,
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

      if arr->Array.length > 0 {
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      chartFetch()->ignore
    }
    None
  }, [])

  <PageLoaderWrapper
    screenState
    customLoader={<Shimmer styleClass="w-full h-96" />}
    customUI={PerformanceUtils.customUI(entity.title)}>
    <PerformanceUtils.Card title="Payment Failures">
      <LoadedTable
        visibleColumns
        title="Performance Monitor"
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
  </PageLoaderWrapper>
}
