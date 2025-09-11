@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open ReconEngineAccountsTransformedEntriesHelper
  open ReconEngineAccountsTransformedEntriesUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (stagingData, setStagingData) = React.useState(_ => [
    Dict.make()->ReconEngineExceptionStagingUtils.processingItemToObjMapper,
  ])

  let fetchStagingData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)

      let stagingUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST,
      )
      let res = await fetchDetails(stagingUrl)
      let stagingList =
        res->LogicUtils.getArrayDataFromJson(
          ReconEngineExceptionStagingUtils.processingItemToObjMapper,
        )

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
