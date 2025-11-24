@react.component
let make = (~ruleDetails: ReconEngineTypes.reconRuleType) => {
  open LogicUtils
  open ReconEngineOverviewUtils
  open ReconEngineOverviewHelper
  open ReconEngineAccountsUtils

  let (accountData, setAccountData) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (allTransactionsData, setAllTransactionsData) = React.useState(_ => [])
  let getTransactions = ReconEngineHooks.useGetTransactions()
  let getAccounts = ReconEngineHooks.useGetAccounts()

  let getTransactionsAndAccountData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let accountData = await getAccounts()
      setAccountData(_ => accountData)
      let transactionsData = await getTransactions(
        ~queryParamerters=Some(
          `rule_id=${ruleDetails.rule_id}&transaction_status=posted,mismatched,expected,partially_reconciled`,
        ),
      )
      setAllTransactionsData(_ => transactionsData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let (
    (sourceAccountName, sourceAccountCurrency),
    (targetAccountName, targetAccountCurrency),
  ) = React.useMemo(() => {
    let source =
      ruleDetails.sources->getValueFromArray(0, Dict.make()->getAccountRefPayloadFromDict)
    let target =
      ruleDetails.targets->getValueFromArray(0, Dict.make()->getAccountRefPayloadFromDict)
    let sourceInfo = getAccountNameAndCurrency(accountData, source.account_id)
    let targetInfo = getAccountNameAndCurrency(accountData, target.account_id)
    (sourceInfo, targetInfo)
  }, (ruleDetails, accountData))

  let ruleTransactionsData = React.useMemo(() => {
    allTransactionsData->Array.filter(transaction =>
      transaction.rule.rule_id === ruleDetails.rule_id
    )
  }, (allTransactionsData, ruleDetails.rule_id))

  let cardData = React.useMemo(() => {
    calculateAccountAmounts(
      ruleTransactionsData,
      ~sourceAccountName,
      ~sourceAccountCurrency,
      ~targetAccountName,
      ~targetAccountCurrency,
    )
  }, (
    ruleTransactionsData,
    sourceAccountName,
    sourceAccountCurrency,
    targetAccountName,
    targetAccountCurrency,
  ))

  React.useEffect(() => {
    getTransactionsAndAccountData()->ignore
    None
  }, [])

  <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
    {cardData
    ->Array.map(card => {
      <PageLoaderWrapper
        key={randomString(~length=10)}
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-28" message="No data available" />}
        customLoader={<Shimmer styleClass="w-full h-28 rounded-xl" />}>
        <OverviewCard title={card.cardTitle} value={card.cardValue} />
      </PageLoaderWrapper>
    })
    ->React.array}
  </div>
}
