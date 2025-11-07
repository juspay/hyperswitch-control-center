open Typography

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
    Dict.make()->getTransactionsPayloadFromDict
  )
  let (allExceptionDetails, setAllExceptionDetails) = React.useState(_ => [
    Dict.make()->getTransactionsPayloadFromDict,
  ])
  let (entriesList, setEntriesList) = React.useState(_ => [
    Dict.make()->transactionsEntryItemToObjMapperFromDict,
  ])
  let (accountsData, setAccountsData) = React.useState(_ => [])
  let getTransactions = ReconEngineHooks.useGetTransactions()
  let getAccounts = ReconEngineHooks.useGetAccounts()

  let getExceptionDetails = async _ => {
    try {
      let currentExceptionUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSACTIONS_LIST,
        ~id=Some(id),
      )
      let res = await fetchDetails(currentExceptionUrl)
      let currentException = res->getDictFromJsonObject->getTransactionsPayloadFromDict
      let exceptionsList = await getTransactions(
        ~queryParamerters=Some(`transaction_id=${currentException.transaction_id}`),
      )
      let currentExceptionDetails =
        exceptionsList
        ->Array.filter(txn => txn.id == currentException.id)
        ->getValueFromArray(0, Dict.make()->getTransactionsPayloadFromDict)
      let entriesUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#PROCESSED_ENTRIES_LIST_WITH_TRANSACTION,
        ~id=Some(currentException.transaction_id),
      )
      let entriesRes = await fetchDetails(entriesUrl)
      let entriesList = entriesRes->getArrayDataFromJson(transactionsEntryItemToObjMapperFromDict)
      let entriesDataArray = currentExceptionDetails.entries->Array.map(entry => {
        let foundEntry =
          entriesList
          ->Array.find(e => entry.entry_id == e.entry_id)
          ->Option.getOr(Dict.make()->transactionsEntryItemToObjMapperFromDict)

        {
          ...foundEntry,
          account_name: entry.account.account_name,
        }
      })
      let accountData = await getAccounts()
      setEntriesList(_ => entriesDataArray)
      setCurrentExceptionDetails(_ => currentExceptionDetails)
      setAllExceptionDetails(_ => exceptionsList)
      setAccountsData(_ => accountData)
      setScreenState(_ => PageLoaderWrapper.Success)
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
            entriesList={entriesList}
            currentExceptionDetails={currentExceptionsDetails}
            accountsData
          />,
      },
      {
        title: "Audit Trail",
        renderContent: () => <AuditTrail allTransactionDetails={allExceptionDetails} />,
      },
    ]
  }, (allExceptionDetails, entriesList, accountsData))

  <div>
    <div className="flex flex-col gap-4 mb-6">
      <BreadCrumbNavigation
        path=[{title: "Recon Exceptions", link: `/v1/recon-engine/transaction-exceptions`}]
        currentPageTitle=id
        cursorStyle="cursor-pointer"
        customTextClass="text-nd_gray-400"
        titleTextClass="text-nd_gray-600 font-medium"
        fontWeight="font-medium"
        dividerVal=Slash
        childGapClass="gap-2"
      />
      <PageUtils.PageHeading title="Recon Exceptions Detail" />
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exists in out record" renderType=NotFound
      />}>
      <div className="flex flex-col gap-4">
        <TransactionDetailInfo
          currentTransactionDetails={currentExceptionsDetails}
          detailsFields=[TransactionId, Status, Variance, CreatedAt]
        />
        <Tabs
          tabs
          showBorder=true
          includeMargin=false
          defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center ${body.md.semibold}`}
          selectTabBottomBorderColor="bg-primary"
        />
      </div>
    </PageLoaderWrapper>
  </div>
}
