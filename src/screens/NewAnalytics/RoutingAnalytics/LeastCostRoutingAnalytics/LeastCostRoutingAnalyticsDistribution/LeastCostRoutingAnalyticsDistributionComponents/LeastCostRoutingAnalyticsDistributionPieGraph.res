@react.component
let make = () => {
  open Typography
  open APIUtils
  open LogicUtils
  open LeastCostRoutingAnalyticsTypes

  let (response, setResponse) = React.useState(_ => JSON.Encode.null)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")

  let getData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Post, ~id=Some("payments"))

      let body =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~metrics=Some([(#sessionized_debit_routing: requestPayloadMetrics :> string)]),
            ~delta=false,
            ~startDateTime=startTimeVal,
            ~endDateTime=endTimeVal,
            ~groupByNames=Some([(#card_network: requestPayloadMetrics :> string)]),
            ~filter=Some(LeastCostRoutingAnalyticsUtils.filterDict),
          )->JSON.Encode.object,
        ]->JSON.Encode.array
      let response = await updateDetails(url, body, Post)
      let responseData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])
      if responseData->Array.length > 0 {
        setResponse(_ => response)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Error fetching data"))
    }
  }

  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getData()->ignore
    }
    None
  }, (startTimeVal, endTimeVal))

  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData height="h-72" />}
    customLoader={<Shimmer styleClass="w-full h-22-rem rounded-xl" />}>
    <div className="flex flex-col">
      <div className="border rounded-xl py-2 px-4 border-nd_gray-200 rounded-b-none bg-nd_gray-25">
        <p className={`text-nd_gray-600 px-3 py-10-px ${body.md.semibold}`}>
          {"Volume Distribution"->React.string}
        </p>
      </div>
      <div
        className="flex border rounded-xl border-t-0 border-nd_gray-200 h-22-rem rounded-t-none items-center ">
        <PieGraph
          options={LeastCostRoutingAnalyticsDistributionUtils.chartOptions(
            response,
            ~tooltipTitle="Card Network",
          )}
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
