open Typography

@react.component
let make = (~selectedIngestionHistory: ReconEngineFileManagementTypes.ingestionHistoryType) => {
  open LogicUtils
  open APIUtils
  open ReconEngineFileManagementUtils
  open ReconEngineIngestionHelper

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (transformationHistoryData, setTransformationHistoryData) = React.useState(_ => [])
  let (accountData, setAccountData) = React.useState(_ =>
    Dict.make()->ReconEngineOverviewUtils.accountItemToObjMapper
  )

  let fetchTransformationHistoryData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let transformationHistoryUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParamerters=Some(
          `ingestion_history_id=${selectedIngestionHistory.ingestion_history_id}`,
        ),
      )
      let res = await fetchDetails(transformationHistoryUrl)
      let transformationHistoryList =
        res->getArrayDataFromJson(transformationHistoryItemToObjMapper)
      let accountUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#ACCOUNTS_LIST,
        ~id=Some(selectedIngestionHistory.account_id),
      )
      let res = await fetchDetails(accountUrl)
      let accountData = res->getDictFromJsonObject->ReconEngineOverviewUtils.accountItemToObjMapper
      setAccountData(_ => accountData)
      setTransformationHistoryData(_ => transformationHistoryList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    fetchTransformationHistoryData()->ignore
    None
  }, [])

  <PageLoaderWrapper
    screenState
    customLoader={<div className="h-full flex flex-col justify-center items-center">
      <div className="animate-spin">
        <Icon name="spinner" size=20 />
      </div>
    </div>}>
    <div className="flex flex-col gap-2 mt-4">
      <h1 className={`${body.lg.semibold} text-nd_gray-800`}>
        {"Transformation History"->React.string}
      </h1>
      <p className={`${body.md.regular} text-nd_gray-600`}>
        {"Check the transformation history for the selected ingestion."->React.string}
      </p>
    </div>
    <div className="flex flex-col gap-4 mt-4 w-full">
      {transformationHistoryData
      ->Array.map(transformationHistory => {
        <>
          <TransformationHistoryDetailsInfo
            transformationHistoryData=transformationHistory
            detailsFields=[TransformationName, Status, ProcessedAt]
            accountData
          />
        </>
      })
      ->React.array}
    </div>
  </PageLoaderWrapper>
}
