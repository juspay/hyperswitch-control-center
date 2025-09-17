@react.component
let make = (~selectedTransformationHistoryId: option<string>) => {
  open LogicUtils
  open ReconEngineAccountsTransformedEntriesHelper
  open ReconEngineAccountsTransformedEntriesUtils
  open ReconEngineHooks

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (stagingData, setStagingData) = React.useState(_ => [
    Dict.make()->getProcessingEntryPayloadFromDict,
  ])
  let getProcessingEntries = useGetProcessingEntries()

  let fetchStagingData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = switch selectedTransformationHistoryId {
      | Some(id) => Some(`transformation_history_id=${id}`)
      | None => None
      }
      let stagingList = await getProcessingEntries(~queryParamerters=queryParams)

      setStagingData(_ => stagingList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    fetchStagingData()->ignore
    None
  }, [])

  <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6 mt-2">
    {cardDetails(~stagingData)
    ->Array.map(card => {
      <PageLoaderWrapper
        key={randomString(~length=10)}
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-28" message="No data available" />}
        customLoader={<Shimmer styleClass="w-full h-28 rounded-xl" />}>
        <TransformedEntriesOverviewCard key=card.title title=card.title value=card.value />
      </PageLoaderWrapper>
    })
    ->React.array}
  </div>
}
