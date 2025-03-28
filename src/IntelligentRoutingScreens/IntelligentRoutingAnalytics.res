module GetProductionAccess = {
  @react.component
  let make = () => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let {isProdIntentCompleted, setShowProdIntentForm} = React.useContext(
      GlobalProvider.defaultContext,
    )
    let isProdIntent = isProdIntentCompleted->Option.getOr(false)
    let productionAccessString = isProdIntent
      ? "Production Access Requested"
      : "Get Production Access"

    switch isProdIntentCompleted {
    | Some(_) =>
      <Button
        text=productionAccessString
        buttonType=Primary
        buttonSize=Medium
        buttonState=Normal
        onClick={_ => {
          if !isProdIntent {
            setShowProdIntentForm(_ => true)
            mixpanelEvent(~eventName="intelligent_routing_get_production_access")
          }
        }}
      />
    | None =>
      <Shimmer
        styleClass="h-10 px-4 py-3 m-2 ml-2 mb-3 dark:bg-black bg-white rounded" shimmerType={Small}
      />
    }
  }
}

module TransactionsTable = {
  @react.component
  let make = (~setTimeRange) => {
    open APIUtils
    open LogicUtils
    open IntelligentRoutingTypes
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let showToast = ToastState.useShowToast()
    let (tableData, setTableData) = React.useState(() => [])
    let (offset, setOffset) = React.useState(() => 0)
    let (totalCount, setTotalCount) = React.useState(_ => 0)
    let (tabIndex, setTabIndex) = React.useState(_ => 0)
    let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Loading)
    let limit = 50

    let fetchTableData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(
          ~entityName=V1(INTELLIGENT_ROUTING_RECORDS),
          ~methodType=Get,
          ~queryParamerters=Some(`limit=${limit->Int.toString}&offset=${offset->Int.toString}`),
        )
        let res = await fetchDetails(url)

        let total = res->getDictFromJsonObject->getInt("total_payment_count", 0)
        let arr = res->getDictFromJsonObject->getArrayFromDict("simulation_outcome_of_each_txn", [])

        let data =
          arr
          ->JSON.Encode.array
          ->getArrayDataFromJson(IntelligentRoutingTransactionsEntity.itemToObjectMapper)

        data->Array.sort((t1, t2) => {
          let t1 = t1.created_at
          let t2 = t2.created_at

          t1 <= t2 ? -1. : 1.
        })

        let minDate = switch data->Array.get(0) {
        | Some(txn) => txn.created_at
        | None => ""
        }
        let _maxDate = switch data->Array.get(data->Array.length - 1) {
        | Some(txn) => txn.created_at
        | None => ""
        }
        setTimeRange(prev => {...prev, minDate})

        if total <= offset {
          setOffset(_ => 0)
        }
        if total > 0 {
          let dataDictArr = arr->Belt.Array.keepMap(JSON.Decode.object)

          let arr = Array.make(~length=offset, Dict.make())
          let txnData =
            arr
            ->Array.concat(dataDictArr)
            ->Array.map(IntelligentRoutingTransactionsEntity.itemToObjectMapper)

          let list = txnData->Array.map(Nullable.make)
          setTotalCount(_ => total)
          setTableData(_ => list)
        }

        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => {
          setScreenState(_ => PageLoaderWrapper.Loading)
          showToast(~message="Failed to fetch transaction details", ~toastType=ToastError)
        }
      }
    }

    React.useEffect(() => {
      fetchTableData()->ignore
      None
    }, [offset])

    let table = data =>
      <LoadedTable
        title=" "
        hideTitle=true
        actualData=data
        totalResults=totalCount
        resultsPerPage=10
        offset
        setOffset
        entity={IntelligentRoutingTransactionsEntity.transactionDetailsEntity()}
        currrentFetchCount={data->Array.length}
        tableheadingClass="h-12"
        tableHeadingTextClass="!font-normal"
        nonFrozenTableParentClass="!rounded-lg"
        loadedTableParentClass="flex flex-col pt-6"
      />

    let failedTxnTableData = tableData->Array.filter(txn =>
      switch txn->Nullable.toOption {
      | Some(transaction) => transaction.payment_status === false
      | None => false
      }
    )

    let tabs: array<Tabs.tab> = React.useMemo(() => {
      open Tabs
      [
        {
          title: "All",
          renderContent: () => {table(tableData)},
        },
        {
          title: "Failed",
          renderContent: () => {table(failedTxnTableData)},
        },
      ]
    }, [tableData])

    <PageLoaderWrapper screenState={screenState}>
      <div className="flex flex-col gap-2">
        <div className="text-nd_gray-600 font-semibold">
          {"Transactions Details"->React.string}
        </div>
        <Tabs
          initialIndex={tabIndex >= 0 ? tabIndex : 0}
          tabs
          showBorder=true
          includeMargin=false
          defaultClasses="!w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
          onTitleClick={index => {
            setTabIndex(_ => index)
          }}
          selectTabBottomBorderColor="bg-primary"
          customBottomBorderColor="bg-nd_gray-150"
        />
      </div>
    </PageLoaderWrapper>
  }
}

