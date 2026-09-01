open Typography

@react.component
let make = (
  ~ruleId: string,
  ~accountData: array<ReconEngineTypes.accountType>,
  ~reconRulesList: array<ReconEngineRulesTypes.rulePayload>,
) => {
  open LogicUtils
  open ReconEngineFilterUtils
  open ReconEngineExceptionTransactionUtils
  open ReconEngineTypes
  open ReconEngineTransactionsUtils
  open ReconEngineTransactionsTypes
  open HierarchicalTransactionsTableEntity

  let getTransactionsV2 = ReconEngineHooks.useGetCursorPage(
    ~hyperswitchReconType=#TRANSACTIONS_LIST_V2,
    ~itemMapper=ReconEngineUtils.transactionItemToObjMapper,
  )

  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (appliedSearchText, setAppliedSearchText) = React.useState(_ => "")
  let searchTypeRef = React.useRef(SearchTransactionId)
  let (selectedRows, setSelectedRows) = React.useState(_ => [])
  let url = RescriptReactRouter.useUrl()
  let {
    updateExistingKeys,
    filterValueJson,
    filterValue,
    filterKeys,
    setfilterKeys,
  } = React.useContext(FilterContext.filterContext)
  let globalDateFilters = ReconEngineAtoms.globalDateFiltersAtom->Recoil.useRecoilValueFromAtom
  let filterValueJsonWithGlobalDate = mergeGlobalDateFilters(~filterValueJson, ~globalDateFilters)
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

  let sortDict = Recoil.useRecoilValueFromAtom(LoadedTable.sortAtom)
  let title = "Exception Transactions"
  let sortOrder = sortDict->getMappedValueFromDict(title, Desc, getSortOrder)

  let exceptionStatusList = getTransactionStatusValueFromStatusList([
    Missing,
    OverAmount(Mismatch),
    UnderAmount(Mismatch),
    OverAmount(Expected),
    UnderAmount(Expected),
    DataMismatch,
    PartiallyReconciled,
    CurrencyMismatch,
    SplitMismatch,
  ])

  let urlStatusList = React.useMemo(() => {
    url.search->isNonEmptyString
      ? url.search
        ->getDictFromUrlSearchParams
        ->getValueFromDict("status", "")
        ->String.split(",")
        ->Array.filter(isNonEmptyString)
      : []
  }, [url.search])

  let pendingUrlStatusApplication =
    urlStatusList->isNonEmptyArray &&
      filterValueJsonWithGlobalDate->getArrayFromDict("status", [])->isEmptyArray

  let enhancedFilterValueJson = {
    let enhanced = Dict.copy(filterValueJsonWithGlobalDate)
    let statusFilter = filterValueJsonWithGlobalDate->getArrayFromDict("status", [])
    if statusFilter->isEmptyArray {
      let fallbackStatusList = urlStatusList->isNonEmptyArray ? urlStatusList : exceptionStatusList
      enhanced->Dict.set("status", fallbackStatusList->getJsonFromArrayOfString)
    }
    enhanced
  }

  let fetchPage = (~sortBy, ~direction) => {
    setAppliedSearchText(_ => searchText)
    getTransactionsV2(
      ~body=buildTransactionsV2Body(
        ~filterValueJson=enhancedFilterValueJson,
        ~searchType=searchTypeRef.current,
        ~searchText,
        ~ruleId,
        ~sortBy,
        ~direction,
        ~order=sortOrder,
        ~limit=4,
      ),
    )
  }

  let {
    items: transactions,
    cursors,
    screenState,
    goToFirstPage,
    goToNextPage,
    goToPrevPage,
  } = ReconEngineCursorPaginationHook.useCursorPagination(
    ~fetchPage,
    ~persistKey=Some(`recon-engine-exception-transactions-${ruleId}`),
  )

  let handleSearchSubmit = (selectedType: option<string>) => {
    let newSearchType = selectedType->mapOptionOrDefault(SearchTransactionId, searchTypeFromString)
    searchTypeRef.current = newSearchType
    goToFirstPage()
  }

  let isSearchActive = appliedSearchText->isNonEmptyString

  let bulkSelectionFilters = isSearchActive
    ? None
    : Some(buildTransactionBulkSelectionFilters(~filterValueJson=enhancedFilterValueJson, ~ruleId))

  let selectionFilterScopeText = buildSelectionFilterScopeText(
    ~userSelectedFilterValueJson=filterValueJsonWithGlobalDate,
  )

  React.useEffect(() => {
    let urlSearch = url.search
    if urlSearch->isNonEmptyString {
      let filtersToApply = Dict.make()
      urlSearch
      ->getDictFromUrlSearchParams
      ->getMappedValueFromDict("status", (), value => {
        filtersToApply->Dict.set("status", `[${value}]`)
      })

      if !(filtersToApply->isEmptyDict) {
        updateExistingKeys(filtersToApply)
        if !(filterKeys->Array.includes("status")) {
          setfilterKeys(prev => prev->Array.concat(["status"]))
        }
      }
    }
    None
  }, [])

  React.useEffect(() => {
    if hasGlobalDateFilterValue(~globalDateFilters) && !pendingUrlStatusApplication {
      goToFirstPage()
    }
    None
  }, (filterValue, sortOrder, globalDateFilters, pendingUrlStatusApplication))

  let urlPathString = url.path->List.toArray->Array.joinWith("/")

  let customUpdateUrlWith = React.useMemo(() => {
    dict => {
      updateExistingKeys(dict)

      let filteredDict =
        dict
        ->Dict.toArray
        ->Array.filter(((key, _value)) => {
          key !== startTimeFilterKey && key !== endTimeFilterKey
        })

      let filteredArray = [
        ("rule_id", ruleId),
        ...filteredDict->Array.map(item => {
          let (key, value) = item
          (key, value)
        }),
      ]

      let queryString = filteredArray->Dict.fromArray->FilterUtils.parseFilterDictV2
      let finalUrl = if queryString->isNonEmptyString {
        `/${urlPathString}?${queryString}`
      } else {
        `/${urlPathString}`
      }
      RescriptReactRouter.push(finalUrl)
    }
  }, [urlPathString, ruleId])

  let topFilterUi = {
    <div className="flex flex-row -ml-1.5">
      <DynamicFilter
        title="ReconEngineExceptionTransactionFilters"
        initialFilters={initialDisplayFilters()}
        options=[]
        popupFilterFields=[]
        initialFixedFilters=[]
        defaultFilterKeys=[]
        tabNames=filterKeys
        key="ReconEngineExceptionTransactionFilters"
        updateUrlWith=customUpdateUrlWith
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
  }

  let noExceptionsFoundComponent =
    <div className="h-40-vh flex flex-col justify-center items-center gap-2">
      <p className={`${heading.sm.semibold} text-nd_gray-800`}>
        {"No exceptions to show."->React.string}
      </p>
      <p className={`${body.md.medium} text-nd_gray-500`}>
        {"All transactions are matched successfully across this system."->React.string}
      </p>
    </div>

  <div className="flex flex-col gap-4">
    <div className="flex-shrink-0 mt-3"> {topFilterUi} </div>
    <PageLoaderWrapper screenState>
      <LoadedTableWithCustomColumns
        title
        hideTitle=true
        actualData={transactions->Array.map(Nullable.make)}
        totalResults={transactions->Array.length}
        entity={hierarchicalTransactionsLoadedTableEntity(
          "v1/recon-engine/exceptions/recon",
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
        dataNotFoundComponent=noExceptionsFoundComponent
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
    </PageLoaderWrapper>
    <RenderIf condition={selectedRows->isNonEmptyArray}>
      <ReconEngineTransactionsBulkActions
        selectedRows={selectedRows->Array.map(json => json->Identity.jsonToAnyType)}
        setSelectedRows
        showVoidButton=true
        refreshList={() => goToFirstPage()}
        selectionFilters=?bulkSelectionFilters
        filterScopeCopy=selectionFilterScopeText
        currentPageCount={transactions->Array.length}
        isSinglePage={cursors.next->Option.isNone && cursors.prev->Option.isNone}
      />
    </RenderIf>
  </div>
}
