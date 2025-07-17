@react.component
let make = () => {
  open ReconEngineTransactionsUtils
  open LogicUtils

  let (filterDataJson, _setFilterDataJson) = React.useState(_ => None)
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_transactions_date_filter_opened")
  }
  let (dimensions, _setDimensions) = React.useState(_ => [])
  let tabNames = HSAnalyticsUtils.getStringListFromArrayDict(dimensions)
  let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let (configuredTransactions, setConfiguredReports) = React.useState(_ => [])
  let (filteredTransactionsData, setFilteredReports) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

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
        title="ReconEngineTransactionsFilters"
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
    setFilteredReports(_ => filteredList)
  }, ~wait=200)

  let getTransactionsList = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let response = SampleTransactions.data
      let data = response->getDictFromJsonObject->getArrayFromDict("transactions", [])
      let transactionsList = data->getArrayOfTransactionsListPayloadType
      setConfiguredReports(_ => transactionsList)
      setFilteredReports(_ => transactionsList->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getTransactionsList()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState>
    <div className="flex flex-row justify-between items-center gap-4">
      <div className="flex-shrink-0">
        <PageUtils.PageHeading
          title="Transactions" subTitle="View your transactions and their details"
        />
      </div>
      <div className="flex flex-row items-center gap-4">
        <div className="flex-shrink-0"> {topFilterUi} </div>
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
    </div>
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
}
