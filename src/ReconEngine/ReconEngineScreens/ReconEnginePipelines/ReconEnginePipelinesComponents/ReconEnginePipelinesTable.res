open ReconEngineTypes
open ReconEnginePipelinesUtils

@react.component
let make = (~accountData: array<ReconEngineTypes.accountType>, ~refreshTrigger=false) => {
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

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ingestionHistoryType>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.file_name, searchText) ||
          isContainingStringLowercase(obj.ingestion_name, searchText)
        | None => false
        }
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
  }, (filterValue, refreshTrigger))

  let (accountOptions, connectorOptions) = React.useMemo(() => {
    let unwrappedHistory = ingestionHistoryData->Belt.Array.keepMap(Nullable.toOption)
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
        actualData={filteredHistoryData}
        entity={ReconEnginePipelinesTableEntity.pipelineIngestionHistoryTableEntity(
          "v1/recon-engine/pipelines",
          ~authorization=Access,
          ~accountData,
        )}
        resultsPerPage=10
        totalResults={filteredHistoryData->Array.length}
        offset
        setOffset
        currentFetchCount={filteredHistoryData->Array.length}
        tableheadingClass="h-12"
        tableHeadingTextClass="!font-normal"
        nonFrozenTableParentClass="!rounded-lg"
        loadedTableParentClass="flex flex-col"
        enableEqualWidthCol=false
        showAutoScroll=true
        filters={<TableSearchFilter
          data={ingestionHistoryData}
          filterLogic
          placeholder="Search by File Name or Ingestion Name"
          customSearchBarWrapperWidth="w-full lg:w-1/3"
          customInputBoxWidth="w-full rounded-xl"
          searchVal=searchText
          setSearchVal=setSearchText
        />}
      />
    </PageLoaderWrapper>
  </div>
}
