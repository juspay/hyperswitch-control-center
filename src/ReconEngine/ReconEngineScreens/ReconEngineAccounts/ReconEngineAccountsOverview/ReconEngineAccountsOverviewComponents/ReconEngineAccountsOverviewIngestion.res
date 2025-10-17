open ReconEngineTypes

@react.component
let make = (~ingestionHistoryData: ingestionHistoryType) => {
  open ReconEngineAccountsSourcesTypes
  open LogicUtils
  open APIUtils
  open ReconEngineAccountsSourcesHelper
  open ReconEngineAccountsSourcesUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ingestionConfigData, setIngestionConfigData) = React.useState(_ =>
    Dict.make()->getIngestionConfigPayloadFromDict
  )
  let (showModal, setShowModal) = React.useState(_ => false)

  let fetchIngestionConfigDetails = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let ingestionConfigUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_CONFIG,
        ~id=Some(ingestionHistoryData.ingestion_id),
      )
      let ingestionConfigRes = await fetchDetails(ingestionConfigUrl)
      let ingestionConfigData =
        ingestionConfigRes
        ->getDictFromJsonObject
        ->getIngestionConfigPayloadFromDict
      setIngestionConfigData(_ => ingestionConfigData)

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let detailsFields: array<ReconEngineAccountsSourcesEntity.ingestionConfigColType> = [
    SourceConfigName,
    ConfigurationType,
    IngestionId,
    LastSyncAt,
  ]

  let getIngestionButtonActions = [
    {
      buttonType: ViewFile,
      onClick: _ => (),
      disabled: true,
    },
    {
      buttonType: Download,
      onClick: _ => (),
      disabled: true,
    },
    {
      buttonType: Timeline,
      onClick: ev => {
        ev->ReactEvent.Mouse.stopPropagation
        setShowModal(_ => true)
      },
      disabled: false,
    },
  ]

  React.useEffect(() => {
    fetchIngestionConfigDetails()->ignore
    None
  }, [ingestionHistoryData.ingestion_id])

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
            heading={ReconEngineAccountsSourcesEntity.getIngestionConfigHeading(colType)}
            value={ReconEngineAccountsSourcesEntity.getIngestionConfigCell(
              ingestionConfigData,
              colType,
            )}
          />
        })
        ->React.array}
      </div>
      <div className="flex flex-row gap-4">
        {getIngestionButtonActions
        ->Array.mapWithIndex((action, index) => {
          <Button
            key={index->Int.toString}
            buttonType=Secondary
            buttonState={action.disabled ? Disabled : Normal}
            text={(action.buttonType :> string)}
            onClick={action.onClick}
            customButtonStyle="!w-fit"
          />
        })
        ->React.array}
      </div>
      <ReconEngineAccountSourceFileTimeline
        showModal setShowModal ingestionHistoryId=ingestionHistoryData.ingestion_history_id
      />
    </div>
  </PageLoaderWrapper>
}
