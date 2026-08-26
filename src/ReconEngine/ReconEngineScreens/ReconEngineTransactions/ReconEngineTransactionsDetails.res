@react.component
let make = (~id) => {
  open LogicUtils
  open ReconEngineTransactionsUtils
  open ReconEngineTransactionsHelper
  open ReconEngineRulesUtils
  open APIUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (accountsData, setAccountsData) = React.useState(_ => [])
  let (ruleAccountIds, setRuleAccountIds) = React.useState(_ => [])
  let (currentTransactionDetails, setCurrentTransactionDetails) = React.useState(_ =>
    Dict.make()->getTransactionsPayloadFromDict
  )

  let getTransactionsV2 = ReconEngineHooks.useGetCursorPage(
    ~hyperswitchReconType=#TRANSACTIONS_LIST_V2,
    ~itemMapper=ReconEngineUtils.transactionItemToObjMapper,
  )
  let getAccounts = ReconEngineHooks.useGetAccounts()

  let getTransactionDetails = async _ => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let transactionsPage = await getTransactionsV2(
        ~body=buildTransactionRetrievalBody(~transactionId=id),
      )
      switch transactionsPage.items->Array.get(0) {
      | Some(currentTransaction) => {
          let ruleUrl = getURL(
            ~entityName=V1(HYPERSWITCH_RECON),
            ~methodType=Get,
            ~hyperswitchReconType=#RECON_RULES,
            ~id=Some(currentTransaction.rule.rule_id),
          )
          let (ruleRes, accountData) = await Promise.all2((fetchDetails(ruleUrl), getAccounts()))
          let rule = ruleRes->getDictFromJsonObject->ruleItemToObjMapper
          let (sourceAccountId, targetAccounts) = getSourceAndTargetAccountDetails(rule.strategy)
          let accountIds =
            [sourceAccountId]
            ->Array.concat(targetAccounts->Array.map(target => target.account_id))
            ->Array.filter(isNonEmptyString)
            ->getUniqueArray
          setCurrentTransactionDetails(_ => currentTransaction)
          setRuleAccountIds(_ => accountIds)
          setAccountsData(_ => accountData)
          setScreenState(_ => PageLoaderWrapper.Success)
        }
      | None => setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch transaction details"))
    }
  }

  React.useEffect(() => {
    getTransactionDetails()->ignore
    None
  }, [])

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    [
      {
        title: "Entries",
        renderContent: () =>
          <ReconEngineTransactionEntries
            primaryTransactionId={currentTransactionDetails.id}
            accountIds=ruleAccountIds
            accountsData
          />,
      },
      {
        title: "Audit Trail",
        renderContent: () =>
          <AuditTrailTab transactionId={currentTransactionDetails.transaction_id} />,
      },
    ]
  }, (currentTransactionDetails, ruleAccountIds, accountsData))

  <div>
    <div className="flex flex-col gap-4 mb-8">
      <BreadCrumbNavigation
        path=[{title: "Transactions", link: `/v1/recon-engine/transactions`}] currentPageTitle=id
      />
      <PageUtils.PageHeading title="Transactions Detail" />
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exists in out record" renderType=NotFound
      />}>
      <div className="flex flex-col">
        <TransactionDetailInfo
          currentTransactionDetails={currentTransactionDetails}
          detailsFields=[TransactionId, Status, Variance, CreatedAt, RuleName]
        />
        <RenderIf condition={currentTransactionDetails.data.mismatched_fields->isNonEmptyArray}>
          <div className="px-2 pt-5">
            <ReconEngineExceptionsHelper.MismatchSummary
              mismatchedFields={currentTransactionDetails.data.mismatched_fields}
            />
          </div>
        </RenderIf>
        <Tabs tabs />
      </div>
    </PageLoaderWrapper>
  </div>
}
