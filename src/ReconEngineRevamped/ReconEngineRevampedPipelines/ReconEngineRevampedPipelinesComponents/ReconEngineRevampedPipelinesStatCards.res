@react.component
let make = (~onCardClick: string => unit) => {
  open LogicUtils
  open ReconEngineRevampedPipelinesHelper

  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let defaultDateRange = HSwitchRemoteFilter.getDateFilteredObject(~range=90)
  let startTime =
    filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, defaultDateRange.start_time)
  let endTime =
    filterValueJson->getString(HSAnalyticsUtils.endTimeFilterKey, defaultDateRange.end_time)

  let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (historyData, setHistoryData) = React.useState((_): array<
    ReconEngineTypes.ingestionHistoryType,
  > => [])

  let fetchData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = ReconEngineRevampedUtils.getQueryParamFromFilters(~filterValueJson)
      let res = await getIngestionHistory(~queryParameters=Some(queryParams))
      setHistoryData(_ => res)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if startTime->isNonEmptyString && endTime->isNonEmptyString {
      fetchData()->ignore
    }
    None
  }, (startTime, endTime, filterValue))

  let connectedStatCards = React.useMemo(() => {
    ReconEngineRevampedPipelinesUtils.getConnectedStatCards(historyData)
  }, [historyData])

  let cardFilter = (title: ReconEngineRevampedPipelinesTypes.connectedStatCardsTitle) => {
    switch title {
    | IngestionRuns => "all"
    | Processed => "processed"
    | Failed => "failed"
    | TotalSources => "all"
    }
  }

  <div
    className="grid xl:grid-cols-4 lg:grid-cols-2 sm:grid-cols-2 grid-cols-1 gap-0 rounded-xl border border-nd_gray-200 overflow-hidden shadow-sm bg-white mt-4">
    {connectedStatCards
    ->Array.mapWithIndex((card, index) => {
      <PageLoaderWrapper
        key={index->Int.toString}
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-24" message="" />}
        customLoader={<Shimmer styleClass="h-24 w-full" />}>
        <ConnectedStatCard
          title=card.title
          value=card.value
          description=card.description
          cardType=card.cardType
          icon=card.icon
          onPress={() => onCardClick(cardFilter(card.title))}
        />
      </PageLoaderWrapper>
    })
    ->React.array}
  </div>
}
