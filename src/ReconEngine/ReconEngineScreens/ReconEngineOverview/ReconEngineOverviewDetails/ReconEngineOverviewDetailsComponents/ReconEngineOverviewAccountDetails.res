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

  let (sourceAccountId, targetAccountIds) = getSourceAndAllTargetAccountIds(ruleDetails)

  let (sourceAccountData, targetAccountsData) = React.useMemo(() => {
    let sourceAccount = getAccountData(accountData, sourceAccountId)
    let targetAccounts =
      targetAccountIds->Array.map(targetId => getAccountData(accountData, targetId))

    (sourceAccount, targetAccounts)
  }, (ruleDetails, accountData))

  let (sourceTransactionData, targetAccountsTransactionData) = React.useMemo(() => {
    let accountTransactionData = processAllTransactionsWithAmounts(
      [ruleDetails],
      allTransactionsData,
      accountData,
    )

    let sourceData = getTransactionsData(accountTransactionData, sourceAccountData.account_id)
    let targetData =
      targetAccountsData->Array.map(targetAccount =>
        getTransactionsData(accountTransactionData, targetAccount.account_id)
      )
    (sourceData, targetData)
  }, (allTransactionsData, sourceAccountData.account_id, targetAccountsData))

  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData height="h-64" message="No data available." />}
    customLoader={<Shimmer styleClass="h-64 w-full rounded-xl" />}>
    <div
      className={`grid gap-6 ${targetAccountsData->Array.length > 1
          ? "grid-cols-1"
          : "grid-cols-1 lg:grid-cols-2"}`}>
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
          targetAccountsTransactionData
          ->Array.get(index)
          ->Option.getOr(Dict.make()->accountTransactionDataToObjMapper)
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
