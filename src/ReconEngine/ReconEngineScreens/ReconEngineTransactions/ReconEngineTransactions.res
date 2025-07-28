open Typography

@react.component
let make = () => {
  open ReconEngineTransactionsUtils
  open LogicUtils
  open ReconEngineUtils
  open ReconEngineTransactionsTypes

  let mixpanelEvent = MixpanelHook.useSendEvent()

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_transactions_date_filter_opened")
  }
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
  let getTransactions = ReconEngineTransactionsHook.useGetTransactions()

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
      />
    </div>
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
      let queryString = ReconEngineUtils.buildQueryStringFromFilters(
        ~filterValueJson=enhancedFilterValueJson,
      )
      let transactionsList = await getTransactions(~queryParamerters=Some(queryString))
      let transactionListData = transactionsList
      setConfiguredTransactions(_ => transactionListData)
      setFilteredReports(_ => transactionListData->Array.map(Nullable.make))
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
    <div className="flex flex-row justify-between items-center gap-3">
      <div className="flex-shrink-0">
        <PageUtils.PageHeading
          title="Transactions"
          subTitle="View your transactions and their details"
          customSubTitleStyle={body.lg.medium}
          customTitleStyle={`${heading.lg.semibold} py-0`}
        />
      </div>
      <div className="flex-shrink-0 mt-2">
        <Button
          text="Generate Report"
          buttonType=Primary
          buttonSize=Large
          buttonState=Disabled
          onClick={_ => {
            mixpanelEvent(~eventName="recon_engine_transactions_generate_reports_clicked")
          }}
        />
      </div>
    </div>
    <div className="flex-shrink-0"> {topFilterUi} </div>
    <PageLoaderWrapper screenState>
      <LoadedTableWithCustomColumns
        title="All Transactions"
        actualData={filteredTransactionsData}
        entity={TransactionsTableEntity.transactionsEntity(
          `v1/recon-engine/transactions`,
          ~authorization=Access,
        )}
        resultsPerPage=10
        filters={<TableSearchFilter
          data={configuredTransactions->Array.map(Nullable.make)}
          filterLogic
          placeholder="Search Transaction Id or Status"
          searchVal=searchText
          setSearchVal=setSearchText
          customSearchBarWrapperWidth="w-full lg:w-1/3"
          customInputBoxWidth="w-full rounded-xl"
        />}
        totalResults={filteredTransactionsData->Array.length}
        offset
        setOffset
        currrentFetchCount={configuredTransactions->Array.length}
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
