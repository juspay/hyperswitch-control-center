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
          "txn_no": 12,
          "payment_intent_id": "AF575HMAG08321",
          "payment_attempt_id": "merchant1-AF575HMAG08321-1",
          "amount": 407.56,
          "payment_gateway": "PSP11",
          "payment_status": true,
          "created_at": "2025-03-10T12:25:00Z",
          "payment_method_type": "APPLEPAY",
          "order_currency": "USD",
          "model_connector": "PSP2",
          "suggested_uplift": 5.9,
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
    let getPercentageChange = (~primaryValue, ~secondaryValue) => {
      let (value, direction) = NewAnalyticsUtils.calculatePercentageChange(
        ~primaryValue,
        ~secondaryValue,
      )

      let (textColor, icon) = switch direction {
      | Upward => ("#12B76A", "nd-arrow-up-no-underline")
      | Downward => ("#F04E42", "nd-arrow-down-no-underline")
      | No_Change => ("#A0A0A0", "")
      }

      <div className={`flex gap-2`}>
        <Icon name={icon} size=12 />
        <p className={textColor}> {value->LogicUtils.valueFormatter(Rate)->React.string} </p>
      </div>
    }

    <div className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 p-4">
      <div className="w-full flex items-center justify-between">
        <p className="text-nd_gray-500 text-md leading-4 font-medium"> {title->React.string} </p>
        <div className="flex gap-1 text-green-800 bg-green-200 rounded-md px-2">
          {getPercentageChange(
            ~primaryValue=simulatedValue->Float.fromString->Option.getOr(0.0),
            ~secondaryValue=actualValue->Float.fromString->Option.getOr(0.0),
          )}
        </div>
      </div>
      <div className="w-full flex items-center justify-between">
        <p className="text-nd_gray-400 text-sm leading-4 font-medium"> {"Actual"->React.string} </p>
        <p className="text-nd_gray-500 font-semibold leading-8 text-lg text-nowrap">
          {actualValue->React.string}
        </p>
      </div>
      <div className="w-full flex items-center justify-between">
        <p className="text-nd_gray-400 text-sm leading-4 font-medium">
          {"Simulated"->React.string}
        </p>
        <p className="text-nd_gray-700 font-semibold leading-8 text-lg text-nowrap">
          {simulatedValue->React.string}
        </p>
      </div>
    </div>
  }
}

module MetricCards = {
  @react.component
  let make = (~data) => {
    open LogicUtils

    let dataTyped = data->IntelligentRoutingUtils.responseMapper
    let authorizationRate = dataTyped.overall_success_rate
    let failedPayments = dataTyped.total_failed_payments
    let revenue = dataTyped.total_revenue
    let faar = dataTyped.faar

    <div className="grid grid-cols-2 xl:grid-cols-4 gap-6">
      <Card
        title="Authorization Rate"
        actualValue={authorizationRate.baseline->valueFormatter(Rate)}
        simulatedValue={authorizationRate.model->valueFormatter(Rate)}
      />
      <Card
        title="FAAR"
        actualValue={faar.baseline->valueFormatter(Rate)}
        simulatedValue={faar.model->valueFormatter(Rate)}
      />
      <Card
        title="Failed Payments"
        actualValue={failedPayments.baseline->Float.toInt->formatAmount("$")}
        simulatedValue={failedPayments.model->Float.toInt->formatAmount("$")}
      />
      <Card
        title="Revenue"
        actualValue={revenue.baseline->Float.toInt->formatAmount("$")}
        simulatedValue={revenue.model->Float.toInt->formatAmount("$")}
      />
    </div>
  }
}
module Overview = {
  @react.component
  let make = (~data) => {
    <div className="mt-10">
      <MetricCards data />
    </div>
  }
}

