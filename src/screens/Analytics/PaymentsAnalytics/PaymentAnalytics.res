@react.component
let make = () => {
  open LogicUtils
  open Promise
  open PaymentAnalyticsEntity
  open APIUtils
  open HSAnalyticsUtils
  let updateDetails = useUpdateMethod()
  let defaultFilters = [startTimeFilterKey, endTimeFilterKey]
  let (filterDataJson, setFilterDataJson) = React.useState(_ => None)
  let {updateExistingKeys, filterValueJson} = React.useContext(FilterContext.filterContext)
  let filterData = filterDataJson->Option.getOr(Dict.make()->JSON.Encode.object)
  let getURL = useGetURL()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (metrics, setMetrics) = React.useState(_ => [])
  let (dimensions, setDimensions) = React.useState(_ => [])
  let fetchDetails = useGetMethod()
  let {updateAnalytcisEntity} = OMPSwitchHooks.useUserInfo()
  let {userInfo: {analyticsEntity}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )

  let loadInfo = async () => {
    try {
      let infoUrl = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Get, ~id=Some(domain))
      let infoDetails = await fetchDetails(infoUrl)
      setMetrics(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("metrics", []))
      setDimensions(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("dimensions", []))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }
  let getPaymetsDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let paymentUrl = getURL(~entityName=ORDERS, ~methodType=Get)
      let paymentDetails = await fetchDetails(paymentUrl)
      let data = paymentDetails->getDictFromJsonObject->getArrayFromDict("data", [])
      if data->Array.length < 0 {
        setScreenState(_ => PageLoaderWrapper.Custom)
      } else {
        await loadInfo()
      }
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  let generalMetrics = [
    "payment_success_rate",
    "payment_count",
    "payment_success_count",
    "connector_success_rate",
  ]
  let analyticsAmountMetrics = [
    "payment_success_rate",
    "avg_ticket_size",
    "payment_processed_amount",
  ]

  let formatMetrics = arrMetrics => {
    arrMetrics->Array.map(metric => {
      [
        ("name", metric->JSON.Encode.string),
        ("desc", ""->JSON.Encode.string),
      ]->LogicUtils.getJsonFromArrayOfJson
    })
  }

  React.useEffect(() => {
    getPaymetsDetails()->ignore
    None
  }, [])

  let tabKeys = getStringListFromArrayDict(dimensions)
  let tabValues =
    tabKeys
    ->Array.mapWithIndex((key, index) => {
      let a: DynamicTabs.tab = if key === "payment_method_type" {
        {
          title: "Payment Method + Payment Method Type",
          value: "payment_method,payment_method_type",
          isRemovable: index > 2,
        }
      } else {
        {
          title: key->LogicUtils.snakeToTitle,
          value: key,
          isRemovable: index > 2,
        }
      }
      a
    })
    ->Array.concat([
      {
        title: "Payment Method Type",
        value: "payment_method_type",
        isRemovable: true,
      },
    ])

  let formatData = (data: array<RescriptCore.Nullable.t<AnalyticsTypes.paymentTableType>>) => {
    let actualdata =
      data
      ->Array.map(Nullable.toOption)
      ->Array.reduce([], (arr, value) => {
        switch value {
        | Some(val) => arr->Array.concat([val])
        | _ => arr
        }
      })

    actualdata->Array.sort((a, b) => {
      let success_count_a = a.payment_success_count
      let success_count_b = b.payment_success_count

      success_count_a <= success_count_b ? 1. : -1.
    })

    actualdata->Array.map(Nullable.make)
  }

  let title = "Payments Analytics"

  let formaPayload = (singleStatBodyEntity: DynamicSingleStat.singleStatBodyEntity) => {
    [
      AnalyticsUtils.getFilterRequestBody(
        ~filter=singleStatBodyEntity.filter,
        ~metrics=singleStatBodyEntity.metrics,
        ~delta=?singleStatBodyEntity.delta,
        ~startDateTime=singleStatBodyEntity.startDateTime,
        ~endDateTime=singleStatBodyEntity.endDateTime,
        ~mode=singleStatBodyEntity.mode,
        ~groupByNames=Some(["currency"]),
        ~customFilter=?singleStatBodyEntity.customFilter,
        ~source=?singleStatBodyEntity.source,
        ~granularity=singleStatBodyEntity.granularity,
        ~prefix=singleStatBodyEntity.prefix,
      )->JSON.Encode.object,
    ]
    ->JSON.Encode.array
    ->JSON.stringify
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="analytics",
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")

  let analyticsfilterUrl = getURL(~entityName=ANALYTICS_FILTERS, ~methodType=Post, ~id=Some(domain))
  let paymentAnalyticsUrl = getURL(
    ~entityName=ANALYTICS_PAYMENTS,
    ~methodType=Post,
    ~id=Some(domain),
  )

  let filterBody = React.useMemo(() => {
    let filterBodyEntity: AnalyticsUtils.filterBodyEntity = {
      startTime: startTimeVal,
      endTime: endTimeVal,
      groupByNames: tabKeys,
      source: "BATCH",
    }
    AnalyticsUtils.filterBody(filterBodyEntity)
  }, (startTimeVal, endTimeVal, tabKeys->Array.joinWith(",")))

  let body = filterBody->JSON.Encode.object

  React.useEffect(() => {
    setFilterDataJson(_ => None)
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      try {
        updateDetails(analyticsfilterUrl, body, Post)
        ->thenResolve(json => setFilterDataJson(_ => Some(json)))
        ->catch(_ => resolve())
        ->ignore
      } catch {
      | _ => ()
      }
    }
    None
  }, (startTimeVal, endTimeVal, body->JSON.stringify))

  let topFilterUi = switch filterDataJson {
  | Some(filterData) =>
    <div className="flex flex-row">
      <DynamicFilter
        initialFilters={initialFilterFields(filterData)}
        options=[]
        popupFilterFields={options(filterData)}
        initialFixedFilters={initialFixedFilterFields(filterData)}
        defaultFilterKeys=defaultFilters
        tabNames=tabKeys
        updateUrlWith=updateExistingKeys
        key="0"
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
  | None =>
    <div className="flex flex-row">
      <DynamicFilter
        initialFilters=[]
        options=[]
        popupFilterFields=[]
        initialFixedFilters={initialFixedFilterFields(filterData)}
        defaultFilterKeys=defaultFilters
        tabNames=tabKeys
        updateUrlWith=updateExistingKeys //
        key="1"
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
  }

  open AnalyticsNew
  <PageLoaderWrapper screenState customUI={<NoData title />}>
    <div className="flex flex-col gap-5">
      <div className="flex items-center justify-between ">
        <PageUtils.PageHeading title />
        <OMPSwitchHelper.OMPViews
          views={OMPSwitchUtils.analyticsViewList(~checkUserEntity)}
          selectedEntity={analyticsEntity}
          onChange={updateAnalytcisEntity}
        />
      </div>
      <div
        className="-ml-1 sticky top-0 z-10 p-1 bg-hyperswitch_background py-3 -mt-3 rounded-lg border">
        topFilterUi
      </div>
      <div className="flex flex-col gap-14">
        <MetricsState
          heading="Payments Overview"
          singleStatEntity={getSingleStatEntity(
            generalMetrics->formatMetrics,
            generalMetricsColumns,
            ~uri=paymentAnalyticsUrl,
          )}
          filterKeys=tabKeys
          startTimeFilterKey
          endTimeFilterKey
          moduleName="general_metrics"
        />
        <MetricsState
          heading="Amount Metrics"
          singleStatEntity={getSingleStatEntity(
            analyticsAmountMetrics->formatMetrics,
            amountMetricsColumns,
            ~uri=paymentAnalyticsUrl,
          )}
          filterKeys=tabKeys
          startTimeFilterKey
          endTimeFilterKey
          moduleName="payments_analytics_amount"
          formaPayload
        />
        <SmartRetryAnalytics filterKeys=tabKeys moduleName="payments_smart_retries" />
        <OverallSummary
          filteredTabVales=tabValues
          moduleName="overall_summary"
          filteredTabKeys={tabKeys}
          chartEntity={chartEntity(tabKeys, ~uri=paymentAnalyticsUrl)}
          defaultSort="total_volume"
          getTable={getPaymentTable}
          colMapper
          distributionArray={Some([distribution])}
          tableEntity={Some(paymentTableEntity(~uri=paymentAnalyticsUrl))}
          deltaMetrics={getStringListFromArrayDict(metrics)}
          deltaArray=[]
          tableGlobalFilter=filterByData
          weeklyTableMetricsCols
          formatData={Some(formatData)}
          startTimeFilterKey
          endTimeFilterKey
          heading="Payments Trends"
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
