@react.component
let make = (~ingestionId) => {
  open ReconEngineIngestionHelper
  open LogicUtils
  open APIUtils
  open ReconEngineFileManagementUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ingestionConfigData, setIngestionConfigData) = React.useState(_ =>
    Dict.make()->ingestionConfigItemToObjMapper
  )

  let fetchIngestionHistoryData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let ingestionConfigUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_CONFIG,
        ~id=Some(ingestionId),
      )
      let ingestionConfigRes = await fetchDetails(ingestionConfigUrl)
      let ingestionConfigData =
        ingestionConfigRes
        ->getDictFromJsonObject
        ->ingestionConfigItemToObjMapper
      setIngestionConfigData(_ => ingestionConfigData)

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let detailsFields: array<ReconEngineFileManagementEntity.ingestionConfigColType> = [
    SourceConfigName,
    ConfigurationType,
    IngestionId,
    LastSyncAt,
  ]

  React.useEffect(() => {
    fetchIngestionHistoryData()->ignore
    None
  }, [ingestionId])

  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData height="h-44" message="No data available." />}
    customLoader={<Shimmer styleClass="h-44 w-full rounded-b-xl" />}>
    <div className="flex flex-col gap-3 px-6 pb-6 pt-3">
      <div className="grid grid-cols-4 gap-4 justify-items-start">
        {detailsFields
        ->Array.map(colType => {
          <DisplayKeyValueParams
            key={LogicUtils.randomString(~length=10)}
            heading={ReconEngineFileManagementEntity.getIngestionConfigHeading(colType)}
            value={ReconEngineFileManagementEntity.getIngestionConfigCell(
              ingestionConfigData,
              colType,
            )}
          />
        })
        ->React.array}
      </div>
      <div className="flex flex-row gap-4">
        <Button buttonType=Secondary text="View File" customButtonStyle="!w-fit" />
        <Button buttonType=Secondary text="Download" customButtonStyle="!w-fit" />
        <Button buttonType=Secondary text="Timeline" customButtonStyle="!w-fit" />
      </div>
    </div>
  </PageLoaderWrapper>
}