module Card = {
  @react.component
  let make = (
    ~title: string,
    ~actualValue: float,
    ~simulatedValue: float,
    ~valueFormat=false,
    ~statType=LogicUtilsTypes.Default,
    ~currency="",
    ~amountFormat=false,
  ) => {
    open LogicUtils

    let displayValue = value =>
      switch (amountFormat, valueFormat) {
      | (true, false) => value->Float.toInt->formatAmount(currency)
      | (false, true) => value->valueFormatter(statType, ~currency)
      | (_, _) => value->valueFormatter(statType, ~currency)
      }

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
        <p className={textColor}> {value->valueFormatter(Rate)->React.string} </p>
      </div>
    }

    <div className="flex flex-col gap-6 items-start border rounded-xl border-nd_gray-150 p-4">
      <div className="w-full flex items-center justify-between">
        <p className="text-nd_gray-500 text-md leading-4 font-medium"> {title->React.string} </p>
      </div>
      <div className="w-full flex gap-6">
        <div className="w-full flex flex-col gap-2 items-start justify-between">
          <p className="text-nd_gray-400 text-sm leading-4 font-medium">
            {"Without Intelligence"->React.string}
          </p>
          <p className="text-nd_gray-500 font-semibold leading-8 text-lg text-nowrap">
            {displayValue(actualValue)->React.string}
          </p>
        </div>
        <div className="w-full flex flex-col gap-2 items-start justify-between">
          <p className="text-nd_gray-400 text-sm leading-4 font-medium">
            {"With Intelligence"->React.string}
          </p>
          <div className="flex gap-4">
            <p className="text-nd_gray-700 font-semibold leading-8 text-lg text-nowrap">
              {displayValue(simulatedValue)->React.string}
            </p>
            <div
              className="flex items-center gap-1 text-green-800 bg-green-200 rounded-md px-2 text-sm leading-1">
              {getPercentageChange(~primaryValue=simulatedValue, ~secondaryValue=actualValue)}
            </div>
          </div>
        </div>
      </div>
    </div>
  }
}

module MetricCards = {
  @react.component
  let make = (~data) => {
    let dataTyped = data->IntelligentRoutingUtils.responseMapper
    let authorizationRate = dataTyped.overall_success_rate
    let faar = dataTyped.faar

    <div className="grid grid-cols-2 gap-6">
      <Card
        title="Authorization Rate"
        actualValue={authorizationRate.baseline}
        simulatedValue={authorizationRate.model}
        valueFormat=true
        statType=Rate
      />
      <Card
        title="First Attempt Authorization Rate (FAAR)"
        actualValue={faar.baseline}
        simulatedValue={faar.model}
        valueFormat=true
        statType=Rate
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
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Success)
  let (stats, setStats) = React.useState(_ => JSON.Encode.null)
  let (selectedGateway, setSelectedGateway) = React.useState(() => "")
  let (gateways, setGateways) = React.useState(() => [])
  let (timeRange, setTimeRange) = React.useState(() => defaultTimeRange)

