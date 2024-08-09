@react.component
let make = () => {
  let domain = "payments"
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
      let filterUri = `${Window.env.apiBaseUrl}/analytics/v1/filters/payments`
      let res = await updateDetails(filterUri, filterBody(~groupBy)->JSON.Encode.object, Post)
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
      let infoUrl = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Get, ~id=Some(domain))
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
  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
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
        initialFixedFilters={initialFixedFilterFields(Dict.make()->JSON.Encode.object)}
        defaultFilterKeys=defaultFilters
        tabNames=[]
        key="1"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>

  <>
    <PageLoaderWrapper screenState>
      <div
        className="-ml-1 sticky top-0 z-30  p-1 bg-hyperswitch_background py-3 -mt-3 rounded-lg border">
        topFilterUi
      </div>
      <div className="grid grid-cols-4 grid-rows-1 gap-3">
        <GaugeChartPerformance
          startTimeVal endTimeVal entity={PerformanceMonitorEntity.getSuccessRatePerformanceEntity}
        />
        // <GaugeChartPerformance
        //   startTimeVal
        //   endTimeVal
        //   entity={PerformanceMonitorEntity.getRefundsSuccessRatePerformanceEntity}
        //   domain="refunds"
        // />
        <GaugeFailureRate
          startTimeVal
          endTimeVal
          metric=#payment_count
          title="Payments Failure Rate"
          filter=#status
          customValue={"failure"}
        />
        <div className="col-span-2">
          <BarChartPerformance
            startTimeVal
            endTimeVal
            dimensions
            entity={PerformanceMonitorEntity.getStatusPerformanceEntity}
          />
        </div>

        // <GaugeFailureRate
        //   startTimeVal
        //   endTimeVal
        //   metric=#refund_count
        //   title="Refunds Failure Rate"
        //   domain="refunds"
        //   filter=#refund_status
        //   customValue={"failed"}
        // />
      </div>
      <div className="flex gap-2">
        <div className="flex-col">
          <BarChartPerformance
            startTimeVal
            endTimeVal
            dimensions
            entity={PerformanceMonitorEntity.getConnectorPerformanceEntity}
          />
        </div>
        <div className="flex-col">
          <BarChartPerformance
            startTimeVal
            endTimeVal
            dimensions
            entity={PerformanceMonitorEntity.getPaymentMethodPerformanceEntity}
          />
        </div>
      </div>
      <div className="grid grid-cols-3 gap-4">
        <div className="">
          <PieChartPerformance
            startTimeVal
            endTimeVal
            dimensions
            entity={PerformanceMonitorEntity.getConnectorPaymentMethodFailureEntity}
          />
        </div>
        <div className="">
          <PieChartPerformance
            startTimeVal
            endTimeVal
            dimensions
            entity={PerformanceMonitorEntity.getConnectorFailureEntity}
          />
        </div>
        <div className="">
          <PieChartPerformance
            startTimeVal
            endTimeVal
            dimensions
            entity={PerformanceMonitorEntity.getPaymentMethodFailureEntity}
          />
        </div>
      </div>
    </PageLoaderWrapper>
  </>
}
