@react.component
let make = (~id) => {
  open LogicUtils
  open ReconEngineTransactionsUtils
  open ReconEngineTransactionsHelper

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (currentExceptionsDetails, setCurrentExceptionDetails) = React.useState(_ =>
    Dict.make()->getAllTransactionPayload
  )
  let (allExceptionDetails, setAllExceptionDetails) = React.useState(_ => [
    Dict.make()->getAllTransactionPayload,
  ])

  let getExceptionDetails = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let response = SampleDataExceptionTransaction.data
      let data = response->getDictFromJsonObject->getArrayFromDict("exceptions", [])
      let exceptionsList = data->getArrayOfTransactionsListPayloadType
      let selectedCurrentExceptionArray = exceptionsList->Array.filter(item => item.id == id)
      let selectedCurrentExceptionData =
        selectedCurrentExceptionArray->getValueFromArray(0, Dict.make()->getAllTransactionPayload)
      let allExceptionsDetails =
        exceptionsList->Array.filter(item =>
          item.transaction_id == selectedCurrentExceptionData.transaction_id
        )
      setCurrentExceptionDetails(_ => selectedCurrentExceptionData)
      setAllExceptionDetails(_ => allExceptionsDetails)
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
        path=[{title: "Overview", link: `/v1/recon-engine/exceptions`}]
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
