open Typography

@react.component
let make = (~breadCrumbNavigationPath, ~ingestionHistoryId) => {
  open LogicUtils
  open APIUtils
  open ReconEngineAccountsOverviewUtils
  open ReconEngineAccountsUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let url = RescriptReactRouter.useUrl()
  let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ingestionHistoryData, setIngestionHistoryData) = React.useState(_ =>
    Dict.make()->getAccountsOverviewIngestionHistoryPayloadFromDict
  )
  let (accountData, setAccountData) = React.useState(_ => Dict.make()->getAccountPayloadFromDict)
  let (selectedTransformationHistoryId, setSelectedTransformationHistoryId) = React.useState(_ =>
    ""
  )

  let (transformationStatus, setTransformationStatus) = React.useState(_ => #Loading)
  let (manualReviewStatus, setManualReviewStatus) = React.useState(_ => #Loading)
  let (transformationHistoryId, setTransformationHistoryId) = React.useState(_ => None)
  let (stagingEntryId, setStagingEntryId) = React.useState(_ => None)

  let fetchIngestionHistoryData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let ingestionHistoryList = await getIngestionHistory(
        ~queryParamerters=Some(`ingestion_history_id=${ingestionHistoryId}`),
      )
      ingestionHistoryList->Array.sort(sortByDescendingVersion)
      let latestIngestionHistory =
        ingestionHistoryList->getValueFromArray(
          0,
          Dict.make()->getAccountsOverviewIngestionHistoryPayloadFromDict,
        )
      setIngestionHistoryData(_ => latestIngestionHistory)
      let accountUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#ACCOUNTS_LIST,
        ~id=Some(latestIngestionHistory.account_id),
      )
      let accountRes = await fetchDetails(accountUrl)
      let accountData = accountRes->getDictFromJsonObject->getAccountPayloadFromDict
      setAccountData(_ => accountData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    fetchIngestionHistoryData()->ignore
    None
  }, [])

  let getActiveTabIndex = () => {
    let transformationHistoryId =
      url.search
      ->getDictFromUrlSearchParams
      ->getvalFromDict("transformationHistoryId")
    let stagingEntryId =
      url.search
      ->getDictFromUrlSearchParams
      ->getvalFromDict("stagingEntryId")
    setTransformationHistoryId(_ => transformationHistoryId)
    setStagingEntryId(_ => stagingEntryId)
  }

  React.useEffect(() => {
    getActiveTabIndex()
    None
  }, [url.search])

  let initialExpandedArray = React.useMemo(() => {
    if Option.isSome(stagingEntryId) {
      2
    } else if Option.isSome(transformationHistoryId) {
      1
    } else {
      0
    }
  }, transformationHistoryId)

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-6 w-full">
      <BreadCrumbNavigation
        path={breadCrumbNavigationPath}
        currentPageTitle=accountData.account_name
        cursorStyle="cursor-pointer"
        dividerVal=Slash
        childGapClass="gap-2"
      />
      <div className="flex flex-col gap-10">
        <PageUtils.PageHeading
          title=ingestionHistoryData.file_name
          customTitleStyle={`${heading.lg.semibold}`}
          customHeadingStyle="py-0"
        />
        <Accordion
          initialExpandedArray={initialExpandedArray->Array.make(~length=1)}
          accordion={ReconEngineAccountsOverviewHelper.getAccordionConfig(
            ~ingestionHistoryData,
            ~transformationStatus,
            ~setTransformationStatus,
            ~selectedTransformationHistoryId,
            ~setSelectedTransformationHistoryId,
            ~manualReviewStatus,
            ~setManualReviewStatus,
            ~transformationHistoryId,
            ~stagingEntryId,
          )}
          accordianTopContainerCss="!border !border-nd_gray-150 !rounded-xl !overflow-scroll"
          accordianBottomContainerCss="!p-4 !bg-nd_gray-25 !rounded-xl !overflow-scroll"
          contentExpandCss={`!${body.md.semibold} !rounded-b-xl !overflow-scroll`}
          titleStyle={`${body.lg.semibold} !text-nd_gray-800`}
          gapClass="flex flex-col gap-8"
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
