module TransactionsTable = {
  @react.component
  let make = () => {
    open APIUtils
    let getURL = useGetURL()
    let _fetchDetails = useGetMethod()
    let showToast = ToastState.useShowToast()
    let (tableData, setTableData) = React.useState(() => [])
    let (offset, setOffset) = React.useState(() => 0)
    let limit = 50

    let fetchTableData = async () => {
      try {
        let _url = getURL(
          ~entityName=V1(INTELLIGENT_ROUTING_RECORDS),
          ~methodType=Get,
          ~queryParamerters=Some(`limit=${limit->Int.toString}&offset=${offset->Int.toString}`),
        )
        // let res = await fetchDetails(url)
        let response = {
          "txn_no": 1,
          "order_id": "ORD123",
          "juspay_txn_id": "TXN456",
          "amount": 99.99,
          "payment_gateway": "PayPal",
          "payment_status": true,
          "payment_method_type": "Credit Card",
          "order_currency": "USD",
          "model_connector": "Stripe",
          "suggested_uplift": 12.34,
        }
        let arr = Array.make(~length=55, response)

        let typedResponse =
          arr->Identity.genericTypeToJson->IntelligentRoutingTransactionsEntity.getTransactionsData
        setTableData(_ => typedResponse->Array.map(Nullable.make))
      } catch {
      | _ => showToast(~message="Failed to fetch transaction details", ~toastType=ToastError)
      }
    }

    React.useEffect(() => {
      fetchTableData()->ignore
      None
    }, [])

    <div>
      <LoadedTable
        title="Transactions Details"
        hideTitle=false
        actualData=tableData
        totalResults={tableData->Array.length}
        resultsPerPage=10
        offset
        setOffset
        entity={IntelligentRoutingTransactionsEntity.transactionDetailsEntity()}
        currrentFetchCount={tableData->Array.length}
        tableheadingClass="h-12"
        tableHeadingTextClass="!font-normal"
        nonFrozenTableParentClass="!rounded-lg"
        loadedTableParentClass="flex flex-col"
      />
    </div>
  }
}

@react.component
let make = () => {
  let (screenState, _setScreenState) = React.useState(() => PageLoaderWrapper.Success)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  React.useEffect(() => {
    setShowSideBar(_ => true)
    None
  }, [])

  <PageLoaderWrapper screenState={screenState}>
    <HSwitchUtils.AlertBanner
      bannerText="Demo Mode: You're viewing sample analytics to help you understand how the reports will look with real data"
      bannerType={Info}
    />
    <PageUtils.PageHeading title="Intelligent Routing Overview" />
    <TransactionsTable />
  </PageLoaderWrapper>
}
