module SuccessChart = {
  @react.component
  let make = (~data: JSON.t) => {
    let params = {
      InsightsTypes.data,
      xKey: "time_bucket",
      yKey: "payment_success_rate",
      comparison: DateRangeUtils.DisableComparison,
    }

    let options =
      RoutingAnalyticsTrendsEntity.routingSuccessRateChartEntity.getObjects(
        ~params,
      )->RoutingAnalyticsTrendsEntity.routingSuccessRateChartEntity.getChatOptions

    <div className="p-6">
      <LineGraph options />
    </div>
  }
}

module VolumeChart = {
  @react.component
  let make = (~data: JSON.t) => {
    let params = {
      InsightsTypes.data,
      yKey: "payment_count",
      xKey: "time_bucket",
      comparison: DateRangeUtils.DisableComparison,
    }

    let options =
      RoutingAnalyticsTrendsEntity.routingVolumeChartEntity.getObjects(
        ~params,
      )->RoutingAnalyticsTrendsEntity.routingVolumeChartEntity.getChatOptions

    <div className="p-6">
      <LineGraph options />
    </div>
  }
}

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open InsightsUtils
  open Typography
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (sharedData, setSharedData) = React.useState(_ => JSON.Encode.null)

  let getMetricData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(ANALYTICS_ROUTING), ~methodType=Post, ~id=Some("routing"))
      let body =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~metrics=Some(["payment_success_rate", "payment_count"]),
            ~delta=false,
            ~groupByNames=Some(["connector"]),
            ~startDateTime=startTimeVal,
            ~endDateTime=endTimeVal,
          )->JSON.Encode.object,
        ]->JSON.Encode.array
      let response = await updateDetails(url, body, Post)
      let responseData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])
      if responseData->Array.length == 0 {
        setScreenState(_ => PageLoaderWrapper.Custom)
      } else {
        let processedData =
          responseData->RoutingAnalyticsTrendsUtils.modifyQueryData->sortQueryDataByDate
        setSharedData(_ => processedData->Identity.genericTypeToJson)
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Unable to fetch."))
    }
  }

  React.useEffect(_ => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getMetricData()->ignore
    }
    None
  }, (startTimeVal, endTimeVal))

  <PageLoaderWrapper screenState customUI={<InsightsHelper.NoData />} customLoader={<Shimmer />}>
    <div className="flex flex-col gap-6 w-full">
      <div className="flex flex-col gap-1 mb-2">
        <p className={`${body.lg.semibold} text-nd_gray-800`}>
          {"Time Series Distribution"->React.string}
        </p>
        <p className={`${body.md.medium} text-nd_gray-400`}>
          {"Track the auth rates and transaction volumes of various processors across time"->React.string}
        </p>
      </div>
      <div className="border border-nd_gray-200 rounded-xl">
        <div className="bg-nd_gray-25 px-6 py-4 border-b border-nd_gray-200 rounded-t-xl">
          <p className={`${body.md.semibold} text-gray-800`}>
            {"Success Over Time"->React.string}
          </p>
        </div>
        <SuccessChart data=sharedData />
      </div>
      <div className="border border-nd_gray-200 rounded-xl">
        <div className="bg-nd_gray-25 px-6 py-4 border-b border-nd_gray-200 rounded-t-xl">
          <p className={`${body.md.semibold} text-gray-800`}>
            {"Volume Over Time"->React.string}
          </p>
        </div>
        <VolumeChart data=sharedData />
      </div>
    </div>
  </PageLoaderWrapper>
}
