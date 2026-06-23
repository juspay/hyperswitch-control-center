open Typography

@react.component
let make = () => {
  open LogicUtils
  open ReconEngineOverviewSummaryUtils

  let getOverviewRulesTimeSeries = ReconEngineHooks.useGetOverviewRulesTimeSeries()

  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (chartPoints, setChartPoints) = React.useState(_ => [])

  let startTime = filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, "")
  let endTime = filterValueJson->getString(HSAnalyticsUtils.endTimeFilterKey, "")

  let fetchReconciliationVolume = async () => {
    open ReconEngineFilterUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let granularity = getOverviewChartGranularity(~startTime, ~endTime)
      let baseQueryParams = buildQueryStringFromFilters(~filterValueJson)
      let granularityParam = `granularity=${granularity->getOverviewChartGranularityQueryValue}`
      let queryParams =
        baseQueryParams->isNonEmptyString
          ? `${baseQueryParams}&${granularityParam}`
          : granularityParam

      let overviewRules = await getOverviewRulesTimeSeries(~queryParameters=Some(queryParams))
      let points = getOverviewChartPoints(~overviewRules, ~granularity)

      setChartPoints(_ => points)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchReconciliationVolume()->ignore
    }
    None
  }, [filterValue])

  let options =
    chartPoints
    ->getOverviewChartOptions
    ->LineAndColumnGraphUtils.getLineColumnGraphOptions

  <div className="border border-nd_gray-200 rounded-xl bg-white">
    <div className="flex flex-col gap-1 px-5 py-3.5 border-b border-nd_gray-200">
      <p className={`${body.md.semibold} text-nd_gray-800`}>
        {"Reconciliation Volume"->React.string}
      </p>
      <p className={`${body.sm.regular} text-nd_gray-600`}>
        {"Matched, exception, expected and missing volume with match rate over time"->React.string}
      </p>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData
        height="h-96" message="No reconciliation data for this date range."
      />}
      customLoader={<Shimmer styleClass="w-full h-96" />}>
      <div className="py-4 overflow-hidden">
        <LineAndColumnGraph options className="w-full" />
      </div>
    </PageLoaderWrapper>
  </div>
}
