open Typography
open ReconEngineRulesTypes

module RuleWiseStackedBarGraph = {
  @react.component
  let make = (~rule: rulePayload) => {
    open CurrencyFormatUtils
    open LogicUtils

    let getTransactions = ReconEngineHooks.useGetTransactions()
    let (allTransactionsData, setAllTransactionsData) = React.useState(_ => [])
    let isMiniLaptopView = MatchMedia.useScreenSizeChecker(~screenSize="1600")
    let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)

    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let getAllTransactionsData = async _ => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let baseQueryString = ReconEngineFilterUtils.buildQueryStringFromFilters(~filterValueJson)
        let statusList =
          ReconEngineFilterUtils.getTransactionStatusValueFromStatusList([
            Posted(Manual),
            Matched(Auto),
            Matched(Manual),
            Matched(Force),
            Expected,
            Missing,
            PartiallyReconciled,
            OverAmount(Mismatch),
            OverAmount(Expected),
            UnderAmount(Mismatch),
            UnderAmount(Expected),
            DataMismatch,
          ])->Array.joinWith(",")

        let queryString = if baseQueryString->isNonEmptyString {
          `${baseQueryString}&rule_id=${rule.rule_id}&status=${statusList}`
        } else {
          `rule_id=${rule.rule_id}&status=${statusList}`
        }
        let transactionsData = await getTransactions(~queryParameters=Some(queryString))
        setAllTransactionsData(_ => transactionsData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Custom)
      }
    }

    let (matchedCount, mismatchedCount, expectedCount) = React.useMemo(() => {
      ReconEngineOverviewUtils.calculateTransactionCounts(allTransactionsData)
    }, [allTransactionsData])

    let totalTransactions = matchedCount + mismatchedCount + expectedCount
    let reconciliationPercentage =
      totalTransactions > 0
        ? matchedCount->Int.toFloat /. totalTransactions->Int.toFloat *. 100.0
        : 0.0

    let stackedBarGraphData = React.useMemo(() => {
      ReconEngineOverviewSummaryUtils.getSummaryStackedBarGraphData(
        ~matchedCount,
        ~mismatchedCount,
        ~expectedCount,
      )
    }, [matchedCount, mismatchedCount, expectedCount])

    React.useEffect(() => {
      if !(filterValue->isEmptyDict) {
        getAllTransactionsData()->ignore
      }
      None
    }, [filterValue])

    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-44" message="No data available." />}
      customLoader={<Shimmer styleClass="h-44 w-full rounded-xl" />}>
      <div
        key={rule.rule_id}
        className="flex flex-col gap-3 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
        <p className={`text-nd_gray-500 ${body.sm.medium}`}> {rule.rule_name->React.string} </p>
        <p className={`text-nd_gray-800 ${heading.md.semibold}`}>
          {`${reconciliationPercentage->valueFormatter(Rate)}`->React.string}
        </p>
        {if totalTransactions > 0 {
          <div className="w-full">
            <StackedBarGraph
              options={StackedBarGraphUtils.getStackedBarGraphOptions(
                stackedBarGraphData,
                ~yMax=totalTransactions,
                ~labelItemDistance={isMiniLaptopView ? 45 : 80},
                ~pointWidth=12,
                ~onPointClick=seriesName =>
                  ReconEngineOverviewUtils.handleBarClick(~rule, seriesName),
              )}
            />
          </div>
        } else {
          <div className="flex gap-4 flex-wrap">
            <div className="flex items-center gap-1.5">
              <span
                className="inline-block w-2.5 h-2.5 rounded-sm flex-shrink-0"
                style={ReactDOM.Style.make(~backgroundColor=ReconEngineOverviewUtils.matchedColor, ())}
              />
              <span className={`text-nd_gray-500 ${body.sm.medium}`}>
                {"Matched"->React.string}
              </span>
              <span className="text-nd_gray-400 mx-0.5"> {"|"->React.string} </span>
              <span className={`text-nd_gray-700 ${body.sm.semibold}`}>
                {matchedCount->Int.toString->React.string}
              </span>
            </div>
            <div className="flex items-center gap-1.5">
              <span
                className="inline-block w-2.5 h-2.5 rounded-sm flex-shrink-0"
                style={ReactDOM.Style.make(~backgroundColor=ReconEngineOverviewUtils.expectedColor, ())}
              />
              <span className={`text-nd_gray-500 ${body.sm.medium}`}>
                {"Expected"->React.string}
              </span>
              <span className="text-nd_gray-400 mx-0.5"> {"|"->React.string} </span>
              <span className={`text-nd_gray-700 ${body.sm.semibold}`}>
                {expectedCount->Int.toString->React.string}
              </span>
            </div>
            <div className="flex items-center gap-1.5">
              <span
                className="inline-block w-2.5 h-2.5 rounded-sm flex-shrink-0"
                style={ReactDOM.Style.make(
                  ~backgroundColor=ReconEngineOverviewUtils.mismatchedColor,
                  (),
                )}
              />
              <span className={`text-nd_gray-500 ${body.sm.medium}`}>
                {"Mismatched"->React.string}
              </span>
              <span className="text-nd_gray-400 mx-0.5"> {"|"->React.string} </span>
              <span className={`text-nd_gray-700 ${body.sm.semibold}`}>
                {mismatchedCount->Int.toString->React.string}
              </span>
            </div>
          </div>
        }}
      </div>
    </PageLoaderWrapper>
  }
}

@react.component
let make = (~reconRulesList: array<rulePayload>) => {
  <div className="grid gap-6 grid-cols-1 lg:grid-cols-2">
    {reconRulesList
    ->Array.map(rule => <RuleWiseStackedBarGraph rule key={rule.rule_id} />)
    ->React.array}
  </div>
}
