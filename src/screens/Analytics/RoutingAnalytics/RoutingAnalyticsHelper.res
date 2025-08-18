module TopFilterUI = {
  @react.component
  let make = (~filterDataJson, ~tabNames) => {
    open HSAnalyticsUtils

    let mixpanelEvent = MixpanelHook.useSendEvent()
    let {updateExistingKeys} = React.useContext(FilterContext.filterContext)

    let dateDropDownTriggerMixpanelCallback = () => {
      mixpanelEvent(~eventName="routing_analytics_date_filter_opened")
    }

    let (initialFilters, popupFilterFields, key) = switch filterDataJson {
    | Some(filterData) => (
        HSAnalyticsUtils.initialFilterFields(filterData, ~isTitle=true),
        HSAnalyticsUtils.options(filterData),
        "0",
      )
    | None => ([], [], "1")
    }

    <div className="flex flex-row -ml-1.5">
      <DynamicFilter
        title="RoutingAnalytics"
        initialFilters
        options=[]
        popupFilterFields
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
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
}
