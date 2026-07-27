open ReconEngineTypes
open HierarchicalTransactionsTableEntity

@react.component
let make = (
  ~rule: ReconEngineRulesTypes.rulePayload,
  ~accountData: array<accountType>,
  ~reconRulesList: array<ReconEngineRulesTypes.rulePayload>,
) => {
  open LogicUtils
  open ReconEngineTransactionsUtils
  open ReconEngineHooks
  open HSAnalyticsUtils
  open ReconEngineTransactionsTypes

  let getTransactionsV2 = useGetCursorPage(
    ~hyperswitchReconType=#TRANSACTIONS_LIST_V2,
    ~itemMapper=ReconEngineUtils.transactionItemToObjMapper,
  )
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )

  let sortDict = Recoil.useRecoilValueFromAtom(LoadedTable.sortAtom)
  let title = "Transactions"
  let sortOrder = sortDict->getMappedValueFromDict(title, Desc, getSortOrder)
  let (searchText, setSearchText) = React.useState(_ => "")
  let searchTypeRef = React.useRef(SearchTransactionId)

  let {
    items: transactions,
    cursors,
    screenState,
    goToFirstPage,
    goToNextPage,
    goToPrevPage,
  } = ReconEngineCursorPaginationHook.useCursorPagination(~fetchPage=(~sortBy, ~direction) => {
    getTransactionsV2(
      ~body=buildTransactionsV2Body(
        ~filterValueJson,
        ~searchType=searchTypeRef.current,
        ~searchText,
        ~ruleId=rule.rule_id,
        ~sortBy,
        ~direction,
        ~order=sortOrder,
      ),
    )
  }, ~persistKey=`recon-engine-transactions-${rule.rule_id}`)
  let (offset, setOffset) = React.useState(_ => 0)
  let (selectedRows, setSelectedRows) = React.useState(_ => [])

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_transactions_date_filter_opened")
  }

  let topFilterUi =
    <div className="flex flex-row -ml-1.5">
      <DynamicFilter
        title="ReconEngineTransactionsFilters"
        initialFilters={statusDisplayFilters()}
        options=[]
        popupFilterFields=[]
        initialFixedFilters={initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineTransactionsFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>

  React.useEffect(() => {
    setSelectedRows(_ => [])
    None
  }, [transactions])

  let handleSearchSubmit = (selectedType: option<string>) => {
    let newSearchType = selectedType->mapOptionOrDefault(SearchTransactionId, searchTypeFromString)
    searchTypeRef.current = newSearchType
    goToFirstPage()
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
      goToFirstPage()
    }
    None
  }, (filterValue, sortOrder))

  <div className="flex flex-col gap-4 mt-3">
    <PageLoaderWrapper screenState>
      <div className="flex-shrink-0"> {topFilterUi} </div>
      <LoadedTableWithCustomColumns
        title
        hideTitle=true
        actualData={transactions->Array.map(Nullable.make)}
        totalResults={transactions->Array.length}
        entity={HierarchicalTransactionsTableEntity.hierarchicalTransactionsLoadedTableEntity(
          `v1/recon-engine/transactions`,
          ~authorization=Access,
          ~reconRulesList,
          ~accountData,
        )}
        resultsPerPage=4
        offset
        setOffset
        currentFetchCount={transactions->Array.length}
        customColumnMapper=TableAtoms.transactionsHierarchicalDefaultCols
        defaultColumns
        showPagination=false
        showResultsPerPageSelector=false
        remoteSortEnabled=true
        tableDataLoading={screenState === PageLoaderWrapper.Loading}
        dataLoading={screenState === PageLoaderWrapper.Loading}
        tableheadingClass="bg-gray-50"
        showAutoScroll=true
        hideCustomisableColumnButton=true
        customSeparation=[(3, 4)]
        filters={<SearchInput
          inputText=searchText
          onChange={value => setSearchText(_ => value)}
          placeholder="Search by ID"
          showTypeSelector=true
          typeSelectorOptions=searchTypeOptions
          onSubmitSearchDropdown=handleSearchSubmit
          showSearchIcon=true
          widthClass="w-max"
        />}
        checkBoxProps={{
          showCheckBox: true,
          selectedData: selectedRows,
          setSelectedData: setSelectedRows,
        }}
        bottomActions={<ReconEngineCursorPaginationButtons
          cursors
          isLoading={screenState === PageLoaderWrapper.Loading}
          hasData={transactions->isNonEmptyArray}
          onPrev=goToPrevPage
          onNext=goToNextPage
        />}
      />
      <RenderIf condition={selectedRows->isNonEmptyArray}>
        <ReconEngineTransactionsBulkActions
          selectedRows={selectedRows->Array.map(json => json->Identity.jsonToAnyType)}
          setSelectedRows
          showPostButton=true
          refreshList={() => goToFirstPage()}
        />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
