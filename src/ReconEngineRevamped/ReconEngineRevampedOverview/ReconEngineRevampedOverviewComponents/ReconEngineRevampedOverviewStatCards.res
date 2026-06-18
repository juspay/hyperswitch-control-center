@react.component
let make = () => {
  open LogicUtils
  open APIUtils
  open ReconEngineRevampedOverviewHelper
  open ReconEngineRevampedOverviewUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (overviewRules, setOverviewRules) = React.useState(_ => [])

  let fetchOverviewRules = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = ReconEngineRevampedUtils.getQueryParamFromFilters(~filterValueJson)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#OVERVIEW_RULES,
        ~methodType=Get,
        ~queryParameters=Some(queryParams),
      )
      let res = await fetchDetails(url)
      let overviewRules = res->getArrayDataFromJson(overviewRulesResponseMapper)
      setOverviewRules(_ => overviewRules)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchOverviewRules()->ignore
    }
    None
  }, [filterValue])

  let statCards = React.useMemo(() => getStatCards(~overviewRules), [overviewRules])

  <div className="flex flex-col gap-6">
    <div
      className="grid xl:grid-cols-4 lg:grid-cols-3 sm:grid-cols-2 grid-cols-1 gap-x-4 gap-y-6 mt-4">
      {statCards
      ->Array.mapWithIndex((card, index) =>
        <PageLoaderWrapper
          screenState
          customUI={<NewAnalyticsHelper.NoData height="h-40" message="No data available." />}
          customLoader={<Shimmer styleClass="h-40 w-full rounded-xl" />}>
          <StatCard
            key={index->Int.toString}
            title=card.title
            value=card.value
            icon=card.icon
            description=card.description
            cardType=card.cardType
          />
        </PageLoaderWrapper>
      )
      ->React.array}
    </div>
    <div
      className="grid xl:grid-cols-5 lg:grid-cols-4 sm:grid-cols-3 grid-cols-2 gap-0 rounded-xl border border-nd_gray-200 overflow-hidden shadow-sm bg-white">
      {connectedStatCards
      ->Array.mapWithIndex((card, index) =>
        <ConnectedStatCard key={index->Int.toString} title=card.title value=card.value />
      )
      ->React.array}
    </div>
  </div>
}
