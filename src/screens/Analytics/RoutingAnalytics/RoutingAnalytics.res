@react.component
let make = () => {
  open HSAnalyticsUtils
  open APIUtils
  open LogicUtils
  open Typography

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()

  let {updateExistingKeys, filterValueJson} = React.useContext(FilterContext.filterContext)
  let {updateAnalytcisEntity} = OMPSwitchHooks.useUserInfo()
  let {userInfo: {analyticsEntity}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
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

      setDimensions(_ => infoDetails->RoutingAnalyticsUtils.filterCurrencyFromDimensions)
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
        InsightsUtils.requestBody(
          ~startTime,
          ~endTime,
          ~groupByNames=Some(tabNames),
          ~metrics=[],
          ~filter=None,
          ~delta=Some(true),
        )
        ->getArrayFromJson([])
        ->getValueFromArray(0, JSON.Encode.null)
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

  <PageLoaderWrapper screenState customUI={<InsightsHelper.NoData />}>
    <div className="flex flex-col gap-8">
      <div className="flex items-center justify-between ">
        <PageUtils.PageHeading
          title="Routing Analytics"
          subTitle="Get a comprehensive view of how your payment routing strategies are performing across different processors and routing logics."
          customHeadingStyle={`${body.lg.semibold} !text-nd_gray-800`}
          customSubTitleStyle={`${body.lg.medium} !text-nd_gray-400 !opacity-100 !mt-1`}
        />
        <div className="mr-4">
          <Portal to="RoutingAnalyticsOMPView">
            <OMPSwitchHelper.OMPViews
              views={OMPSwitchUtils.analyticsViewList(~checkUserEntity)}
              selectedEntity={analyticsEntity}
              onChange={updateAnalytcisEntity}
              entityMapper=UserInfoUtils.analyticsEntityMapper
              disabledDisplayName="Hyperswitch_test"
            />
          </Portal>
        </div>
      </div>
      <RoutingAnalyticsHelper.TopFilterUI filterDataJson tabNames />
      <RoutingAnalyticsMetrics />
      <RoutingAnalyticsDistribution />
      <RoutingAnalyticsSummary />
      <RoutingAnalyticsTrends />
    </div>
  </PageLoaderWrapper>
}
