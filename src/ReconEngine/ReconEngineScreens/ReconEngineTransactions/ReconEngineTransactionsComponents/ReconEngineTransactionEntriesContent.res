open Typography

@react.component
let make = (
  ~primaryTransactionId: string,
  ~accountId: string,
  ~accountsData: array<ReconEngineTypes.accountType>,
  ~transformationNameMap: Dict.t<string>,
  ~currencyOptions: array<FilterSelectBox.dropdownOption>,
  ~transformationConfigOptions: array<FilterSelectBox.dropdownOption>,
  ~entriesDetailFields=EntriesTableEntity.transactionEntriesDetailFields,
) => {
  open LogicUtils
  open EntriesTableEntity
  open ReconEngineExceptionTransactionUtils
  open ReconEngineExceptionTransactionHelper
  open ReconEngineTransactionsTypes
  open ReconEngineTransactionsUtils

  let getEntries = ReconEngineHooks.useGetCursorPage(
    ~hyperswitchReconType=#PROCESSED_ENTRIES_LIST,
    ~itemMapper=transactionsEntryItemToObjMapperFromDict,
  )
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let (searchText, setSearchText) = React.useState(_ => "")
  let searchTypeRef = React.useRef(SearchEntryOrderId)

  let {
    items: entriesList,
    cursors,
    screenState,
    goToFirstPage,
    goToNextPage,
    goToPrevPage,
  } = ReconEngineCursorPaginationHook.useCursorPagination(~fetchPage=(~sortBy, ~direction) => {
    getEntries(
      ~body=buildEntriesListBody(
        ~primaryTransactionId,
        ~accountIds=[accountId],
        ~sortBy,
        ~direction,
        ~filterValueJson,
        ~searchType=searchTypeRef.current,
        ~searchText,
      ),
    )
  })

  React.useEffect(() => {
    goToFirstPage()
    None
  }, [filterValue])

  let handleSearchSubmit = (selectedType: option<string>) => {
    searchTypeRef.current =
      selectedType->mapOptionOrDefault(SearchEntryOrderId, entrySearchTypeFromString)
    goToFirstPage()
  }

  let accountName =
    accountsData
    ->Array.find(account => account.account_id == accountId)
    ->mapOptionOrDefault(accountId, account => account.account_name)

  let filterSearchRowUi =
    <div className="flex flex-row justify-between items-center gap-4">
      <div className="flex flex-row -ml-1.5">
        <DynamicFilter
          title={`ReconEngineTransactionEntriesFilters-${accountId}`}
          initialFilters={entriesDisplayFilters(~currencyOptions, ~transformationConfigOptions)}
          options=[]
          popupFilterFields=[]
          initialFixedFilters=[]
          defaultFilterKeys=[]
          tabNames=filterKeys
          key={`ReconEngineTransactionEntriesFilters-${accountId}`}
          updateUrlWith=updateExistingKeys
          filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
          showCustomFilter=false
          refreshFilters=false
        />
      </div>
      <SearchInput
        inputText=searchText
        onChange={value => setSearchText(_ => value)}
        placeholder="Search by ID"
        showTypeSelector=true
        typeSelectorOptions=entrySearchTypeOptions
        onSubmitSearchDropdown=handleSearchSubmit
        showSearchIcon=true
        widthClass="w-max"
      />
    </div>

  let enrichedEntriesList = React.useMemo(() => {
    entriesList->Array.map(entry => {
      ...entry,
      transformation_name: entry.transformation_id->Option.flatMap(
        id => transformationNameMap->Dict.get(id),
      ),
    })
  }, (entriesList, transformationNameMap))

  let (groupedEntries, accountInfoMap) = React.useMemo(() => {
    getGroupedEntriesAndAccountMaps(
      ~accountsData,
      ~updatedEntriesList=enrichedEntriesList->addUniqueIdsToEntries,
    )
  }, (enrichedEntriesList, accountsData))

  let sectionDetails = (sectionIndex: int, rowIndex: int) => {
    getSectionRowDetails(
      ~sectionIndex,
      ~rowIndex,
      ~groupedEntries=groupedEntries->convertGroupedEntriesToEntryType,
    )
  }

  let tableSections = React.useMemo(() => {
    let sections = getEntriesSections(
      ~groupedEntries,
      ~accountInfoMap,
      ~detailsFields=entriesDetailFields,
      ~showTotalAmount=false,
    )
    let accountIds = groupedEntries->Dict.keysToArray
    sections->Array.mapWithIndex((section, index) => {
      let accountId = accountIds->getValueFromArray(index, "")
      let entriesWithUniqueId = groupedEntries->getValueFromDict(accountId, [])

      (
        {
          rows: section.rows,
          rowData: entriesWithUniqueId->Array.map(entry => entry->Identity.genericTypeToJson),
        }: ReconEngineExceptionTransactionTypes.tableSection
      )
    })
  }, (groupedEntries, accountInfoMap))

  <div className="flex flex-col gap-2">
    <p className={`text-nd_gray-700 ${body.lg.semibold}`}> {accountName->React.string} </p>
    {filterSearchRowUi}
    <PageLoaderWrapper screenState customLoader={<Shimmer styleClass="h-40 w-full rounded-xl" />}>
      <RenderIf condition={entriesList->isNonEmptyArray}>
        <div className="flex flex-col">
          <ReconEngineCustomExpandableSelectionTable
            title=""
            heading={entriesDetailFields->Array.map(getHeading)}
            getSectionRowDetails=sectionDetails
            showScrollBar=true
            showOptions=false
            selectedRows=[]
            onRowSelect={_ => ()}
            sections=tableSections
          />
          <ReconEngineCursorPaginationButtons
            cursors
            isLoading={screenState === PageLoaderWrapper.Loading}
            hasData={entriesList->isNonEmptyArray}
            onPrev=goToPrevPage
            onNext=goToNextPage
          />
        </div>
      </RenderIf>
      <RenderIf condition={entriesList->isEmptyArray}>
        <NewAnalyticsHelper.NoData height="h-40" message="No data available." />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
