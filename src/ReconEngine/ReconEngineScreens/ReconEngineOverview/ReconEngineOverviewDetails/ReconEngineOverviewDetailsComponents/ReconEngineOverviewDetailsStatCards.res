open ReconEngineOverviewSummaryHelper
open ReconEngineOverviewSummaryUtils

@react.component
let make = (~ruleDetails: ReconEngineRulesTypes.rulePayload) => {
  open LogicUtils
  open ReconEngineUtils

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (overviewRule, setOverviewRule) = React.useState(_ =>
    Dict.make()->overviewRulesResponseMapper
  )
  let getOverviewRules = ReconEngineHooks.useGetOverviewRules()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)

  let getOverviewRulesData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let baseQueryString = ReconEngineFilterUtils.buildQueryStringFromFilters(~filterValueJson)
      let queryString =
        baseQueryString->isNonEmptyString
          ? `${baseQueryString}&rule_ids=${ruleDetails.rule_id}`
          : `rule_ids=${ruleDetails.rule_id}`
      let overviewRules = await getOverviewRules(~queryParameters=Some(queryString))
      let currentOverviewRule =
        overviewRules->getValueFromArray(0, Dict.make()->overviewRulesResponseMapper)
      setOverviewRule(_ => currentOverviewRule)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      getOverviewRulesData()->ignore
    }
    None
  }, [filterValue])

  let statCards = React.useMemo(() => {
    getDetailsConnectedStatCards(~overviewRule)
  }, [overviewRule])

  <div
    className="grid xl:grid-cols-5 lg:grid-cols-4 sm:grid-cols-3 grid-cols-2 rounded-xl border border-nd_gray-200 overflow-hidden shadow-sm bg-white">
    {statCards
    ->Array.mapWithIndex((card, index) => {
      <PageLoaderWrapper
        key={index->Int.toString}
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-24" message="No data available." />}
        customLoader={<Shimmer styleClass="h-24 w-full" />}>
        <ConnectedStatCard
          title={card.connectedStatCardTitle}
          value=card.connectedStatCardValue
          cardType=card.connectedStatCardType
          onConnectedStatCardClick={() => {
            card.connectedStatCardPath->Option.mapOr((), path => RescriptReactRouter.push(path))
          }}
        />
      </PageLoaderWrapper>
    })
    ->React.array}
  </div>
}
