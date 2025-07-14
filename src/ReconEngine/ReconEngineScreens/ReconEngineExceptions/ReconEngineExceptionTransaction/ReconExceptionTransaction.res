@react.component
let make = () => {
  open ReconEngineTransactionsUtils
  open LogicUtils

  let (filterDataJson, _setFilterDataJson) = React.useState(_ => None)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (exceptionData, setExceptionData) = React.useState(_ => [])
  let (filteredExceptionData, setFilteredExceptionData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (dimensions, _setDimensions) = React.useState(_ => [])
  let tabNames = HSAnalyticsUtils.getStringListFromArrayDict(dimensions)
  let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_exception_transaction_date_filter_opened")
  }

  let topFilterUi = {
    let (initialFilters, popupFilterFields, key) = switch filterDataJson {
    | Some(filterData) => (
        HSAnalyticsUtils.initialFilterFields(filterData, ~isTitle=true),
        HSAnalyticsUtils.options(filterData),
        "0",
      )
    | None => ([], [], "1")
    }

    <div className="flex flex-row">
      <DynamicFilter
        title="ReconEngineExceptionTransactionFilters"
        initialFilters
        options=[]
        popupFilterFields
        initialFixedFilters={initialFixedFilterFields(~events=dateDropDownTriggerMixpanelCallback)}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames
        key
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
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

  let getExceptionEntriesList = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let response = SampleDataExceptionTransaction.data
      let data = response->getDictFromJsonObject->getArrayFromDict("exceptions", [])
      //TODO: remove this filter once backend filtering is there
      let filteredData = data->Array.filter(item => {
        let status = item->getDictFromJsonObject->getString("transaction_status", "")
        status === "expected" || status === "mismatched"
      })
      let exceptionList = filteredData->getArrayOfTransactionsListPayloadType
      setExceptionData(_ => exceptionList)
      setFilteredExceptionData(_ => exceptionList->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getExceptionEntriesList()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-4">
      <RenderIf condition={exceptionData->Array.length > 0}>
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
            customSearchBarWrapperWidth="w-full lg:w-1/2 mt-8 mb-2"
            customInputBoxWidth="w-full rounded-xl "
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
      </RenderIf>
    </div>
  </PageLoaderWrapper>
}
