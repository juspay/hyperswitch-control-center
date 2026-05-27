open Typography
open ReconEngineTypes
open ReconEngineTransformedEntryExceptionsStatusUtils

module Shell = {
  @react.component
  let make = () => {
    open LogicUtils
    open ReconEngineFilterUtils
    open ReconEngineHooks

    let url = RescriptReactRouter.useUrl()
    let getProcessingEntries = useGetProcessingEntries()

    let {filterValueJson, filterValue, updateExistingKeys, filterKeys} = React.useContext(
      FilterContext.filterContext,
    )

    let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
    let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

    let (entries, setEntries) = React.useState(_ => [])
    let (smartView, setSmartView) = React.useState(_ => NeedsReview)
    let (selectedRows, setSelectedRows) = React.useState(_ => [])
    let (searchText, setSearchText) = React.useState(_ => "")
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let urlSearchDict = url.search->getDictFromUrlSearchParams
    let selectedEntryId = urlSearchDict->getOptionValFromDict("id")

    let setSelectedEntry = (idOpt: option<string>) => {
      let basePath = GlobalVars.appendDashboardPath(
        ~url="/v1/recon-engine/exceptions/transformed-entries",
      )
      let nextUrl = switch idOpt {
      | Some(id) => `${basePath}?id=${id}`
      | None => basePath
      }
      RescriptReactRouter.push(nextUrl)
    }

    let onSmartViewChange = (view: smartView) => {
      setSmartView(_ => view)
      let statusCsv =
        view
        ->smartViewStatuses
        ->Array.map(entryStatusToWire)
        ->Array.joinWith(",")
      updateExistingKeys(Dict.fromArray([("status", `[${statusCsv}]`)]))
    }

    let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
      ~updateExistingKeys,
      ~startTimeFilterKey,
      ~endTimeFilterKey,
      ~range=180,
      ~origin="recon_engine_transformed_entries_exceptions",
      (),
    )

    let fetchEntries = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let enhanced = Dict.copy(filterValueJson)
        let rawStatus = filterValueJson->getArrayFromDict("status", [])
        let effectiveStatus = if rawStatus->Array.length === 0 {
          smartView
          ->smartViewStatuses
          ->Array.map(entryStatusToWire)
          ->getJsonFromArrayOfString
        } else {
          rawStatus
          ->Array.map(v => v->getStringFromJson(""))
          ->getJsonFromArrayOfString
        }
        enhanced->Dict.set("status", effectiveStatus)

        /* account_id and entry_type are filtered client-side. */
        enhanced->Dict.set("account_id", JSON.Encode.array([]))
        enhanced->Dict.set("entry_type", JSON.Encode.array([]))

        let query = buildQueryStringFromFilters(~filterValueJson=enhanced)
        let result = await getProcessingEntries(~queryParameters=Some(query))
        setEntries(_ => result)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load exceptions"))
      }
    }

    React.useEffect0(() => {
      setInitialFilters()
      None
    })

    React.useEffect(() => {
      if !(filterValue->isEmptyDict) {
        fetchEntries()->ignore
      }
      None
    }, (filterValue, smartView))

    let accountOptions = React.useMemo(() => {
      getAccountOptionsFromStagingEntries(entries)
    }, [entries])

    let visibleEntries = React.useMemo(() => {
      let accountFilter =
        filterValueJson
        ->getArrayFromDict("account_id", [])
        ->Array.map(j => j->getStringFromJson(""))
      let entryTypeFilter =
        filterValueJson
        ->getArrayFromDict("entry_type", [])
        ->Array.map(j => j->getStringFromJson(""))

      entries->Array.filter(e => {
        let matchesSearch =
          searchText->isEmptyString ||
          isContainingStringLowercase(e.staging_entry_id, searchText) ||
          isContainingStringLowercase(e.order_id, searchText)
        let matchesAccount =
          accountFilter->Array.length === 0 || accountFilter->Array.includes(e.account.account_id)
        let matchesType =
          entryTypeFilter->Array.length === 0 ||
            entryTypeFilter->Array.includes(e.entry_type->String.toLowerCase)
        matchesSearch && matchesAccount && matchesType
      })
    }, (entries, searchText, filterValueJson))

    let activeEntry = React.useMemo(() => {
      switch selectedEntryId {
      | Some(id) => entries->Array.find(e => e.staging_entry_id === id)
      | None => visibleEntries->Array.get(0)
      }
    }, (selectedEntryId, entries, visibleEntries))

    let viewCounts = React.useMemo(() => {
      entries->countByView
    }, [entries])

    let visibleCount = visibleEntries->Array.length
    let totalCount = entries->Array.length

    let header =
      <div
        className="flex flex-row justify-between items-center px-6 pt-5 pb-4 bg-white flex-shrink-0">
        <div className="flex flex-row items-baseline gap-2.5">
          <p className={`${heading.lg.semibold} text-nd_gray-800 tracking-tight`}>
            {"Transformed Entry Exceptions"->React.string}
          </p>
          <span className={`${body.md.medium} text-nd_gray-500 tabular-nums`}>
            {`· ${visibleCount->Int.toString} of ${totalCount->Int.toString}`->React.string}
          </span>
        </div>
      </div>

    <div className="absolute left-0 min-w-full flex flex-col h-[calc(100vh-4rem)] bg-white">
      {header}
      <ReconEngineTransformedEntryExceptionsSmartViewsRail
        activeView={smartView} onChange={onSmartViewChange} counts={viewCounts}
      />
      <div className="flex flex-row flex-1 min-h-0">
        <ReconEngineTransformedEntryExceptionsListPane
          screenState
          entries={visibleEntries}
          accountOptions
          activeEntryId={activeEntry->Option.map(e => e.staging_entry_id)}
          onSelect={entry => setSelectedEntry(Some(entry.staging_entry_id))}
          selectedRows
          setSelectedRows
          searchText
          setSearchText
          filterKeys
          updateExistingKeys
        />
        <ReconEngineTransformedEntryExceptionsDetailPane
          activeEntry onClearSelection={_ => setSelectedEntry(None)}
        />
      </div>
      <RenderIf condition={selectedRows->Array.length > 0}>
        <ReconEngineTransformedEntryBulkActions
          selectedRows setSelectedRows refreshList={() => fetchEntries()->ignore}
        />
      </RenderIf>
    </div>
  }
}

@react.component
let make = () => <Shell />
