open Typography

@react.component
let make = (~config: ReconEngineFileManagementTypes.ingestionConfigType, ~tabIndex: string) => {
  open TableUtils
  open ReconEngineFileManagementUtils
  open ReconEngineAccountsSourcesUtils
  open ReconEngineAccountsSourcesHelper

  let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ingestionHistoryList, setIngestionHistoryList) = React.useState(_ => [
    Dict.make()->ingestionHistoryItemToObjMapper,
  ])

  let fetchIngestionHistoryData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let ingestionHistoryList = await getIngestionHistory(
        ~queryParamerters=Some(`ingestion_id=${config.ingestion_id}`),
      )
      setIngestionHistoryList(_ => ingestionHistoryList)
      setScreenState(_ => PageLoaderWrapper.Success)
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
    <Link
      to_={GlobalVars.appendDashboardPath(
        ~url=`/v1/recon-engine/sources/${config.account_id}?tabIndex=${tabIndex}`,
      )}
      className="p-5 border border-nd_gray-200 rounded-lg hover:border-nd_primary_blue-400 transition-colors duration-200 cursor-pointer">
      <div
        className="flex md:flex-row items-center justify-between w-full border-b pb-2 border-nd_gray-150">
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
      <div className="mt-4 grid grid-cols-2 items-center justify-items-between gap-x-32 gap-y-4">
        {sourceConfigItems
        ->Array.map(item => {
          <SourceConfigItem key={item.label->sourceConfigLabelToString} data={item} />
        })
        ->React.array}
      </div>
    </Link>
  </PageLoaderWrapper>
}
