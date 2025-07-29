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
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
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

  let (
    sourcePostedAmount,
    targetPostedAmount,
    missingInTargetAmount,
    netVariance,
  ) = React.useMemo(() => {
    calculateAccountAmounts(ruleTransactionsData)
  }, [ruleTransactionsData])

  React.useEffect(() => {
    getTransactionsAndAccountData()->ignore
    None
  }, [])

  <PageLoaderWrapper
    screenState
    customLoader={<div className="h-full flex flex-col justify-center items-center">
      <div className="animate-spin">
        <Icon name="spinner" size=20 />
      </div>
    </div>}>
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
      <OverviewCard
        title={`Expected from ${sourceAccountName}`}
        value={sourcePostedAmount->valueFormatter(AmountWithSuffix, ~suffix=sourceAccountCurrency)}
      />
      <OverviewCard
        title={`Received by ${targetAccountName}`}
        value={targetPostedAmount->valueFormatter(AmountWithSuffix, ~suffix=targetAccountCurrency)}
      />
      <OverviewCard
        title="Variance"
        value={netVariance->valueFormatter(AmountWithSuffix, ~suffix=sourceAccountCurrency)}
      />
      <OverviewCard
        title={`Missing in ${targetAccountName}`}
        value={missingInTargetAmount->valueFormatter(
          AmountWithSuffix,
          ~suffix=targetAccountCurrency,
        )}
      />
    </div>
  </PageLoaderWrapper>
}
