open Typography

@react.component
let make = (~onRuleClick: string => unit) => {
  open LogicUtils
  open ReconEngineOverviewSummaryUtils
  open ReconEngineOverviewSummaryHelper

  let getOverviewRules = ReconEngineHooks.useGetOverviewRules()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (rules, setRules) = React.useState(_ => [])

  let fetchRulesActivity = async () => {
    open ReconEngineFilterUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = buildQueryStringFromFilters(~filterValueJson)
      let overviewRules = await getOverviewRules(~queryParameters=Some(queryParams))
      setRules(_ => overviewRules)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchRulesActivity()->ignore
    }
    None
  }, [filterValue])

  let computedRules = React.useMemo(() => {
    getRuleActivityItems(~overviewRules=rules)
  }, [rules])

  <div className="border border-nd_gray-200 rounded-xl bg-white h-full">
    <div className="flex flex-col gap-1 px-5 py-3.5 border-b border-nd_gray-200 shadow-sm">
      <p className={`${body.md.semibold} text-nd_gray-800`}>
        {"Top rules by activity"->React.string}
      </p>
      <p className={`${body.sm.regular} text-nd_gray-600`}>
        {"Sorted by exception count"->React.string}
      </p>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData
        height="h-48" message="No rules data for this date range."
      />}
      customLoader={<Shimmer styleClass="w-full h-48" />}>
      <div>
        <div
          className="grid grid-cols-[48px_1fr_140px_140px_220px] pt-3.5 pb-2.5 border-b border-nd_gray-200">
          <div className="pl-6" />
          <div className={`${body.xs.medium} text-nd_gray-400 uppercase tracking-wide`}>
            {"Rule"->React.string}
          </div>
          <div
            className={`${body.xs.medium} text-nd_gray-400 uppercase tracking-wide text-right pr-6`}>
            {"Volume"->React.string}
          </div>
          <div
            className={`${body.xs.medium} text-nd_gray-400 uppercase tracking-wide text-right pr-6`}>
            {"Exceptions"->React.string}
          </div>
          <div className={`${body.xs.medium} text-nd_gray-400 uppercase tracking-wide pl-4 pr-6`}>
            {"Match Rate"->React.string}
          </div>
        </div>
        <div className="max-h-80 overflow-y-auto pb-4">
          <RenderIf condition={computedRules->isNonEmptyArray}>
            {computedRules
            ->Array.mapWithIndex((item, index) =>
              <RuleActivityRow item index onClick={() => onRuleClick(item.overview_rule.rule_id)} />
            )
            ->React.array}
          </RenderIf>
          <RenderIf condition={computedRules->isEmptyArray}>
            <NewAnalyticsHelper.NoData height="h-32" message="No rules found." />
          </RenderIf>
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
