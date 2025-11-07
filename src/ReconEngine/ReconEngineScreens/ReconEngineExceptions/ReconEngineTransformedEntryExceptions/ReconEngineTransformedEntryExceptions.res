open Typography

@react.component
let make = () => {
  open ReconEngineHooks
  open ReconEngineFilterUtils
  open LogicUtils
  open ReconEngineTypes
  open ReconEngineTransformedEntryExceptionsUtils

  let getGetProcessingEntries = useGetProcessingEntries()
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
    mixpanelEvent(~eventName="recon_engine_transformed_entries_exceptions_date_filter_opened")
  }

  let accountOptions = React.useMemo(() => {
    getAccountOptionsFromStagingEntries(stagingData)
  }, [stagingData])

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
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let enhancedFilterValueJson = Dict.copy(filterValueJson)
      let statusFilter = filterValueJson->getArrayFromDict("status", [])
      if statusFilter->Array.length == 0 {
        enhancedFilterValueJson->Dict.set(
          "status",
          ["needs_manual_review"]->getJsonFromArrayOfString,
        )
      }
      let queryString = ReconEngineFilterUtils.buildQueryStringFromFilters(
        ~filterValueJson=enhancedFilterValueJson,
      )

      let stagingList = await getGetProcessingEntries(~queryParamerters=Some(queryString))
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
    ~origin="recon_engine_transformed_entries_exceptions",
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
        title="ReconEngineTransformedEntriesExceptionsFilters"
        initialFilters={initialDisplayFilters(~accountOptions)}
        options=[]
        popupFilterFields=[]
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineTransformedEntriesExceptionsFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
        setOffset
      />
    </div>
  }

  <div className="flex flex-col gap-5 w-full">
    <div className="flex flex-row justify-between items-center">
      <PageUtils.PageHeading
        title="Transformed Entry Exceptions"
        customTitleStyle={`${heading.lg.semibold}`}
        customHeadingStyle="py-0"
      />
    </div>
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-4">
        <div className="flex-shrink-0"> {topFilterUi} </div>
        <RenderIf condition={stagingData->Array.length == 0}>
          <div className="h-40-vh flex flex-col justify-center items-center gap-2">
            <p className={`${heading.sm.semibold} text-gray-800`}>
              {"No exceptions to show."->React.string}
            </p>
            <p className={`${body.md.medium} text-gray-500`}>
              {"All transformed entries have been processed successfully and entered into the reconciliation engine."->React.string}
            </p>
          </div>
        </RenderIf>
        <RenderIf condition={stagingData->Array.length > 0}>
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
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}
