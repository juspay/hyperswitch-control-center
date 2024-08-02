@react.component
let make = () => {
  let domain = "payments"
  open APIUtils
  open LogicUtils

  open HSAnalyticsUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let fetchDetails = useGetMethod()
  let defaultFilters = [startTimeFilterKey, endTimeFilterKey]
  let {updateExistingKeys, filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
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
      let res = await updateDetails(filterUri, filterBody(~groupBy)->JSON.Encode.object, Post, ())
      Js.log(res)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => ()
    }
  }
  let loadInfo = async () => {
    try {
      let infoUrl = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Get, ~id=Some(domain), ())
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
    <div
      className="-ml-1 sticky top-0 z-30  p-1 bg-hyperswitch_background py-3 -mt-3 rounded-lg border">
      topFilterUi
    </div>
    <div className="flex flex-col gap-14">
      <ConnectorPerformance startTimeVal endTimeVal />
    </div>
  </>
}
