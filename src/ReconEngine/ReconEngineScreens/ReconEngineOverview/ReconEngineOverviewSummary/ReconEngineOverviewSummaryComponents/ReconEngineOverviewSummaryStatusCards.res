open Typography

module StatusCard = {
  @react.component
  let make = (~title: string, ~value: string, ~iconName: string, ~iconColor: string, ~bgColor: string) => {
    <div
      className={`flex flex-col gap-2 border border-nd_gray-150 rounded-xl p-4 ${bgColor} min-w-[180px]`}>
      <div className="flex flex-row items-center gap-2">
        <Icon name={iconName} size=16 className={iconColor} />
        <p className={`text-nd_gray-500 ${body.sm.medium}`}> {title->React.string} </p>
      </div>
      <p className={`text-nd_gray-800 ${heading.md.semibold}`}> {value->React.string} </p>
    </div>
  }
}

@react.component
let make = (~reconRulesList: array<ReconEngineRulesTypes.rulePayload>) => {
  open ReconEngineOverviewSummaryHelper
  open ReconEngineTypes

  let getTransactions = ReconEngineHooks.useGetTransactions()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (transactionCounts, setTransactionCounts) = React.useState(_ => (0, 0, 0))

  let fetchAllTransactions = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let baseQueryString = ReconEngineFilterUtils.buildQueryStringFromFilters(~filterValueJson)
      let statusList =
        ReconEngineFilterUtils.getTransactionStatusValueFromStatusList([
          Posted(Auto),
          Posted(Manual),
          Posted(Force),
          Expected,
          Missing,
          PartiallyReconciled,
          OverAmount(Mismatch),
          OverAmount(Expected),
          UnderAmount(Mismatch),
          UnderAmount(Expected),
          DataMismatch,
        ])->Array.joinWith(",")

      let ruleIds = reconRulesList->Array.map(rule => rule.rule_id)->Array.joinWith(",")
      let queryString = if baseQueryString->LogicUtils.isNonEmptyString {
        `${baseQueryString}&rule_id=${ruleIds}&status=${statusList}`
      } else {
        `rule_id=${ruleIds}&status=${statusList}`
      }

      let allTransactions = await getTransactions(~queryParameters=Some(queryString))
      let counts = ReconEngineOverviewUtils.calculateTransactionCounts(allTransactions)
      setTransactionCounts(_ => counts)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if !(filterValue->LogicUtils.isEmptyDict) && reconRulesList->Array.length > 0 {
      fetchAllTransactions()->ignore
    }
    None
  }, (filterValue, reconRulesList))

  let (postedCount, mismatchedCount, expectedCount) = transactionCounts
  let totalTransactions = postedCount + mismatchedCount + expectedCount
  let reconciledPercentage =
    totalTransactions > 0
      ? postedCount->Int.toFloat /. totalTransactions->Int.toFloat *. 100.0
      : 0.0

  let reconciledPercentageStr = `${reconciledPercentage->Float.toFixedWithPrecision(~digits=1)}%`

  <PageLoaderWrapper
    screenState
    customUI={<Shimmer styleClass="h-24 w-full rounded-xl" />}
    customLoader={<Shimmer styleClass="h-24 w-full rounded-xl" />}>
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <StatusCard
        title="Total Transactions"
        value={totalTransactions->Int.toString}
        iconName="nd-reports"
        iconColor="text-nd_gray-500"
        bgColor="bg-white"
      />
      <StatusCard
        title="Reconciled"
        value={reconciledPercentageStr}
        iconName="nd-check-circle-outline"
        iconColor="text-nd_green-600"
        bgColor="bg-white"
      />
      <StatusCard
        title="Pending"
        value={expectedCount->Int.toString}
        iconName="nd-hour-glass-outline"
        iconColor="text-nd_yellow-600"
        bgColor="bg-white"
      />
      <StatusCard
        title="Mismatched"
        value={mismatchedCount->Int.toString}
        iconName="nd-alert-triangle-outline"
        iconColor="text-nd_red-500"
        bgColor="bg-white"
      />
    </div>
  </PageLoaderWrapper>
}
