open Typography
open ReconEngineTypes
open ReconEngineDataStatusUtils

let accountNameOrEmpty = (accounts: array<accountType>, accountId: string): string =>
  accounts
  ->Array.find(a => a.account_id === accountId)
  ->Option.map(a => a.account_name)
  ->Option.getOr("")

module Shell = {
  @react.component
  let make = () => {
    open LogicUtils
    open ReconEngineFilterUtils

    let url = RescriptReactRouter.useUrl()
    let getAccounts = ReconEngineHooks.useGetAccounts()
    let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()

    let {filterValueJson, filterValue, updateExistingKeys, filterKeys} = React.useContext(
      FilterContext.filterContext,
    )

    let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
    let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

    let (accounts, setAccounts) = React.useState(_ => [])
    let (items, setItems) = React.useState(_ => [])
    let (smartView, setSmartView) = React.useState(_ => AllFiles)
    let (searchText, setSearchText) = React.useState(_ => "")
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let urlSearchDict = url.search->getDictFromUrlSearchParams
    let selectedFileId = urlSearchDict->getOptionValFromDict("file")

    let setSelectedFile = (idOpt: option<string>) => {
      let basePath = GlobalVars.appendDashboardPath(~url="/v1/recon-engine/sources")
      let nextUrl = switch idOpt {
      | Some(id) => `${basePath}?file=${id}`
      | None => basePath
      }
      RescriptReactRouter.push(nextUrl)
    }

    let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
      ~updateExistingKeys,
      ~startTimeFilterKey,
      ~endTimeFilterKey,
      ~range=180,
      ~origin="recon_engine_sources",
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

    let fetchItems = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        /* Build status filter — if user hasn't picked any, leave the backend default. */
        let query = buildQueryStringFromFilters(~filterValueJson)
        let res = await getIngestionHistory(~queryParameters=Some(query))
        /* Keep one row per file — the latest non-discarded version. */
        let latestOnly =
          res
          ->dedupeToLatest
          ->Array.toSorted((a, b) => compareLogic(b.created_at, a.created_at))
        setItems(_ => latestOnly)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load files"))
      }
    }

    React.useEffect0(() => {
      setInitialFilters()
      loadAccounts()->ignore
      None
    })

    React.useEffect(() => {
      if !(filterValue->isEmptyDict) {
        fetchItems()->ignore
      }
      None
    }, [filterValue])

    /* Apply client-side smart-view + search filters. */
    let visibleItems = React.useMemo(() => {
      items->Array.filter(it => {
        let matchesSearch =
          searchText->isEmptyString ||
          isContainingStringLowercase(it.file_name, searchText) ||
          isContainingStringLowercase(it.ingestion_name, searchText) ||
          isContainingStringLowercase(accountNameOrEmpty(accounts, it.account_id), searchText)
        let matchesView = sourcesSmartViewMatches(smartView, it)
        matchesSearch && matchesView
      })
    }, (items, searchText, smartView, accounts))

    let activeIngestion = React.useMemo(() => {
      switch selectedFileId {
      | Some(id) => items->Array.find(i => i.ingestion_history_id === id)
      | None => None
      }
    }, (selectedFileId, items))

    /* Pre-compute counts for each smart-view tab. */
    let counts = React.useMemo(() => {
      allSourcesSmartViews->Array.map(v => (
        v,
        items->Array.filter(it => sourcesSmartViewMatches(v, it))->Array.length,
      ))
    }, [items])

    let visibleCount = visibleItems->Array.length
    let totalCount = items->Array.length

    let header =
      <div
        className="flex flex-row justify-between items-center px-6 pt-5 pb-4 bg-white flex-shrink-0">
        <div className="flex flex-row items-baseline gap-2.5">
          <p className={`${heading.lg.semibold} text-nd_gray-800 tracking-tight`}>
            {"Data sources"->React.string}
          </p>
          <span className={`${body.md.medium} text-nd_gray-500 tabular-nums`}>
            {`· ${visibleCount->Int.toString} of ${totalCount->Int.toString} files`->React.string}
          </span>
        </div>
        <div className="flex flex-row gap-2 items-center">
          <Button
            text="Manage sources"
            buttonType=Secondary
            buttonSize=Small
            leftIcon={CustomIcon(<Icon name="nd-settings" size=14 />)}
            onClick={_ =>
              RescriptReactRouter.push(
                GlobalVars.appendDashboardPath(~url="/v1/recon-engine/sources/manage"),
              )}
          />
        </div>
      </div>

    <div className="absolute left-0 min-w-full flex flex-col h-[calc(100vh-4rem)] bg-white">
      {header}
      <ReconEngineSourcesSmartViewsRail
        activeView={smartView} onChange={v => setSmartView(_ => v)} counts
      />
      <div className="flex flex-row flex-1 min-h-0">
        <ReconEngineSourcesListPane
          screenState
          items={visibleItems}
          accounts
          activeId={activeIngestion->Option.map(i => i.ingestion_history_id)}
          onSelect={ing => setSelectedFile(Some(ing.ingestion_history_id))}
          searchText
          setSearchText
          filterKeys
          updateExistingKeys
        />
        <ReconEngineSourcesDetailPane
          accounts activeIngestion onClose={() => setSelectedFile(None)}
        />
      </div>
    </div>
  }
}

@react.component
let make = () => {
  <FilterContext key="recon-engine-sources" index="recon-engine-sources">
    <Shell />
  </FilterContext>
}
