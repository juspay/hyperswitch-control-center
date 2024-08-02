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
  let {generateReport} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let loadInfo = async () => {
    try {
      let infoUrl = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Get, ~id=Some(domain), ())
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
      let paymentUrl = getURL(~entityName=ORDERS, ~methodType=Get, ())
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
  let subTitle = "Gain Insights, monitor performance and make Informed Decisions with Payment Analytics."

  let formaPayload = (singleStatBodyEntity: DynamicSingleStat.singleStatBodyEntity) => {
    [
      AnalyticsUtils.getFilterRequestBody(
        ~filter=singleStatBodyEntity.filter,
        ~metrics=singleStatBodyEntity.metrics,
        ~delta=?singleStatBodyEntity.delta,
        ~startDateTime=singleStatBodyEntity.startDateTime,
        ~endDateTime=singleStatBodyEntity.endDateTime,
        ~mode=singleStatBodyEntity.mode,
        ~groupByNames=["currency"]->Some,
        ~customFilter=?singleStatBodyEntity.customFilter,
        ~source=?singleStatBodyEntity.source,
        ~granularity=singleStatBodyEntity.granularity,
        ~prefix=singleStatBodyEntity.prefix,
        (),
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

  let filterUri = `${Window.env.apiBaseUrl}/analytics/v1/filters/${domain}`

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
        updateDetails(filterUri, body, Post, ())
        ->thenResolve(json => setFilterDataJson(_ => json->Some))
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
  <PageLoaderWrapper screenState customUI={<NoData title subTitle />}>
    <div className="flex flex-col gap-5">
      <div className="flex items-center justify-between ">
        <PageUtils.PageHeading title subTitle />
        <RenderIf condition={generateReport}>
          <GenerateReport entityName={PAYMENT_REPORT} />
        </RenderIf>
      </div>
      <div
        className="-ml-1 sticky top-0 z-30  p-1 bg-hyperswitch_background py-3 -mt-3 rounded-lg border">
        topFilterUi
      </div>
      <div className="flex flex-col gap-14">
        <MetricsState
          heading="Payments Overview"
          singleStatEntity={getSingleStatEntity(
            generalMetrics->formatMetrics,
            generalMetricsColumns,
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
          chartEntity={chartEntity(tabKeys)}
          defaultSort="total_volume"
          getTable={getPaymentTable}
          colMapper
          distributionArray={[distribution]->Some}
          tableEntity={paymentTableEntity()->Some}
          deltaMetrics={getStringListFromArrayDict(metrics)}
          deltaArray=[]
          tableGlobalFilter=filterByData
          weeklyTableMetricsCols
          formatData={formatData->Some}
          startTimeFilterKey
          endTimeFilterKey
          heading="Payments Trends"
        />
        // <PerformanceMonitor startTimeVal endTimeVal />
      </div>
    </div>
  </PageLoaderWrapper>
}
