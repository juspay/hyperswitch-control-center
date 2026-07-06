open Typography

@react.component
let make = () => {
  open PageUtils

  let {updateExistingKeys, filterKeys} = React.useContext(FilterContext.filterContext)
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_pipelines_date_filter_opened")
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~range=180,
    ~origin="recon_engine_pipelines",
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  <div className="flex flex-col">
    <PageHeading
      title="Pipelines" customTitleStyle={`${heading.lg.semibold}`} customHeadingStyle="py-0"
    />
    <div className="flex flex-row justify-end">
      <DynamicFilter
        title="ReconEnginePipelinesFilters"
        initialFilters=[]
        options=[]
        popupFilterFields=[]
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEnginePipelinesFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
    <ReconEnginePipelinesStatCards />
  </div>
}
