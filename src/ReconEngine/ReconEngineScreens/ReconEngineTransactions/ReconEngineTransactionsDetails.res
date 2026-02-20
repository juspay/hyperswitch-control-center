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
  let (entriesList, setEntriesList) = React.useState(_ => [
    Dict.make()->transactionsEntryItemToObjMapperFromDict,
  ])
  let (accountsData, setAccountsData) = React.useState(_ => [])
  let (currentTransactionDetails, setCurrentTransactionDetails) = React.useState(_ =>
    Dict.make()->getTransactionsPayloadFromDict
  )
  let (allTransactionDetails, setAllTransactionDetails) = React.useState(_ => [
    Dict.make()->getTransactionsPayloadFromDict,
  ])
  let getTransactions = ReconEngineHooks.useGetTransactions()
  let getAccounts = ReconEngineHooks.useGetAccounts()

  let getTransactionDetails = async _ => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let transactionsList = await getTransactions(~queryParameters=Some(`transaction_id=${id}`))
      transactionsList->Array.sort(sortByVersion)
      let currentTransaction =
        transactionsList->getValueFromArray(0, Dict.make()->getTransactionsPayloadFromDict)
      let entriesUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#PROCESSED_ENTRIES_LIST_WITH_TRANSACTION,
        ~id=Some(currentTransaction.transaction_id),
      )
      let entriesRes = await fetchDetails(entriesUrl)
      let entriesList = entriesRes->getArrayDataFromJson(transactionsEntryItemToObjMapperFromDict)
      let entriesDataArray = currentTransaction.entries->Array.map(entry => {
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
      setCurrentTransactionDetails(_ => currentTransaction)
      setAllTransactionDetails(_ => transactionsList)
      setAccountsData(_ => accountData)
      setScreenState(_ => PageLoaderWrapper.Success)
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
        title: "Audit Trail",
        renderContent: () => <AuditTrail allTransactionDetails={allTransactionDetails} />,
      },
      {
        title: "Entries",
        renderContent: () =>
          <ReconEngineTransactionEntries
            entriesList={entriesList}
            currentTransactionDetails={currentTransactionDetails}
            accountsData
          />,
      },
    ]
  }, (allTransactionDetails, entriesList, accountsData))

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
      <div className="flex flex-col">
        <TransactionDetailInfo
          currentTransactionDetails={currentTransactionDetails}
          detailsFields=[TransactionId, Status, Variance, CreatedAt, RuleName]
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
