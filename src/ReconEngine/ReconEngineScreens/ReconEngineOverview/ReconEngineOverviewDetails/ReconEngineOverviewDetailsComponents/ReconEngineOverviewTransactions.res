open HierarchicalTransactionsTableEntity

@react.component
let make = (~ruleDetails: ReconEngineRulesTypes.rulePayload) => {
  open LogicUtils
  open ReconEngineTransactionsUtils
  open ReconEngineTransactionsTypes

  let getTransactionsV2 = ReconEngineHooks.useGetCursorPage(
    ~hyperswitchReconType=#TRANSACTIONS_LIST_V2,
    ~itemMapper=ReconEngineUtils.transactionItemToObjMapper,
  )
  let getAccounts = ReconEngineHooks.useGetAccounts()
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let showToast = ToastAdapter.useShowToast()

  let (accountData, setAccountData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let searchTypeRef = React.useRef(SearchTransactionId)

  let sortDict = Recoil.useRecoilValueFromAtom(LoadedTable.sortAtom)
  let title = "Overview Transactions"
  let sortOrder = sortDict->getMappedValueFromDict(title, Desc, getSortOrder)

  let fetchAccounts = async () => {
    try {
      let accounts = await getAccounts()
      setAccountData(_ => accounts)
    } catch {
    | _ => showToast(~message="Failed to fetch accounts", ~toastType=ToastError)
    }
  }

  let fetchPage = (~sortBy, ~direction) =>
    getTransactionsV2(
      ~body=buildTransactionsV2Body(
        ~filterValueJson,
        ~searchType=searchTypeRef.current,
        ~searchText,
        ~ruleId=ruleDetails.rule_id,
        ~sortBy,
        ~direction,
        ~order=sortOrder,
        ~limit=5,
      ),
    )

  let {
    items: transactions,
    cursors,
    screenState,
    goToFirstPage,
    goToNextPage,
    goToPrevPage,
  } = ReconEngineCursorPaginationHook.useCursorPagination(
    ~fetchPage,
    ~persistKey=`recon-engine-overview-transactions-${ruleDetails.rule_id}`,
  )

  let handleSearchSubmit = (selectedType: option<string>) => {
    let newSearchType = selectedType->mapOptionOrDefault(SearchTransactionId, searchTypeFromString)
    searchTypeRef.current = newSearchType
    goToFirstPage()
  }

  React.useEffect(() => {
    fetchAccounts()->ignore
    None
  }, [])

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      goToFirstPage()
    }
    None
  }, (filterValue, sortOrder))

  let statusFilterUi =
    <div className="flex flex-row">
      <DynamicFilter
        title="ReconEngineOverviewTransactionsFilters"
        initialFilters={statusDisplayFilters()}
        options=[]
        popupFilterFields=[]
        initialFixedFilters=[]
        defaultFilterKeys=[]
        tabNames=filterKeys
        key="ReconEngineOverviewTransactionsFilters"
        updateUrlWith=updateExistingKeys
        showCustomFilter=false
        refreshFilters=false
      />
    </div>

  <div className="flex flex-col gap-4">
    <div className="flex-shrink-0"> {statusFilterUi} </div>
    <PageLoaderWrapper screenState customLoader={<Shimmer styleClass="w-full h-96 rounded-xl" />}>
      <LoadedTableWithCustomColumns
        title
        hideTitle=true
        actualData={transactions->Array.map(Nullable.make)}
        totalResults={transactions->Array.length}
        entity={hierarchicalTransactionsLoadedTableEntity(
          `v1/recon-engine/transactions`,
          ~authorization=Access,
          ~reconRulesList=[ruleDetails],
          ~accountData,
        )}
        resultsPerPage=5
        offset
        setOffset
        currentFetchCount={transactions->Array.length}
        customColumnMapper=TableAtoms.transactionsHierarchicalDefaultCols
        defaultColumns
        showSerialNumberInCustomizeColumns=false
        sortingBasedOnDisabled=false
        remoteSortEnabled=true
        showPagination=false
        showResultsPerPageSelector=false
        tableDataLoading={screenState === PageLoaderWrapper.Loading}
        dataLoading={screenState === PageLoaderWrapper.Loading}
        customizeColumnButtonIcon="nd-filter-horizontal"
        hideRightTitleElement=true
        showAutoScroll=true
        customSeparation=[(3, 4)]
        filters={<SearchInput
          inputText=searchText
          onChange={value => setSearchText(_ => value)}
          placeholder="Search by ID"
          autoFocus=false
          showTypeSelector=true
          typeSelectorOptions=searchTypeOptions
          onSubmitSearchDropdown=handleSearchSubmit
          showSearchIcon=true
          widthClass="w-max"
        />}
        bottomActions={<ReconEngineCursorPaginationButtons
          cursors
          isLoading={screenState === PageLoaderWrapper.Loading}
          hasData={transactions->isNonEmptyArray}
          onPrev=goToPrevPage
          onNext=goToNextPage
        />}
      />
    </PageLoaderWrapper>
  </div>
}
