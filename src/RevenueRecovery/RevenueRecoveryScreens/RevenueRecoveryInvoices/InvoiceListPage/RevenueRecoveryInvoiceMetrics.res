open APIUtils
open LogicUtils
open Typography

module MetricCard = {
  @react.component
  let make = (~title: string, ~value) => {
    <div className="bg-white border border-nd_br_gray-200 rounded-xl p-5 flex-1">
      <div className="flex items-center justify-between mb-3">
        <span className={`${body.md.medium} text-nd_gray-400`}> {title->React.string} </span>
      </div>
      <div className={`${heading.lg.bold} text-nd_gray-900`}>
        {value->CurrencyFormatUtils.valueFormatter(Volume)->React.string}
      </div>
    </div>
  }
}

@react.component
let make = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (metrics, setMetrics) = React.useState(_ => {
    (0.0, 0.0, 0.0) // (success, inProgress, failed)
  })

  let {filterValueJson} = FilterContext.filterContext->React.useContext

  let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=30)

  let startTime =
    filterValueJson->getString(OrderUIUtils.startTimeFilterKey(V2), defaultDate.start_time)
  let endTime = filterValueJson->getString(OrderUIUtils.endTimeFilterKey(V2), defaultDate.end_time)

  let fetchMetrics = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      // Fetch success count (succeeded, recovered)
      let successUrl = getURL(
        ~entityName=V2(V2_ORDERS_AGGREGATE),
        ~methodType=Get,
        ~queryParameters=Some(`start_time=${startTime}&end_time=${endTime}`),
      )
      let response = await fetchDetails(successUrl, ~version=V2)
      let successDict = response->getDictFromJsonObject
      let statusWithCount = successDict->getDictfromDict("status_with_count")
      let successCount = statusWithCount->getFloat("succeeded", 0.0)
      let failedCount = statusWithCount->getFloat("failed", 0.0)
      let inProgressCount = statusWithCount->getFloat("processing", 0.0)

      setMetrics(_ => (successCount, inProgressCount, failedCount))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(_) => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch metrics"))
    }
  }

  React.useEffect(() => {
    fetchMetrics()->ignore
    None
  }, [startTime, endTime])

  let (successCount, inProgressCount, failedCount) = metrics

  <PageLoaderWrapper screenState>
    <div className="grid grid-cols-3 gap-4">
      <MetricCard title="Total Recovered Invoices" value={successCount} />
      <MetricCard title="Invoices In Progress" value={inProgressCount} />
      <MetricCard title="Failed / Lost Invoices" value={failedCount} />
    </div>
  </PageLoaderWrapper>
}
