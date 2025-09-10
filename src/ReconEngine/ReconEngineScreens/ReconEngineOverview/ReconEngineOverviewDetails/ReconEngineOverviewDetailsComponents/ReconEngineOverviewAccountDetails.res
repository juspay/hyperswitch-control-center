open Typography
open ReconEngineOverviewTypes
open ReconEngineOverviewSummaryTypes
open ReconEngineOverviewSummaryUtils
open ReconEngineOverviewUtils
open APIUtils
open LogicUtils

module AmountRow = {
  @react.component
  let make = (~label: string, ~amount: string, ~count: string) => {
    <div className="flex flex-row justify-between items-center">
      <div>
        <p className={`${body.md.medium} text-nd_gray-400 mb-1`}> {label->React.string} </p>
      </div>
      <div className="flex flex-col items-end">
        <p className={`${body.lg.semibold} text-nd_gray-600`}> {amount->React.string} </p>
        <p className={`${body.sm.medium} text-nd_gray-400`}> {count->React.string} </p>
      </div>
    </div>
  }
}

module AccountDetailCard = {
  @react.component
  let make = (
    ~accountName: string,
    ~otherAccountName: string,
    ~isSource: bool,
    ~transactionData: ReconEngineOverviewSummaryTypes.accountTransactionData,
  ) => {
    let formatAmount = (balance: ReconEngineOverviewTypes.balanceType): string => {
      `${Math.abs(balance.value)->valueFormatter(Amount)} ${balance.currency}`
    }

    let formatCount = (count: int): string => {
      `${count->Int.toString} Txns`
    }

    let (
      reconciledAmount,
      reconciledCount,
      mismatchAmount,
      mismatchCount,
      pendingAmount,
      pendingCount,
      pendingLabel,
    ) = if isSource {
      (
        formatAmount(transactionData.posted_transaction_amount),
        formatCount(transactionData.posted_transaction_count),
        formatAmount(transactionData.mismatched_transaction_amount),
        formatCount(transactionData.mismatched_transaction_count),
        formatAmount(transactionData.pending_transaction_amount),
        formatCount(transactionData.pending_transaction_count),
        "Pending",
      )
    } else {
      (
        formatAmount(transactionData.posted_confirmation_amount),
        formatCount(transactionData.posted_confirmation_count),
        formatAmount(transactionData.mismatched_confirmation_amount),
        formatCount(transactionData.mismatched_confirmation_count),
        formatAmount(transactionData.pending_confirmation_amount),
        formatCount(transactionData.pending_confirmation_count),
        "Expected",
      )
    }

    <div className="border rounded-xl border-nd_gray-200 ">
      <div className="border-b p-4 bg-nd_gray-25 rounded-t-xl   ">
        <p className={`${body.md.semibold} text-nd_gray-800`}> {accountName->React.string} </p>
      </div>
      <div className="p-4 flex flex-col gap-4">
        <AmountRow
          label={`Reconciled with ${otherAccountName}`}
          amount={reconciledAmount}
          count={reconciledCount}
        />
        <AmountRow
          label={`Mismatch with ${otherAccountName}`} amount={mismatchAmount} count={mismatchCount}
        />
        <div className="border-t pt-4">
          <p className={`${body.sm.semibold} text-nd_gray-600 mb-3`}>
            {"FUNDS IN FLIGHT"->React.string}
          </p>
          <AmountRow label={pendingLabel} amount={pendingAmount} count={pendingCount} />
        </div>
      </div>
    </div>
  }
}

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
