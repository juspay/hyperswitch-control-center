open Typography
open ReconEngineTypes

module RuleWiseStackedBarGraph = {
  @react.component
  let make = (~rule: ReconEngineTypes.reconRuleType) => {
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
        let queryString = if baseQueryString->isNonEmptyString {
          `${baseQueryString}&rule_id=${rule.rule_id}&status=posted_auto,posted_manual,posted_force,expected,partially_reconciled,over_payment_mismatch,over_payment_expected,under_payment_mismatch,under_payment_expected,data_mismatch`
        } else {
          `rule_id=${rule.rule_id}&status=posted_auto,posted_manual,posted_force,expected,partially_reconciled,over_payment_mismatch,over_payment_expected,under_payment_mismatch,under_payment_expected,data_mismatch`
        }
        let transactionsData = await getTransactions(~queryParameters=Some(queryString))
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
              ~pointWidth=12,
            )}
          />
        </div>
      </div>
    </PageLoaderWrapper>
  }
}

@react.component
let make = (~reconRulesList: array<reconRuleType>) => {
  <div className="grid gap-6 grid-cols-1 lg:grid-cols-2">
    {reconRulesList
    ->Array.map(rule => <RuleWiseStackedBarGraph rule key={rule.rule_id} />)
    ->React.array}
  </div>
}
