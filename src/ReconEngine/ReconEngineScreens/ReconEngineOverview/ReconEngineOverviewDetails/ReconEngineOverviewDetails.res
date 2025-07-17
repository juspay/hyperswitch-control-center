@react.component
let make = (
  ~ruleDetails: ReconEngineOverviewTypes.reconRuleType,
  ~accountData: array<ReconEngineOverviewTypes.accountType>,
  ~transactionsData: array<ReconEngineTransactionsTypes.transactionPayload>,
) => {
  open ReconEngineOverviewHelper
  open LogicUtils
  open ReconEngineOverviewUtils

  let ruleTransactionsData = React.useMemo(() => {
    transactionsData->Array.filter(transaction => transaction.rule.rule_id === ruleDetails.rule_id)
  }, (transactionsData, ruleDetails.rule_id))

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

  let (sourcePostedAmount, targetPostedAmount, netVariance) = React.useMemo(() => {
    calculateAccountAmounts(ruleTransactionsData)
  }, ruleTransactionsData)

  <div className="flex flex-col gap-8">
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <OverviewCard
        title={`Expected from ${sourceAccountName}`}
        value={formatAmountWithCurrency(sourcePostedAmount, sourceAccountCurrency)}
      />
      <OverviewCard
        title={`Received by ${targetAccountName}`}
        value={formatAmountWithCurrency(targetPostedAmount, targetAccountCurrency)}
      />
      <OverviewCard
        title="Net Variance" value={formatAmountWithCurrency(netVariance, sourceAccountCurrency)}
      />
    </div>
    <StackedBarGraph transactionsData={ruleTransactionsData} />
    <ReconRuleLineGraph transactionsData={ruleTransactionsData} />
    <ReconRuleTransactions ruleDetails={ruleDetails} />
  </div>
}
