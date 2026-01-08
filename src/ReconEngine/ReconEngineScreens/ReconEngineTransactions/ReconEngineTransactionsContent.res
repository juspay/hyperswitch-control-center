@react.component
let make = (~account: ReconEngineTypes.accountType) => {
  open LogicUtils
  open ReconEngineTypes
  open ReconEngineTransactionsUtils
  open ReconEngineFilterUtils
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
  let (searchText, setSearchText) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_transactions_date_filter_opened")
  }

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<transactionType>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.transaction_id, searchText) ||
          isContainingStringLowercase(
            obj.transaction_status->TransactionsTableEntity.getDomainTransactionStatusString,
            searchText,
          ) ||
          obj.entries->Array.some(entry => isContainingStringLowercase(entry.order_id, searchText))
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
      getEntryTypeAccountOptions(configuredTransactions, ~entryType=Credit),
      getEntryTypeAccountOptions(configuredTransactions, ~entryType=Debit),
    )
  }, [configuredTransactions])

  let topFilterUi = {
    <div className="flex flex-row -ml-1.5">
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
      let statusFilter = filterValueJson->getArrayFromDict("status", [])

      // If posted_manual is selected, automatically add posted_force
      let finalStatusFilter = ReconEngineFilterUtils.getMergedPostedTransactionStatusFilter(
        statusFilter,
      )

      if finalStatusFilter->Array.length === 0 {
        enhancedFilterValueJson->Dict.set(
          "status",
          [
            "expected",
            "over_amount_mismatch",
            "under_amount_mismatch",
            "over_amount_expected",
            "under_amount_expected",
            "posted_auto",
            "posted_manual",
            "posted_force",
            "void",
            "partially_reconciled",
            "data_mismatch",
          ]->getJsonFromArrayOfString,
        )
      }

      let sourceQueryString =
        buildQueryStringFromFilters(~filterValueJson=enhancedFilterValueJson) ++
        "&credit_account=" ++
        account.account_id

      let targetQueryString =
        buildQueryStringFromFilters(~filterValueJson=enhancedFilterValueJson) ++
        "&debit_account=" ++
        account.account_id

      let sourceTransactions = await getTransactions(~queryParameters=Some(sourceQueryString))
      let targetTransactions = await getTransactions(~queryParameters=Some(targetQueryString))

      let allTransactions = sourceTransactions->Array.concat(targetTransactions)
      let uniqueTransactions = allTransactions->Array.reduce([], (
        acc: array<transactionType>,
        transaction,
      ) => {
        let exists = acc->Array.some(t => t.transaction_id == transaction.transaction_id)
        exists ? acc : acc->Array.concat([transaction])
      })

      setConfiguredTransactions(_ => uniqueTransactions)
      setFilteredReports(_ => uniqueTransactions->Array.map(Nullable.make))
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

  <div className="flex flex-col gap-4">
    <PageLoaderWrapper screenState>
      <div className="flex-shrink-0"> {topFilterUi} </div>
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
          placeholder="Search Transaction ID or Order ID or Status"
          searchVal=searchText
          setSearchVal=setSearchText
          customSearchBarWrapperWidth="w-full lg:w-1/3"
          customInputBoxWidth="w-full rounded-xl"
        />}
      />
    </PageLoaderWrapper>
  </div>
}
