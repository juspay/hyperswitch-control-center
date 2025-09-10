@react.component
let make = (~account: ReconEngineOverviewTypes.accountType) => {
  open LogicUtils
  open ReconEngineTransactionsTypes
  open ReconEngineTransactionsUtils
  open ReconEngineUtils
  open HierarchicalTransactionsTableEntity

  let getTransactions = ReconEngineHooks.useGetTransactions()
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey
  let (configuredTransactions, setConfiguredTransactions) = React.useState(_ => [])
  let (filteredTransactionsData, setFilteredReports) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (resultsPerPage, _setResultsPerPage) = React.useState(_ => 10)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_transactions_date_filter_opened")
  }

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<transactionPayload>) => {
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
    setFilteredReports(_ => filteredList)
  }, ~wait=200)

  let (creditAccountOptions, debitAccountOptions) = React.useMemo(() => {
    (
      getEntryTypeAccountOptions(configuredTransactions, ~entryType="credit"),
      getEntryTypeAccountOptions(configuredTransactions, ~entryType="debit"),
    )
  }, [configuredTransactions])

  let topFilterUi = {
    <div className="flex flex-row">
      <DynamicFilter
        title="ReconEngineTransactionsFilters"
        initialFilters={initialDisplayFilters(~creditAccountOptions, ~debitAccountOptions, ())}
        options=[]
        popupFilterFields=[]
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineTransactionsFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
        setOffset
      />
    </div>
  }

  let fetchTransactionsData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let enhancedFilterValueJson = Dict.copy(filterValueJson)
      let statusFilter = filterValueJson->getArrayFromDict("transaction_status", [])
      if statusFilter->Array.length === 0 {
        enhancedFilterValueJson->Dict.set(
          "transaction_status",
          ["expected", "mismatched", "posted"]->getJsonFromArrayOfString,
        )
      }

      let sourceQueryString =
        ReconEngineUtils.buildQueryStringFromFilters(~filterValueJson=enhancedFilterValueJson) ++
        "&credit_account=" ++
        account.account_id

      let targetQueryString =
        ReconEngineUtils.buildQueryStringFromFilters(~filterValueJson=enhancedFilterValueJson) ++
        "&debit_account=" ++
        account.account_id

      let sourceTransactions = await getTransactions(~queryParamerters=Some(sourceQueryString))
      let targetTransactions = await getTransactions(~queryParamerters=Some(targetQueryString))

      let allTransactions = Array.concat(sourceTransactions, targetTransactions)
      setConfiguredTransactions(_ => allTransactions)
      setFilteredReports(_ => allTransactions->Array.map(Nullable.make))
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
    ~origin="recon_engine_transactions",
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchTransactionsData()->ignore
    }
    None
  }, [filterValue])

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-4 relative">
      <div className="flex justify-between items-center absolute right-0 -top-4">
        <div className="flex-shrink-0"> {topFilterUi} </div>
      </div>
      <LoadedTableWithCustomColumns
        title="Transactions"
        hideTitle=true
        actualData=filteredTransactionsData
        totalResults={filteredTransactionsData->Array.length}
        entity={HierarchicalTransactionsTableEntity.hierarchicalTransactionsLoadedTableEntity(
          `v1/recon-engine/transactions`,
          ~authorization=Access,
        )}
        resultsPerPage=6
        offset
        setOffset
        currrentFetchCount={filteredTransactionsData->Array.length}
        customColumnMapper=TableAtoms.transactionsHierarchicalDefaultCols
        defaultColumns
        showPagination=true
        showResultsPerPageSelector=true
        tableDataLoading={screenState == PageLoaderWrapper.Loading}
        dataLoading={screenState == PageLoaderWrapper.Loading}
        tableheadingClass="bg-gray-50"
        showAutoScroll=true
        hideCustomisableColumnButton=true
        customSeparation=[(2, 3)]
        filters={<TableSearchFilter
          data={configuredTransactions->Array.map(Nullable.make)}
          filterLogic
          placeholder="Search Transaction Id or Status"
          searchVal=searchText
          setSearchVal=setSearchText
          customSearchBarWrapperWidth="w-full lg:w-1/3"
          customInputBoxWidth="w-full rounded-xl"
        />}
      />
    </div>
  </PageLoaderWrapper>
}
