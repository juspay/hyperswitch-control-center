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

  let getTransactionsV2 = useGetTransactionsV2()
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let (transactions, setTransactions) = React.useState(_ => [])
  let (
    cursors,
    setCursors,
  ) = React.useState((_): ReconEngineTransactionsTypes.transactionCursors => {
    next: None,
    prev: None,
  })
  let (offset, setOffset) = React.useState(_ => 0)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (selectedRows, setSelectedRows) = React.useState(_ => [])

  let (searchText, setSearchText) = React.useState(_ => "")
  let (searchType, setSearchType) = React.useState(_ => ReconEngineTransactionsTypes.TransactionId)

  let sortDict = Recoil.useRecoilValueFromAtom(LoadedTable.sortAtom)
  let sortOrder =
    sortDict->getMappedValueFromDict(
      "Transactions",
      ReconEngineTransactionsTypes.Desc,
      getSortOrder,
    )

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

  let fetchPage = async (~sortBy, ~direction, ~searchType, ~searchText) => {
    if screenState !== PageLoaderWrapper.Success {
      setScreenState(_ => PageLoaderWrapper.Loading)
    }
    try {
      let body = buildTransactionsV2Body(
        ~filterValueJson,
        ~searchType,
        ~searchText,
        ~ruleId=rule.rule_id,
        ~sortBy,
        ~direction,
        ~order=sortOrder,
        (),
      )
      let page = await getTransactionsV2(~body)
      setTransactions(_ => page.transactions)
      setCursors(_ => page.cursors)
      setSelectedRows(_ => [])
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let goToFirstPage = () =>
    fetchPage(~sortBy=defaultSortBy, ~direction=#next, ~searchType, ~searchText)->ignore

  let goToNextPage = () => {
    cursors.next->mapOptionOrDefault((), cursor => {
      fetchPage(~sortBy=cursor, ~direction=#next, ~searchType, ~searchText)->ignore
    })
  }

  let goToPrevPage = () => {
    cursors.prev->mapOptionOrDefault((), cursor => {
      fetchPage(~sortBy=cursor, ~direction=#previous, ~searchType, ~searchText)->ignore
    })
  }

  let handleSearchSubmit = (selectedType: option<string>) => {
    let newSearchType =
      selectedType->mapOptionOrDefault(
        ReconEngineTransactionsTypes.TransactionId,
        searchTypeFromString,
      )
    setSearchType(_ => newSearchType)
    fetchPage(
      ~sortBy=defaultSortBy,
      ~direction=#next,
      ~searchType=newSearchType,
      ~searchText,
    )->ignore
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
        title="Transactions"
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
