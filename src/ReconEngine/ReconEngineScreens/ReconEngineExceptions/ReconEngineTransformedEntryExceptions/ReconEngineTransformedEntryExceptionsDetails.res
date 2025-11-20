open Typography

@react.component
let make = (~id) => {
  open APIUtils
  open LogicUtils
  open ReconEngineUtils
  open ReconEngineTransformedEntryExceptionsHelper
  open ReconEngineHooks

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let getProcessingEntries = useGetProcessingEntries()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (currentTransformedEntryDetails, setCurrentTransformedEntryDetails) = React.useState(_ =>
    Dict.make()->processingItemToObjMapper
  )
  let (updatedTransformedEntryDetails, setUpdatedTransformedEntryDetails) = React.useState(_ =>
    Dict.make()->processingItemToObjMapper
  )
  let (allTransformedEntryDetails, setAllTransformedEntryDetails) = React.useState(_ => [
    Dict.make()->processingItemToObjMapper,
  ])

  let getTransformedEntryDetails = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let currentTransformedEntryUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST,
        ~id=Some(id),
      )
      let res = await fetchDetails(currentTransformedEntryUrl)
      let currentTransformedEntry = res->getDictFromJsonObject->processingItemToObjMapper
      setCurrentTransformedEntryDetails(_ => currentTransformedEntry)
      setUpdatedTransformedEntryDetails(_ => currentTransformedEntry)
      let transformedEntriesList = await getProcessingEntries(
        ~queryParamerters=Some(`staging_entry_id=${currentTransformedEntry.staging_entry_id}`),
      )
      setAllTransformedEntryDetails(_ => transformedEntriesList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch transformed entry details"))
    }
  }

  React.useEffect(() => {
    getTransformedEntryDetails()->ignore
    None
  }, [])

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    [
      {
        title: "Entry Details",
        renderContent: () =>
          <ReconEngineTransformedEntryExceptionEntry
            currentTransformedEntryDetails
            setUpdatedTransformedEntryDetails
            updatedTransformedEntryDetails
          />,
      },
      {
        title: "Audit Trail",
        renderContent: () => <AuditTrail allTransactionDetails=allTransformedEntryDetails />,
      },
    ]
  }, (allTransformedEntryDetails, currentTransformedEntryDetails, updatedTransformedEntryDetails))

  <>
    <div className="flex flex-col gap-4">
      <BreadCrumbNavigation
        path=[
          {
            title: "Transformed Entry Exceptions",
            link: `/v1/recon-engine/transformed-entry-exceptions`,
          },
        ]
        currentPageTitle=id
        cursorStyle="cursor-pointer"
        customTextClass="text-nd_gray-400"
        titleTextClass="text-nd_gray-600 font-medium"
        fontWeight="font-medium"
        dividerVal=Slash
        childGapClass="gap-2"
      />
      <PageUtils.PageHeading title="Transformed Entry Detail" />
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exists in out record" renderType=NotFound
      />}>
      <div className="flex flex-col gap-4">
        <TransformedEntryDetailsInfo
          currentProcessingEntryDetails={currentTransformedEntryDetails}
          detailsFields=[StagingEntryId, Status, AccountName, EffectiveAt]
        />
        <Tabs
          tabs
          showBorder=true
          includeMargin=false
          defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center ${body.md.semibold}`}
          selectTabBottomBorderColor="bg-primary"
        />
      </div>
    </PageLoaderWrapper>
  </>
}
