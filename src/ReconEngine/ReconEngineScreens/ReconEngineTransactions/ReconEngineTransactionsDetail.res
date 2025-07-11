@react.component
let make = (~id) => {
  open LogicUtils
  open ReconEngineTransactionsUtils
  open ReconEngineTransactionsHelper

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (currentTransactionDetails, setCurrentTransactionDetails) = React.useState(_ =>
    Dict.make()->getAllTransactionPayload
  )
  let (allTransactionDetails, setAllTransactionDetails) = React.useState(_ => [
    Dict.make()->getAllTransactionPayload,
  ])
  let defaultObject = Dict.make()->getAllTransactionPayload

  let getTransactionDetails = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let response = SampleTransactions.data
      let data = response->getDictFromJsonObject->getArrayFromDict("transactions", [])
      let transactionsList = data->getArrayOfTransactionsListPayloadType
      let selectedCurrentTransactionArray = transactionsList->Array.filter(item => item.id == id)
      let selectedCurrentTransactionData =
        selectedCurrentTransactionArray->getValueFromArray(0, defaultObject)
      let allTransactionDetails =
        transactionsList->Array.filter(item =>
          item.transaction_id == selectedCurrentTransactionData.transaction_id
        )
      setCurrentTransactionDetails(_ => selectedCurrentTransactionData)
      setAllTransactionDetails(_ => allTransactionDetails)
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
        path=[{title: "Overview", link: `/v1/recon-engine/transactions`}]
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
