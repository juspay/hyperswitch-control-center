@react.component
let make = () => {
  open LogicUtils
  open ReconEngineTypes
  open ReconEngineOverviewSummaryHelper
  open ReconEngineOverviewSummaryUtils

  let getOverviewRules = ReconEngineHooks.useGetOverviewRules()
  let getProcessingEntries = ReconEngineHooks.useGetProcessingEntries()
  let getTransformationHistory = ReconEngineHooks.useGetTransformationHistory()
  let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()

  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (overviewRules, setOverviewRules) = React.useState(_ => [])
  let (processingEntries, setProcessingEntries) = React.useState(_ => [])
  let (failedTransformationHistory, setFailedTransformationHistory) = React.useState(_ => [])
  let (failedIngestionHistory, setFailedIngestionHistory) = React.useState(_ => [])

  let fetchOverviewRules = async () => {
    open ReconEngineFilterUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = buildQueryStringFromFilters(~filterValueJson)

      let statusList = getProcessingEntryStatusValueFromStatusList([NeedsManualReview])
      let ingestionTransformationStatusList = getIngestionTransformationHistoryStatusValueFromStatusList([
        Failed,
      ])
      let overviewRulesFetch = getOverviewRules(~queryParameters=Some(queryParams))
      let processingEntriesFetch = getProcessingEntries(
        ~queryParameters=Some(`${queryParams}&status=${statusList->Array.joinWith(",")}`),
      )
      let failedTransformationHistoryFetch = getTransformationHistory(
        ~queryParameters=Some(
          `${queryParams}&status=${ingestionTransformationStatusList->Array.joinWith(",")}`,
        ),
      )
      let failedIngestionHistoryFetch = getIngestionHistory(
        ~queryParameters=Some(
          `${queryParams}&status=${ingestionTransformationStatusList->Array.joinWith(",")}`,
        ),
      )

      let (
        overviewRules,
        processingEntries,
        failedTransformationHistory,
        failedIngestionHistory,
      ) = await Promise.all4((
        overviewRulesFetch,
        processingEntriesFetch,
        failedTransformationHistoryFetch,
        failedIngestionHistoryFetch,
      ))

      setOverviewRules(_ => overviewRules)
      setProcessingEntries(_ => processingEntries)
      setFailedTransformationHistory(_ => failedTransformationHistory)
      setFailedIngestionHistory(_ => failedIngestionHistory)
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

  let (statCards, connectedStatCards) = React.useMemo(() => {
    (
      getStatCards(~overviewRules, ~processingEntries),
      getConnectedStatCards(~overviewRules, ~failedTransformationHistory, ~failedIngestionHistory),
    )
  }, (overviewRules, processingEntries, failedTransformationHistory, failedIngestionHistory))

  <div className="flex flex-col gap-6">
    <div
      className="grid xl:grid-cols-4 lg:grid-cols-3 sm:grid-cols-2 grid-cols-1 gap-x-4 gap-y-6 mt-4">
      {statCards
      ->Array.mapWithIndex((card, index) => {
        <PageLoaderWrapper
          screenState
          customUI={<NewAnalyticsHelper.NoData height="h-40" message="No data available." />}
          customLoader={<Shimmer styleClass="h-40 w-full rounded-xl" />}>
          <StatCard
            key={index->Int.toString}
            title={(card.statCardTitle :> string)}
            value=card.statCardValue
            icon=card.statCardIcon
            description=card.statCardDescription
            cardType=card.statCardType
            onStatCardClick={() =>
              card.statCardPath->mapOptionOrDefault((), path => RescriptReactRouter.push(path))}
          />
        </PageLoaderWrapper>
      })
      ->React.array}
    </div>
    <div
      className="grid xl:grid-cols-5 lg:grid-cols-4 sm:grid-cols-3 grid-cols-2 rounded-xl border border-nd_gray-200 overflow-hidden shadow-sm bg-white">
      {connectedStatCards
      ->Array.mapWithIndex((card, index) => {
        <PageLoaderWrapper
          screenState
          customUI={<NewAnalyticsHelper.NoData height="h-24" message="No data available." />}
          customLoader={<Shimmer styleClass="h-24 w-full" />}>
          <ConnectedStatCard
            key={index->Int.toString}
            title={(card.connectedStatCardTitle :> string)}
            value=card.connectedStatCardValue
            cardType=card.connectedStatCardType
            onConnectedStatCardClick={() => {
              card.connectedStatCardPath->mapOptionOrDefault((), path =>
                RescriptReactRouter.push(path)
              )
            }}
          />
        </PageLoaderWrapper>
      })
      ->React.array}
    </div>
  </div>
}
