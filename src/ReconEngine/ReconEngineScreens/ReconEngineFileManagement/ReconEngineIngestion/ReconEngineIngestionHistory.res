@react.component
let make = (~account: ReconEngineOverviewTypes.accountType, ~showModal) => {
  open APIUtils
  open ReconEngineFileManagementUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (ingestionHistoryData, setIngestionHistoryData) = React.useState(_ => [])
  let (filteredHistoryData, setFilteredHistoryData) = React.useState(_ => [])
  let (searchText, setSearchText) = React.useState(_ => "")
  let (offset, setOffset) = React.useState(_ => 0)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_ingestion_history_date_filter_opened")
  }

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ReconEngineFileManagementTypes.ingestionHistoryType>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.status, searchText) ||
          isContainingStringLowercase(obj.upload_type, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredHistoryData(_ => filteredList)
  }, ~wait=200)

  let fetchIngestionHistoryData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let queryString =
        ReconEngineUtils.buildQueryStringFromFilters(~filterValueJson)->String.concat(
          `&account_id=${account.account_id}`,
        )
      let stagingUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_HISTORY,
        ~queryParamerters=Some(queryString),
      )

      let res = await fetchDetails(stagingUrl)
      let ingestionHistoryList =
        res->LogicUtils.getArrayDataFromJson(ingestionHistoryItemToObjMapper)

      let ingestionHistoryData = ingestionHistoryList->Array.map(Nullable.make)
      setIngestionHistoryData(_ => ingestionHistoryData)
      setFilteredHistoryData(_ => ingestionHistoryData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="recon_engine_ingestion_history",
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchIngestionHistoryData()->ignore
    }
    None
  }, (filterValue, showModal))

  let topFilterUi = {
    <div className="flex flex-row">
      <DynamicFilter
        title="ReconEngineIngestionHistoryFilters"
        initialFilters={initialIngestionDisplayFilters()}
        options=[]
        popupFilterFields=[]
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineIngestionHistoryFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
  }

  <div className="flex flex-col gap-4 my-4">
    <div className="flex-shrink-0"> {topFilterUi} </div>
    <PageLoaderWrapper screenState>
      <LoadedTable
        title="Ingestion History"
        hideTitle=true
        actualData={filteredHistoryData}
        entity={ReconEngineFileManagementEntity.ingestionHistoryTableEntity(
          `v1/recon-engine/file-management`,
          ~authorization=Access,
        )}
        resultsPerPage=50
        totalResults={filteredHistoryData->Array.length}
        offset
        setOffset
        currrentFetchCount={filteredHistoryData->Array.length}
        tableheadingClass="h-12"
        tableHeadingTextClass="!font-normal"
        nonFrozenTableParentClass="!rounded-lg"
        loadedTableParentClass="flex flex-col"
        enableEqualWidthCol=false
        showAutoScroll=true
        filters={<TableSearchFilter
          data={ingestionHistoryData}
          filterLogic
          placeholder="Search by Status or Upload Type"
          customSearchBarWrapperWidth="w-full lg:w-1/3"
          customInputBoxWidth="w-full rounded-xl"
          searchVal=searchText
          setSearchVal=setSearchText
        />}
      />
    </PageLoaderWrapper>
  </div>
}
