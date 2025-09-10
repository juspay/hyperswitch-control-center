@react.component
let make = (~account: ReconEngineOverviewTypes.accountType) => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (configData, setConfigData) = React.useState(_ => [])

  let getIngestionConfig = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
        ~queryParamerters=Some(`account_id=${account.account_id}`),
      )
      let res = await fetchDetails(url)
      let configs =
        res->getArrayDataFromJson(
          ReconEngineFileManagementUtils.transformationConfigItemToObjMapper,
        )
      setConfigData(_ => configs)
      setScreenState(_ => PageLoaderWrapper.Success)
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
    <div className="grid lg:grid-cols-3 md:grid-cols-2 grid-cols-1 gap-6 items-center w-full p-6">
      {configData
      ->Array.mapWithIndex((config, _index) => {
        <ReconEngineAccountTransformationConfigDetails key=config.ingestion_id config={config} />
      })
      ->React.array}
    </div>
  </PageLoaderWrapper>
}
