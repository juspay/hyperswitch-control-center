@react.component
let make = (~ruleDetails: ReconEngineRulesTypes.rulePayload) => {
  let {updateExistingKeys, filterKeys} = React.useContext(FilterContext.filterContext)
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_overview_details_date_filter_opened")
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~range=180,
    ~origin="recon_engine_overview_details",
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  <div className="flex flex-col gap-8 mt-8">
    <div className="flex flex-row justify-end">
      <DynamicFilter
        title="ReconEngineOverviewDetailsFilters"
        initialFilters=[]
        options=[]
        popupFilterFields=[]
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineOverviewDetailsFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
    <ReconEngineOverviewDetailsStatCards ruleDetails />
    <ReconEngineOverviewAccountDetails ruleDetails />
    <ReconEngineOverviewDetailsReconciliationVolume ruleDetails />
    <ReconEngineOverviewTransactions ruleDetails />
  </div>
}