@react.component
let make = () => {
  open IntelligentRoutingHelper
  open APIUtils
  let getURL = useGetURL()
  let _fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, _setScreenState) = React.useState(() => PageLoaderWrapper.Success)
  let (stats, setStats) = React.useState(_ => JSON.Encode.null)
  let (selectedPSP, setSelectedPSP) = React.useState(() => "")
  let (keys, setKeys) = React.useState(() => [])

  let getStatistics = async () => {
    try {
      let _url = getURL(~entityName=V1(INTELLIGENT_ROUTING_GET_STATISTICS), ~methodType=Get)
      // let res = await fetchDetails(url)
      let response = IntelligentRoutingStatsResponse.response
      setStats(_ => response)
      let statsData =
        (response->IntelligentRoutingUtils.responseMapper).time_series_data->Array.get(0)
      let psps = switch statsData {
      | Some(statsData) => statsData.volume_distribution_as_per_sr
      | None => JSON.Encode.null
      }
      let keys = psps->LogicUtils.getDictFromJsonObject->Dict.keysToArray
      setKeys(_ => keys)
      setSelectedPSP(_ => keys->Array.get(0)->Option.getOr(""))
    } catch {
    | _ => showToast(~message="Failed to fetch statistics data", ~toastType=ToastError)
    }
  }

  React.useEffect(() => {
    setShowSideBar(_ => true)
    getStatistics()->ignore
    None
  }, [])

  let makeOption = (keys): array<SelectBox.dropdownOption> => {
    keys->Array.map(key => {
      let options: SelectBox.dropdownOption = {label: key, value: key}
      options
    })
  }

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: ev => {
      let value = ev->Identity.formReactEventToString
      setSelectedPSP(_ => value)
    },
    onFocus: _ => (),
    value: selectedPSP->JSON.Encode.string,
    checked: true,
  }

  <PageLoaderWrapper screenState={screenState}>
    <div
      className="absolute z-10 top-76-px left-0 w-full py-3 px-10 bg-orange-50 flex justify-between items-center">
      <div className="flex gap-4 items-center">
        <Icon name="nd-information-triangle" size=24 />
        <p className="text-nd_gray-600 text-base leading-6 font-medium">
          {"You are in demo environment and this is sample setup."->React.string}
        </p>
      </div>
      <Button
        text="Get Production Access"
        buttonType=Primary
        buttonSize=Medium
        buttonState=Normal
        onClick={_ => ()}
      />
    </div>
    <div className="mt-10">
      <PageUtils.PageHeading title="Intelligent Routing Uplift Analysis" />
      <div className="flex flex-col gap-12">
        <Overview data=stats />
        <div className="flex flex-col gap-6">
          <div className="text-nd_gray-600 font-semibold"> {"Insights"->React.string} </div>
          <div className="border rounded-lg p-4 flex flex-col ">
            <div className="!w-full flex justify-end">
              <SelectBox.BaseDropdown
                allowMultiSelect=false
                buttonText="Select PSP"
                input
                deselectDisable=true
                customButtonStyle="!rounded-lg"
                options={makeOption(keys)}
                marginTop="mt-10"
                hideMultiSelectButtons=true
                addButton=false
                fullLength=true
                shouldDisplaySelectedOnTop=true
                customSelectionIcon={CustomIcon(<Icon name="nd-check" />)}
              />
            </div>
            <LineAndColumnGraph
              options={LineAndColumnGraphUtils.getLineColumnGraphOptions(
                lineColumnGraphOptions(stats, ~processor=selectedPSP),
              )}
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="border rounded-lg p-4">
              <LineGraph
                options={LineGraphUtils.getLineGraphOptions(lineGraphOptions(stats))}
                className="mr-3"
              />
            </div>
            <div className="border rounded-lg p-4">
              <ColumnGraph
                options={ColumnGraphUtils.getColumnGraphOptions(columnGraphOptions(stats))}
              />
            </div>
          </div>
        </div>
        <TransactionsTable />
      </div>
    </div>
  </PageLoaderWrapper>
}
