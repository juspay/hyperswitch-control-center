open Typography
open ReconEngineOverviewUtils

@react.component
let make = (~ruleId: string) => {
  open LogicUtils

  let (transactionsData, setTransactionsData) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {updateExistingKeys, filterValueJson, filterValue} = React.useContext(
    FilterContext.filterContext,
  )

  let getTransactions = ReconEngineHooks.useGetTransactions()
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

  let fetchTransactions = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let enhancedFilterValueJson = Dict.copy(filterValueJson)
      let baseQueryString = ReconEngineFilterUtils.buildQueryStringFromFilters(
        ~filterValueJson=enhancedFilterValueJson,
      )
      let statusList =
        ReconEngineFilterUtils.getTransactionStatusValueFromStatusList([
          Posted(Manual),
          Matched(Auto),
          Matched(Manual),
          Matched(Force),
        ])->Array.joinWith(",")

      let suffix = `rule_id=${ruleId}&status=${statusList}`
      let queryString = if baseQueryString->isNonEmptyString {
        `${baseQueryString}&${suffix}`
      } else {
        suffix
      }
      let transactions = await getTransactions(~queryParameters=Some(queryString))
      setTransactionsData(_ => transactions)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~range=180,
    ~origin="recon_engine_reconciled_graph",
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchTransactions()->ignore
    }
    None
  }, [filterValue])

  let volumeData = React.useMemo1(() => {
    let countData = processCountGraphData(transactionsData, ~graphColor=matchedVolumeColor)
    createColumnGraphCountPayload(~countData, ~title="Matched Volume", ~color=matchedVolumeColor)
  }, [transactionsData])

  <div className="border rounded-xl border-nd_gray-200">
    <div
      className="flex flex-row justify-between items-center p-4 bg-nd_gray-25 rounded-t-xl border-b border-nd_gray-200">
      <div className={`text-nd_gray-600 ${body.md.semibold}`}>
        {"Matched Volume"->React.string}
      </div>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-72" message="No data available" />}
      customLoader={<Shimmer styleClass="w-full h-344-px rounded-b-xl" />}>
      <div className="w-full p-4">
        <ColumnGraph options={ColumnGraphUtils.getColumnGraphOptions(volumeData)} />
      </div>
    </PageLoaderWrapper>
  </div>
}
