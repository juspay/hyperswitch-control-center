open Typography

@react.component
let make = (~account: ReconEngineOverviewTypes.accountType) => {
  open APIUtils
  open TableUtils
  open LogicUtils
  open ReconEngineFileManagementUtils

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
        ~queryParamerters=Some(`account_id=${account.account_id}`),
      )
      let res = await fetchDetails(stagingUrl)
      let ingestionHistoryList = res->getArrayDataFromJson(ingestionHistoryItemToObjMapper)
      setIngestionHistoryList(_ => ingestionHistoryList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => ()
    }
  }

  let (processedPercentage, labelColor) = React.useMemo(() => {
    let total = ingestionHistoryList->Array.length->Int.toFloat
    let processed =
      ingestionHistoryList
      ->Array.filter(item => item.status->statusMapper == Processed)
      ->Array.length
      ->Int.toFloat
    let percentage = valueFormatter(processed *. 100.0 /. total, Rate)
    (
      percentage,
      if percentage->Float.fromString >= Some(90.0) {
        LabelGreen
      } else {
        LabelRed
      },
    )
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
          title: `${processedPercentage} Files Processed`,
          color: labelColor,
        })}
        textAlign=Table.Left
        labelMargin="!py-0"
      />
    </PageLoaderWrapper>
  </div>
}
