open Typography

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open ReconEngineRevampedOverviewUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (overviewRules, setOverviewRules) = React.useState(_ => [])

  let fetchStatusDistribution = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = ReconEngineRevampedUtils.getQueryParamFromFilters(~filterValueJson)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#OVERVIEW_RULES,
        ~methodType=Get,
        ~queryParameters=Some(queryParams),
      )
      let response = await fetchDetails(url)
      let rules = response->getArrayDataFromJson(overviewRulesResponseMapper)
      setOverviewRules(_ => rules)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchStatusDistribution()->ignore
    }
    None
  }, [filterValue])

  let distribution = React.useMemo(() => {
    getOverviewStatusDistribution(~overviewRules)
  }, [overviewRules])

  let totalCount = distribution->Array.reduce(0, (total, item) => total + item.count)
  let options = distribution->getOverviewStatusDistributionOptions

  <div className="h-full border border-nd_gray-200 rounded-lg bg-white">
    <div className="flex flex-col gap-1 px-5 py-3.5 border-b border-nd_gray-200 shadow-sm">
      <p className={`${body.md.semibold} text-nd_gray-800`}>
        {"Status distribution"->React.string}
      </p>
      <p className={`${body.sm.regular} text-nd_gray-600`}>
        {"All transactions in the period"->React.string}
      </p>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData
        height="h-72" message="No reconciliation data for this date range."
      />}
      customLoader={<Shimmer styleClass="w-full h-72" />}>
      <div
        className="flex flex-col sm:flex-row items-center justify-center gap-4 min-h-72 px-4 py-3">
        <PieGraph options className="shrink-0" />
        <div className="flex flex-col gap-3 w-full max-w-44">
          {distribution
          ->Array.map(item => {
            let percentage =
              totalCount === 0
                ? 0
                : Math.round(
                    item.count->Int.toFloat /. totalCount->Int.toFloat *. 100.0,
                  )->Float.toInt
            <div key=item.name className="flex items-center justify-between gap-4">
              <div className="flex items-center gap-2 min-w-0">
                <span
                  className="w-2.5 h-2.5 rounded-sm shrink-0"
                  style={ReactDOM.Style.make(~backgroundColor=item.color, ())}
                />
                <span className={`${body.sm.regular} text-nd_gray-700 truncate`}>
                  {item.name->React.string}
                </span>
              </div>
              <div className="text-right shrink-0">
                <p className={`${body.sm.semibold} text-nd_gray-800`}>
                  {`${percentage->Int.toString}%`->React.string}
                </p>
                <p className={`${body.xs.regular} text-nd_gray-500`}>
                  {item.count->ReconEngineRevampedUtils.formatNumber->React.string}
                </p>
              </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
