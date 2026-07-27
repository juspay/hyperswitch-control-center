open ReconEngineRulesTypes

@react.component
let make = (~ruleDetails: rulePayload) => {
  open ReconEngineOverviewSummaryUtils
  open ReconEngineOverviewHelper
  open LogicUtils

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ruleAccountsOverview, setRuleAccountsOverview) = React.useState(_ => [])
  let getRuleAccountBreakdown = ReconEngineHooks.useGetRuleAccountBreakdown()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)

  let getAccountAndTransactionData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)

      let baseQueryString = ReconEngineFilterUtils.buildQueryStringFromFilters(~filterValueJson)
      let suffix = `rule_ids=${ruleDetails.rule_id}`
      let queryString = baseQueryString->isNonEmptyString ? `${baseQueryString}&${suffix}` : suffix

      let breakdown = await getRuleAccountBreakdown(~queryParameters=Some(queryString))
      setRuleAccountsOverview(_ => breakdown)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      getAccountAndTransactionData()->ignore
    }
    None
  }, [filterValue])

  let (sourceAccountData, targetAccountsData) = React.useMemo(() => {
    getSourceAndTargetAccounts(ruleAccountsOverview, ~ruleId=ruleDetails.rule_id)
  }, (ruleAccountsOverview, ruleDetails.rule_id))

  let (sourceTransactionData, targetAccountsTransactionData) = React.useMemo(() => {
    let sourceData = accountTransactionDataFromStatusBreakdown(sourceAccountData.status_breakdown)
    let targetData =
      targetAccountsData->Array.map(targetAccount =>
        accountTransactionDataFromStatusBreakdown(targetAccount.status_breakdown)
      )
    (sourceData, targetData)
  }, (sourceAccountData, targetAccountsData))

  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData height="h-64" message="No data available." />}
    customLoader={<Shimmer styleClass="h-64 w-full rounded-xl" />}>
    <div
      className={`grid gap-6 grid-cols-1 ${targetAccountsData->Array.length > 1
          ? ""
          : "lg:grid-cols-2"}`}>
      <AccountDetailCard
        accountName={sourceAccountData.account_name}
        otherAccountName={targetAccountsData
        ->Array.map(acc => acc.account_name)
        ->Array.joinWith(", ")}
        isSource={true}
        transactionData={sourceTransactionData}
      />
      {targetAccountsData
      ->Array.mapWithIndex((targetAccount, index) => {
        let targetTransactionData =
          targetAccountsTransactionData->getValueFromArray(
            index,
            Dict.make()->accountTransactionDataToObjMapper,
          )
        <AccountDetailCard
          key={targetAccount.account_id}
          accountName={targetAccount.account_name}
          otherAccountName={sourceAccountData.account_name}
          isSource={false}
          transactionData={targetTransactionData}
        />
      })
      ->React.array}
    </div>
  </PageLoaderWrapper>
}