  let getStatistics = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(INTELLIGENT_ROUTING_GET_STATISTICS), ~methodType=Get)
      let response = await fetchDetails(url)
      setStats(_ => response)
      let statsData = (response->IntelligentRoutingUtils.responseMapper).time_series_data
      let gatewayData = switch statsData->Array.get(0) {
      | Some(statsData) => statsData.volume_distribution_as_per_sr
      | None => JSON.Encode.null
      }

      statsData->Array.sort((t1, t2) => {
        let t1 = t1.time_stamp
        let t2 = t2.time_stamp

        t1 <= t2 ? -1. : 1.
      })
      let minDate = switch statsData->Array.get(0) {
      | Some(txn) => txn.time_stamp
      | None => ""
      }
      let maxDate = switch statsData->Array.get(statsData->Array.length - 1) {
      | Some(txn) => txn.time_stamp
      | None => ""
      }
      setTimeRange(_ => {minDate, maxDate})

      let gatewayKeys =
        gatewayData
        ->LogicUtils.getDictFromJsonObject
        ->Dict.keysToArray
      gatewayKeys->Array.sort((key1, key2) => {
        key1 <= key2 ? -1. : 1.
      })
      setGateways(_ => gatewayKeys)
      setSelectedGateway(_ => gatewayKeys->Array.get(0)->Option.getOr(""))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => {
        setScreenState(_ => PageLoaderWrapper.Success)
        showToast(~message="Failed to fetch statistics data", ~toastType=ToastError)
      }
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
      setSelectedGateway(_ => value)
    },
    onFocus: _ => (),
    value: selectedGateway->JSON.Encode.string,
    checked: true,
  }

  let dateRange = displayDateRange(~minDate=timeRange.minDate, ~maxDate=timeRange.maxDate)

  let _infoBanner =
    <div
      className=" top-76-px left-0 w-full py-3 px-4 bg-nd_primary_blue-50 flex justify-between items-center rounded-md">
      <div className="flex gap-4 items-center">
        <Icon name="nd-warning" />
        <div className="text-nd_gray-600 text-base !leading-6 font-medium">
          <span> {"Our Intelligent system made "->React.string} </span>
          <span className="font-bold"> {"6890"->React.string} </span>
          <span>
            {" (9.2%) switches from primary processor to an alternate processor."->React.string}
          </span>
        </div>
      </div>
    </div>

  <PageLoaderWrapper screenState={screenState}>
    <div
      className="absolute z-10 top-76-px left-0 w-full py-3 px-10 bg-orange-50 flex justify-between items-center">
      <div className="flex gap-4 items-center">
        <Icon name="nd-information-triangle" size=24 />
        <p className="text-nd_gray-600 text-base leading-6 font-medium">
          {"You are in demo environment and this is sample setup."->React.string}
        </p>
      </div>
      <GetProductionAccess />
    </div>
    <div className="mt-10">
      <div className="flex items-center justify-between">
        <PageUtils.PageHeading title="Intelligent Routing Uplift Analysis" />
        <p className="text-nd_gray-500 font-medium"> {dateRange->React.string} </p>
      </div>
      <div className="flex flex-col gap-12">
        <Overview data=stats />
        // {infoBanner}
        <div className="flex flex-col gap-6">
          <div className="text-nd_gray-600 font-semibold"> {"Insights"->React.string} </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col border rounded-lg p-4">
              <div className="flex justify-between">
                <p className="text-fs-14 text-nd_gray-600">
                  {"Overall Transaction Distribution"->React.string}
                </p>
                <div className="flex flex-col xl:flex-row gap-4">
                  {displayLegend(gateways)->React.array}
                </div>
              </div>
              <div className="h-full flex flex-col xl:flex-row items-center justify-between gap-1">
                <PieGraph
                  options={PieGraphUtils.getPieChartOptions(pieGraphOptionsActual(stats))}
                />
                <PieGraph
                  options={PieGraphUtils.getPieChartOptions(pieGraphOptionsSimulated(stats))}
                />
              </div>
            </div>
            <div className="border rounded-lg p-4">
              <LineGraph options={LineGraphUtils.getLineGraphOptions(lineGraphOptions(stats))} />
            </div>
          </div>
          <div className="border rounded-lg p-4 flex flex-col ">
            <div className="relative">
              <div className="!w-full flex justify-end absolute z-10 top-0 right-0 left-0">
                <SelectBox.BaseDropdown
                  allowMultiSelect=false
                  buttonText="Select PSP"
                  input
                  deselectDisable=true
                  customButtonStyle="!rounded-lg"
                  options={makeOption(gateways)}
                  marginTop="mt-10"
                  hideMultiSelectButtons=true
                  addButton=false
                  fullLength=true
                  shouldDisplaySelectedOnTop=true
                  customSelectionIcon={CustomIcon(<Icon name="nd-check" />)}
                />
              </div>
            </div>
            <LineAndColumnGraph
              options={LineAndColumnGraphUtils.getLineColumnGraphOptions(
                lineColumnGraphOptions(stats, ~processor=selectedGateway),
              )}
            />
          </div>
        </div>
        <TransactionsTable setTimeRange />
      </div>
    </div>
  </PageLoaderWrapper>
}
