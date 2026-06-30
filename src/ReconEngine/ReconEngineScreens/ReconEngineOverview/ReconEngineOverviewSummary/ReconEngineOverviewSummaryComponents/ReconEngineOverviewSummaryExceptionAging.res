open Typography

@react.component
let make = () => {
  open LogicUtils
  open ReconEngineOverviewSummaryTypes
  open ReconEngineOverviewSummaryUtils

  let getOverviewRulesTimeSeries = ReconEngineHooks.useGetOverviewRulesTimeSeries()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (agingData, setAgingData) = React.useState(_ => [])

  let fetchAgingData = async () => {
    open ReconEngineFilterUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let baseQueryParams = buildQueryStringFromFilters(~filterValueJson)
      let granularityParam = "granularity=day"
      let queryParams =
        baseQueryParams->isNonEmptyString
          ? `${baseQueryParams}&${granularityParam}`
          : granularityParam

      let overviewRules = await getOverviewRulesTimeSeries(~queryParameters=Some(queryParams))
      let results = getExceptionAgingDataFromTimeSeries(~overviewRules)
      setAgingData(_ => results)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchAgingData()->ignore
    }
    None
  }, [filterValue])

  let total = agingData->Array.reduce(0, (acc, item) => acc + item.total)

  <div className="border border-nd_gray-200 rounded-xl bg-white h-full">
    <div className="flex flex-col gap-1 px-5 py-3.5 border-b border-nd_gray-200 shadow-sm">
      <p className={`${body.md.semibold} text-nd_gray-800`}> {"Exception aging"->React.string} </p>
      <p className={`${body.sm.regular} text-nd_gray-600`}>
        {"How long open breaks have been waiting"->React.string}
      </p>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData
        height="h-64" message="No exception data for this date range."
      />}
      customLoader={<Shimmer styleClass="w-full h-64" />}>
      <div className="px-5 py-4">
        <div className="flex items-start gap-3 mb-4">
          <span className={`${heading.xl.bold} text-nd_red-500`}>
            <ReconEngineOverviewSummaryHelper.NumberCell value={total} />
          </span>
        </div>
        <RenderIf condition={total > 0}>
          <ReconEngineOverviewSummaryHelper.ExceptionAgingBar agingData total />
        </RenderIf>
        <RenderIf condition={total == 0}>
          <div className="h-2 w-full rounded-full bg-nd_gray-150 mb-5" />
        </RenderIf>
        <div className="flex flex-col gap-1">
          {agingData
          ->Array.map(item =>
            <ReconEngineOverviewSummaryHelper.ExceptionAgingRow key={item.label} item total />
          )
          ->React.array}
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
