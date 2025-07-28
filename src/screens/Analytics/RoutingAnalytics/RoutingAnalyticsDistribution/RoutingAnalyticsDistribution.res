@react.component
let make = () => {
  open Typography
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()

  let {updateExistingKeys, filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeFilterKey = filterValueJson->getString("startTime", "")
  let endTimeFilterKey = filterValueJson->getString("endTime", "")

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (dimensions, setDimensions) = React.useState(_ => [])
  let (filterDataJson, setFilterDataJson) = React.useState(_ => None)

  let loadInfo = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let infoUrl = getURL(~entityName=V1(ANALYTICS_ROUTING), ~methodType=Get, ~id=Some("routing"))
      let infoDetails = await fetchDetails(infoUrl)
      setDimensions(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("dimensions", []))
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
          ~startTime=startTimeFilterKey,
          ~endTime=endTimeFilterKey,
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
    ~origin="routing_analytics_distribution",
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    loadInfo()->ignore
    None
  }, [])

  React.useEffect(() => {
    if (
      startTimeFilterKey->isNonEmptyString &&
      endTimeFilterKey->isNonEmptyString &&
      dimensions->Array.length > 0
    ) {
      getFilters()->ignore
    }
    None
  }, (startTimeFilterKey, endTimeFilterKey, dimensions))

  let topFilterUi = {
    let (initialFilters, popupFilterFields, key) = switch filterDataJson {
    | Some(filterData) => (
        HSAnalyticsUtils.initialFilterFields(filterData, ~isTitle=true),
        HSAnalyticsUtils.options(filterData),
        "0",
      )
    | None => ([], [], "1")
    }

    <div className="flex flex-row">
      <DynamicFilter
        title="AuthenticationAnalyticsV2"
        initialFilters
        options=[]
        popupFilterFields
        initialFixedFilters=[]
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames
        key
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
  }

  <PageLoaderWrapper screenState customUI={<InsightsHelper.NoData />}>
    <PageUtils.PageHeading
      title="Distribution"
      customHeadingStyle="flex flex-col mb-6 "
      customTitleStyle={`!${body.lg.semibold} text-nd_gray-800`}
    />
    <div className="-ml-1 sticky top-0 z-10 bg-hyperswitch_background/70 rounded-lg my-3">
      {topFilterUi}
    </div>
    <div className="grid xl:grid-cols-2 gap-2 grid-cols-1">
      <RoutingAnalyticsDistributionConnectorVolume />
      <RoutingAnalyticsDistributionRoutingApproach />
    </div>
  </PageLoaderWrapper>
}
