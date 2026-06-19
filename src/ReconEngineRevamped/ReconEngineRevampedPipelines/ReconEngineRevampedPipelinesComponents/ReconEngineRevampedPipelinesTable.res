open Typography

module FilterDropdown = {
  @react.component
  let make = (~value: string, ~options: array<(string, string)>, ~onChange: string => unit) => {
    open LogicUtils
    let selectOptions = options->Array.map(((v, l)) => {SelectBox.label: l, value: v})
    let input = ReactFinalForm.makeInputRecord(value->JSON.Encode.string, ev => {
      let v = ev->Identity.genericTypeToJson->getStringFromJson(value)
      onChange(v)
    })
    <SelectBoxAdapter
      input options=selectOptions allowMultiSelect=false isDropDown=true deselectDisable=true
    />
  }
}

@react.component
let make = (~statusFilter: string, ~setStatusFilter: (string => string) => unit) => {
  open LogicUtils

  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let defaultDateRange = HSwitchRemoteFilter.getDateFilteredObject(~range=90)
  let startTime =
    filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, defaultDateRange.start_time)
  let endTime =
    filterValueJson->getString(HSAnalyticsUtils.endTimeFilterKey, defaultDateRange.end_time)

  let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()
  let getAccounts = ReconEngineHooks.useGetAccounts()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (allItems, setAllItems) = React.useState((_): array<
    ReconEngineRevampedPipelinesTypes.pipelineIngestionItem,
  > => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (accountFilter, setAccountFilter) = React.useState(_ => "all")
  let (connectorFilter, setConnectorFilter) = React.useState(_ => "all")
  let (sortOrder, setSortOrder) = React.useState(_ => "recent")

  let fetchData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = ReconEngineRevampedUtils.getQueryParamFromFilters(~filterValueJson)
      let historyRes = await getIngestionHistory(~queryParameters=Some(queryParams))
      let accountsRes = await getAccounts()

      let accountMap: Dict.t<string> = Dict.make()
      accountsRes->Array.forEach(a => accountMap->Dict.set(a.account_id, a.account_name))

      let items =
        historyRes->Array.map(h =>
          ReconEngineRevampedPipelinesUtils.pipelineIngestionItemFromHistory(h, accountMap)
        )
      setAllItems(_ => items)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if startTime->isNonEmptyString && endTime->isNonEmptyString {
      fetchData()->ignore
    }
    None
  }, (startTime, endTime, filterValue))

  let accountOptions = React.useMemo(() => {
    let seen: Dict.t<bool> = Dict.make()
    let opts = [("all", "All accounts")]
    allItems->Array.forEach(item => {
      if !(seen->Dict.get(item.account_id)->Option.isSome) {
        seen->Dict.set(item.account_id, true)
        opts->Array.push((item.account_id, item.account_name))->ignore
      }
    })
    opts
  }, [allItems])

  let connectorOptions = React.useMemo(() => {
    let seen: Dict.t<bool> = Dict.make()
    let opts = [("all", "All connectors")]
    allItems->Array.forEach(item => {
      let key = item.upload_type->String.toLowerCase
      if !(seen->Dict.get(key)->Option.isSome) {
        seen->Dict.set(key, true)
        opts
        ->Array.push((key, ReconEngineRevampedPipelinesUtils.getUploadTypeLabel(item.upload_type)))
        ->ignore
      }
    })
    opts
  }, [allItems])

  let isActive = (s: ReconEngineTypes.ingestionTransformationStatusType) =>
    s == ReconEngineTypes.Processed ||
    s == ReconEngineTypes.Processing ||
    s == ReconEngineTypes.Failed ||
    s == ReconEngineTypes.Pending

  let filtered = React.useMemo(() => {
    let base = allItems->Array.filter(item => {
      let matchesStatus = switch statusFilter {
      | "processed" => item.status == ReconEngineTypes.Processed
      | "processing" => item.status == ReconEngineTypes.Processing
      | "failed" => item.status == ReconEngineTypes.Failed
      | "pending" => item.status == ReconEngineTypes.Pending
      | _ => isActive(item.status)
      }
      let matchesAccount = accountFilter == "all" || item.account_id == accountFilter
      let matchesConnector =
        connectorFilter == "all" || item.upload_type->String.toLowerCase == connectorFilter
      let matchesSearch =
        !(searchText->isNonEmptyString) ||
        isContainingStringLowercase(item.ingestion_name, searchText) ||
        isContainingStringLowercase(item.file_name, searchText) ||
        isContainingStringLowercase(item.account_name, searchText)
      matchesStatus && matchesAccount && matchesConnector && matchesSearch
    })
    switch sortOrder {
    | "oldest" => base->Array.toSorted((a, b) => String.compare(a.created_at, b.created_at))
    | _ => base->Array.toSorted((a, b) => String.compare(b.created_at, a.created_at))
    }
  }, (allItems, statusFilter, accountFilter, connectorFilter, searchText, sortOrder))

  let nullableData = filtered->Array.map(Nullable.make)

  let statusOptions = [
    ("all", "All statuses"),
    ("processed", "Processed"),
    ("processing", "Processing"),
    ("failed", "Failed"),
    ("pending", "Pending"),
  ]

  let sortOptions = [("recent", "Most recent"), ("oldest", "Oldest first")]

  <div className="mt-6">
    <div className="flex items-center justify-between mb-3">
      <p className={`${body.md.semibold} text-nd_gray-800 uppercase tracking-wide`}>
        {`Ingestion Histories`->React.string}
      </p>
      <p className={`${body.sm.medium} text-nd_gray-400`}>
        {`${filtered->Array.length->Int.toString} runs`->React.string}
      </p>
    </div>
    <div className="flex flex-row items-center gap-3 flex-wrap mb-3">
      <div
        className="flex items-center gap-2 border border-nd_gray-200 rounded-lg px-3 py-2 w-56 bg-white">
        <Icon name="nd-search" size=13 className="text-nd_gray-400 flex-shrink-0" />
        <input
          className={`${body.sm.regular} w-full outline-none text-nd_gray-700 placeholder:text-nd_gray-400 bg-transparent`}
          placeholder="Search feed, file, id"
          value=searchText
          onChange={e => {
            let v = ReactEvent.Form.target(e)["value"]
            setSearchText(_ => v)
            setOffset(_ => 0)
          }}
        />
      </div>
      <FilterDropdown
        value=accountFilter
        options=accountOptions
        onChange={v => {
          setAccountFilter(_ => v)
          setOffset(_ => 0)
        }}
      />
      <FilterDropdown
        value=statusFilter
        options=statusOptions
        onChange={v => {
          setStatusFilter(_ => v)
          setOffset(_ => 0)
        }}
      />
      <FilterDropdown
        value=connectorFilter
        options=connectorOptions
        onChange={v => {
          setConnectorFilter(_ => v)
          setOffset(_ => 0)
        }}
      />
      <FilterDropdown value=sortOrder options=sortOptions onChange={v => setSortOrder(_ => v)} />
    </div>
    <div className="border border-nd_gray-200 rounded-xl overflow-hidden">
      <PageLoaderWrapper
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-64" message="No ingestion history found." />}
        customLoader={<Shimmer styleClass="h-64 w-full" />}>
        <LoadedTable
          title="Ingestion Histories"
          hideTitle=true
          actualData=nullableData
          entity={ReconEngineRevampedPipelinesUtils.pipelineTableEntity(~authorization=Access)}
          resultsPerPage=10
          totalResults={filtered->Array.length}
          offset
          setOffset
          currentFetchCount={filtered->Array.length}
          tableheadingClass="h-11"
          tableHeadingTextClass="!font-normal"
          nonFrozenTableParentClass="!rounded-none !border-0 !shadow-none"
          loadedTableParentClass="flex flex-col"
          enableEqualWidthCol=false
          showAutoScroll=true
        />
      </PageLoaderWrapper>
    </div>
  </div>
}
