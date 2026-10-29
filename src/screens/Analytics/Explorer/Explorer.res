open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerSelection
open ExplorerHelper
open NewAnalyticsHelper

@react.component
let make = () => {
  let {filterValueJson, updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
  let fetchMetrics = ExplorerHooks.useFetchExplorerMetrics()
  let fetchBackendDimensions = ExplorerHooks.useFetchBackendDimensions()
  let getSignal = AbortControllerHook.useAbortController()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (responses, setResponses) = React.useState(_ => emptyResponses)
  let (dimensionsByDomain, setDimensionsByDomain) = React.useState(_ => Dict.make())
  let (editing, setEditing) = React.useState(_ => None)

  let source = filterValueJson->sourceFromFilters
  let infoDomain = sourceConfig(source).infoDomain
  let selection =
    filterValueJson->selectionFromFilters(
      ~backendDimensions=dimensionsByDomain->getOptionValFromDict(infoDomain),
    )
  let dimensionsReady = dimensionsByDomain->getOptionValFromDict(infoDomain)->Option.isSome
  let dataset = selection->ExplorerData.buildDataset(responses)
  let hasData =
    selection->hasDates && screenState == PageLoaderWrapper.Success && dataset.overall.total > 0.0

  let setDimensions = names =>
    setDimensionsByDomain(prev => {
      let dimensions = prev->Dict.copy
      dimensions->Dict.set(infoDomain, names)
      dimensions
    })

  let getBackendDimensions = async () => {
    try {
      let names = await fetchBackendDimensions(~infoDomain)
      setDimensions(names)
    } catch {
    | _ => setDimensions(sourceConfig(source).dimensions->Array.map(key => (key :> string)))
    }
  }

  let getExplorerData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let signal = getSignal()
      let current = selection->currentWindow
      let previous = selection->previousWindow
      let fetchCounts = (~daily=false, window) =>
        fetchMetrics(~source, ~body=selection->getCountRequestBody(~window, ~daily), ~signal)
      let (currentRows, previousRows, currentDaily, previousDaily) = await Promise.all4((
        fetchCounts(current),
        fetchCounts(previous),
        fetchCounts(~daily=true, current),
        selection.split->isNonEmptyArray ? Promise.resolve([]) : fetchCounts(~daily=true, previous),
      ))
      setResponses(_ => {currentRows, previousRows, currentDaily, previousDaily})
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | AbortControllerHook.AbortError => ()
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch explorer data"))
    }
  }

  React.useEffect(() => {
    if !dimensionsReady {
      getBackendDimensions()->ignore
    }
    None
  }, [infoDomain])

  React.useEffect(() => {
    if !dimensionsReady {
      setScreenState(_ => PageLoaderWrapper.Loading)
    } else if selection->hasDates {
      getExplorerData()->ignore
    }
    None
  }, (selection->requestKey, dimensionsReady))

  let labelFor = (key, value) => getDimensionValueLabel(key, value, ~profileList)
  let setSource = source =>
    if source != selection.source {
      setEditing(_ => None)
      [
        selection->getClearFiltersUpdate,
        [(#source, (source :> string)), (#split, "[]")]->selectionUpdate,
      ]
      ->DictionaryUtils.mergeDicts
      ->updateExistingKeys
    }

  <div className="flex flex-col gap-4">
    <DomainTabs selection onSource=setSource />
    <SourceTabs selection onSource=setSource />
    <ExplorerQueryBar
      selection
      dataset
      labelFor
      onUpdate=updateExistingKeys
      editing
      setEditing={key => setEditing(_ => key)}>
      <RenderIf condition=hasData>
        <div className="border-t border-nd_br_gray-150 pt-4">
          <ExplorerSummary selection dataset labelFor />
        </div>
      </RenderIf>
    </ExplorerQueryBar>
    <RenderIf condition={selection->hasDates}>
      <PageLoaderWrapper
        screenState
        customLoader={<Shimmer styleClass="w-full h-80 rounded-xl" />}
        sectionHeight="h-80">
        <RenderIf condition={dataset.overall.total > 0.0}>
          <div className="flex flex-col gap-4">
            <ExplorerMetricCards selection dataset />
            <ExplorerViews selection dataset labelFor onUpdate=updateExistingKeys />
          </div>
        </RenderIf>
        <RenderIf condition={dataset.overall.total == 0.0}>
          <NoData
            height="h-32" message="No data for this selection. Widen the dates or remove a filter."
          />
        </RenderIf>
      </PageLoaderWrapper>
    </RenderIf>
    <RenderIf condition={!(selection->hasDates)}>
      <NoData height="h-32" message="Select a date range to load the data." />
    </RenderIf>
  </div>
}
