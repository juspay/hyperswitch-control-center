@react.component
let make = () => {
  open ReconEngineTransactionsUtils
  open LogicUtils
  open APIUtils

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
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let topFilterUi = {
    <div className="flex flex-row">
      <DynamicFilter
        title="ReconEngineTransactionsFilters"
        initialFilters={initialDisplayFilters()}
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
    setFilteredReports(_ => filteredList)
  }, ~wait=200)

  let fetchTransactionsData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let queryString = ReconEngineUtils.buildQueryStringFromFilters(~filterValueJson)
      let transactionsUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSACTIONS_LIST,
        ~queryParamerters=Some(queryString),
      )

      let res = await fetchDetails(transactionsUrl)
      let transactionsList = res->getArrayDataFromJson(getAllTransactionPayload)

      let transactionsDataList = transactionsList->Array.map(Nullable.make)
      setConfiguredTransactions(_ => transactionsList->Array.map(Nullable.make))
      setFilteredReports(_ => transactionsDataList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
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

  <div className="flex flex-col gap-4 my-4">
    <div className="flex flex-row justify-between items-center gap-3">
      <div className="flex-shrink-0">
        <PageUtils.PageHeading
          title="Transactions"
          subTitle="View your transactions and their details"
          customHeadingStyle="!py-0"
        />
      </div>
      <div className="flex-shrink-0 mt-2">
        <Button
          text="Generate Report"
          buttonType=Primary
          buttonSize=Large
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
          data={configuredTransactions}
          filterLogic
          placeholder="Search Transaction Id or Status"
          customSearchBarWrapperWidth="w-1/3"
          searchVal=searchText
          setSearchVal=setSearchText
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
