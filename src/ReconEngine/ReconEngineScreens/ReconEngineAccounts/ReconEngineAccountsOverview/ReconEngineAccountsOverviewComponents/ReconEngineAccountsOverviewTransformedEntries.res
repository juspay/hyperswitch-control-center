@react.component
let make = (
  ~selectedTransformationHistoryId,
  ~onNeedsManualReviewPresent=?,
  ~stagingEntryId: option<string>,
) => {
  open LogicUtils
  open ReconEngineAccountsTransformedEntriesUtils
  open ReconEngineFilterUtils
  open ReconEngineTypes
  open ReconEngineHooks

  let getGetProcessingEntries = useGetProcessingEntries()
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

  let filterDataBySearchText = (data: array<processingEntryType>, searchText: string) => {
    if searchText->isNonEmptyString {
      data->Array.filter((obj: processingEntryType) => {
        isContainingStringLowercase(obj.staging_entry_id, searchText) ||
        isContainingStringLowercase((obj.status :> string), searchText)
      })
    } else {
      data
    }
  }

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<processingEntryType>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.staging_entry_id, searchText) ||
          isContainingStringLowercase((obj.status :> string), searchText) ||
          isContainingStringLowercase(obj.order_id, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredStagingData(_ => filteredList)
  }, ~wait=200)

  let fetchStagingData = async () => {
    if selectedTransformationHistoryId->isNonEmptyString {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let enhancedFilterValueJson = Dict.copy(filterValueJson)
        let statusFilter = filterValueJson->getArrayFromDict("status", [])
        if statusFilter->Array.length == 0 {
          enhancedFilterValueJson->Dict.set(
            "status",
            ["pending", "processed", "needs_manual_review"]->getJsonFromArrayOfString,
          )
        }
        let queryString =
          ReconEngineFilterUtils.buildQueryStringFromFilters(
            ~filterValueJson=enhancedFilterValueJson,
          )->String.concat(`&transformation_history_id=${selectedTransformationHistoryId}`)

        let stagingList = await getGetProcessingEntries(~queryParamerters=Some(queryString))
        let initialSearchText = stagingEntryId->Option.getOr("")
        let filteredList = filterDataBySearchText(stagingList, initialSearchText)
        if stagingEntryId->Option.isSome {
          setSearchText(_ => initialSearchText)
        }

        setStagingData(_ => stagingList)
        setFilteredStagingData(_ => filteredList->Array.map(Nullable.make))
        let isNeedsManualReviewPresent =
          stagingList->Array.some(entry => entry.status === NeedsManualReview)
        switch onNeedsManualReviewPresent {
        | Some(callback) => callback(isNeedsManualReviewPresent)
        | None => ()
        }
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
      }
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

  let accountOptions = React.useMemo(() => {
    getAccountOptionsFromStagingEntries(stagingData)
  }, [stagingData])

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchStagingData()->ignore
    }
    None
  }, (filterValue, stagingEntryId))

  let topFilterUi = {
    <div className="flex flex-row -ml-1.5">
      <DynamicFilter
        title="ReconEngineExceptionStagingFilters"
        initialFilters={initialDisplayFilters(~accountOptions)}
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
  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData height="h-96" message="No data available." />}
    customLoader={<Shimmer styleClass="h-96 w-full rounded-b-xl" />}>
    <div className="flex flex-col gap-4 my-4 px-6 pb-16">
      <ReconEngineAccountsTransformedEntriesOverviewCards
        selectedTransformationHistoryId=Some(selectedTransformationHistoryId)
      />
      <div className="flex-shrink-0"> {topFilterUi} </div>
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
          data={stagingData->Array.map(Nullable.make)}
          filterLogic
          placeholder="Search Staging Entry ID or Order ID or Status"
          customSearchBarWrapperWidth="w-full lg:w-1/3"
          customInputBoxWidth="w-full rounded-xl"
          searchVal=searchText
          setSearchVal=setSearchText
        />}
      />
    </div>
  </PageLoaderWrapper>
}
