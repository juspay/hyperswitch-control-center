open Typography
open ReconEngineTypes
open LogicUtils

@react.component
let make = (~ingestionHistoryId: string) => {
  open ReconEngineDataOverviewUtils
  open ReconEnginePipelinesUtils

  let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()
  let getTransformationHistory = ReconEngineHooks.useGetTransformationHistory()
  let getAccounts = ReconEngineHooks.useGetAccounts()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (latestIngestionHistory, setLatestIngestionHistory) = React.useState(_ =>
    Dict.make()->ReconEngineDataSourcesUtils.getIngestionHistoryPayloadFromDict
  )
  let (transformationHistory, setTransformationHistory) = React.useState(_ => [])
  let (accountData, setAccountData) = React.useState(_ => [])
  let (showErrorsModal, setShowErrorsModal) = React.useState(_ => false)

  let fetchPipelineDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryString = `ingestion_history_id=${ingestionHistoryId}`
      let ingestionHistoryFetch = getIngestionHistory(~queryParameters=Some(queryString))
      let transformationHistoryFetch = getTransformationHistory(~queryParameters=Some(queryString))
      let accountsFetch = getAccounts()
      let (ingestionHistoryList, transformationHistoryList, accounts) = await Promise.all3((
        ingestionHistoryFetch,
        transformationHistoryFetch,
        accountsFetch,
      ))
      ingestionHistoryList->Array.sort(sortByDescendingVersion)
      let latestIngestionHistory =
        ingestionHistoryList->getValueFromArray(
          0,
          Dict.make()->ReconEngineDataSourcesUtils.getIngestionHistoryPayloadFromDict,
        )

      setLatestIngestionHistory(_ => latestIngestionHistory)
      setTransformationHistory(_ => transformationHistoryList)
      setAccountData(_ => accounts)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch pipeline details"))
    }
  }

  React.useEffect(() => {
    fetchPipelineDetails()->ignore
    None
  }, [ingestionHistoryId])

  let accountName = ReconEnginePipelinesTableEntity.getAccountName(
    ~accountData,
    latestIngestionHistory.account_id,
  )

  let errorItems = React.useMemo(() => {
    transformationHistory->getTransformationErrors
  }, [transformationHistory])

  let statCards = React.useMemo(() => {
    getPipelineDetailStatCards(
      ~transformationHistory,
      ~totalErrors=errorItems->Array.length,
      ~onErrorsClick=() => setShowErrorsModal(_ => true),
    )
  }, (transformationHistory, errorItems))

  <PageLoaderWrapper screenState>
    <div className="w-full flex flex-col gap-6">
      <BreadCrumbNavigation
        path=[{title: "Pipelines", link: "/v1/recon-engine/pipelines"}]
        currentPageTitle=latestIngestionHistory.ingestion_history_id
      />
      <div className="border border-nd_gray-200 rounded-xl bg-white overflow-hidden">
        <div className="p-5">
          <div className="flex items-start justify-between gap-4">
            <div className="flex items-start gap-3">
              <div
                className="w-9 h-9 rounded-lg border border-nd_gray-200 bg-nd_gray-50 flex items-center justify-center flex-shrink-0">
                <Icon name="nd-file" size=16 className="text-nd_gray-500" />
              </div>
              <div>
                <div className="flex items-center gap-2 flex-wrap mb-1">
                  <p className={`${heading.sm.semibold} text-nd_gray-800 truncate`}>
                    {latestIngestionHistory.file_name->React.string}
                  </p>
                  <TableUtils.LabelCell
                    labelColor={switch latestIngestionHistory.status {
                    | Processed => LabelGreen
                    | Failed => LabelRed
                    | Processing => LabelOrange
                    | Pending => LabelYellow
                    | Discarded | UnknownIngestionTransformationStatus => LabelGray
                    }}
                    text={(latestIngestionHistory.status :> string)->capitalizeString}
                  />
                  <RenderIf condition={latestIngestionHistory.version > 0}>
                    <span
                      className={`${body.xs.medium} px-2 py-0.5 rounded-full bg-nd_gray-100 text-nd_gray-500 border border-nd_gray-200`}>
                      {`v${latestIngestionHistory.version->Int.toString}`->React.string}
                    </span>
                  </RenderIf>
                </div>
                <p className={`${body.sm.regular} text-nd_gray-400`}>
                  {`${latestIngestionHistory.upload_type}
                    }${accountName->isNonEmptyString ? ` · ${accountName}` : ""}`->React.string}
                </p>
              </div>
            </div>
            <div
              className="flex flex-col items-end justify-center min-w-150-px min-h-9 flex-shrink-0">
              <TableUtils.DateCell
                timestamp=latestIngestionHistory.created_at
                textAlign=Right
                isCard=true
                textStyle={`${body.sm.semibold} text-nd_gray-700`}
              />
            </div>
          </div>
        </div>
        <div className="border-t border-nd_gray-150 flex divide-x divide-nd_gray-150">
          {statCards
          ->Array.mapWithIndex((card, index) =>
            <ReconEnginePipelinesHelper.StatCard
              key={index->Int.toString}
              label=card.pipelineDetailStatCardLabel
              value=card.pipelineDetailStatCardValue
              desc=card.pipelineDetailStatCardDesc
              descColor=card.pipelineDetailStatCardDescColor
              onClick=?card.pipelineDetailStatCardOnClick
            />
          )
          ->React.array}
        </div>
      </div>
      <ReconEnginePipelinesHelper.ErrorsModal
        showModal=showErrorsModal setShowModal=setShowErrorsModal errors=errorItems
      />
    </div>
  </PageLoaderWrapper>
}
