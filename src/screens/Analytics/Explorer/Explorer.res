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
  let {filterValueJson, updateExistingKeys, removeKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
  let fetchMetrics = ExplorerHooks.useFetchExplorerMetrics()
  let fetchBackendDimensions = ExplorerHooks.useFetchBackendDimensions()
  let getSignal = AbortControllerHook.useAbortController()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (responses, setResponses) = React.useState(_ => emptyResponses)
  let (dimensionsByDomain, setDimensionsByDomain) = React.useState(_ => Dict.make())
  let (editing, setEditing) = React.useState(_ => None)

  let infoDomain = sourceConfig(filterValueJson->sourceFromFilters).infoDomain
  let question =
    filterValueJson->questionFromFilters(
      ~backendDimensions=infoDomain->Option.flatMap(domain => dimensionsByDomain->Dict.get(domain)),
    )
  let dataset = question->ExplorerData.buildDataset(responses)
  let isSplit = question.split->isNonEmptyArray
  let hasData =
    question->hasDates && screenState == PageLoaderWrapper.Success && dataset.overall.total > 0.0

  let getBackendDimensions = async () => {
    try {
      switch infoDomain {
      | Some(infoDomain) =>
        let names = await fetchBackendDimensions(~infoDomain)
        setDimensionsByDomain(prev => {
          let dimensions = prev->Dict.copy
          dimensions->Dict.set(infoDomain, names)
          dimensions
        })
      | None => ()
      }
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
      let fetchRows = async body =>
        switch body {
        | Some(body) => await fetchMetrics(~source, ~body, ~signal)
        | None => []
        }
      let fetchCounts = (~window, ~daily=false) =>
        fetchRows(Some(question->getCountRequestBody(~window, ~daily)))
      let fetchRate = (~window, ~groupBy=question.split, ~daily=false) =>
        fetchRows(question->getRateRequestBody(~window, ~groupBy, ~daily))
      let (
        (currentRows, previousRows, currentDaily, previousDaily),
        (
          rateCurrent,
          ratePrevious,
          rateCurrentDaily,
          ratePreviousDaily,
          rateOverallCurrent,
          rateOverallPrevious,
        ),
      ) = await Promise.all2((
        Promise.all4((
          fetchCounts(~window=current),
          fetchCounts(~window=previous),
          fetchCounts(~window=current, ~daily=true),
          isSplit ? fetchRows(None) : fetchCounts(~window=previous, ~daily=true),
        )),
        Promise.all6((
          fetchRate(~window=current),
          fetchRate(~window=previous),
          fetchRate(~window=current, ~daily=true),
          isSplit ? fetchRows(None) : fetchRate(~window=previous, ~daily=true),
          isSplit ? fetchRate(~window=current, ~groupBy=[]) : fetchRows(None),
          isSplit ? fetchRate(~window=previous, ~groupBy=[]) : fetchRows(None),
        )),
      ))
      setResponses(_ => {
        currentRows,
        previousRows,
        currentDaily,
        previousDaily,
        rateCurrent,
        ratePrevious,
        rateCurrentDaily,
        ratePreviousDaily,
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
  }, [infoDomain->Option.getOr("")])

  React.useEffect(() => {
    if question->hasDates {
      getExplorerData()->ignore
    }
    None
  }, [question->requestKey])

  let setSelection = updates => updates->selectionUpdate->updateExistingKeys
  let clearFilters = () =>
    question.filters->Array.map(((key, _)) => getFilterUrlKey(key))->removeKeys
  let setSource = source =>
    if source != question.source {
      clearFilters()
      setEditing(_ => None)
      setSelection([
        ("source", source->sourceToString),
        ("split", "[]"),
        ("flow", (AllFlows :> string)),
        ("from", ""),
      ])
    }
  let applyPreset = preset => {
    clearFilters()
    setEditing(_ => None)
    preset->presetUpdate->updateExistingKeys
  }

  let labelFor = (key, value) => getDimensionValueLabel(key, value, ~profileList)
  let (previousStart, previousEnd) = question->previousWindow
  let viewContext = {
    question,
    dataset,
    hasPrevious: dataset.overallPrevious.total > 0.0,
    currentLabel: periodLabel(question.startTime, question.endTime),
    previousLabel: periodLabel(previousStart, previousEnd),
    singleCurrency: question->needsCurrency
      ? dataset.amountCurrency
      : question->getSelectedFilterValues(#currency)->getValueFromArray(0, ""),
    chartKey: [
      question->requestKey,
      question.measure->measureToString,
      (question.flow :> string),
      dataset.amountCurrency,
    ]->Array.joinWith("|"),
    labelFor,
    groupLabel: group => group.values->getValuesLabel(~split=question.split, ~labelFor),
    onFocus: group => question->getFocusUpdate(group)->updateExistingKeys,
  }
  let drilledFrom =
    question.source
    ->getSourceDimensions
    ->findDimension(filterValueJson->getString(urlKey("from"), ""))
  let suggestions = question->getSplitSuggestions(~drilledFrom)

  <div className="flex flex-col gap-4">
    <div className="flex flex-wrap items-end justify-between gap-3">
      <DomainTabs question onSource=setSource />
      <PresetPicker question onPreset=applyPreset />
    </div>
    <SourceTabs question onSource=setSource />
    <ExplorerQueryBar
      viewContext
      onUpdate=updateExistingKeys
      onClearFilters=clearFilters
      editing
      setEditing={key => setEditing(_ => key)}>
      <RenderIf condition=hasData>
        <div className="border-t border-nd_br_gray-150 pt-4">
          <ExplorerSummary viewContext />
        </div>
      </RenderIf>
    </ExplorerQueryBar>
    {if question->hasDates {
      <PageLoaderWrapper
        screenState
        customLoader={<Shimmer styleClass="w-full h-80 rounded-xl" />}
        sectionHeight="h-80">
        {dataset.overall.total == 0.0
          ? <NoData
              height="h-32"
              message="No data for this selection. Widen the dates or remove a filter."
            />
          : <div className="flex flex-col gap-4">
              <ExplorerMetricCards viewContext />
              <ExplorerCard>
                <div
                  className="flex flex-wrap items-center justify-between gap-3 border-b border-nd_br_gray-150 px-5 py-3">
                  <div className="flex flex-col">
                    <div className={`${body.lg.semibold} text-nd_gray-800`}>
                      {question->ExplorerDescriptions.viewTitle->React.string}
                    </div>
                    <div className={`${body.sm.regular} text-nd_gray-500`}>
                      {`${viewContext.currentLabel} · ${question->ExplorerDescriptions.viewNote}`->React.string}
                    </div>
                  </div>
                  <ViewTabs
                    view=question.view onViewChange={view => setSelection([("view", view)])}
                  />
                </div>
                <div className="px-3 py-4">
                  <ExplorerViews viewContext />
                </div>
                <RenderIf condition={isSplit && dataset.unmeasured->isNonEmptyArray}>
                  <UnmeasuredNote viewContext />
                </RenderIf>
                <RenderIf condition={suggestions->isNonEmptyArray}>
                  <SplitSuggestions
                    suggestions
                    onSelect={key =>
                      setSelection([
                        (
                          "split",
                          question
                          ->splitAt(Math.Int.min(question.split->Array.length, 1), Some(key))
                          ->splitValue,
                        ),
                      ])}
                  />
                </RenderIf>
              </ExplorerCard>
            </div>}
      </PageLoaderWrapper>
    } else {
      <NoData height="h-32" message="Select a date range to load the data." />
    }}
  </div>
}
