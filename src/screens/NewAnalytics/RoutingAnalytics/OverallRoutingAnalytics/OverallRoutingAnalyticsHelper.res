module TopFilterUI = {
  @react.component
  let make = (~filterDataJson, ~tabNames) => {
    open HSAnalyticsUtils

    let {updateExistingKeys} = React.useContext(FilterContext.filterContext)

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
        initialFixedFilters={[]}
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
