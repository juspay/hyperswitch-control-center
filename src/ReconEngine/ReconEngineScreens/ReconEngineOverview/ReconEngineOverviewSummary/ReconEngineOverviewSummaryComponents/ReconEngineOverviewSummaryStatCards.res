@react.component
let make = () => {
  open LogicUtils
  open ReconEngineTypes
  open ReconEngineOverviewSummaryHelper
  open ReconEngineOverviewSummaryUtils

  let getOverviewRules = ReconEngineHooks.useGetOverviewRules()
  let getProcessingEntries = ReconEngineHooks.useGetProcessingEntries()

  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (overviewRules, setOverviewRules) = React.useState(_ => [])
  let (processingEntries, setProcessingEntries) = React.useState(_ => [])

  let fetchOverviewRules = async () => {
    open ReconEngineFilterUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = buildQueryStringFromFilters(~filterValueJson)
      let overviewRules = await getOverviewRules(~queryParameters=Some(queryParams))
      setOverviewRules(_ => overviewRules)

      let statusList = getProcessingEntryStatusValueFromStatusList([NeedsManualReview])
      let processingEntries = await getProcessingEntries(
        ~queryParameters=Some(`${queryParams}&status=${statusList->Array.joinWith(",")}`),
      )
      setProcessingEntries(_ => processingEntries)
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

  let statCards = React.useMemo(() => {
    getStatCards(~overviewRules, ~processingEntries)
  }, (overviewRules, processingEntries))

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
            title=card.statCardTitle
            value=card.statCardValue
            icon=card.statCardIcon
            description=card.statCardDescription
            cardType=card.statCardType
            onStatCardClick=card.onStatCardClick
          />
        </PageLoaderWrapper>
      )
      ->React.array}
    </div>
  </div>
}
