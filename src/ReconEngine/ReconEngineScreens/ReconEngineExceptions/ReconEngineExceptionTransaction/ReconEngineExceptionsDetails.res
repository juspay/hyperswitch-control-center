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
  let (currentExceptionsDetails, setCurrentExceptionDetails) = React.useState(_ =>
    Dict.make()->getTransactionsPayloadFromDict
  )
  let (accountsData, setAccountsData) = React.useState(_ => [])
  let (ruleAccountIds, setRuleAccountIds) = React.useState(_ => [])
  let getTransactionsV2 = ReconEngineHooks.useGetCursorPage(
    ~hyperswitchReconType=#TRANSACTIONS_LIST_V2,
    ~itemMapper=ReconEngineUtils.transactionItemToObjMapper,
  )
  let getAccounts = ReconEngineHooks.useGetAccounts()

  let getExceptionDetails = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let transactionsPage = await getTransactionsV2(
        ~body=buildTransactionRetrievalBody(~transactionId=id),
      )
      switch transactionsPage.items->Array.get(0) {
      | Some(currentExceptionDetails) => {
          let ruleUrl = getURL(
            ~entityName=V1(HYPERSWITCH_RECON),
            ~methodType=Get,
            ~hyperswitchReconType=#RECON_RULES,
            ~id=Some(currentExceptionDetails.rule.rule_id),
          )
          let (ruleRes, accountData) = await Promise.all2((fetchDetails(ruleUrl), getAccounts()))
          let rule = ruleRes->getDictFromJsonObject->ruleItemToObjMapper
          let (sourceAccountId, targetAccounts) = getSourceAndTargetAccountDetails(rule.strategy)
          let accountIds =
            [sourceAccountId]
            ->Array.concat(targetAccounts->Array.map(target => target.account_id))
            ->Array.filter(isNonEmptyString)
            ->getUniqueArray
          setCurrentExceptionDetails(_ => currentExceptionDetails)
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
    getExceptionDetails()->ignore
    None
  }, [])

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    [
      {
        title: "Entries",
        renderContent: () =>
          <ReconEngineExceptionTransactionEntries
            accountIds=ruleAccountIds
            currentExceptionDetails={currentExceptionsDetails}
            accountsData
          />,
      },
      {
        title: "Audit Trail",
        renderContent: () =>
          <AuditTrailTab transactionId={currentExceptionsDetails.transaction_id} />,
      },
    ]
  }, (currentExceptionsDetails, ruleAccountIds, accountsData))

  <div>
    <div className="flex flex-col gap-4 mb-6">
      <BreadCrumbNavigation
        path=[{title: "Recon Exceptions", link: "/v1/recon-engine/exceptions/recon"}]
        currentPageTitle=id
      />
      <PageUtils.PageHeading title="Recon Exceptions Detail" />
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Transaction does not exists in out record" renderType=NotFound
      />}>
      <div className="flex flex-col gap-4">
        <TransactionDetailInfo
          currentTransactionDetails={currentExceptionsDetails}
          detailsFields=[TransactionId, Status, Variance, CreatedAt]
        />
        <Tabs tabs />
      </div>
    </PageLoaderWrapper>
  </div>
}
