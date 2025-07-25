@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open Typography

  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (response, setResponse) = React.useState(_ => JSON.Encode.null)

  let getData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(ANALYTICS_ROUTING), ~methodType=Post, ~id=Some("routing"))
      let body =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~metrics=Some(["payment_count"]),
            ~delta=false,
            ~groupByNames=Some(["routing_approach"]),
            ~startDateTime=startTimeVal,
            ~endDateTime=endTimeVal,
          )->JSON.Encode.object,
        ]->JSON.Encode.array
      let response = await updateDetails(url, body, Post)

      let responseData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])
      setResponse(_ => response)
      if responseData->Array.length > 0 {
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
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
  }, [startTimeVal, endTimeVal])

  <PageLoaderWrapper screenState customUI={<InsightsHelper.NoData />} customLoader={<Shimmer />}>
    <div className="flex flex-col">
      <div className="border rounded-xl py-2 px-4 border-nd_gray-200 rounded-b-none bg-nd_gray-25">
        <p className={`text-nd_gray-600  px-3 py-[10px] ${body.md.semibold}`}>
          {"Routing Logic Distribution"->React.string}
        </p>
      </div>
      <div
        className="flex border rounded-xl border-t-0 border-nd_gray-200 h-[14rem] rounded-t-none">
        <PieGraph
          options={RoutingAnalyticsDistributionUtils.chartOptions(
            response,
            ~groupByText="routing_approach",
          )}
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
