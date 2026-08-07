open Typography

@react.component
let make = () => {
  open ReconEngineHooks
  open ReconEngineFilterUtils
  open LogicUtils
  open APIUtils
  open ReconEngineTypes
  open ReconEngineUtils
  open ReconEngineDataTransformedEntriesUtils
  open ReconEngineDataTransformedEntriesTypes
  open HSAnalyticsUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let getProcessingEntriesV2 = useGetCursorPage(
    ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST_V2,
    ~itemMapper=ReconEngineUtils.processingItemToObjMapper,
  )
  let getAccounts = useGetAccounts()
  let showToast = ToastAdapter.useShowToast()
  let {
    updateExistingKeys,
    removeKeys,
    reset,
    filterValueJson,
    filterValue,
    filterKeys,
  } = React.useContext(FilterContext.filterContext)
  let url = RescriptReactRouter.useUrl()
  let basePath = GlobalVars.appendDashboardPath(
    ~url="/v1/recon-engine/exceptions/transformed-entries",
  )

  let (accountData, setAccountData) = React.useState((_): array<accountType> => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (offset, setOffset) = React.useState(_ => 0)
  let searchTypeRef = React.useRef(SearchStagingEntryId)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (selectedRows, setSelectedRows) = React.useState(_ => [])
  let (transformationConfigs, setTransformationConfigs) = React.useState((_): array<
    transformationConfigType,
  > => [])
  let (pendingTransformationConfigIds, setPendingTransformationConfigIds) = React.useState(_ => [])
  let (
    selectedTransformationConfigIds,
    setSelectedTransformationConfigIds,
  ) = React.useState(_ => [])

  let title = "Transformed Entry Exceptions"
  let sortDict = Recoil.useRecoilValueFromAtom(LoadedTable.sortAtom)
  let sortOrder = sortDict->getMappedValueFromDict(title, Desc, getSortOrder)

  let mixpanelEvent = MixpanelHook.useSendEvent()

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_transformed_entries_exceptions_date_filter_opened")
  }

  let selectedAccountId = React.useMemo(() => {
    let accountIdFromUrl =
      url.search->getDictFromUrlSearchParams->getValueFromDict("account_id", "")
    switch accountData->Array.find(account => account.account_id === accountIdFromUrl) {
    | Some(account) => account.account_id
    | None =>
      accountData
      ->Array.get(0)
      ->mapOptionOrDefault("", account => account.account_id)
    }
  }, (url.search, accountData))

  let {
    items: processingEntries,
    cursors,
    screenState: tableScreenState,
    goToFirstPage,
    goToNextPage,
    goToPrevPage,
  } = ReconEngineCursorPaginationHook.useCursorPagination(~fetchPage=(~sortBy, ~direction) => {
    let enhancedFilterValueJson = Dict.copy(filterValueJson)
    let statusFilter = filterValueJson->getArrayFromDict("status", [])
    if selectedAccountId->isNonEmptyString {
      enhancedFilterValueJson->Dict.set(
        "account_ids",
        [selectedAccountId]->getJsonFromArrayOfString,
      )
    }
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
        ~transformationConfigIds=selectedTransformationConfigIds,
      ),
    )
  }, ~persistKey=`recon-engine-transformed-entry-exceptions-${selectedAccountId}`)

  let fetchAccounts = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let accounts = await getAccounts()
      setAccountData(_ => accounts)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch accounts"))
    }
  }

  let fetchTransformationFilters = async accountId => {
    try {
      let transformationConfigUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
        ~queryParameters=Some(`account_id=${accountId}`),
      )
      let transformationConfigsRes = await fetchDetails(transformationConfigUrl)
      let transformationConfigs =
        transformationConfigsRes->getArrayDataFromJson(transformationConfigItemToObjMapper)
      transformationConfigs->Array.sort((a, b) => compareLogic(b.created_at, a.created_at))

      setTransformationConfigs(_ => transformationConfigs)
    } catch {
    | _ =>
      setTransformationConfigs(_ => [])
      showToast(~message="Failed to fetch transformation configs", ~toastType=ToastError)
    }
  }

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
    fetchAccounts()->ignore
    None
  }, [])

  React.useEffect(() => {
    if selectedAccountId->isNonEmptyString {
      if filterValue->Dict.get("account_ids")->Option.isSome {
        removeKeys(["account_ids"])
      } else if filterValue->isEmptyDict {
        setInitialFilters()
      }
    }
    None
  }, (selectedAccountId, filterValue))

  React.useEffect(() => {
    if selectedAccountId->isNonEmptyString {
      setPendingTransformationConfigIds(_ => [])
      setSelectedTransformationConfigIds(_ => [])
      setTransformationConfigs(_ => [])
      fetchTransformationFilters(selectedAccountId)->ignore
    }
    None
  }, [selectedAccountId])

  React.useEffect(() => {
    if (
      selectedAccountId->isNonEmptyString &&
      !(filterValue->isEmptyDict) &&
      filterValue->Dict.get("account_ids")->Option.isNone
    ) {
      setSelectedRows(_ => [])
      goToFirstPage()
    }
    None
  }, (filterValue, sortOrder, selectedAccountId, selectedTransformationConfigIds))

  React.useEffect(() => {
    if selectedAccountId->isNonEmptyString {
      let accountIdFromUrl =
        url.search->getDictFromUrlSearchParams->getValueFromDict("account_id", "")
      if accountIdFromUrl !== selectedAccountId {
        RescriptReactRouter.push(`${basePath}?account_id=${selectedAccountId}`)
      }
    }
    None
  }, (selectedAccountId, url.search))

  let initialTabIndex = React.useMemo(() => {
    selectedAccountId->isNonEmptyString
      ? accountData
        ->Array.findIndexOpt(account => account.account_id === selectedAccountId)
        ->Option.getOr(0)
      : 0
  }, (selectedAccountId, accountData))

  let resetFiltersForAccountSwitch = () => {
    setSearchText(_ => "")
    searchTypeRef.current = SearchStagingEntryId
    setSelectedRows(_ => [])
    setOffset(_ => 0)
    setPendingTransformationConfigIds(_ => [])
    setSelectedTransformationConfigIds(_ => [])
    reset()
    removeKeys(["account_ids"])
  }

  let onTitleClick = idx => {
    switch accountData->Array.get(idx) {
    | Some(account) =>
      RescriptReactRouter.push(`${basePath}?account_id=${account.account_id}`)
      resetFiltersForAccountSwitch()
    | None => ()
    }
  }

  let topFilterUi = {
    let transformationConfigOptions = transformationConfigs->Array.map((
      config
    ): SelectBox.dropdownOption => {
      label: config.name,
      value: config.transformation_id,
    })
    let applyTransformationConfigFilter: MultiSelectBindings.actionButtonType = {
      text: "Apply",
      onClick: _ => {
        setSelectedTransformationConfigIds(_ => pendingTransformationConfigIds)
      },
    }
    let clearTransformationConfigFilter = () => {
      setPendingTransformationConfigIds(_ => [])
      setSelectedTransformationConfigIds(_ => [])
    }
    let transformationConfigInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "transformation_config_ids",
      value: pendingTransformationConfigIds->getJsonFromArrayOfString,
      onBlur: _ => (),
      onFocus: _ => (),
      checked: false,
      onChange: ev => {
        setPendingTransformationConfigIds(_ => ev->Identity.formReactEventToArrayOfString)
      },
    }

    let transformationConfigFilter =
      <SelectBoxAdapter.BaseDropdown
        buttonText="Select Transformation Config"
        allowMultiSelect=true
        input=transformationConfigInput
        options=transformationConfigOptions
        hideMultiSelectButtons=false
        showSelectAll=true
        disableSelect={transformationConfigOptions->isEmptyArray}
        showClearButton=true
        onClearAllClick=clearTransformationConfigFilter
        minMenuWidth=280
        maxMenuWidth=320
        fixedDropDownDirection=BottomRight
        primaryAction=applyTransformationConfigFilter
        selectionTagType=Count
      />

    <div className="flex flex-row -ml-1.5">
      <DynamicFilter
        title="ReconEngineTransformedEntriesExceptionsFilters"
        initialFilters={ReconEngineTransformedEntryExceptionsUtils.initialDisplayFilters()}
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
        customFilterActions=transformationConfigFilter
        refreshFilters=false
      />
    </div>
  }

  let tableContent = {
    <PageLoaderWrapper screenState=tableScreenState>
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
            tableDataLoading={tableScreenState === Loading}
            dataLoading={tableScreenState === Loading}
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
              isLoading={tableScreenState === Loading}
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
  }

  let tabs: array<Tabs.tab> = accountData->Array.map((account): Tabs.tab => {
    title: account.account_name,
    renderContent: () => tableContent,
  })

  <div className="flex flex-col gap-5 w-full">
    <div className="flex flex-row justify-between items-center">
      <PageUtils.PageHeading
        title="Transformed Entry Exceptions"
        customTitleStyle={`${heading.lg.semibold}`}
        customHeadingStyle="py-0"
      />
    </div>
    <PageLoaderWrapper screenState>
      <RenderIf condition={accountData->isEmptyArray}>
        <div className="my-4">
          <NoDataFound
            message="No accounts found. Please create an account to view the sources."
            renderType={Painting}
            customMessageCss={`${body.lg.semibold} text-nd_gray-400`}
          />
        </div>
      </RenderIf>
      <RenderIf condition={accountData->isNonEmptyArray}>
        <Tabs tabs initialIndex=initialTabIndex onTitleClick />
      </RenderIf>
      <RenderIf condition={selectedRows->isNonEmptyArray}>
        <ReconEngineTransformedEntryBulkActions
          selectedRows={selectedRows->Array.map(json => json->Identity.jsonToAnyType)}
          setSelectedRows
          refreshList={() => goToFirstPage()}
        />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
