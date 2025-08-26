@react.component
let make = () => {
  open HSAnalyticsUtils
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()

  let {updateExistingKeys, filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (dimensions, setDimensions) = React.useState(_ => [])
  let (filterDataJson, setFilterDataJson) = React.useState(_ => None)

  let startTime = filterValueJson->getString("startTime", "")
  let endTime = filterValueJson->getString("endTime", "")

  let loadInfo = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let infoUrl = getURL(~entityName=V1(ANALYTICS_ROUTING), ~methodType=Get, ~id=Some("routing"))
      let infoDetails = await fetchDetails(infoUrl)

      setDimensions(_ => infoDetails->OverallRoutingAnalyticsUtils.filterCurrencyFromDimensions)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  let tabNames = HSAnalyticsUtils.getStringListFromArrayDict(dimensions)

  let getFilters = async () => {
    setFilterDataJson(_ => None)
    try {
      let analyticsfilterUrl = getURL(
        ~entityName=V1(ANALYTICS_FILTERS),
        ~methodType=Post,
        ~id=Some("routing"),
      )
      let filterBody =
        AnalyticsUtils.getFilterRequestBody(
          ~metrics=Some([]),
          ~delta=true,
          ~groupByNames=Some(tabNames),
          ~filter=None,
          ~startDateTime=startTime,
          ~endDateTime=endTime,
        )->JSON.Encode.object

      let filterData = await updateDetails(analyticsfilterUrl, filterBody, Post)
      setFilterDataJson(_ => Some(filterData))
    } catch {
    | _ => setFilterDataJson(_ => None)
    }
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
    loadInfo()->ignore
    None
  }, [])

  React.useEffect(() => {
    if startTime->isNonEmptyString && endTime->isNonEmptyString && dimensions->Array.length > 0 {
      getFilters()->ignore
    }
    None
  }, (startTime, endTime, dimensions))

  <PageLoaderWrapper screenState customUI={<NewAnalyticsHelper.NoData />}>
    <div className="flex flex-col gap-8">
      <OverallRoutingAnalyticsHelper.TopFilterUI filterDataJson tabNames />
      <RoutingAnalyticsMetrics />
      <RoutingAnalyticsDistribution />
      <RoutingAnalyticsSummary />
      <RoutingAnalyticsTrends />
    </div>
  </PageLoaderWrapper>
}
