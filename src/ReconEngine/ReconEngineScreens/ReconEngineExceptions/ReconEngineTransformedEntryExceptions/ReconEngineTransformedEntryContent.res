open Typography

@react.component
let make = (~accountId: string) => {
  open LogicUtils
  open APIUtils
  open HSAnalyticsUtils
  open ReconEngineHooks
  open ReconEngineFilterUtils
  open ReconEngineTypes
  open ReconEngineUtils
  open ReconEngineDataTransformedEntriesUtils
  open ReconEngineDataTransformedEntriesTypes

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let getProcessingEntriesV2 = useGetCursorPage(
    ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST_V2,
    ~itemMapper=ReconEngineUtils.processingItemToObjMapper,
  )
  let showToast = ToastAdapter.useShowToast()
  let {updateExistingKeys, filterValueJson, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )

  let searchTypeRef = React.useRef(SearchStagingEntryId)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (selectedRows, setSelectedRows) = React.useState(_ => [])
  let (transformationConfigs, setTransformationConfigs) = React.useState((_): array<
    transformationConfigType,
  > => [])

  let title = "Transformed Entry Exceptions"
  let sortDict = Recoil.useRecoilValueFromAtom(LoadedTable.sortAtom)
  let sortOrder = sortDict->getMappedValueFromDict(title, Desc, getSortOrder)

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
    enhancedFilterValueJson->Dict.set("account_ids", [accountId]->getJsonFromArrayOfString)
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
  }, ~persistKey=`recon-engine-transformed-entry-exceptions-${accountId}`)

  let fetchTransformationFilters = async () => {
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

  React.useEffect(() => {
    fetchTransformationFilters()->ignore
    None
  }, [accountId])

  let appliedFilters = buildQueryStringFromFilters(~filterValueJson)

  React.useEffect(() => {
    if (
      !(filterValueJson->isEmptyDict) &&
      filterValueJson->getOptionValFromDict("account_ids")->Option.isNone
    ) {
      setSelectedRows(_ => [])
      goToFirstPage()
    }
    None
  }, (appliedFilters, sortOrder))

  let topFilterUi = {
    let transformationConfigOptions = transformationConfigs->Array.map((
      config
    ): FilterSelectBox.dropdownOption => {
      label: config.name,
      value: config.transformation_id,
    })

    let transformationConfigFilter =
      <FormRenderer.FieldRenderer
        field={FormRenderer.makeFieldInfo(
          ~label="transformation_config_ids",
          ~name="transformation_config_ids",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=transformationConfigOptions,
            ~buttonText="Select Transformation Config",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~showSelectAll=true,
            ~disableSelect={transformationConfigOptions->isEmptyArray},
            ~customButtonStyle="bg-none",
            ~dropdownCustomWidth="300px",
            ~fixedDropDownDirection=BottomRight,
            (),
          ),
        )}
        labelClass="hidden"
        fieldWrapperClass="p-0"
      />

    <div className="flex flex-row -ml-1.5">
      <DynamicFilter
        title="ReconEngineTransformedEntriesExceptionsFilters"
        initialFilters={ReconEngineTransformedEntryExceptionsUtils.initialDisplayFilters()}
        options=[]
        popupFilterFields=[]
        initialFixedFilters=[]
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

  let noExceptionsFoundComponent =
    <div className="h-40-vh flex flex-col justify-center items-center gap-2">
      <p className={`${heading.sm.semibold} text-nd_gray-800`}>
        {"No exceptions to show."->React.string}
      </p>
      <p className={`${body.md.medium} text-nd_gray-500`}>
        {"All transformed entries have been processed successfully and entered into the reconciliation engine."->React.string}
      </p>
    </div>

  <PageLoaderWrapper screenState=tableScreenState>
    <div className="flex flex-col gap-4">
      <div className="flex-shrink-0"> {topFilterUi} </div>
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
        offset=0
        setOffset={_ => ()}
        currentFetchCount={processingEntries->Array.length}
        dataNotFoundComponent=noExceptionsFoundComponent
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
      <RenderIf condition={selectedRows->isNonEmptyArray}>
        <ReconEngineTransformedEntryBulkActions
          selectedRows={selectedRows->Array.map(json => json->Identity.jsonToAnyType)}
          setSelectedRows
          refreshList={() => goToFirstPage()}
        />
      </RenderIf>
    </div>
  </PageLoaderWrapper>
}
