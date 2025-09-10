open Typography

@react.component
let make = (~id) => {
  open LogicUtils
  open APIUtils
  open ReconEngineFileManagementUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ingestionHistoryData, setIngestionHistoryData) = React.useState(_ =>
    Dict.make()->ingestionHistoryItemToObjMapper
  )
  let (accountData, setAccountData) = React.useState(_ =>
    Dict.make()->ReconEngineOverviewUtils.accountItemToObjMapper
  )
  let (selectedTransformationHistoryId, setSelectedTransformationHistoryId) = React.useState(_ =>
    ""
  )

  let (transformationStatus, setTransformationStatus) = React.useState(_ => #Loading)
  let (manualReviewStatus, setManualReviewStatus) = React.useState(_ => #Loading)

  let fetchIngestionHistoryData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let ingestionHistoryUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_HISTORY,
        ~id=Some(id),
      )
      let ingestionHistoryRes = await fetchDetails(ingestionHistoryUrl)
      let ingestionHistoryData =
        ingestionHistoryRes->getDictFromJsonObject->ingestionHistoryItemToObjMapper
      setIngestionHistoryData(_ => ingestionHistoryData)

      let accountUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#ACCOUNTS_LIST,
        ~id=Some(ingestionHistoryData.account_id),
      )
      let accountRes = await fetchDetails(accountUrl)
      let accountData =
        accountRes->getDictFromJsonObject->ReconEngineOverviewUtils.accountItemToObjMapper
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

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-6 w-full">
      <BreadCrumbNavigation
        path=[{title: "Ingestion", link: `/v1/recon-engine/sources/${accountData.account_id}`}]
        currentPageTitle=accountData.account_name
        cursorStyle="cursor-pointer"
        customTextClass="text-nd_gray-400"
        titleTextClass="text-nd_gray-600 font-medium"
        fontWeight="font-medium"
        dividerVal=Slash
        childGapClass="gap-2"
      />
      <div className="flex flex-col gap-10 mb-12">
        <PageUtils.PageHeading
          title=ingestionHistoryData.file_name
          customTitleStyle={`${heading.lg.semibold}`}
          customHeadingStyle="py-0"
        />
        <Accordion
          initialExpandedArray=[0]
          accordion={ReconEngineAccountsOverviewHelper.getAccordionConfig(
            ~ingestionHistoryData,
            ~transformationStatus,
            ~setTransformationStatus,
            ~selectedTransformationHistoryId,
            ~setSelectedTransformationHistoryId,
            ~manualReviewStatus,
            ~setManualReviewStatus,
          )}
          accordianTopContainerCss="!border !border-nd_gray-150 !rounded-xl !overflow-visible"
          accordianBottomContainerCss="!p-4 !bg-nd_gray-25 !rounded-xl"
          contentExpandCss={`!${body.md.semibold} !rounded-b-xl`}
          titleStyle={`${body.lg.semibold} !text-nd_gray-800`}
          gapClass="flex flex-col gap-8"
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
