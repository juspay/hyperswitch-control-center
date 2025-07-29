@react.component
let make = () => {
  open LogicUtils
  open APIUtils
  open ReconEngineExceptionStagingUtils
  open ReconEngineExceptionTypes

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (stagingData, setStagingData) = React.useState(_ => [])
  let (filteredStagingData, setFilteredStagingData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

  let mixpanelEvent = MixpanelHook.useSendEvent()

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_exception_staging_date_filter_opened")
  }

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
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let queryString =
        ReconEngineUtils.buildQueryStringFromFilters(~filterValueJson)->String.concat(
          "&status=needs_manual_review",
        )
      let stagingUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST,
        ~queryParamerters=Some(queryString),
      )

      let res = await fetchDetails(stagingUrl)
      let stagingList = res->LogicUtils.getArrayDataFromJson(processingItemToObjMapper)

      let stagingDataList = stagingList->Array.map(Nullable.make)
      setStagingData(_ => stagingDataList)
      setFilteredStagingData(_ => stagingDataList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="recon_engine_exception_staging",
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
    <div className="flex flex-row">
      <DynamicFilter
        title="ReconEngineExceptionStagingFilters"
        initialFilters={initialDisplayFilters()}
        options=[]
        popupFilterFields=[]
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineExceptionStagingFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
        setOffset
      />
    </div>
  }

  <div className="flex flex-col gap-4 my-4">
    <div className="flex-shrink-0"> {topFilterUi} </div>
    <PageLoaderWrapper screenState>
      <LoadedTable
        title="Staging Entries"
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
        showAutoScroll=true
        filters={<TableSearchFilter
          data={stagingData}
          filterLogic
          placeholder="Search Staging Entry ID or Status"
          customSearchBarWrapperWidth="w-full lg:w-1/3"
          customInputBoxWidth="w-full rounded-xl"
          searchVal=searchText
          setSearchVal=setSearchText
        />}
      />
    </PageLoaderWrapper>
  </div>
}
