@react.component
let make = (~id) => {
  open LogicUtils
  open ReconEngineTransactionsUtils
  open ReconEngineTransactionsHelper

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
      let transactionsList = await getTransactions(~queryParamerters=Some(`transaction_id=${id}`))
      transactionsList->Array.sort(sortByVersion)
      let currentTransaction =
        transactionsList->getValueFromArray(0, Dict.make()->getTransactionsPayloadFromDict)
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

  let detailsFields = React.useMemo(() => {
    open TransactionsTableEntity
    switch (
      currentTransactionDetails.transaction_status,
      currentTransactionDetails.data.posted_type,
    ) {
    | (Posted, Some(ForceReconciled)) => [
        TransactionId,
        Status,
        Variance,
        ReconciliationType,
        CreatedAt,
        Reason,
      ]
    | (Posted, Some(ManuallyReconciled)) => [
        TransactionId,
        Status,
        Variance,
        ReconciliationType,
        CreatedAt,
        Reason,
      ]
    | _ => [TransactionId, Status, Variance, CreatedAt]
    }
  }, [currentTransactionDetails])

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
        <TransactionDetailInfo
          currentTransactionDetails={currentTransactionDetails} detailsFields={detailsFields}
        />
        <AuditTrail allTransactionDetails={allTransactionDetails} />
      </div>
    </PageLoaderWrapper>
  </div>
}
