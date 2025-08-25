open Typography

@react.component
let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
  open LogicUtils

  let (allTransactionsData, setAllTransactionsData) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let getTransactions = ReconEngineTransactionsHook.useGetTransactions()

  let getAllTransactionsData = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let transactionsData = await getTransactions(
        ~queryParamerters=Some(`rule_id=${ruleDetails.rule_id}`),
      )
      setAllTransactionsData(_ => transactionsData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1600px)")
  let (postedCount, mismatchedCount, expectedCount) = React.useMemo(() => {
    ReconEngineOverviewUtils.calculateTransactionCounts(allTransactionsData)
  }, [allTransactionsData])

  let totalTransactions = postedCount + mismatchedCount + expectedCount
  let stackedBarGraphData = React.useMemo(() => {
    ReconEngineOverviewUtils.getStackedBarGraphData(~postedCount, ~mismatchedCount, ~expectedCount)
  }, [postedCount, mismatchedCount, expectedCount])
  let reconciliationPercentage =
    totalTransactions > 0
      ? postedCount->Int.toFloat /. totalTransactions->Int.toFloat *. 100.0
      : 0.0

  React.useEffect(() => {
    getAllTransactionsData()->ignore
    None
  }, [])

  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData height="h-40" message="No data available" />}
    customLoader={<Shimmer styleClass="w-full h-40 rounded-xl" />}>
    <div
      className="flex flex-col space-y-2 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
      <p className={`text-nd_gray-400 ${body.sm.medium}`}> {"Total Transaction"->React.string} </p>
      <p className={`text-nd_gray-800 ${heading.md.semibold}`}>
        {`${reconciliationPercentage->valueFormatter(Rate)}`->React.string}
      </p>
      <div className="w-full">
        <StackedBarGraph
          options={StackedBarGraphUtils.getStackedBarGraphOptions(
            stackedBarGraphData,
            ~yMax=totalTransactions,
            ~labelItemDistance={isMiniLaptopView ? 45 : 90},
            ~pointWidth=12,
          )}
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
