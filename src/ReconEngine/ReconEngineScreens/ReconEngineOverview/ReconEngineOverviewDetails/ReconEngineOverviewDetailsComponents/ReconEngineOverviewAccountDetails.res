open ReconEngineRulesTypes

@react.component
let make = (~ruleDetails: rulePayload) => {
  open ReconEngineOverviewSummaryUtils
  open ReconEngineOverviewHelper

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
        ~queryParameters=Some(
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

  let (sourceAccountId, targetAccountId) = switch ruleDetails.strategy {
  | OneToOne(oneToOne) =>
    switch oneToOne {
    | SingleSingle(data) => (data.source_account.account_id, data.target_account.account_id)
    | SingleMany(data) => (data.source_account.account_id, data.target_account.account_id)
    | ManySingle(data) => (data.source_account.account_id, data.target_account.account_id)
    }
  }

  let (sourceAccountData, targetAccountData) = React.useMemo(() => {
    let sourceAccount = getAccountData(accountData, sourceAccountId)
    let targetAccount = getAccountData(accountData, targetAccountId)

    (sourceAccount, targetAccount)
  }, (ruleDetails, accountData))

  let (sourceTransactionData, targetTransactionData) = React.useMemo(() => {
    let accountTransactionData = processAllTransactionsWithAmounts(
      [ruleDetails],
      allTransactionsData,
      accountData,
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
