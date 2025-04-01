@react.component
let make = (~domain="payments") => {
  open APIUtils
  open LogicUtils
  open HSAnalyticsUtils
  open PerformanceMonitorEntity
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let fetchDetails = useGetMethod()
  let defaultFilters = [startTimeFilterKey, endTimeFilterKey]
  let {updateExistingKeys, filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (dimensions, setDimensions) = React.useState(_ => []->dimensionObjMapper)
  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="analytics",
    (),
  )
  let {checkUserEntity, userInfo: {analyticsEntity}} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {updateAnalytcisEntity} = OMPSwitchHooks.useUserInfo()
  let filterBody = (~groupBy) => {
    let filterBodyEntity: AnalyticsUtils.filterBodyEntity = {
      startTime: startTimeVal,
      endTime: endTimeVal,
      groupByNames: groupBy,
      source: "BATCH",
    }
    AnalyticsUtils.filterBody(filterBodyEntity)
  }
  let fetchFilterData = async dimensions => {
    try {
      let groupBy = getStringListFromArrayDict(dimensions)
      let filterUrl = getURL(~entityName=V1(ANALYTICS_FILTERS), ~methodType=Post, ~id=Some(domain))
      let res = await updateDetails(filterUrl, filterBody(~groupBy)->JSON.Encode.object, Post)
      let dim =
        res
        ->getDictFromJsonObject
        ->getJsonObjectFromDict("queryData")
        ->getArrayFromJson([])
        ->dimensionObjMapper
      setDimensions(_ => dim)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => ()
    }
  }
  let loadInfo = async () => {
    try {
      setScreenState(_ => Loading)
      let infoUrl = getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Get, ~id=Some(domain))
      let infoDetails = await fetchDetails(infoUrl)
      let dimensions = infoDetails->getDictFromJsonObject->getArrayFromDict("dimensions", [])
      fetchFilterData(dimensions)->ignore
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }
  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="performance_monitor_date_filter_opened")
  }
  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      mixpanelEvent(~eventName="performance_monitor_date_filter")
      loadInfo()->ignore
    }
    None
  }, (startTimeVal, endTimeVal))
  let topFilterUi =
    <div className="flex flex-row">
      <DynamicFilter
        initialFilters=[]
        options=[]
        popupFilterFields=[]
        initialFixedFilters={initialFixedFilterFields(
          Dict.make()->JSON.Encode.object,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=defaultFilters
        tabNames=[]
        key="1"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-5">
      <div className="flex items-center justify-between ">
        <PageUtils.PageHeading title="Performance Monitor" subTitle="" />
        <div className="mr-5">
          <OMPSwitchHelper.OMPViews
            views={OMPSwitchUtils.analyticsViewList(~checkUserEntity)}
            selectedEntity={analyticsEntity}
            onChange={updateAnalytcisEntity}
            entityMapper=UserInfoUtils.analyticsEntityMapper
          />
        </div>
      </div>
      <div
        className="-ml-1 sticky top-0 z-30  p-1 bg-hyperswitch_background py-3 -mt-3 rounded-lg border">
        topFilterUi
      </div>
      <div className="flex flex-col gap-3">
        <div className="grid grid-cols-4 grid-rows-1 gap-3">
          <div className="flex flex-col gap-3">
            <GaugeChartPerformance
              startTimeVal endTimeVal entity={getSuccessRatePerformanceEntity}
            />
            <GaugeFailureRate
              startTimeVal
              endTimeVal
              entity1={overallPaymentCount}
              entity2={getFailureRateEntity}
              dimensions
            />
          </div>
          <div className="col-span-3">
            <BarChartPerformance
              domain startTimeVal endTimeVal dimensions entity={getStatusPerformanceEntity}
            />
          </div>
        </div>
        <div className="grid grid-cols-2 grid-rows-1 gap-3">
          <BarChartPerformance
            domain
            startTimeVal
            endTimeVal
            dimensions
            entity={getPerformanceEntity(
              ~filters=[#payment_method],
              ~groupBy=[#payment_method],
              ~groupByKeys=[#payment_method],
              ~title="Payment Distribution By Payment Method",
            )}
          />
          <BarChartPerformance
            domain
            startTimeVal
            endTimeVal
            dimensions
            entity={getPerformanceEntity(
              ~filters=[#connector],
              ~groupBy=[#connector],
              ~groupByKeys=[#connector],
              ~title="Payment Distribution By Connector",
            )}
          />
        </div>
        <TablePerformance
          startTimeVal endTimeVal entity={getFailureEntity} getTableData visibleColumns tableEntity
        />
        <div className="grid grid-cols-2 grid-rows-1 gap-3">
          <PieChartPerformance
            domain startTimeVal endTimeVal dimensions entity={getConnectorFailureEntity}
          />
          <PieChartPerformance
            domain startTimeVal endTimeVal dimensions entity={getPaymentMethodFailureEntity}
          />
        </div>
        <div className="grid grid-cols-2 grid-rows-1 gap-3">
          <PieChartPerformance
            domain
            startTimeVal
            endTimeVal
            dimensions
            entity={getConnectorPaymentMethodFailureEntity}
          />
        </div>
      </div>
    </div>
  </PageLoaderWrapper>
}
