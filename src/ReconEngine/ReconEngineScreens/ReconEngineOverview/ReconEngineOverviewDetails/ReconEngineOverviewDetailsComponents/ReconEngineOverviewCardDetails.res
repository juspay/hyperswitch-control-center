@react.component
let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
  open LogicUtils
  open ReconEngineOverviewUtils
  open ReconEngineOverviewHelper
  open APIUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (accountData, setAccountData) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (allTransactionsData, setAllTransactionsData) = React.useState(_ => [])
  let getTransactions = ReconEngineTransactionsHook.useGetTransactions()

  let getTransactionsAndAccountData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#ACCOUNTS_LIST,
      )
      let res = await fetchDetails(url)
      let accountData = res->getArrayDataFromJson(accountItemToObjMapper)
      setAccountData(_ => accountData)
      let transactionsData = await getTransactions(
        ~queryParamerters=Some(`rule_id=${ruleDetails.rule_id}`),
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
    let source = ruleDetails.sources->getValueFromArray(0, defaultAccountDetails)
    let target = ruleDetails.targets->getValueFromArray(0, defaultAccountDetails)
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
    ->Array.mapWithIndex((card, index) => {
      <PageLoaderWrapper
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-28" message="No data available" />}
        customLoader={<Shimmer styleClass="w-full h-28 rounded-xl" />}>
        <OverviewCard key={index->Int.toString} title={card["title"]} value={card["value"]} />
      </PageLoaderWrapper>
    })
    ->React.array}
  </div>
}
