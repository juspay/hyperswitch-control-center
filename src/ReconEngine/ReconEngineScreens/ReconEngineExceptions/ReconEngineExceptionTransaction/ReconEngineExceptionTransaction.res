open Typography

@react.component
let make = (~ruleId: string) => {
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
  let getAccounts = ReconEngineHooks.useGetAccounts()
  let getReconRuleList = ReconEngineHooks.useGetReconRuleList()
  let showToast = ToastAdapter.useShowToast()

  let (accountData, setAccountData) = React.useState(_ => [])
  let (reconRulesList, setReconRulesList) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let searchTypeRef = React.useRef(SearchTransactionId)
  let (selectedRows, setSelectedRows) = React.useState(_ => [])
  let url = RescriptReactRouter.useUrl()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {
    updateExistingKeys,
    filterValueJson,
    filterValue,
    filterKeys,
    setfilterKeys,
  } = React.useContext(FilterContext.filterContext)
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_exception_transaction_date_filter_opened")
  }

  let sortDict = Recoil.useRecoilValueFromAtom(LoadedTable.sortAtom)
  let title = "Exception Transactions"
  let sortOrder = sortDict->getMappedValueFromDict(title, Desc, getSortOrder)

  let exceptionStatusList = getTransactionStatusValueFromStatusList([
    Expected,
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

  let fetchAccountsAndRules = async () => {
    try {
      let accounts = await getAccounts()
      let rules = await getReconRuleList()
      setAccountData(_ => accounts)
      setReconRulesList(_ => rules)
    } catch {
    | _ => showToast(~message="Failed to fetch accounts", ~toastType=ToastError)
    }
  }

  let fetchPage = (~sortBy, ~direction) => {
    let enhancedFilterValueJson = Dict.copy(filterValueJson)
    let statusFilter = filterValueJson->getArrayFromDict("status", [])
    if statusFilter->isEmptyArray {
      enhancedFilterValueJson->Dict.set("status", exceptionStatusList->getJsonFromArrayOfString)
    }
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
    ~persistKey=`recon-engine-exception-transactions-${ruleId}`,
  )

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
    ~origin="recon_engine_exception_transaction",
    (),
  )

  React.useEffect(() => {
    fetchAccountsAndRules()->ignore
    let urlSearch = url.search
    if urlSearch->isNonEmptyString {
      let urlParams = urlSearch->getDictFromUrlSearchParams
      let filtersToApply = Dict.make()

      urlParams->getMappedValueFromDict("status", (), value => {
        let formattedValue = value->String.includes(",") ? `[${value}]` : value
        filtersToApply->Dict.set("status", formattedValue)
      })

      if !(filtersToApply->isEmptyDict) {
        updateExistingKeys(filtersToApply)
        if !(filterKeys->Array.includes("status")) {
          setfilterKeys(prev => prev->Array.concat(["status"]))
        }
      }
    }
    setInitialFilters()
    None
  }, [])

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      goToFirstPage()
    }
    None
  }, (filterValue, sortOrder))

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
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineExceptionTransactionFilters"
        updateUrlWith=customUpdateUrlWith
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
  }

  <div className="flex flex-col gap-4 mt-3">
    <PageLoaderWrapper screenState>
      <div className="flex-shrink-0"> {topFilterUi} </div>
      <RenderIf condition={transactions->isEmptyArray}>
        <div className="h-40-vh flex flex-col justify-center items-center gap-2">
          <p className={`${heading.sm.semibold} text-nd_gray-800`}>
            {"No exceptions to show."->React.string}
          </p>
          <p className={`${body.md.medium} text-nd_gray-500`}>
            {"All transactions are matched successfully across this system."->React.string}
          </p>
        </div>
      </RenderIf>
      <RenderIf condition={transactions->isNonEmptyArray}>
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
      </RenderIf>
    </PageLoaderWrapper>
    <RenderIf condition={selectedRows->isNonEmptyArray}>
      <ReconEngineTransactionsBulkActions
        selectedRows={selectedRows->Array.map(json => json->Identity.jsonToAnyType)}
        setSelectedRows
        showVoidButton=true
        refreshList={() => goToFirstPage()}
      />
    </RenderIf>
  </div>
}
