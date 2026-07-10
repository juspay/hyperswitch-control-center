open HierarchicalTransactionsTableEntity

@react.component
let make = (~ruleDetails: ReconEngineRulesTypes.rulePayload) => {
  open LogicUtils
  open ReconEngineTransactionsUtils
  open ReconEngineTransactionsTypes

  let getTransactionsV2 = ReconEngineHooks.useGetTransactionsV2()
  let getAccounts = ReconEngineHooks.useGetAccounts()
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )

  let (transactions, setTransactions) = React.useState(_ => [])
  let (cursors, setCursors) = React.useState((_): transactionCursors => {
    next: None,
    prev: None,
  })
  let (accountData, setAccountData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (searchType, setSearchType) = React.useState(_ => SearchTransactionId)

  let sortDict = Recoil.useRecoilValueFromAtom(LoadedTable.sortAtom)
  let sortOrder = sortDict->getMappedValueFromDict("Overview Transactions", Desc, getSortOrder)

  let fetchAccounts = async () => {
    try {
      let accounts = await getAccounts()
      setAccountData(_ => accounts)
    } catch {
    | _ => ()
    }
  }

  let fetchPage = async (~sortBy, ~direction, ~searchType, ~searchText) => {
    if screenState !== PageLoaderWrapper.Success {
      setScreenState(_ => PageLoaderWrapper.Loading)
    }
    try {
      let body = buildTransactionsV2Body(
        ~filterValueJson,
        ~searchType,
        ~searchText,
        ~ruleId=ruleDetails.rule_id,
        ~sortBy,
        ~direction,
        ~order=sortOrder,
        ~limit=5,
      )
      let page = await getTransactionsV2(~body)
      setTransactions(_ => page.transactions)
      setCursors(_ => page.cursors)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let goToFirstPage = () => {
    fetchPage(~sortBy=defaultSortBy, ~direction=#next, ~searchType, ~searchText)->ignore
  }

  let goToNextPage = () => {
    cursors.next->mapOptionOrDefault((), nextCursor => {
      fetchPage(~sortBy=nextCursor, ~direction=#next, ~searchType, ~searchText)->ignore
    })
  }

  let goToPrevPage = () => {
    cursors.prev->mapOptionOrDefault((), prevCursor => {
      fetchPage(~sortBy=prevCursor, ~direction=#previous, ~searchType, ~searchText)->ignore
    })
  }

  let handleSearchSubmit = (selectedType: option<string>) => {
    let newSearchType = selectedType->mapOptionOrDefault(SearchTransactionId, searchTypeFromString)
    setSearchType(_ => newSearchType)
    fetchPage(
      ~sortBy=defaultSortBy,
      ~direction=#next,
      ~searchType=newSearchType,
      ~searchText,
    )->ignore
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
        title="Overview Transactions"
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
          showTypeSelector=true
          typeSelectorOptions=searchTypeOptions
          onSubmitSearchDropdown=handleSearchSubmit
          showSearchIcon=true
          widthClass="w-max"
        />}
      />
      <RenderIf condition={transactions->isNonEmptyArray}>
        <div className="flex flex-row justify-end items-center gap-3">
          <Button
            text="Prev"
            buttonType=Secondary
            buttonSize=Small
            buttonState={cursors.prev->Option.isNone || screenState === PageLoaderWrapper.Loading
              ? Button.Disabled
              : Button.Normal}
            onClick={_ => goToPrevPage()}
          />
          <Button
            text="Next"
            buttonType=Primary
            buttonSize=Small
            buttonState={cursors.next->Option.isNone || screenState === PageLoaderWrapper.Loading
              ? Button.Disabled
              : Button.Normal}
            onClick={_ => goToNextPage()}
          />
        </div>
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
