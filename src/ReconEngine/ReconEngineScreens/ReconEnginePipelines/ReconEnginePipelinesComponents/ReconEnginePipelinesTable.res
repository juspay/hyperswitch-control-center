open ReconEngineTypes
open ReconEnginePipelinesUtils
open Typography

@react.component
let make = (~accountData: array<ReconEngineTypes.accountType>) => {
  open LogicUtils

  let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()
  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (ingestionHistoryData, setIngestionHistoryData) = React.useState(_ => [])
  let (filteredHistoryData, setFilteredHistoryData) = React.useState(_ => [])
  let (sortOption, setSortOption) = React.useState(_ => #MostRecent)

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ingestionHistoryType>) => {
        obj
        ->getOptionalFromNullable
        ->mapOptionOrDefault(
          false,
          obj =>
            isContainingStringLowercase(obj.file_name, searchText) ||
            isContainingStringLowercase(obj.ingestion_name, searchText),
        )
      })
    } else {
      arr
    }
    setFilteredHistoryData(_ => filteredList)
  }, ~wait=200)

  let fetchIngestionHistoryData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let enhancedFilterValueJson = Dict.copy(filterValueJson)
      let statusFilter = filterValueJson->getArrayFromDict("status", [])
      if statusFilter->Array.length === 0 {
        let activeStatusList = ReconEngineFilterUtils.getIngestionTransformationHistoryStatusValueFromStatusList([
          Pending,
          Processing,
          Processed,
          Failed,
        ])
        enhancedFilterValueJson->Dict.set("status", activeStatusList->getJsonFromArrayOfString)
      }
      let queryString = ReconEngineFilterUtils.buildQueryStringFromFilters(
        ~filterValueJson=enhancedFilterValueJson,
      )
      let ingestionHistoryList = await getIngestionHistory(~queryParameters=Some(queryString))
      let ingestionHistoryData = ingestionHistoryList->Array.map(Nullable.make)
      setIngestionHistoryData(_ => ingestionHistoryData)
      setFilteredHistoryData(_ => ingestionHistoryData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchIngestionHistoryData()->ignore
    }
    None
  }, [filterValue])

  let sortedHistoryData = React.useMemo(() => {
    filteredHistoryData->sortIngestionHistory(sortOption)
  }, (filteredHistoryData, sortOption))

  let sortOptionLabel = (sortOption :> string)->camelCaseToTitle

  let sortDropdownOptions = ingestionHistorySortOptions->Array.map(opt => {
    let label = (opt :> string)->camelCaseToTitle
    {
      HeadlessUISelectBox.label,
      value: label,
      isDisabled: false,
      leftIcon: Button.NoIcon,
      customTextStyle: None,
      customIconStyle: None,
      rightIcon: Button.NoIcon,
      description: None,
      customComponent: None,
    }
  })

  let setSortOptionFromLabel = label => {
    ingestionHistorySortOptions
    ->Array.find(opt => (opt :> string)->camelCaseToTitle === label)
    ->Option.forEach(opt => {
      let nextOption = opt === sortOption ? #MostRecent : opt
      setSortOption(_ => nextOption)
    })
  }

  let (accountOptions, connectorOptions) = React.useMemo(() => {
    let unwrappedHistory = ingestionHistoryData->Array.filterMap(getOptionalFromNullable)
    (getAccountOptions(accountData), getConnectorOptions(unwrappedHistory))
  }, (accountData, ingestionHistoryData))

  let topFilterUi = {
    <div className="flex flex-row -ml-1.5 mt-4">
      <DynamicFilter
        title="ReconEnginePipelinesTableFilters"
        initialFilters={initialPipelinesTableFilters(~accountOptions, ~connectorOptions)}
        options=[]
        popupFilterFields=[]
        initialFixedFilters=[]
        defaultFilterKeys=[]
        tabNames=filterKeys
        key="ReconEnginePipelinesTableFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
        setOffset
      />
    </div>
  }

  <div className="flex flex-col gap-4">
    <div className="flex-shrink-0"> {topFilterUi} </div>
    <PageLoaderWrapper screenState>
      <LoadedTable
        title="Ingestion Runs"
        hideTitle=true
        actualData={sortedHistoryData}
        entity={ReconEnginePipelinesTableEntity.pipelineIngestionHistoryTableEntity(
          "v1/recon-engine/pipelines",
          ~authorization=Access,
          ~accountData,
        )}
        resultsPerPage=10
        totalResults={sortedHistoryData->Array.length}
        offset
        setOffset
        currentFetchCount={sortedHistoryData->Array.length}
        tableheadingClass="h-12"
        tableHeadingTextClass="!font-normal"
        nonFrozenTableParentClass="!rounded-lg"
        loadedTableParentClass="flex flex-col"
        enableEqualWidthCol=false
        showAutoScroll=true
        filters={<div className="flex flex-row items-center gap-3 w-full">
          <TableSearchFilter
            data={ingestionHistoryData}
            filterLogic
            placeholder="Search by File Name or Ingestion Name"
            customSearchBarWrapperWidth="w-full lg:w-1/3"
            customInputBoxWidth="w-full rounded-xl"
            searchVal=searchText
            setSearchVal=setSearchText
          />
          <HeadlessUISelectBox
            options=sortDropdownOptions
            setValue=setSortOptionFromLabel
            value={HeadlessUI.String(sortOptionLabel)}
            dropdownPosition=Right
            showTick=false
            dropDownClass="w-52">
            <div
              className={`flex items-center gap-2 px-3 py-2 border rounded-lg bg-white h-10 hover:bg-nd_gray-50 cursor-pointer text-nd_gray-700 whitespace-nowrap ${body.md.medium}`}>
              <div> {`Sort: ${sortOptionLabel}`->React.string} </div>
              <Icon name="chevron-down" size=12 className="opacity-50" />
            </div>
          </HeadlessUISelectBox>
        </div>}
      />
    </PageLoaderWrapper>
  </div>
}
