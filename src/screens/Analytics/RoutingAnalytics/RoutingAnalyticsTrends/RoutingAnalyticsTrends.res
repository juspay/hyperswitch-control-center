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
  let (successData, setSuccessData) = React.useState(_ => JSON.Encode.array([]))
  let (volumeData, setVolumeData) = React.useState(_ => JSON.Encode.array([]))

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
      let processedData = responseData->RoutingAnalyticsTrendsUtils.modifyQueryData
      let sortedData = processedData->sortQueryDataByDate
      setSuccessData(_ => sortedData->Identity.genericTypeToJson)
      setVolumeData(_ => sortedData->Identity.genericTypeToJson)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Unable to fetch."))
    }
  }

  let getData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    await getMetricData()
    let successDataLength = successData->getArrayFromJson([])->Array.length
    let volumeDataLength = volumeData->getArrayFromJson([])->Array.length

    if successDataLength > 0 || volumeDataLength > 0 {
      setScreenState(_ => PageLoaderWrapper.Success)
    } else {
      setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(_ => {
    getData()->ignore
    None
  }, (startTimeVal, endTimeVal))

  <PageLoaderWrapper screenState customUI={<InsightsHelper.NoData />} customLoader={<Shimmer />}>
    <div className="flex flex-col gap-6 w-full mt-12">
      <div className="flex flex-col gap-1 mb-2">
        <p className={`${body.lg.semibold} text-nd_gray-800`}> {"Routing Trends"->React.string} </p>
        <p className={`${body.md.medium} text-nd_gray-400`}>
          {"Analyze the trends in routing metrics over time."->React.string}
        </p>
      </div>
      <div className="border border-nd_gray-200 rounded-xl">
        <div className="bg-nd_gray-25 px-6 py-4 border-b border-nd_gray-200 rounded-t-xl">
          <p className={`${body.md.semibold} text-gray-800`}>
            {"Success Over Time"->React.string}
          </p>
        </div>
        <SuccessChart data=successData />
      </div>
      <div className="border border-nd_gray-200 rounded-xl">
        <div className="bg-nd_gray-25 px-6 py-4 border-b border-nd_gray-200 rounded-t-xl">
          <p className={`${body.md.semibold} text-gray-800`}>
            {"Volume Over Time"->React.string}
          </p>
        </div>
        <VolumeChart data=volumeData />
      </div>
    </div>
  </PageLoaderWrapper>
}
