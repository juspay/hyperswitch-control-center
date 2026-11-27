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
  let (ruleAccountIds, setRuleAccountIds) = React.useState(_ => [])
  let (accountsData, setAccountsData) = React.useState(_ => [])
  let getTransactionVersions = ReconEngineHooks.useGetTransactionVersions()
  let getAccounts = ReconEngineHooks.useGetAccounts()

  let getExceptionDetails = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let exceptionsPage = await getTransactionVersions(~transactionId=id, ~limit=1)
      let currentExceptionDetails =
        exceptionsPage.items->getValueFromArray(0, Dict.make()->getTransactionsPayloadFromDict)
      if currentExceptionDetails.id->isNonEmptyString {
        let ruleUrl = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#RECON_RULES,
          ~id=Some(currentExceptionDetails.rule.rule_id),
        )
        let rule = (await fetchDetails(ruleUrl))->getDictFromJsonObject->ruleItemToObjMapper
        let accountData = await getAccounts()
        setRuleAccountIds(_ => rule.strategy->getRuleAccountIds)
        setCurrentExceptionDetails(_ => currentExceptionDetails)
        setAccountsData(_ => accountData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
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
          <AuditTrailTab
            transactionId={currentExceptionsDetails.transaction_id}
            accountIds=ruleAccountIds
            accountsData
          />,
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
