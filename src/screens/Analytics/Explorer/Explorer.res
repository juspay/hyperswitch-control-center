open Typography
open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerQuery
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

  let infoDomain = sourceConfig(filterValueJson->sourceFromFilters).infoDomain
  let question =
    filterValueJson->questionFromFilters(
      ~backendDimensions=dimensionsByDomain->Dict.get(infoDomain),
    )
  let dataset = question->ExplorerData.buildDataset(responses)
  let isSplit = question.split->isNonEmptyArray

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
      let current = (question.startTime, question.endTime)
      let previous = question->previousWindow
      let fetchCounts = window =>
        fetchMetrics(~source, ~body=question->getCountRequestBody(~window), ~signal)
      let fetchRate = async (window, ~groupBy) =>
        switch question->getRateRequestBody(~window, ~groupBy) {
        | Some(body) => await fetchMetrics(~source, ~body, ~signal)
        | None => []
        }
      let fetchOverallRate = async window => isSplit ? await fetchRate(window, ~groupBy=[]) : []
      let (
        currentRows,
        previousRows,
        rateCurrent,
        ratePrevious,
        rateOverallCurrent,
        rateOverallPrevious,
      ) = await Promise.all6((
        fetchCounts(current),
        fetchCounts(previous),
        fetchRate(current, ~groupBy=question.split),
        fetchRate(previous, ~groupBy=question.split),
        fetchOverallRate(current),
        fetchOverallRate(previous),
      ))
      setResponses(_ => {
        currentRows,
        previousRows,
        rateCurrent,
        ratePrevious,
        rateOverallCurrent,
        rateOverallPrevious,
      })
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | AbortControllerHook.AbortError => ()
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch explorer data"))
    }
  }

  React.useEffect(() => {
    getBackendDimensions()->ignore
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
      [("source", source->sourceToString), ("split", "[]")]->selectionUpdate->updateExistingKeys
    }

  let viewContext = {
    question,
    dataset,
    hasPrevious: dataset.overallPrevious.total > 0.0,
    labelFor: (key, value) => getDimensionValueLabel(key, value, ~profileList),
  }
  let currentLabel = periodLabel(question.startTime, question.endTime)

  <div className="flex flex-col gap-4">
    <SourceTabs question onSource=setSource />
    <ExplorerQueryBar viewContext onUpdate=updateExistingKeys />
    {if question->hasDates {
      <PageLoaderWrapper
        screenState
        customLoader={<Shimmer styleClass="w-full h-80 rounded-xl" />}
        sectionHeight="h-80">
        {dataset.overall.total == 0.0
          ? <NoData
              height="h-32" message="No data for the selected dates. Try a wider date range."
            />
          : <div className="flex flex-col gap-4">
              <ExplorerMetricCards viewContext />
              <ExplorerCard>
                <div className="flex flex-col border-b border-nd_br_gray-150 px-5 py-3">
                  <div className={`${body.lg.semibold} text-nd_gray-800`}>
                    {question->ExplorerDescriptions.viewTitle->React.string}
                  </div>
                  <div className={`${body.sm.regular} text-nd_gray-500`}>
                    {`${currentLabel} · ${question->ExplorerDescriptions.viewNote}`->React.string}
                  </div>
                </div>
                <div className="px-3 py-4">
                  <ExplorerViews viewContext />
                </div>
                <RenderIf condition={isSplit && dataset.unmeasured->isNonEmptyArray}>
                  <UnmeasuredNote viewContext />
                </RenderIf>
              </ExplorerCard>
            </div>}
      </PageLoaderWrapper>
    } else {
      <NoData height="h-32" message="Select a date range to load the data." />
    }}
  </div>
}
