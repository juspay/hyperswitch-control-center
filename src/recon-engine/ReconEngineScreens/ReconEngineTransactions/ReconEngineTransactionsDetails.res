@react.component
let make = (~id) => {
  open LogicUtils
  open ReconEngineTransactionsUtils
  open ReconEngineTransactionsHelper
  open APIUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (currentTransactionDetails, setCurrentTransactionDetails) = React.useState(_ =>
    Dict.make()->getTransactionsPayloadFromDict
  )
  let (allTransactionDetails, setAllTransactionDetails) = React.useState(_ => [
    Dict.make()->getTransactionsPayloadFromDict,
  ])
  let getTransactions = ReconEngineHooks.useGetTransactions()

  let getTransactionDetails = async _ => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let currentTransactionUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSACTIONS_LIST,
        ~id=Some(id),
      )
      let res = await fetchDetails(currentTransactionUrl)
      let currentTransaction = res->getDictFromJsonObject->getTransactionsPayloadFromDict

      let transactionsList = await getTransactions(
        ~queryParamerters=Some(`transaction_id=${currentTransaction.transaction_id}`),
      )
      setCurrentTransactionDetails(_ => currentTransaction)
      setAllTransactionDetails(_ => transactionsList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch transaction details"))
    }
  }

  React.useEffect(() => {
    getTransactionDetails()->ignore
    None
  }, [])

  <div>
    <div className="flex flex-col gap-4 mb-8">
      <BreadCrumbNavigation
        path=[{title: "Transactions", link: `/v1/recon-engine/transactions`}]
        currentPageTitle=id
        cursorStyle="cursor-pointer"
        customTextClass="text-nd_gray-400"
        titleTextClass="text-nd_gray-600 font-medium"
        fontWeight="font-medium"
        dividerVal=Slash
        childGapClass="gap-2"
      />
      <PageUtils.PageHeading title="Transactions Detail" />
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exists in out record" renderType=NotFound
      />}>
      <div className="flex flex-col gap-8">
        <TransactionDetailInfo currentTransactionDetails={currentTransactionDetails} />
        <AuditTrail allTransactionDetails={allTransactionDetails} />
      </div>
    </PageLoaderWrapper>
  </div>
}
