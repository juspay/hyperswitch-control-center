@react.component
let make = (~config: ReconEngineTypes.transformationConfigType) => {
  open LogicUtils
  open APIUtils
  open ReconEngineAccountsTransformationUtils

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let (transformationHistoryList, setTransformationHistoryList) = React.useState(_ => [])
  let (filteredHistoryData, setFilteredHistoryData) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")

  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_transformation_history_date_filter_opened")
  }

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ReconEngineTypes.transformationHistoryType>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase((obj.status :> string), searchText) ||
          isContainingStringLowercase(obj.transformation_history_id, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredHistoryData(_ => filteredList)
  }, ~wait=200)

  let topFilterUi = {
    <div className="flex flex-row">
      <DynamicFilter
        title="ReconEngineAccountsTransformationHistoryFilters"
        initialFilters={initialIngestionDisplayFilters()}
        options=[]
        popupFilterFields=[]
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineAccountsTransformationHistoryFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
        setOffset
      />
    </div>
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~range=180,
    ~origin="recon_engine_accounts_sources_ingestion_history",
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  let fetchTransformationHistoryData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let queryString =
        ReconEngineFilterUtils.buildQueryStringFromFilters(~filterValueJson)->String.concat(
          `&transformation_id=${config.id}`,
        )

      let transformationHistoryUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParamerters=Some(queryString),
      )
      let transformationHistoryRes = await fetchDetails(transformationHistoryUrl)
      let transformationHistoryList =
        transformationHistoryRes->getArrayDataFromJson(getTransformationHistoryPayloadFromDict)

      let transformationHistoryData = transformationHistoryList->Array.map(Nullable.make)
      setTransformationHistoryList(_ => transformationHistoryData)
      setFilteredHistoryData(_ => transformationHistoryData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchTransformationHistoryData()->ignore
    }
    None
  }, (config, filterValue))

  <div className="flex flex-col gap-4 my-4">
    <div className="flex-shrink-0"> {topFilterUi} </div>
    <PageLoaderWrapper screenState>
      <LoadedTable
        title="Transformation History"
        hideTitle=true
        actualData={filteredHistoryData}
        entity={ReconEngineAccountsTransformationHistoryTableEntity.transformationHistoryTableEntity(
          `v1/recon-engine/transformation/ingestion-history`,
          ~authorization=Access,
        )}
        resultsPerPage=10
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
          data={transformationHistoryList}
          filterLogic
          placeholder="Search by Transformation History ID or Status"
          customSearchBarWrapperWidth="w-full lg:w-1/3"
          customInputBoxWidth="w-full rounded-xl"
          searchVal=searchText
          setSearchVal=setSearchText
        />}
      />
    </PageLoaderWrapper>
  </div>
}
