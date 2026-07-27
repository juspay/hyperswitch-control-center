open Typography

@react.component
let make = () => {
  open ReconEngineHooks
  open ReconEngineFilterUtils
  open LogicUtils
  open ReconEngineTypes
  open ReconEngineDataTransformedEntriesUtils
  open ReconEngineDataTransformedEntriesTypes
  open HSAnalyticsUtils

  let getProcessingEntriesV2 = useGetCursorPage(
    ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST_V2,
    ~itemMapper=ReconEngineUtils.processingItemToObjMapper,
  )
  let getAccounts = useGetAccounts()
  let showToast = ToastAdapter.useShowToast()
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )

  let (accountData, setAccountData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let searchTypeRef = React.useRef(SearchStagingEntryId)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (selectedRows, setSelectedRows) = React.useState(_ => [])

  let title = "Transformed Entry Exceptions"
  let sortDict = Recoil.useRecoilValueFromAtom(LoadedTable.sortAtom)
  let sortOrder = sortDict->getMappedValueFromDict(title, Desc, getSortOrder)

  let mixpanelEvent = MixpanelHook.useSendEvent()

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_transformed_entries_exceptions_date_filter_opened")
  }

  let {
    items: processingEntries,
    cursors,
    screenState,
    goToFirstPage,
    goToNextPage,
    goToPrevPage,
  } = ReconEngineCursorPaginationHook.useCursorPagination(~fetchPage=(~sortBy, ~direction) => {
    let enhancedFilterValueJson = Dict.copy(filterValueJson)
    let statusFilter = filterValueJson->getArrayFromDict("status", [])
    if statusFilter->isEmptyArray {
      enhancedFilterValueJson->Dict.set(
        "status",
        getProcessingEntryStatusValueFromStatusList([NeedsManualReview])->getJsonFromArrayOfString,
      )
    }
    getProcessingEntriesV2(
      ~body=buildProcessingEntriesV2Body(
        ~filterValueJson=enhancedFilterValueJson,
        ~searchType=searchTypeRef.current,
        ~searchText,
        ~sortBy,
        ~direction,
        ~order=sortOrder,
      ),
    )
  }, ~persistKey="recon-engine-transformed-entry-exceptions")

  let fetchAccounts = async () => {
    try {
      let accounts = await getAccounts()
      setAccountData(_ => accounts)
    } catch {
    | _ => showToast(~message="Failed to fetch accounts", ~toastType=ToastError)
    }
  }

  let accountOptions =
    accountData->Array.map((account: accountType): FilterSelectBox.dropdownOption => {
      label: account.account_name,
      value: account.account_id,
    })

  let handleSearchSubmit = (selectedType: option<string>) => {
    let newSearchType = selectedType->mapOptionOrDefault(SearchStagingEntryId, searchTypeFromString)
    searchTypeRef.current = newSearchType
    setSelectedRows(_ => [])
    goToFirstPage()
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="recon_engine_transformed_entries_exceptions",
    ~range=180,
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    fetchAccounts()->ignore
    None
  }, [])

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      setSelectedRows(_ => [])
      goToFirstPage()
    }
    None
  }, (filterValue, sortOrder))

  let topFilterUi = {
    <div className="flex flex-row -ml-1.5">
      <DynamicFilter
        title="ReconEngineTransformedEntriesExceptionsFilters"
        initialFilters={ReconEngineTransformedEntryExceptionsUtils.initialDisplayFilters(
          ~accountOptions,
        )}
        options=[]
        popupFilterFields=[]
        initialFixedFilters={initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineTransformedEntriesExceptionsFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
  }

  <div className="flex flex-col gap-5 w-full">
    <div className="flex flex-row justify-between items-center">
      <PageUtils.PageHeading
        title="Transformed Entry Exceptions"
        customTitleStyle={`${heading.lg.semibold}`}
        customHeadingStyle="py-0"
      />
    </div>
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-4">
        <div className="flex-shrink-0"> {topFilterUi} </div>
        <RenderIf condition={processingEntries->isEmptyArray}>
          <div className="h-40-vh flex flex-col justify-center items-center gap-2">
            <p className={`${heading.sm.semibold} text-nd_gray-800`}>
              {"No exceptions to show."->React.string}
            </p>
            <p className={`${body.md.medium} text-nd_gray-500`}>
              {"All transformed entries have been processed successfully and entered into the reconciliation engine."->React.string}
            </p>
          </div>
        </RenderIf>
        <RenderIf condition={processingEntries->isNonEmptyArray}>
          <LoadedTable
            title
            hideTitle=true
            actualData={processingEntries->Array.map(Nullable.make)}
            entity={ReconEngineExceptionEntity.transformedEntryExceptionTableEntity(
              `v1/recon-engine/exceptions/transformed-entries`,
              ~authorization=Access,
            )}
            resultsPerPage=10
            totalResults={processingEntries->Array.length}
            offset
            setOffset
            currentFetchCount={processingEntries->Array.length}
            tableheadingClass="h-12"
            tableHeadingTextClass="!font-normal"
            nonFrozenTableParentClass="!rounded-lg"
            loadedTableParentClass="flex flex-col"
            enableEqualWidthCol=false
            showAutoScroll=true
            remoteSortEnabled=true
            showPagination=false
            showResultsPerPageSelector=false
            tableDataLoading={screenState === PageLoaderWrapper.Loading}
            dataLoading={screenState === PageLoaderWrapper.Loading}
            filters={<SearchInput
              inputText=searchText
              onChange={value => setSearchText(_ => value)}
              placeholder="Search by ID"
              showTypeSelector=true
              typeSelectorOptions=searchTypeOptionsWithTransformationHistory
              onSubmitSearchDropdown=handleSearchSubmit
              showSearchIcon=true
              widthClass="w-max"
            />}
            bottomActions={<ReconEngineCursorPaginationButtons
              cursors
              isLoading={screenState === PageLoaderWrapper.Loading}
              hasData={processingEntries->isNonEmptyArray}
              onPrev={() => {
                setSelectedRows(_ => [])
                goToPrevPage()
              }}
              onNext={() => {
                setSelectedRows(_ => [])
                goToNextPage()
              }}
            />}
            checkBoxProps={{
              showCheckBox: true,
              selectedData: selectedRows,
              setSelectedData: setSelectedRows,
            }}
          />
        </RenderIf>
      </div>
    </PageLoaderWrapper>
    <RenderIf condition={selectedRows->isNonEmptyArray}>
      <ReconEngineTransformedEntryBulkActions
        selectedRows={selectedRows->Array.map(json => json->Identity.jsonToAnyType)}
        setSelectedRows
        refreshList={() => goToFirstPage()}
      />
    </RenderIf>
  </div>
}
