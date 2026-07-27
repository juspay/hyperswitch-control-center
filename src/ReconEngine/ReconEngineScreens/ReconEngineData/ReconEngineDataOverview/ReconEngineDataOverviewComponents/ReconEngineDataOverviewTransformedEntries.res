@react.component
let make = (
  ~selectedTransformationHistoryId,
  ~onNeedsManualReviewPresent=?,
  ~stagingEntryId: option<string>,
) => {
  open LogicUtils
  open ReconEngineDataTransformedEntriesUtils
  open ReconEngineDataTransformedEntriesTypes
  open ReconEngineTypes
  open ReconEngineHooks

  let getProcessingEntriesV2 = useGetCursorPage(
    ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST_V2,
    ~itemMapper=ReconEngineUtils.processingItemToObjMapper,
  )
  let getStagingEntriesOverview = useGetStagingEntriesOverview()
  let getAccounts = useGetAccounts()
  let showToast = ToastAdapter.useShowToast()
  let (accountData, setAccountData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let searchTypeRef = React.useRef(SearchStagingEntryId)
  let (searchText, setSearchText) = React.useState(_ => stagingEntryId->Option.getOr(""))
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

  let sortDict = Recoil.useRecoilValueFromAtom(LoadedTable.sortAtom)
  let title = "Transformed Entries"
  let sortOrder = sortDict->getMappedValueFromDict(title, Desc, getSortOrder)

  let mixpanelEvent = MixpanelHook.useSendEvent()

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_exception_staging_date_filter_opened")
  }

  let {
    items: processingEntries,
    cursors,
    screenState,
    goToFirstPage,
    goToNextPage,
    goToPrevPage,
  } = ReconEngineCursorPaginationHook.useCursorPagination(~fetchPage=(~sortBy, ~direction) => {
    getProcessingEntriesV2(
      ~body=buildProcessingEntriesV2Body(
        ~filterValueJson,
        ~searchType=searchTypeRef.current,
        ~searchText,
        ~sortBy,
        ~direction,
        ~order=sortOrder,
        ~transformationHistoryId=selectedTransformationHistoryId,
      ),
    )
  }, ~persistKey=`recon-engine-data-overview-transformed-entries-${selectedTransformationHistoryId}`)

  let checkNeedsManualReview = async () => {
    await onNeedsManualReviewPresent->mapOptionOrDefault(Promise.resolve(), async callback => {
      try {
        let enhancedFilterValueJson = Dict.copy(filterValueJson)
        enhancedFilterValueJson->Dict.set(
          "transformation_history_ids",
          selectedTransformationHistoryId->JSON.Encode.string,
        )
        let queryString = ReconEngineFilterUtils.buildQueryStringFromFilters(
          ~filterValueJson=enhancedFilterValueJson,
        )
        let stagingOverview = await getStagingEntriesOverview(~queryParameters=Some(queryString))
        callback(stagingOverview->getTotalNeedsManualReviewEntries > 0.0)
      } catch {
      | _ => showToast(~message="Failed to fetch manual review status", ~toastType=ToastError)
      }
    })
  }

  let fetchAccounts = async () => {
    try {
      let accounts = await getAccounts()
      setAccountData(_ => accounts)
    } catch {
    | _ => showToast(~message="Failed to fetch accounts", ~toastType=ToastError)
    }
  }

  let accountOptions =
    accountData->Array.map((account: accountType): FilterSelectBox.dropdownOption => {
      label: account.account_name,
      value: account.account_id,
    })

  let handleSearchSubmit = (selectedType: option<string>) => {
    let newSearchType = selectedType->mapOptionOrDefault(SearchStagingEntryId, searchTypeFromString)
    searchTypeRef.current = newSearchType
    goToFirstPage()
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
    fetchAccounts()->ignore
    None
  }, [])

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      goToFirstPage()
      checkNeedsManualReview()->ignore
    }
    None
  }, (filterValue, sortOrder))

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
      />
    </div>
  }
  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData height="h-96" message="No data available." />}
    customLoader={<Shimmer styleClass="h-96 w-full rounded-b-xl" />}>
    <div className="flex flex-col gap-4 my-4 px-6 pb-16">
      <ReconEngineDataTransformedEntriesOverviewCards
        selectedTransformationHistoryId=Some(selectedTransformationHistoryId)
      />
      <div className="flex-shrink-0"> {topFilterUi} </div>
      <LoadedTable
        title
        hideTitle=true
        actualData={processingEntries->Array.map(Nullable.make)}
        entity={ReconEngineExceptionEntity.processingTableEntity}
        resultsPerPage=10
        totalResults={processingEntries->Array.length}
        offset
        setOffset
        currentFetchCount={processingEntries->Array.length}
        tableheadingClass="h-12"
        tableHeadingTextClass="!font-normal"
        nonFrozenTableParentClass="!rounded-lg"
        loadedTableParentClass="flex flex-col"
        enableEqualWidthCol=false
        showAutoScroll=true
        remoteSortEnabled=true
        showPagination=false
        showResultsPerPageSelector=false
        tableDataLoading={screenState === PageLoaderWrapper.Loading}
        dataLoading={screenState === PageLoaderWrapper.Loading}
        filters={<SearchInput
          inputText=searchText
          onChange={value => setSearchText(_ => value)}
          placeholder="Search by ID"
          showTypeSelector=true
          typeSelectorOptions=searchTypeOptions
          onSubmitSearchDropdown=handleSearchSubmit
          showSearchIcon=true
          widthClass="w-max"
        />}
        bottomActions={<ReconEngineCursorPaginationButtons
          cursors
          isLoading={screenState === PageLoaderWrapper.Loading}
          hasData={processingEntries->isNonEmptyArray}
          onPrev=goToPrevPage
          onNext=goToNextPage
        />}
      />
    </div>
  </PageLoaderWrapper>
}
