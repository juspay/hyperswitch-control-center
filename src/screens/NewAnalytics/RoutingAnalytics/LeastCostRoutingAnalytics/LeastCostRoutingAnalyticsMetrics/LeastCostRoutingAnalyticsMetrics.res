open Typography

module LeastCostAnalyticsBasicMetricsCard = {
  open APIUtils
  open LogicUtils
  open LeastCostRoutingAnalyticsMetricsTypes
  open LeastCostRoutingAnalyticsMetricsUtils
  open LeastCostRoutingAnalyticsTypes

  @react.component
  let make = () => {
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let startTimeVal = filterValueJson->getString("startTime", "")
    let endTimeVal = filterValueJson->getString("endTime", "")
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let (metricsDataResponse, setMetricsDataResponse) = React.useState(_ =>
      Dict.make()->metricsQueryDataItemToObjMapper
    )

    let getData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)

        let url = getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Post, ~id=Some("payments"))

        let body =
          [
            AnalyticsUtils.getFilterRequestBody(
              ~metrics=Some([(#sessionized_debit_routing: requestPayloadMetrics :> string)]),
              ~delta=true,
              ~startDateTime=startTimeVal,
              ~endDateTime=endTimeVal,
              ~filter=Some(LeastCostRoutingAnalyticsUtils.filterDict),
            )->JSON.Encode.object,
          ]->JSON.Encode.array

        let response = await updateDetails(url, body, Post)

        let responseObj =
          response
          ->getDictFromJsonObject
          ->getArrayFromDict("queryData", [])
          ->basicsMetricsMapper

        setMetricsDataResponse(_ => responseObj)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Custom)
      }
    }

    React.useEffect(_ => {
      if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
        getData()->ignore
      }
      None
    }, (startTimeVal, endTimeVal))

    <div className="grid md:grid-cols-2 gap-4">
      <PageLoaderWrapper
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-[84px]" />}
        customLoader={<Shimmer styleClass="h-[84px] w-full rounded-xl" />}>
        <div
          className="flex flex-col border rounded-xl p-4 bg-white shadow-xs border-nd_gray-200 gap-6 2xl:gap-2">
          <p className={`${body.md.medium} text-nd_gray-400`}> {"Total Savings"->React.string} </p>
          <p className={`${heading.md.semibold} text-nd_gray-800`}>
            {`${(metricsDataResponse.debit_routing_savings_in_usd /. 100.0)
                ->valueFormatter(AmountWithSuffix, ~currency="$")} `->React.string}
          </p>
        </div>
      </PageLoaderWrapper>
      <PageLoaderWrapper
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-[84px]" />}
        customLoader={<Shimmer styleClass="h-[84px] w-full rounded-xl" />}>
        <div
          className="flex flex-col border rounded-xl p-4 bg-white shadow-xs border-nd_gray-200 gap-6 2xl:gap-2">
          <p className={`${body.md.medium} text-nd_gray-400`}>
            {"Debit Routed Transactions"->React.string}
          </p>
          <p className={`${heading.md.semibold} text-nd_gray-800`}>
            {metricsDataResponse.debit_routed_transaction_count->Int.toString->React.string}
          </p>
        </div>
      </PageLoaderWrapper>
    </div>
  }
}

module LeastCostAnalyticsRegulationMetricsCard = {
  open APIUtils
  open LogicUtils
  open LeastCostRoutingAnalyticsMetricsUtils
  open LeastCostRoutingAnalyticsTypes

  @react.component
  let make = () => {
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let startTimeVal = filterValueJson->getString("startTime", "")
    let endTimeVal = filterValueJson->getString("endTime", "")
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let (metricsDataResponse, setMetricsDataResponse) = React.useState(_ => [
      Dict.make()->metricsQueryDataItemToObjMapper,
    ])

    let getData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)

        let url = getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Post, ~id=Some("payments"))

        let body =
          [
            AnalyticsUtils.getFilterRequestBody(
              ~metrics=Some([(#sessionized_debit_routing: requestPayloadMetrics :> string)]),
              ~delta=true,
              ~startDateTime=startTimeVal,
              ~endDateTime=endTimeVal,
              ~filter=Some(LeastCostRoutingAnalyticsUtils.filterDict),
              ~groupByNames=Some([(#is_issuer_regulated: requestPayloadMetrics :> string)]),
            )->JSON.Encode.object,
          ]->JSON.Encode.array

        let response = await updateDetails(url, body, Post)
        let responseObj =
          response
          ->getDictFromJsonObject
          ->getArrayFromDict("queryData", [])
          ->Array.map(item => item->getDictFromJsonObject->metricsQueryDataItemToObjMapper)

        setMetricsDataResponse(_ => responseObj)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Custom)
      }
    }

    React.useEffect(_ => {
      if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
        getData()->ignore
      }
      None
    }, (startTimeVal, endTimeVal))

    let (regulatedPercentage, unregulatedPercentage) = React.useMemo(() => {
      calculateRegulatedPercentages(metricsDataResponse)
    }, [metricsDataResponse])

    <div className="grid md:grid-cols-2 gap-4">
      <PageLoaderWrapper
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-[84px]" />}
        customLoader={<Shimmer styleClass="h-[84px] w-full rounded-xl" />}>
        <div
          className="flex flex-col border rounded-xl p-4 bg-white shadow-xs border-nd_gray-200 gap-2">
          <p className={`${body.md.medium} text-nd_gray-400`}>
            {"Regulated Transactions Percentage"->React.string}
          </p>
          <p className={`${heading.md.semibold} text-nd_gray-800`}>
            {regulatedPercentage->valueFormatter(Rate)->React.string}
          </p>
        </div>
      </PageLoaderWrapper>
      <PageLoaderWrapper
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-[84px]" />}
        customLoader={<Shimmer styleClass="h-[84px] w-full rounded-xl" />}>
        <div
          className="flex flex-col border rounded-xl p-4 bg-white shadow-xs border-nd_gray-200 gap-2">
          <p className={`${body.md.medium} text-nd_gray-400`}>
            {"Unregulated Transactions Percentage"->React.string}
          </p>
          <p className={`${heading.md.semibold} text-nd_gray-800`}>
            {unregulatedPercentage->valueFormatter(Rate)->React.string}
          </p>
        </div>
      </PageLoaderWrapper>
    </div>
  }
}

@react.component
let make = () => {
  <div className="grid md:grid-cols-2 gap-6 mt-12">
    <LeastCostAnalyticsBasicMetricsCard />
    <LeastCostAnalyticsRegulationMetricsCard />
  </div>
}
