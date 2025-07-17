@react.component
let make = () => {
  open ReconEngineExceptionTransactionUtils
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (exceptionData, setExceptionData) = React.useState(_ => [])
  let (filteredExceptionData, setFilteredExceptionData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_exception_transaction_date_filter_opened")
  }
  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ReconEngineTransactionsTypes.transactionPayload>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.transaction_id, searchText) ||
          isContainingStringLowercase(obj.transaction_status, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredExceptionData(_ => filteredList)
  }, ~wait=200)

  let fetchExceptionsData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let enhancedFilterValueJson = Dict.copy(filterValueJson)
      let statusFilter = filterValueJson->getArrayFromDict("transaction_status", [])
      if statusFilter->Array.length === 0 {
        enhancedFilterValueJson->Dict.set(
          "transaction_status",
          ["expected", "mismatched"]->getJsonFromArrayOfString,
        )
      }
      let queryString = ReconEngineUtils.buildQueryStringFromFilters(
        ~filterValueJson=enhancedFilterValueJson,
      )
      let exceptionsUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSACTIONS_LIST,
        ~queryParamerters=Some(queryString),
      )

      let res = await fetchDetails(exceptionsUrl)
      let exceptionList =
        res->getArrayDataFromJson(ReconEngineTransactionsUtils.getAllTransactionPayload)

      let exceptionDataList = exceptionList->Array.map(Nullable.make)
      setExceptionData(_ => exceptionList)
      setFilteredExceptionData(_ => exceptionDataList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="recon_engine_exception_transaction",
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchExceptionsData()->ignore
    }
    None
  }, [filterValue])

  let topFilterUi = {
    <div className="flex flex-row">
      <DynamicFilter
        title="ReconEngineExceptionTransactionFilters"
        initialFilters={initialDisplayFilters()}
        options=[]
        popupFilterFields=[]
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineExceptionTransactionFilters"
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
      <LoadedTableWithCustomColumns
        title="Exception Entries - Expected & Mismatched"
        actualData={filteredExceptionData}
        entity={TransactionsTableEntity.transactionsEntity(
          `v1/recon-engine/exceptions`,
          ~authorization=userHasAccess(~groupAccess=UsersManage),
        )}
        resultsPerPage=10
        filters={<TableSearchFilter
          data={exceptionData->Array.map(Nullable.make)}
          filterLogic
          placeholder="Search Exception ID or Status"
          customSearchBarWrapperWidth="w-full lg:w-1/2"
          customInputBoxWidth="w-full rounded-xl"
          searchVal=searchText
          setSearchVal=setSearchText
        />}
        totalResults={filteredExceptionData->Array.length}
        offset
        setOffset
        currrentFetchCount={exceptionData->Array.length}
        customColumnMapper=TableAtoms.reconTransactionsDefaultCols
        defaultColumns={TransactionsTableEntity.defaultColumns}
        showSerialNumberInCustomizeColumns=false
        sortingBasedOnDisabled=false
        hideTitle=true
        remoteSortEnabled=true
        customizeColumnButtonIcon="nd-filter-horizontal"
        hideRightTitleElement=true
        showAutoScroll=true
      />
    </PageLoaderWrapper>
  </div>
}
