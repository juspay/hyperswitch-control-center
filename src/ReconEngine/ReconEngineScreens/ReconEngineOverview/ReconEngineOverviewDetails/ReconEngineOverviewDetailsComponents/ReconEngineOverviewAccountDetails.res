@react.component
let make = (~ruleDetails: ReconEngineTypes.reconRuleType) => {
  open ReconEngineTypes
  open ReconEngineOverviewSummaryUtils
  open ReconEngineOverviewHelper
  open LogicUtils
  open ReconEngineAccountsUtils

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (accountData, setAccountData) = React.useState(_ => [])
  let (allTransactionsData, setAllTransactionsData) = React.useState(_ => [])
  let getTransactions = ReconEngineHooks.useGetTransactions()
  let getAccounts = ReconEngineHooks.useGetAccounts()

  let getAccountAndTransactionData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let accounts = await getAccounts()
      setAccountData(_ => accounts)
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

  React.useEffect(() => {
    getAccountAndTransactionData()->ignore
    None
  }, [])

  let (sourceAccountData, targetAccountData) = React.useMemo(() => {
    let source =
      ruleDetails.sources->getValueFromArray(0, Dict.make()->getAccountRefPayloadFromDict)
    let target =
      ruleDetails.targets->getValueFromArray(0, Dict.make()->getAccountRefPayloadFromDict)

    let sourceAccount = getAccountData(accountData, source.account_id)
    let targetAccount = getAccountData(accountData, target.account_id)

    (sourceAccount, targetAccount)
  }, (ruleDetails, accountData))

  let (sourceTransactionData, targetTransactionData) = React.useMemo(() => {
    let accountTransactionData = processAllTransactionsWithAmounts(
      [ruleDetails],
      allTransactionsData,
    )

    let sourceData = getTransactionsData(accountTransactionData, sourceAccountData.account_id)
    let targetData = getTransactionsData(accountTransactionData, targetAccountData.account_id)
    (sourceData, targetData)
  }, (allTransactionsData, sourceAccountData.account_id, targetAccountData.account_id))

  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData height="h-64" message="No data available." />}
    customLoader={<Shimmer styleClass="h-64 w-full rounded-xl" />}>
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <AccountDetailCard
        accountName={sourceAccountData.account_name}
        otherAccountName={targetAccountData.account_name}
        isSource={true}
        transactionData={sourceTransactionData}
      />
      <AccountDetailCard
        accountName={targetAccountData.account_name}
        otherAccountName={sourceAccountData.account_name}
        isSource={false}
        transactionData={targetTransactionData}
      />
    </div>
  </PageLoaderWrapper>
}
