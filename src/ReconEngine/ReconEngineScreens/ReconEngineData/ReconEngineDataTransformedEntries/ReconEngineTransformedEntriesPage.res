open Typography
open ReconEngineTypes
open ReconEngineDataStatusUtils

module Shell = {
  @react.component
  let make = () => {
    open LogicUtils
    open ReconEngineFilterUtils

    let url = RescriptReactRouter.useUrl()
    let getAccounts = ReconEngineHooks.useGetAccounts()
    let getProcessingEntries = ReconEngineHooks.useGetProcessingEntries()

    let {filterValueJson, filterValue, updateExistingKeys, filterKeys} = React.useContext(
      FilterContext.filterContext,
    )

    let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
    let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

    let (accounts, setAccounts) = React.useState(_ => [])
    let (entries, setEntries) = React.useState(_ => [])
    let (smartView, setSmartView) = React.useState(_ => AllEntries)
    let (searchText, setSearchText) = React.useState(_ => "")
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let urlSearchDict = url.search->getDictFromUrlSearchParams
    let selectedEntryId = urlSearchDict->getOptionValFromDict("entry")
    let preFilterIngestionHistoryId = urlSearchDict->getOptionValFromDict("ingestion_history_id")

    let setSelectedEntry = (idOpt: option<string>) => {
      let basePath = GlobalVars.appendDashboardPath(~url="/v1/recon-engine/transformed-entries")
      let qs = switch preFilterIngestionHistoryId {
      | Some(h) => `ingestion_history_id=${h}`
      | None => ""
      }
      let entryQs = switch idOpt {
      | Some(id) => `entry=${id}`
      | None => ""
      }
      let combined = [qs, entryQs]->Array.filter(s => s !== "")->Array.joinWith("&")
      let nextUrl = combined === "" ? basePath : `${basePath}?${combined}`
      RescriptReactRouter.push(nextUrl)
    }

    let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
      ~updateExistingKeys,
      ~startTimeFilterKey,
      ~endTimeFilterKey,
      ~range=180,
      ~origin="recon_engine_accounts_transformed_entries",
      (),
    )

    let loadAccounts = async () => {
      try {
        let result = await getAccounts()
        setAccounts(_ => result)
      } catch {
      | _ => ()
      }
    }

    let fetchEntries = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        /* Build status from smart view + filter context. */
        let enhanced = Dict.copy(filterValueJson)
        let rawStatus = filterValueJson->getArrayFromDict("status", [])
        let statusArray = if rawStatus->Array.length === 0 {
          smartView
          ->entriesSmartViewStatuses
          ->Array.map(entryStatusToWire)
          ->Array.map(JSON.Encode.string)
        } else {
          rawStatus
        }
        enhanced->Dict.set("status", JSON.Encode.array(statusArray))
        switch preFilterIngestionHistoryId {
        | Some(h) => enhanced->Dict.set("ingestion_history_id", JSON.Encode.string(h))
        | None => ()
        }
        let query = buildQueryStringFromFilters(~filterValueJson=enhanced)
        let result = await getProcessingEntries(~queryParameters=Some(query))
        setEntries(_ => result)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load entries"))
      }
    }

    React.useEffect0(() => {
      setInitialFilters()
      loadAccounts()->ignore
      None
    })

    React.useEffect(() => {
      if !(filterValue->isEmptyDict) {
        fetchEntries()->ignore
      }
      None
    }, (filterValue, smartView))

    let visibleEntries = React.useMemo(() => {
      entries->Array.filter(e => {
        let matchesSearch =
          searchText->isEmptyString ||
          isContainingStringLowercase(e.staging_entry_id, searchText) ||
          isContainingStringLowercase(e.order_id, searchText) ||
          isContainingStringLowercase(e.account.account_name, searchText)
        matchesSearch
      })
    }, (entries, searchText))

    let activeEntry = React.useMemo(() => {
      switch selectedEntryId {
      | Some(id) => entries->Array.find(e => e.id === id)
      | None => None
      }
    }, (selectedEntryId, entries))

    /* Smart-view counts: count from current dataset; needs-review counts even when not in view. */
    let counts = React.useMemo(() => {
      allEntriesSmartViews->Array.map(v => {
        let statuses = v->entriesSmartViewStatuses
        let c = entries->Array.filter(e => statuses->Array.includes(e.status))->Array.length
        (v, c)
      })
    }, [entries])

    let visibleCount = visibleEntries->Array.length
    let totalCount = entries->Array.length

    let header =
      <div
        className="flex flex-row justify-between items-center px-6 pt-5 pb-4 bg-white flex-shrink-0">
        <div className="flex flex-row items-baseline gap-2.5">
          <p className={`${heading.lg.semibold} text-nd_gray-800 tracking-tight`}>
            {"Transformed entries"->React.string}
          </p>
          <span className={`${body.md.medium} text-nd_gray-500 tabular-nums`}>
            {`· ${visibleCount->Int.toString} of ${totalCount->Int.toString}`->React.string}
          </span>
        </div>
        <RenderIf condition={preFilterIngestionHistoryId->Option.isSome}>
          <div className="flex flex-row items-center gap-2">
            <span
              className={`${body.xs.semibold} text-nd_primary_blue-600 bg-nd_primary_blue-50 border border-nd_primary_blue-100 px-2.5 py-1 rounded-md uppercase tracking-wider`}>
              {"Filtered by source file"->React.string}
            </span>
            <button
              type_="button"
              onClick={_ =>
                RescriptReactRouter.push(
                  GlobalVars.appendDashboardPath(~url="/v1/recon-engine/transformed-entries"),
                )}
              className={`${body.xs.semibold} text-nd_gray-500 hover:text-nd_gray-700 uppercase tracking-wider`}>
              {"Clear"->React.string}
            </button>
          </div>
        </RenderIf>
      </div>

    <div className="absolute left-0 min-w-full flex flex-col h-[calc(100vh-4rem)] bg-white">
      {header}
      <ReconEngineTransformedEntriesKpiStrip entries />
      <ReconEngineTransformedEntriesSmartViewsRail
        activeView={smartView} onChange={v => setSmartView(_ => v)} counts
      />
      <div className="flex flex-row flex-1 min-h-0">
        <ReconEngineTransformedEntriesListPane
          screenState
          entries={visibleEntries}
          accounts
          activeId={activeEntry->Option.map(e => e.id)}
          onSelect={e => setSelectedEntry(Some(e.id))}
          searchText
          setSearchText
          filterKeys
          updateExistingKeys
        />
        <ReconEngineTransformedEntriesDetailPane
          activeEntry onClose={() => setSelectedEntry(None)}
        />
      </div>
    </div>
  }
}

@react.component
let make = () => {
  <FilterContext key="recon-engine-transformed-entries" index="recon-engine-transformed-entries">
    <Shell />
  </FilterContext>
}
