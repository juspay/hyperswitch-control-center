open Typography

@react.component
let make = (~account: ReconEngineTypes.accountType) => {
  open TableUtils
  open ReconEngineDataSourcesUtils

  let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let (ingestionHistoryList, setIngestionHistoryList) = React.useState(_ => [
    Dict.make()->getIngestionHistoryPayloadFromDict,
  ])

  let fetchIngestionHistoryData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let ingestionHistoryList = await getIngestionHistory(
        ~queryParameters=Some(`account_id=${account.account_id}`),
      )
      setIngestionHistoryList(_ => ingestionHistoryList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Success)
    }
  }

  let (percentage, _label, labelColor) = React.useMemo(() => {
    getHealthyStatus(~ingestionHistoryList)
  }, [ingestionHistoryList])

  React.useEffect(() => {
    fetchIngestionHistoryData()->ignore
    None
  }, [])

  <div className="ml-5 flex flex-row items-center justify-between w-full">
    <div className={`${body.lg.semibold} text-nd_gray-800`}>
      {React.string(account.account_name)}
    </div>
    <PageLoaderWrapper screenState customLoader={<Shimmer styleClass="h-5 w-10 rounded-lg" />}>
      <Table.TableCell
        cell={Label({
          title: `${percentage} Files Processed`,
          color: labelColor,
        })}
        textAlign=Table.Left
        labelMargin="!py-0"
      />
    </PageLoaderWrapper>
  </div>
}
