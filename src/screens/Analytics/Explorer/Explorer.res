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
  let fetchMetrics = ExplorerHooks.useFetchExplorerMetrics()
  let fetchBackendDimensions = ExplorerHooks.useFetchBackendDimensions()
  let getSignal = AbortControllerHook.useAbortController()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (responses, setResponses) = React.useState(_ => emptyResponses)
  let (dimensionsByDomain, setDimensionsByDomain) = React.useState(_ => Dict.make())

  let infoDomain = sourceConfig(filterValueJson->sourceFromFilters).infoDomain
  let selection =
    filterValueJson->selectionFromFilters(
      ~backendDimensions=dimensionsByDomain->getOptionValFromDict(infoDomain),
    )
  let dataset = selection->ExplorerData.buildDataset(responses)

  let getBackendDimensions = async () => {
    try {
      let names = await fetchBackendDimensions(~infoDomain)
      setDimensionsByDomain(prev => {
        let dimensions = prev->Dict.copy
        dimensions->Dict.set(infoDomain, names)
        dimensions
      })
    } catch {
    | _ => ()
    }
  }

  let getExplorerData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let signal = getSignal()
      let source = selection.source
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
    if dimensionsByDomain->getOptionValFromDict(infoDomain)->Option.isNone {
      getBackendDimensions()->ignore
    }
    None
  }, [infoDomain])

  React.useEffect(() => {
    if selection->hasDates {
      getExplorerData()->ignore
    }
    None
  }, [selection->requestKey])

  let setSource = source =>
    if source != selection.source {
      [(#source, (source :> string))]->selectionUpdate->updateExistingKeys
    }

  <div className="flex flex-col gap-4">
    <SourceTabs selection onSource=setSource />
    <ExplorerQueryBar selection dataset onUpdate=updateExistingKeys />
    <RenderIf condition={selection->hasDates}>
      <PageLoaderWrapper
        screenState
        customLoader={<Shimmer styleClass="w-full h-80 rounded-xl" />}
        sectionHeight="h-80">
        <RenderIf condition={dataset.overall.total > 0.0}>
          <div className="flex flex-col gap-4">
            <ExplorerMetricCards selection dataset />
            <ExplorerViews selection dataset onUpdate=updateExistingKeys />
          </div>
        </RenderIf>
        <RenderIf condition={dataset.overall.total == 0.0}>
          <NoData height="h-32" message="No data for the selected dates. Try a wider date range." />
        </RenderIf>
      </PageLoaderWrapper>
    </RenderIf>
    <RenderIf condition={!(selection->hasDates)}>
      <NoData height="h-32" message="Select a date range to load the data." />
    </RenderIf>
  </div>
}
