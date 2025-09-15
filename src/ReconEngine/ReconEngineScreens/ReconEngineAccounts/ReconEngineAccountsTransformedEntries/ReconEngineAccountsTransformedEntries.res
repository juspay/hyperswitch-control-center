open Typography

@react.component
let make = () => {
  open LogicUtils
  open APIUtils
  open ReconEngineAccountsTransformedEntriesUtils
  open ReconEngineExceptionTypes
  open ReconEngineFileManagementUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )

  let (stagingData, setStagingData) = React.useState(_ => [])
  let (filteredStagingData, setFilteredStagingData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

  let mixpanelEvent = MixpanelHook.useSendEvent()

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_accounts_transformed_entries_date_filter_opened")
  }

  let accountOptions = React.useMemo(() => {
    getAccountOptionsFromStagingData(stagingData)
  }, [stagingData])

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<processingEntryType>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.staging_entry_id, searchText) ||
          isContainingStringLowercase(obj.status, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredStagingData(_ => filteredList)
  }, ~wait=200)

  let fetchStagingData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryString = ReconEngineUtils.buildQueryStringFromFilters(~filterValueJson)
      let stagingUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST,
        ~queryParamerters=Some(queryString),
      )
      let res = await fetchDetails(stagingUrl)
      let stagingList =
        res->LogicUtils.getArrayDataFromJson(
          ReconEngineExceptionStagingUtils.processingItemToObjMapper,
        )

      setStagingData(_ => stagingList)
      setFilteredStagingData(_ => stagingList->Array.map(Nullable.make))

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="recon_engine_accounts_transformed_entries",
    ~range=180,
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchStagingData()->ignore
    }
    None
  }, [filterValue])

  let topFilterUi = {
    <div className="flex flex-row -ml-1.5">
      <DynamicFilter
        title="ReconEngineAccountsTransformedEntriesFilters"
        initialFilters={initialDisplayFilters(~accountOptions)}
        options=[]
        popupFilterFields=[]
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineAccountsTransformedEntriesFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
        setOffset
      />
    </div>
  }

  let onEntityClick = async transformedEntry => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParamerters=None,
        ~id=Some(transformedEntry.transformation_history_id),
      )
      let res = await fetchDetails(url)
      let transformationHistoryData =
        res->getDictFromJsonObject->transformationHistoryItemToObjMapper

      RescriptReactRouter.push(
        GlobalVars.appendDashboardPath(
          ~url=`/v1/recon-engine/transformed-entries/ingestion-history/${transformationHistoryData.ingestion_history_id}?stagingEntryId=${transformedEntry.staging_entry_id}`,
        ),
      )
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  <div className="flex flex-col gap-5 w-full">
    <div className="flex flex-row justify-between items-center">
      <PageUtils.PageHeading
        title="Transformed Entries"
        customTitleStyle={`${heading.lg.semibold}`}
        customHeadingStyle="py-0"
      />
    </div>
    <ReconEngineAccountsTransformedEntriesOverviewCards />
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-4">
        <div className="flex-shrink-0"> {topFilterUi} </div>
        <LoadedTable
          title="Transformed Entries"
          hideTitle=true
          actualData={filteredStagingData}
          entity={ReconEngineExceptionEntity.processingTableEntity}
          resultsPerPage=10
          totalResults={filteredStagingData->Array.length}
          offset
          setOffset
          currrentFetchCount={filteredStagingData->Array.length}
          tableheadingClass="h-12"
          tableHeadingTextClass="!font-normal"
          nonFrozenTableParentClass="!rounded-lg"
          loadedTableParentClass="flex flex-col"
          enableEqualWidthCol=false
          onEntityClick={val => {
            onEntityClick(val)->ignore
          }}
          showAutoScroll=true
          filters={<TableSearchFilter
            data={stagingData->Array.map(Nullable.make)}
            filterLogic
            placeholder="Search Staging Entry ID or Status"
            customSearchBarWrapperWidth="w-full lg:w-1/3"
            customInputBoxWidth="w-full rounded-xl"
            searchVal=searchText
            setSearchVal=setSearchText
          />}
        />
      </div>
    </PageLoaderWrapper>
  </div>
}
