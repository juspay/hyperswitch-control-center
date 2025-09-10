open Typography

@react.component
let make = (~account: ReconEngineOverviewTypes.accountType) => {
  open TableUtils
  open APIUtils
  open LogicUtils
  open ReconEngineFileManagementUtils
  open ReconEngineAccountsTransformationUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (transformationHistoryList, setTransformationHistoryList) = React.useState(_ => [
    Dict.make()->transformationHistoryItemToObjMapper,
  ])

  let fetchTransformationHistoryData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let transformationHistoryUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParamerters=Some(`account_id=${account.account_id}`),
      )
      let transformationHistoryRes = await fetchDetails(transformationHistoryUrl)
      let transformationHistoryList =
        transformationHistoryRes->getArrayDataFromJson(transformationHistoryItemToObjMapper)

      setTransformationHistoryList(_ => transformationHistoryList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let (percentage, _label, labelColor) = React.useMemo(() => {
    getHealthyStatus(~transformationHistoryList)
  }, [transformationHistoryList])

  React.useEffect(() => {
    fetchTransformationHistoryData()->ignore
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
