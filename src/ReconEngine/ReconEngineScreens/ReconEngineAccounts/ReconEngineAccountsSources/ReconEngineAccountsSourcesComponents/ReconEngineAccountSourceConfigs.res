@react.component
let make = (~account: ReconEngineTypes.accountType) => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (configData, setConfigData) = React.useState(_ => [
    Dict.make()->ReconEngineUtils.ingestionConfigItemToObjMapper,
  ])

  let getIngestionConfig = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_CONFIG,
        ~queryParameters=Some(`account_id=${account.account_id}`),
      )
      let res = await fetchDetails(url)
      let configs = res->getArrayDataFromJson(ReconEngineUtils.ingestionConfigItemToObjMapper)

      if configs->Array.length > 0 {
        setConfigData(_ => configs)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    getIngestionConfig()->ignore
    None
  }, [])

  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData height="h-52" message="No data available." />}
    customLoader={<Shimmer styleClass="h-52 w-full rounded-b-lg" />}>
    <div
      className="grid 2xl:grid-cols-3 xl:grid-cols-2 md:grid-cols-1 gap-6 items-center w-full p-6">
      {configData
      ->Array.mapWithIndex((config, index) => {
        <ReconEngineAccountSourceConfigDetails
          key=config.ingestion_id config={config} tabIndex={index->Int.toString}
        />
      })
      ->React.array}
    </div>
  </PageLoaderWrapper>
}
