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

    <div className="flex flex-col gap-6">
      <div className="text-nd_gray-600 font-semibold"> {"Transactions Details"->React.string} </div>
      <LoadedTable
        title=" "
        hideTitle=true
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

module Card = {
  @react.component
  let make = (~title: string, ~actualValue: string, ~simulatedValue: string) => {
    <div
      className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
      <p className="text-nd_gray-600 text-lg leading-4 font-medium"> {title->React.string} </p>
      <div className="w-full flex items-center justify-between">
        <p className="text-nd_gray-400 text-sm leading-4 font-medium"> {"Actual"->React.string} </p>
        <p className="text-nd_gray-800 font-semibold leading-8 text-lg">
          {actualValue->React.string}
        </p>
      </div>
      <div className="w-full flex items-center justify-between">
        <p className="text-nd_gray-400 text-sm leading-4 font-medium">
          {"Simulated"->React.string}
        </p>
        <p className="text-nd_gray-800 font-semibold leading-8 text-lg">
          {simulatedValue->React.string}
        </p>
      </div>
    </div>
  }
}

module MetricCards = {
  @react.component
  let make = () => {
    <div className="grid grid-cols-4 gap-6">
      <Card title="Authentication Rate" actualValue="83.24%" simulatedValue="90.84%" />
      <Card title="FAAR" actualValue="76.4%" simulatedValue="83.4%" />
      <Card title="Failed Payments" actualValue="1100" simulatedValue="601" />
      <Card title="Revenue" actualValue="$ 67,453,080" simulatedValue="$ 78,453,080" />
    </div>
  }
}
module Overview = {
  @react.component
  let make = () => {
    <div className="flex flex-col gap-6">
      <div className="text-nd_gray-600 font-semibold"> {"Overview"->React.string} </div>
      <MetricCards />
    </div>
  }
}

@react.component
let make = () => {
  open IntelligentRoutingHelper
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
    <PageUtils.PageHeading title="Intelligent Routing Uplift Analysis" />
    <div className="flex flex-col gap-12">
      <Overview />
      <div className="flex flex-col gap-6">
        <div className="text-nd_gray-600 font-semibold"> {"Insights"->React.string} </div>
        <div className="grid grid-cols-2 gap-4">
          <div className="border rounded-lg p-4">
            <LineGraph
              options={LineGraphUtils.getLineGraphOptions(lineGraphOptions)} className="mr-3"
            />
          </div>
          <div className="border rounded-lg p-4">
            <ColumnGraph options={ColumnGraphUtils.getColumnGraphOptions(columnGraphOptions)} />
          </div>
        </div>
      </div>
      <TransactionsTable />
    </div>
  </PageLoaderWrapper>
}
