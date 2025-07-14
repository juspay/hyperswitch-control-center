@react.component
let make = () => {
  open LogicUtils
  let (stagingData, setStagingData) = React.useState(_ => [])
  let (filteredStagingData, setFilteredStagingData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ReconEngineAccountEntity.processingEntryType>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.staging_entry_id, searchText) ||
          isContainingStringLowercase(obj.status, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredStagingData(_ => filteredList)
  }, ~wait=200)

  let getStagingEntriesList = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let response = SampleDataExceptionStaging.data
      let data = response->getArrayFromJson([])
      let stagingList = data->Array.map(item => {
        item->getDictFromJsonObject->ReconEngineAccountEntity.processingItemToObjMapper
      })
      setStagingData(_ => stagingList)
      setFilteredStagingData(_ => stagingList->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getStagingEntriesList()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-4">
      <RenderIf condition={stagingData->Array.length > 0}>
        <LoadedTable
          title="Staging Entries"
          hideTitle=true
          actualData={filteredStagingData}
          entity={ReconEngineAccountEntity.processingTableEntity}
          resultsPerPage=10
          totalResults={filteredStagingData->Array.length}
          offset
          setOffset
          currrentFetchCount={stagingData->Array.length}
          tableheadingClass="h-12"
          tableHeadingTextClass="!font-normal"
          nonFrozenTableParentClass="!rounded-lg"
          loadedTableParentClass="flex flex-col"
          enableEqualWidthCol=false
          showAutoScroll=true
          filters={<TableSearchFilter
            data={stagingData->Array.map(Nullable.make)}
            filterLogic
            placeholder="Search Staging Entry ID or Status"
            customSearchBarWrapperWidth="w-full lg:w-1/2 mt-8 mb-2"
            customInputBoxWidth="w-full rounded-xl "
            searchVal=searchText
            setSearchVal=setSearchText
          />}
        />
      </RenderIf>
    </div>
  </PageLoaderWrapper>
}
