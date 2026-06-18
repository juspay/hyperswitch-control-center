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
  let (failedIngestionHistoryList, setFailedIngestionHistoryList) = React.useState(_ => [])
  let (
    failedTransformationHistoryList,
    setFailedTransformationHistoryList,
  ) = React.useState(_ => [])
  let (manualReviewStagingEntries, setManualReviewStagingEntries) = React.useState(_ => [])

  let fetchOverviewRules = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = ReconEngineRevampedUtils.getQueryParamFromFilters(~filterValueJson)
      let overviewRulesUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#OVERVIEW_RULES,
        ~methodType=Get,
        ~queryParameters=Some(queryParams),
      )
      let queryString =
        queryParams->isNonEmptyString ? `${queryParams}&status=failed` : "status=failed"

      let ingestionHistoryUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_HISTORY,
        ~queryParameters=Some(queryString),
      )
      let transformationHistoryUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParameters=Some(queryString),
      )
      let manualReviewUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST,
        ~queryParameters=Some(`${queryParams}&status=needs_manual_review`),
      )
      let results = await Promise.all([
        fetchDetails(overviewRulesUrl),
        fetchDetails(ingestionHistoryUrl),
        fetchDetails(transformationHistoryUrl),
        fetchDetails(manualReviewUrl),
      ])

      let overviewRes = results->Array.get(0)->Option.getExn
      let failedIngestionHistoryListRes = results->Array.get(1)->Option.getExn
      let failedTransformationHistoryListRes = results->Array.get(2)->Option.getExn
      let manualReviewStagingEntriesRes = results->Array.get(3)->Option.getExn

      let overviewRules = overviewRes->getArrayDataFromJson(overviewRulesResponseMapper)
      let failedIngestionHistory =
        failedIngestionHistoryListRes->getArrayDataFromJson(overviewIngestionHistoryResponseMapper)
      let failedTransformationHistory =
        failedTransformationHistoryListRes->getArrayDataFromJson(
          overviewTransformationHistoryResponseMapper,
        )
      let manualReviewStagingEntries =
        manualReviewStagingEntriesRes->getArrayDataFromJson(overviewStagingEntryResponseMapper)

      setOverviewRules(_ => overviewRules)
      setFailedIngestionHistoryList(_ => failedIngestionHistory)
      setFailedTransformationHistoryList(_ => failedTransformationHistory)
      setManualReviewStagingEntries(_ => manualReviewStagingEntries)

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
    let statCards = getStatCards(~overviewRules, ~manualReviewStagingEntries)
    let connectedStatCards = getConnectedStatCards(
      ~overviewRules,
      ~failedIngestionHistoryList,
      ~failedTransformationHistoryList,
    )
    (statCards, connectedStatCards)
  }, (overviewRules, failedIngestionHistoryList, failedTransformationHistoryList))

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
      ->Array.mapWithIndex((card, index) => {
        <PageLoaderWrapper
          screenState
          customUI={<NewAnalyticsHelper.NoData height="h-24" message="No data available." />}
          customLoader={<Shimmer styleClass="h-24 w-full" />}>
          <ConnectedStatCard key={index->Int.toString} title=card.title value=card.value />
        </PageLoaderWrapper>
      })
      ->React.array}
    </div>
  </div>
}
