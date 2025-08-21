open Typography

module RuleWiseStackedBarGraph = {
  @react.component
  let make = (~rule: ReconEngineOverviewTypes.reconRuleType) => {
    open LogicUtils

    let getTransactions = ReconEngineTransactionsHook.useGetTransactions()
    let (allTransactionsData, setAllTransactionsData) = React.useState(_ => [])
    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1600px)")

    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let getAllTransactionsData = async _ => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let transactionsData = await getTransactions(
          ~queryParamerters=Some(`rule_id=${rule.rule_id}`),
        )
        setAllTransactionsData(_ => transactionsData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Custom)
      }
    }
    let (postedCount, mismatchedCount, expectedCount) = React.useMemo(() => {
      ReconEngineOverviewUtils.calculateTransactionCounts(allTransactionsData)
    }, [allTransactionsData])

    let totalTransactions = postedCount + mismatchedCount + expectedCount
    let reconciliationPercentage =
      totalTransactions > 0
        ? postedCount->Int.toFloat /. totalTransactions->Int.toFloat *. 100.0
        : 0.0

    let stackedBarGraphData = React.useMemo(() => {
      ReconEngineOverviewSummaryUtils.getSummaryStackedBarGraphData(
        ~postedCount,
        ~mismatchedCount,
        ~expectedCount,
      )
    }, [postedCount, mismatchedCount, expectedCount])

    React.useEffect(() => {
      getAllTransactionsData()->ignore
      None
    }, [])

    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-44" message="No data available." />}
      customLoader={<Shimmer styleClass="h-44 w-full rounded-xl" />}>
      <div
        key={rule.rule_id}
        className="flex flex-col space-y-2 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
        <p className={`text-nd_gray-500 ${body.sm.medium}`}> {rule.rule_name->React.string} </p>
        <p className={`text-nd_gray-800 ${heading.md.semibold}`}>
          {`${reconciliationPercentage->valueFormatter(Rate)}`->React.string}
        </p>
        <div className="w-full">
          <StackedBarGraph
            options={StackedBarGraphUtils.getStackedBarGraphOptions(
              stackedBarGraphData,
              ~yMax=totalTransactions,
              ~labelItemDistance={isMiniLaptopView ? 45 : 80},
            )}
          />
        </div>
      </div>
    </PageLoaderWrapper>
  }
}

@react.component
let make = (~reconRulesList: array<ReconEngineOverviewTypes.reconRuleType>) => {
  let gridClass =
    reconRulesList->Array.length <= 2 ? "grid-cols-2" : "grid-cols-1 md:grid-cols-2 lg:grid-cols-3"

  <div className={`grid gap-6 ${gridClass}`}>
    {reconRulesList
    ->Array.map(rule => <RuleWiseStackedBarGraph rule />)
    ->React.array}
  </div>
}
