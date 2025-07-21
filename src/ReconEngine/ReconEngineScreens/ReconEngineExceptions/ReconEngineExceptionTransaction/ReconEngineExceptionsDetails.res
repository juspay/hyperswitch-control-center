@react.component
let make = (~id) => {
  open LogicUtils
  open ReconEngineTransactionsUtils
  open ReconEngineTransactionsHelper
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (currentExceptionsDetails, setCurrentExceptionDetails) = React.useState(_ =>
    Dict.make()->getAllTransactionPayload
  )
  let (allExceptionDetails, setAllExceptionDetails) = React.useState(_ => [
    Dict.make()->getAllTransactionPayload,
  ])
  let getTransactions = ReconEngineTransactionsHook.useGetTransactions()

  let getExceptionDetails = async _ => {
    try {
      let currentExceptionUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSACTIONS_LIST,
        ~id=Some(id),
      )
      let res = await fetchDetails(currentExceptionUrl)
      let currentException = res->getDictFromJsonObject->getAllTransactionPayload
      let exceptionsList = await getTransactions(
        ~queryParamerters=Some(`transaction_id=${currentException.transaction_id}`),
      )
      setCurrentExceptionDetails(_ => currentException)
      setAllExceptionDetails(_ => exceptionsList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch transaction details"))
    }
  }

  React.useEffect(() => {
    getExceptionDetails()->ignore
    None
  }, [])

  <div>
    <div className="flex flex-col gap-4 mb-8">
      <BreadCrumbNavigation
        path=[{title: "Exceptions", link: `/v1/recon-engine/exceptions`}]
        currentPageTitle=id
        cursorStyle="cursor-pointer"
        customTextClass="text-nd_gray-400"
        titleTextClass="text-nd_gray-600 font-medium"
        fontWeight="font-medium"
        dividerVal=Slash
        childGapClass="gap-2"
      />
      <PageUtils.PageHeading title="Exceptions Detail" />
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exists in out record" renderType=NotFound
      />}>
      <div className="flex flex-col gap-8">
        <TransactionDetailInfo
          currentTransactionDetails={currentExceptionsDetails} detailsFields=[TransactionId, Status]
        />
        <AuditTrail allTransactionDetails={allExceptionDetails} />
      </div>
    </PageLoaderWrapper>
  </div>
}
