open Typography

module RoutingAnalyticsCard = {
  open APIUtils
  open LogicUtils
  open RoutingAnalyticsMetricsTypes
  open RoutingAnalyticsMetricsUtils

  @react.component
  let make = (~metric: metrics) => {
    let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
    let startTimeVal = filterValueJson->getString("startTime", "")
    let endTimeVal = filterValueJson->getString("endTime", "")
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let (metricsDataResponse, setMetricsDataResponse) = React.useState(_ =>
      Dict.make()->metricsResponseItemToObjMapper
    )

    let getData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let (entityName, id) = getAPIURLFromMetricType(metric)
        let url = getURL(~entityName, ~methodType=Post, ~id=Some(id))

        switch metric {
        | #total_failure => {
            let localFilterValueJson = filterValueJson->Dict.copy
            localFilterValueJson->Dict.set("status", ["failure"]->getJsonFromArrayOfString)

            let failureRequestBody =
              [
                AnalyticsUtils.getFilterRequestBody(
                  ~metrics=Some(getMetricRequestPayloadFromMetricType(metric)),
                  ~delta=false,
                  ~startDateTime=startTimeVal,
                  ~endDateTime=endTimeVal,
                  ~filter=Some(localFilterValueJson->JSON.Encode.object),
                )->JSON.Encode.object,
              ]->JSON.Encode.array

            let failureResponse = await updateDetails(url, failureRequestBody, Post)
            let failureResponseObj =
              failureResponse->getDictFromJsonObject->metricsResponseItemToObjMapper
            let failureMetricsResponseObj =
              failureResponseObj.queryData->getValueFromArray(
                0,
                Dict.make()->metricsQueryDataItemToObjMapper,
              )

            let totalRequestBody =
              [
                AnalyticsUtils.getFilterRequestBody(
                  ~metrics=Some(getMetricRequestPayloadFromMetricType(metric)),
                  ~delta=false,
                  ~startDateTime=startTimeVal,
                  ~endDateTime=endTimeVal,
                  ~filter=Some(filterValueJson->JSON.Encode.object),
                )->JSON.Encode.object,
              ]->JSON.Encode.array

            let totalResponse = await updateDetails(url, totalRequestBody, Post)
            let totalResponseObj =
              totalResponse->getDictFromJsonObject->metricsResponseItemToObjMapper

            let totalMetricsResponseObj =
              totalResponseObj.queryData->getValueFromArray(
                0,
                Dict.make()->metricsQueryDataItemToObjMapper,
              )

            let combinedQueryData = {
              payment_success_rate: 0.0,
              payment_count: totalMetricsResponseObj.payment_count,
              payment_success_count: 0,
              payment_failed_count: failureMetricsResponseObj.payment_count,
            }

            let combinedResponse = {
              queryData: [combinedQueryData],
              metaData: totalResponseObj.metaData,
            }

            setMetricsDataResponse(_ => combinedResponse)
            setScreenState(_ => PageLoaderWrapper.Success)
          }
        | _ => {
            let body =
              [
                AnalyticsUtils.getFilterRequestBody(
                  ~metrics=Some(getMetricRequestPayloadFromMetricType(metric)),
                  ~delta=false,
                  ~startDateTime=startTimeVal,
                  ~endDateTime=endTimeVal,
                  ~filter=Some(filterValueJson->JSON.Encode.object),
                )->JSON.Encode.object,
              ]->JSON.Encode.array

            let response = await updateDetails(url, body, Post)
            let responseObj = response->getDictFromJsonObject->metricsResponseItemToObjMapper

            setMetricsDataResponse(_ => responseObj)
            setScreenState(_ => PageLoaderWrapper.Success)
          }
        }
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Custom)
      }
    }

    React.useEffect(_ => {
      if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
        getData()->ignore
      }
      None
    }, (startTimeVal, endTimeVal, filterValue))

    let firstQueryData = React.useMemo(() => {
      metricsDataResponse.queryData->getValueFromArray(
        0,
        Dict.make()->metricsQueryDataItemToObjMapper,
      )
    }, [metricsDataResponse.queryData])

    let firstMetadata = React.useMemo(() => {
      metricsDataResponse.metaData->getValueFromArray(
        0,
        Dict.make()->metricsMetadataItemToObjMapper,
      )
    }, [metricsDataResponse.metaData])

    <PageLoaderWrapper
      screenState
      customUI={<InsightsHelper.NoData height="h-32" />}
      customLoader={<Shimmer styleClass="h-32 w-full rounded-xl" />}>
      <div
        className="flex flex-col gap-4 border rounded-xl p-4 bg-white shadow-xs border-nd_gray-200">
        <p className={`${body.md.medium} text-nd_gray-400`}>
          {metric->getDisplayNameFromMetricType->React.string}
        </p>
        {switch metric {
        | #overall_authorization_rate =>
          <div className="flex flex-col gap-2">
            <p className={`${heading.md.semibold} text-nd_gray-800`}>
              {firstQueryData.payment_success_rate->valueFormatter(Rate)->React.string}
            </p>
            <p className={`${body.sm.medium} text-nd_gray-400`}>
              {"From all routing logics"->React.string}
            </p>
          </div>
        | #first_attempt_authorization_rate =>
          <div className="flex flex-col gap-2">
            <p className={`${heading.md.semibold} text-nd_gray-800`}>
              {firstMetadata.total_success_rate_without_smart_retries
              ->valueFormatter(Rate)
              ->React.string}
            </p>
            <p className={`${body.sm.medium} text-nd_gray-400`}>
              {"From all routing logics"->React.string}
            </p>
          </div>
        | #total_successful =>
          <div className="flex flex-col gap-2">
            <p className={`${heading.md.semibold} text-nd_gray-800`}>
              {firstQueryData.payment_success_count->Int.toString->React.string}
            </p>
            <p className={`${body.sm.medium} text-nd_gray-400`}>
              {`Out of ${firstQueryData.payment_count->Int.toString} transactions`->React.string}
            </p>
          </div>
        | #total_failure =>
          <div className="flex flex-col gap-2">
            <p className={`${heading.md.semibold} text-nd_gray-800`}>
              {firstQueryData.payment_failed_count->Int.toString->React.string}
            </p>
            <p className={`${body.sm.medium} text-nd_gray-400`}>
              {`Out of ${firstQueryData.payment_count->Int.toString} transactions`->React.string}
            </p>
          </div>
        }}
      </div>
    </PageLoaderWrapper>
  }
}

@react.component
let make = () => {
  open RoutingAnalyticsMetricsUtils

  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-4">
    {metricsArray
    ->Array.mapWithIndex((metric, index) =>
      <RoutingAnalyticsCard metric key={index->Int.toString} />
    )
    ->React.array}
  </div>
}
