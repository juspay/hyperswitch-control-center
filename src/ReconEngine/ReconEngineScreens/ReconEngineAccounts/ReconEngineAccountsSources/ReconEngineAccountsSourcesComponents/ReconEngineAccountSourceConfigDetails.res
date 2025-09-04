open Typography

@react.component
let make = (~config: ReconEngineConnectionType.connectionType) => {
  open APIUtils
  open LogicUtils
  open TableUtils
  open ReconEngineFileManagementUtils
  open ReconEngineAccountsSourcesUtils
  open ReconEngineAccountsSourcesHelper

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ingestionHistoryList, setIngestionHistoryList) = React.useState(_ => [
    Dict.make()->ingestionHistoryItemToObjMapper,
  ])

  let fetchIngestionHistoryData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let stagingUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_HISTORY,
        ~queryParamerters=Some(`ingestion_id=${config.ingestion_id}`),
      )
      let res = await fetchDetails(stagingUrl)
      let ingestionHistoryList = res->getArrayDataFromJson(ingestionHistoryItemToObjMapper)
      if ingestionHistoryList->Array.length > 0 {
        setIngestionHistoryList(_ => ingestionHistoryList)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    fetchIngestionHistoryData()->ignore
    None
  }, [config.ingestion_id])

  let sourceConfigItems = React.useMemo(() => {
    ReconEngineAccountsSourcesUtils.getSourceConfigData(~config, ~ingestionHistoryList)
  }, (config, ingestionHistoryList))

  let (_percentage, label, labelColor) = React.useMemo(() => {
    getHealthyStatus(~ingestionHistoryList)
  }, [ingestionHistoryList])

  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData height="h-44" message="No data available." />}
    customLoader={<Shimmer styleClass="h-44 w-full rounded-xl" />}>
    <div
      className="p-5 border border-nd_gray-200 rounded-lg hover:border-nd_primary_blue-400 transition-colors duration-200 cursor-pointer">
      <div
        className="flex flex-row items-center justify-between w-full border-b pb-2 border-nd_gray-150">
        <p className={`${body.md.semibold} text-nd_gray-800`}> {config.name->React.string} </p>
        <Table.TableCell
          cell={Label({
            title: label,
            color: labelColor,
          })}
          textAlign=Table.Left
          labelMargin="!py-0"
        />
      </div>
      <div className="mt-4 grid grid-cols-2 gap-x-32 gap-y-4">
        {sourceConfigItems
        ->Array.map(item => {
          <SourceConfigItem key={item.label->sourceConfigLabelToString} data={item} />
        })
        ->React.array}
      </div>
    </div>
  </PageLoaderWrapper>
}
