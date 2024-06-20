open PaymentAnalyticsEntity
open APIUtils
open HSAnalyticsUtils

@react.component
let make = () => {
  let getURL = useGetURL()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (metrics, setMetrics) = React.useState(_ => [])
  let (dimensions, setDimensions) = React.useState(_ => [])
  let fetchDetails = useGetMethod()
  let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {generateReport} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let loadInfo = async () => {
    open LogicUtils
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
    open LogicUtils
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

  React.useEffect0(() => {
    getPaymetsDetails()->ignore
    None
  })

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

  open AnalyticsNew
  <PageLoaderWrapper screenState customUI={<NoData title subTitle />}>
    <div className="flex items-center justify-between">
      <PageUtils.PageHeading title subTitle />
      <UIUtils.RenderIf condition={generateReport}>
        <GenerateReport entityName={PAYMENT_REPORT} />
      </UIUtils.RenderIf>
    </div>
    <FilterContext
      key="payments_analytics_general_metrics" index="payments_analytics_general_metrics">
      <MetricsState
        singleStatEntity={getSingleStatEntity(metrics, !isLiveMode)}
        filterKeys=tabKeys
        startTimeFilterKey
        endTimeFilterKey
        moduleName="general_metrics"
        initialFilters=initialFilterFields
        options
        initialFixedFilters=initialFixedFilterFields
        tabKeys
        filterUri=Some(`${Window.env.apiBaseUrl}/analytics/v1/filters/${domain}`)
      />
    </FilterContext>
    <FilterContext
      key="payments_analytics_overall_summary" index="payments_analytics_overall_summary">
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
        tableUpdatedHeading=getUpdatedHeading
        tableGlobalFilter=filterByData
        weeklyTableMetricsCols
        formatData={formatData->Some}
        initialFilters=initialFilterFields
        options
        initialFixedFilters=initialFixedFilterFields
        tabKeys
        filterUri=Some(`${Window.env.apiBaseUrl}/analytics/v1/filters/${domain}`)
        startTimeFilterKey
        endTimeFilterKey
      />
    </FilterContext>
  </PageLoaderWrapper>
}
