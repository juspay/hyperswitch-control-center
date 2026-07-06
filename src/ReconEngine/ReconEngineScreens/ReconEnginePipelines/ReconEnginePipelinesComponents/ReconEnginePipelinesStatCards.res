open ReconEnginePipelinesUtils

@react.component
let make = () => {
  open LogicUtils
  open ReconEngineHooks

  let getIngestionHistory = useGetIngestionHistory()
  let getProcessingEntries = useGetProcessingEntries()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ingestionHistory, setIngestionHistory) = React.useState(_ => [])
  let (stagingEntries, setStagingEntries) = React.useState(_ => [])

  let fetchPipelinesStatsData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryString = ReconEngineFilterUtils.buildQueryStringFromFilters(~filterValueJson)
      let ingestionHistoryFetch = getIngestionHistory(~queryParameters=Some(queryString))
      let processingEntriesFetch = getProcessingEntries(~queryParameters=Some(queryString))
      let (ingestionHistory, stagingEntries) = await Promise.all2((
        ingestionHistoryFetch,
        processingEntriesFetch,
      ))
      setIngestionHistory(_ => ingestionHistory)
      setStagingEntries(_ => stagingEntries)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchPipelinesStatsData()->ignore
    }
    None
  }, [filterValue])

  let statCards = React.useMemo(() => {
    getPipelineStatCards(~ingestionHistory, ~stagingEntries)
  }, (ingestionHistory, stagingEntries))

  <div
    className="grid xl:grid-cols-4 lg:grid-cols-3 sm:grid-cols-2 grid-cols-1 gap-x-4 gap-y-6 mt-6">
    {statCards
    ->Array.mapWithIndex((card, index) => {
      <PageLoaderWrapper
        key={index->Int.toString}
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-28" message="No data available." />}
        customLoader={<Shimmer styleClass="h-28 w-full rounded-xl" />}>
        <ReconEngineOverviewSummaryHelper.StatCard
          title={(card.pipelineStatCardTitle :> string)}
          value=card.pipelineStatCardValue
          icon=card.pipelineStatCardIcon
          description=card.pipelineStatCardDescription
          cardType=card.pipelineStatCardType
        />
      </PageLoaderWrapper>
    })
    ->React.array}
  </div>
}
