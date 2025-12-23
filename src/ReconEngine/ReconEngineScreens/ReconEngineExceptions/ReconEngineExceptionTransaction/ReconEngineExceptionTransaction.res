open Typography

@react.component
let make = (~ruleId: string) => {
  open LogicUtils
  open ReconEngineFilterUtils
  open ReconEngineExceptionTransactionUtils
  open ReconEngineTypes
  open HierarchicalTransactionsTableEntity

  let (exceptionData, setExceptionData) = React.useState(_ => [])
  let (filteredExceptionData, setFilteredExceptionData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let getTransactions = ReconEngineHooks.useGetTransactions()
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_exception_transaction_date_filter_opened")
  }

  let (creditAccountOptions, debitAccountOptions) = React.useMemo(() => {
    (
      getEntryTypeAccountOptions(exceptionData, ~entryType=Credit),
      getEntryTypeAccountOptions(exceptionData, ~entryType=Debit),
    )
  }, [exceptionData])

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<transactionType>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.transaction_id, searchText) ||
          isContainingStringLowercase(
            obj.transaction_status->getDomainTransactionStatusString,
            searchText,
          ) ||
          obj.entries->Array.some(entry => isContainingStringLowercase(entry.order_id, searchText))
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
      let statusFilter = filterValueJson->getArrayFromDict("status", [])
      if statusFilter->Array.length === 0 {
        enhancedFilterValueJson->Dict.set(
          "status",
          [
            "expected",
            "over_amount_mismatch",
            "under_amount_mismatch",
            "over_amount_expected",
            "under_amount_expected",
            "data_mismatch",
            "partially_reconciled",
          ]->getJsonFromArrayOfString,
        )
      }
      enhancedFilterValueJson->Dict.set("rule_id", ruleId->JSON.Encode.string)
      let queryString = buildQueryStringFromFilters(~filterValueJson=enhancedFilterValueJson)
      let exceptionList = await getTransactions(~queryParameters=Some(queryString))

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
    ~range=180,
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
    <div className="flex flex-row -ml-1.5">
      <DynamicFilter
        title="ReconEngineExceptionTransactionFilters"
        initialFilters={initialDisplayFilters(~creditAccountOptions, ~debitAccountOptions, ())}
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
        setOffset
      />
    </div>
  }

  <div className="flex flex-col gap-4">
    <PageLoaderWrapper screenState>
      <div className="flex-shrink-0"> {topFilterUi} </div>
      <RenderIf condition={exceptionData->Array.length == 0}>
        <div className="h-40-vh flex flex-col justify-center items-center gap-2">
          <p className={`${heading.sm.semibold} text-gray-800`}>
            {"No exceptions to show."->React.string}
          </p>
          <p className={`${body.md.medium} text-gray-500`}>
            {"All transactions are matched and reconciled successfully across this system."->React.string}
          </p>
        </div>
      </RenderIf>
      <RenderIf condition={exceptionData->Array.length > 0}>
        <LoadedTableWithCustomColumns
          title="Exception Entries - Expected & Mismatched"
          actualData={filteredExceptionData}
          entity={hierarchicalTransactionsLoadedTableEntity(
            "v1/recon-engine/exceptions/recon",
            ~authorization=userHasAccess(~groupAccess=UsersManage),
          )}
          resultsPerPage=6
          filters={<TableSearchFilter
            data={exceptionData->Array.map(Nullable.make)}
            filterLogic
            placeholder="Search Transaction ID or Order ID or Status"
            customSearchBarWrapperWidth="w-full lg:w-1/3"
            customInputBoxWidth="w-full rounded-xl"
            searchVal=searchText
            setSearchVal=setSearchText
          />}
          totalResults={filteredExceptionData->Array.length}
          offset
          setOffset
          currrentFetchCount={exceptionData->Array.length}
          customColumnMapper=TableAtoms.transactionsHierarchicalDefaultCols
          defaultColumns={defaultColumns}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          hideTitle=true
          remoteSortEnabled=true
          customizeColumnButtonIcon="nd-filter-horizontal"
          hideRightTitleElement=true
          showAutoScroll=true
          customSeparation=[(2, 3)]
        />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
