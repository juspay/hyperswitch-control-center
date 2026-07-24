open ReconEnginePipelinesUtils

@react.component
let make = () => {
  open LogicUtils
  open ReconEngineHooks
  open HSAnalyticsUtils

  let getIngestionHistory = useGetIngestionHistory()
  let getStagingEntriesOverview = useGetStagingEntriesOverview()
  let {
    filterValueJson,
    filterValue,
    updateExistingKeys,
    removeKeys,
    setfilterKeys,
  } = React.useContext(FilterContext.filterContext)
  let customFilterKey = "status"

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ingestionHistory, setIngestionHistory) = React.useState(_ => [])
  let (stagingOverviewData, setStagingOverviewData) = React.useState(_ => [])
  let (activeStatusFilter, setActiveStatusFilter) = React.useState(_ => "")

  let fetchPipelinesStatsData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let dateRangeFilterValueJson =
        filterValueJson
        ->Dict.toArray
        ->Array.filter(((key, _)) => [startTimeFilterKey, endTimeFilterKey]->Array.includes(key))
        ->Dict.fromArray
      let queryString = ReconEngineFilterUtils.buildQueryStringFromFilters(
        ~filterValueJson=dateRangeFilterValueJson,
      )
      let ingestionHistoryFetch = getIngestionHistory(~queryParameters=Some(queryString))
      let stagingEntriesOverviewFetch = getStagingEntriesOverview(
        ~queryParameters=Some(queryString),
      )
      let (ingestionHistory, stagingOverviewData) = await Promise.all2((
        ingestionHistoryFetch,
        stagingEntriesOverviewFetch,
      ))
      setIngestionHistory(_ => ingestionHistory)
      setStagingOverviewData(_ => stagingOverviewData)
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
    getPipelineStatCards(~ingestionHistory, ~stagingOverviewData)
  }, (ingestionHistory, stagingOverviewData))

  let onStatCardClick = (card: ReconEnginePipelinesTypes.pipelineStatCardData) => () => {
    switch card.pipelineStatCardClickAction {
    | ClearStatusFilter => removeKeys([customFilterKey])
    | SetStatusFilter(status) => {
        updateExistingKeys(Dict.fromArray([(customFilterKey, `[${status}]`)]))
        setfilterKeys(prev =>
          prev->Array.includes(customFilterKey) ? prev : prev->Array.concat([customFilterKey])
        )
      }
    | NoAction => ()
    }
  }

  let settingActiveStatusFilter = () => {
    let appliedStatusFilter =
      filterValueJson->getArrayFromDict(customFilterKey, [])->getStrArrayFromJsonArray
    setActiveStatusFilter(_ =>
      appliedStatusFilter->Array.length == 1 ? appliedStatusFilter->getValueFromArray(0, "") : ""
    )
  }

  React.useEffect(() => {
    settingActiveStatusFilter()
    None
  }, [filterValue])

  let isCardActive = (card: ReconEnginePipelinesTypes.pipelineStatCardData) =>
    switch card.pipelineStatCardClickAction {
    | ClearStatusFilter => activeStatusFilter->isEmptyString
    | SetStatusFilter(status) => activeStatusFilter == status
    | NoAction => false
    }

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
          onStatCardClick={onStatCardClick(card)}
          isActive={isCardActive(card)}
        />
      </PageLoaderWrapper>
    })
    ->React.array}
  </div>
}
