open ReconEngineOverviewTypes
open ReconEngineOverviewSummaryUtils
open ReconEngineOverviewUtils
open ReconEngineOverviewHelper
open APIUtils
open LogicUtils

@react.component
let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (accountData, setAccountData) = React.useState(_ => [])
  let (allTransactionsData, setAllTransactionsData) = React.useState(_ => [])
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let getTransactions = ReconEngineHooks.useGetTransactions()

  let getAccountAndTransactionData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#ACCOUNTS_LIST,
      )
      let res = await fetchDetails(url)
      let accounts = res->getArrayDataFromJson(accountItemToObjMapper)
      setAccountData(_ => accounts)
      let transactionsData = await getTransactions(
        ~queryParamerters=Some(`rule_id=${ruleDetails.rule_id}`),
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
    let source = ruleDetails.sources->getValueFromArray(0, defaultAccountDetails)
    let target = ruleDetails.targets->getValueFromArray(0, defaultAccountDetails)

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

  <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-64" message="No data available." />}
      customLoader={<Shimmer styleClass="h-64 w-full rounded-xl" />}>
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
    </PageLoaderWrapper>
  </div>
}
