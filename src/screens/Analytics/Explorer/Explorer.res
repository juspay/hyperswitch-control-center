open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerQuestion
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
  let question =
    filterValueJson->questionFromFilters(
      ~backendDimensions=dimensionsByDomain->Dict.get(infoDomain),
    )
  let dataset = question->ExplorerData.buildDataset(responses)

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
      let source = question.source
      let current = question->currentWindow
      let previous = question->previousWindow
      let fetchCounts = window =>
        fetchMetrics(~source, ~body=question->getCountRequestBody(~window), ~signal)
      let (currentRows, previousRows) = await Promise.all2((
        fetchCounts(current),
        fetchCounts(previous),
      ))
      setResponses(_ => {currentRows, previousRows})
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | AbortControllerHook.AbortError => ()
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch explorer data"))
    }
  }

  React.useEffect(() => {
    if dimensionsByDomain->Dict.get(infoDomain)->Option.isNone {
      getBackendDimensions()->ignore
    }
    None
  }, [infoDomain])

  React.useEffect(() => {
    if question->hasDates {
      getExplorerData()->ignore
    }
    None
  }, [question->requestKey])

  let setSource = source =>
    if source != question.source {
      [(#source, (source :> string)), (#split, "[]")]->selectionUpdate->updateExistingKeys
    }

  <div className="flex flex-col gap-4">
    <SourceTabs question onSource=setSource />
    <ExplorerQueryBar question dataset onUpdate=updateExistingKeys />
    <RenderIf condition={question->hasDates}>
      <PageLoaderWrapper
        screenState
        customLoader={<Shimmer styleClass="w-full h-80 rounded-xl" />}
        sectionHeight="h-80">
        <RenderIf condition={dataset.overall.total > 0.0}>
          <div className="flex flex-col gap-4">
            <ExplorerMetricCards question dataset />
            <ExplorerViews question dataset />
          </div>
        </RenderIf>
        <RenderIf condition={dataset.overall.total == 0.0}>
          <NoData height="h-32" message="No data for the selected dates. Try a wider date range." />
        </RenderIf>
      </PageLoaderWrapper>
    </RenderIf>
    <RenderIf condition={!(question->hasDates)}>
      <NoData height="h-32" message="Select a date range to load the data." />
    </RenderIf>
  </div>
}
