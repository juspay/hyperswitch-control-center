open Typography

@react.component
let make = (
  ~primaryTransactionId: string,
  ~accountId: string,
  ~accountsData: array<ReconEngineTypes.accountType>,
  ~currencyOptions: array<FilterSelectBox.dropdownOption>,
  ~changes: Dict.t<ReconEngineExceptionTransactionTypes.entryChange>,
  ~showOptions: bool,
  ~selectedRows: array<JSON.t>,
  ~onRowSelect: (array<JSON.t> => array<JSON.t>) => unit,
  ~isRowSelectable: option<JSON.t => bool>=?,
) => {
  open LogicUtils
  open EntriesTableEntity
  open ReconEngineExceptionTransactionUtils
  open ReconEngineExceptionTransactionHelper
  open ReconEngineHooks
  open ReconEngineTransactionsTypes
  open ReconEngineTransactionsUtils

  let getEntries = useGetCursorPage(
    ~hyperswitchReconType=#PROCESSED_ENTRIES_LIST,
    ~itemMapper=transactionsEntryItemToObjMapperFromDict,
  )
  let getTransformationConfigs = useGetTransformationConfigs()
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let (searchText, setSearchText) = React.useState(_ => "")
  let (transformationConfigs, setTransformationConfigs) = React.useState((_): array<
    ReconEngineTypes.transformationConfigType,
  > => [])
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

  let fetchTransformationConfigs = async () => {
    try {
      let configs = await getTransformationConfigs(~queryParameters=Some(`account_id=${accountId}`))
      setTransformationConfigs(_ => configs)
    } catch {
    | _ => setTransformationConfigs(_ => [])
    }
  }

  React.useEffect(() => {
    fetchTransformationConfigs()->ignore
    None
  }, [accountId])

  React.useEffect(() => {
    goToFirstPage()
    None
  }, [filterValue])

  let transformationConfigOptions = React.useMemo(() => {
    transformationConfigs->Array.map((config): FilterSelectBox.dropdownOption => {
      label: config.name,
      value: config.transformation_id,
    })
  }, [transformationConfigs])

  let handleSearchSubmit = (selectedType: option<string>) => {
    searchTypeRef.current =
      selectedType->mapOptionOrDefault(SearchEntryOrderId, entrySearchTypeFromString)
    goToFirstPage()
  }

  let accountName =
    accountsData
    ->Array.find(account => account.account_id == accountId)
    ->mapOptionOrDefault(accountId, account => account.account_name)

  let pageEntries = React.useMemo(() => {
    let transformationNameMap =
      transformationConfigs
      ->Array.map(config => (config.transformation_id, config.name))
      ->Dict.fromArray
    entriesList
    ->Array.map(entry => {
      ...entry,
      account_name: accountName,
      transformation_name: entry.transformation_id->Option.flatMap(
        id => transformationNameMap->getOptionValFromDict(id),
      ),
    })
    ->addUniqueIdsToEntries
  }, (entriesList, transformationConfigs, accountName))

  let shownEntries = React.useMemo(() => {
    pageEntries->applyEntryChanges(~changes, ~accountId, ~isFirstPage=cursors.prev->Option.isNone)
  }, (pageEntries, changes, accountId, cursors.prev))

  let (groupedEntries, accountInfoMap) = React.useMemo(() => {
    getGroupedEntriesAndAccountMaps(~accountsData, ~updatedEntriesList=shownEntries)
  }, (shownEntries, accountsData))

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
      ~detailsFields=getDetailFieldsForTableSections,
      ~showTotalAmount=false,
    )
    let accountIds = groupedEntries->Dict.keysToArray
    sections->Array.mapWithIndex((section, index) => {
      let sectionAccountId = accountIds->getValueFromArray(index, "")

      (
        {
          rows: section.rows,
          rowData: groupedEntries
          ->getValueFromDict(sectionAccountId, [])
          ->Array.map(entry => entry->Identity.genericTypeToJson),
        }: ReconEngineExceptionTransactionTypes.tableSection
      )
    })
  }, (groupedEntries, accountInfoMap))

  <div className="flex flex-col gap-2">
    <p className={`text-nd_gray-700 ${body.lg.semibold}`}> {accountName->React.string} </p>
    <div className="flex flex-row justify-between items-center gap-4">
      <div className="flex flex-row -ml-1.5">
        <DynamicFilter
          title={`ReconEngineExceptionEntriesFilters-${accountId}`}
          initialFilters={entriesDisplayFilters(~currencyOptions, ~transformationConfigOptions)}
          options=[]
          popupFilterFields=[]
          initialFixedFilters=[]
          defaultFilterKeys=[]
          tabNames=filterKeys
          key={`ReconEngineExceptionEntriesFilters-${accountId}`}
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
    <PageLoaderWrapper screenState customLoader={<Shimmer styleClass="h-40 w-full rounded-xl" />}>
      <RenderIf condition={shownEntries->isNonEmptyArray}>
        <div className="flex flex-col">
          <ReconEngineCustomExpandableSelectionTable
            title=""
            heading={getDetailFieldsForTableSections->Array.map(getHeading)}
            getSectionRowDetails=sectionDetails
            showScrollBar=true
            showOptions
            selectedRows
            onRowSelect
            sections=tableSections
            ?isRowSelectable
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
      <RenderIf condition={shownEntries->isEmptyArray}>
        <NewAnalyticsHelper.NoData height="h-40" message="No data available." />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
