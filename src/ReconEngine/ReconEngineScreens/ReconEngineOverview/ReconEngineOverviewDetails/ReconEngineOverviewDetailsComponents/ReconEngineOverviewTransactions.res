@react.component
let make = (~ruleDetails: ReconEngineTypes.reconRuleType) => {
  open LogicUtils
  open HierarchicalTransactionsTableEntity

  let (configuredTransactions, setConfiguredReports) = React.useState(_ => [])
  let (filteredTransactionsData, setFilteredReports) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let getTransactions = ReconEngineHooks.useGetTransactions()
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_overview_transactions_date_filter_opened")
  }

  let fetchTransactionsData = async () => {
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
            "posted_auto",
            "posted_manual",
            "posted_force",
            "partially_reconciled",
            "void",
          ]->getJsonFromArrayOfString,
        )
      }
      let baseQueryString = ReconEngineFilterUtils.buildQueryStringFromFilters(
        ~filterValueJson=enhancedFilterValueJson,
      )
      let queryString = if baseQueryString->isNonEmptyString {
        `${baseQueryString}&rule_id=${ruleDetails.rule_id}`
      } else {
        `rule_id=${ruleDetails.rule_id}`
      }
      let transactionsList = await getTransactions(~queryParameters=Some(queryString))
      let transactionsListData = transactionsList->Array.map(Nullable.make)
      setConfiguredReports(_ => transactionsListData)
      setFilteredReports(_ => transactionsListData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~range=180,
    ~origin="recon_engine_overview_transactions",
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

  let topFilterUi = {
    <div className="flex flex-row">
      <DynamicFilter
        title="ReconEngineOverviewTransactionsFilters"
        initialFilters={ReconEngineOverviewUtils.initialDisplayFilters()}
        options=[]
        popupFilterFields=[]
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineOverviewTransactionsFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
        setOffset
      />
    </div>
  }

  <div className="flex flex-col gap-4">
    <div className="flex-shrink-0"> {topFilterUi} </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-96" message="No data available" />}
      customLoader={<Shimmer styleClass="w-full h-96 rounded-xl" />}>
      <LoadedTableWithCustomColumns
        title="All Transactions"
        actualData={filteredTransactionsData}
        entity={hierarchicalTransactionsLoadedTableEntity(
          `v1/recon-engine/transactions`,
          ~authorization=Access,
        )}
        resultsPerPage=5
        totalResults={filteredTransactionsData->Array.length}
        offset
        setOffset
        currrentFetchCount={configuredTransactions->Array.length}
        customColumnMapper=TableAtoms.transactionsHierarchicalDefaultCols
        defaultColumns
        showSerialNumberInCustomizeColumns=false
        sortingBasedOnDisabled=false
        hideTitle=true
        remoteSortEnabled=true
        customizeColumnButtonIcon="nd-filter-horizontal"
        hideRightTitleElement=true
        showAutoScroll=true
        customSeparation=[(2, 3)]
      />
    </PageLoaderWrapper>
  </div>
}
