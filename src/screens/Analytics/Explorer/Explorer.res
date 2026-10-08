open ExplorerTypes
open ExplorerUtils
open ExplorerQuery
open ExplorerHelper
open NewAnalyticsHelper

@react.component
let make = () => {
  let {filterValueJson, updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let question = filterValueJson->questionFromFilters
  let fetchMetrics = ExplorerHooks.useFetchExplorerMetrics()
  let getSignal = AbortControllerHook.useAbortController()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (responses, setResponses) = React.useState(_ => emptyResponses)
  let dataset = question->ExplorerData.buildDataset(responses)

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
    if question->hasDates {
      getExplorerData()->ignore
    }
    None
  }, [question->requestKey])

  let setSource = source =>
    if source != question.source {
      [(#source, (source :> string))]->selectionUpdate->updateExistingKeys
    }

  <div className="flex flex-col gap-4">
    <SourceTabs question onSource=setSource />
    <ExplorerQueryBar question dataset onUpdate=updateExistingKeys />
    {if question->hasDates {
      <PageLoaderWrapper
        screenState
        customLoader={<Shimmer styleClass="w-full h-32 rounded-xl" />}
        sectionHeight="h-32">
        {dataset.overall.total == 0.0
          ? <NoData
              height="h-32" message="No data for the selected dates. Try a wider date range."
            />
          : <ExplorerMetricCards question dataset />}
      </PageLoaderWrapper>
    } else {
      <NoData height="h-32" message="Select a date range to load the data." />
    }}
  </div>
}
