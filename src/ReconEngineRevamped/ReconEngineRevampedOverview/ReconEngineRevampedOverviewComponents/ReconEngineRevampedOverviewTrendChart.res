open Typography

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open NewAnalyticsHelper
  open ReconEngineRevampedOverviewUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let defaultDateRange = HSwitchRemoteFilter.getDateFilteredObject(~range=180)

  let startTime =
    filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, defaultDateRange.start_time)
  let endTime =
    filterValueJson->getString(HSAnalyticsUtils.endTimeFilterKey, defaultDateRange.end_time)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (chartPoints, setChartPoints) = React.useState(_ => [])

  let fetchChartData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let granularity = getOverviewChartGranularity(~startTime, ~endTime)
      let buckets = getOverviewChartBuckets(~startTime, ~endTime, ~granularity)
      let requests = buckets->Array.map(bucket => {
        let bucketFilters = filterValueJson->Dict.copy
        bucketFilters->Dict.set("startTime", bucket.startTime->JSON.Encode.string)
        bucketFilters->Dict.set("endTime", bucket.endTime->JSON.Encode.string)
        let queryParams = ReconEngineRevampedUtils.getQueryParamFromFilters(
          ~filterValueJson=bucketFilters,
        )
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#OVERVIEW_RULES,
          ~methodType=Get,
          ~queryParameters=Some(queryParams),
        )

        fetchDetails(url)->Promise.thenResolve(response => {
          let overviewRules = response->getArrayDataFromJson(overviewRulesResponseMapper)
          getOverviewChartPoint(
            ~label=bucket.label,
            ~tooltipLabel=bucket.tooltipLabel,
            ~overviewRules,
          )
        })
      })
      let points = await requests->Promise.all
      setChartPoints(_ => points)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if startTime->isNonEmptyString && endTime->isNonEmptyString {
      fetchChartData()->ignore
    }
    None
  }, (startTime, endTime, filterValue))

  let options =
    chartPoints
    ->getOverviewChartOptions
    ->LineAndColumnGraphUtils.getLineColumnGraphOptions

  <div className="border border-nd_gray-200 rounded-xl bg-white">
    <div className="flex flex-col gap-1 px-5 py-3.5 border-b border-nd_gray-200 shadow-sm">
      <p className={`${body.md.semibold} text-nd_gray-800`}>
        {"Reconciliation volume & match rate"->React.string}
      </p>
      <p className={`${body.sm.regular} text-nd_gray-600`}>
        {"Daily transaction volume with match-rate overlay"->React.string}
      </p>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NoData height="h-72" message="No reconciliation data for this date range." />}
      customLoader={<Shimmer styleClass="w-full h-72" />}>
      <div className="py-4 overflow-hidden">
        <LineAndColumnGraph options className="w-full" />
      </div>
    </PageLoaderWrapper>
  </div>
}
