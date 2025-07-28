@react.component
let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
  open LogicUtils

  let (configuredTransactions, setConfiguredReports) = React.useState(_ => [])
  let (filteredTransactionsData, setFilteredReports) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let getTransactions = ReconEngineTransactionsHook.useGetTransactions()
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
      let statusFilter = filterValueJson->getArrayFromDict("transaction_status", [])
      if statusFilter->Array.length === 0 {
        enhancedFilterValueJson->Dict.set(
          "transaction_status",
          ["expected", "mismatched", "posted"]->getJsonFromArrayOfString,
        )
      }
      let baseQueryString = ReconEngineUtils.buildQueryStringFromFilters(
        ~filterValueJson=enhancedFilterValueJson,
      )
      let queryString = if baseQueryString->isNonEmptyString {
        `${baseQueryString}&rule_id=${ruleDetails.rule_id}`
      } else {
        `rule_id=${ruleDetails.rule_id}`
      }
      let transactionsList = await getTransactions(~queryParamerters=Some(queryString))
      let transactionsListData = transactionsList->Array.map(Nullable.make)
      setConfiguredReports(_ => transactionsListData)
      setFilteredReports(_ => transactionsListData)
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
      />
    </div>
  }

  <div className="flex flex-col gap-4">
    <div className="flex-shrink-0"> {topFilterUi} </div>
    <PageLoaderWrapper
      screenState
      customLoader={<div className="h-full flex flex-col justify-center items-center">
        <div className="animate-spin">
          <Icon name="spinner" size=20 />
        </div>
      </div>}>
      <LoadedTableWithCustomColumns
        title="All Transactions"
        actualData={filteredTransactionsData}
        entity={TransactionsTableEntity.transactionsEntity(
          `v1/recon-engine/transactions`,
          ~authorization=Access,
        )}
        resultsPerPage=10
        totalResults={filteredTransactionsData->Array.length}
        offset
        setOffset
        currrentFetchCount={configuredTransactions->Array.length}
        customColumnMapper=TableAtoms.reconTransactionsOverviewDefaultCols
        defaultColumns={TransactionsTableEntity.defaultColumnsOverview}
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
