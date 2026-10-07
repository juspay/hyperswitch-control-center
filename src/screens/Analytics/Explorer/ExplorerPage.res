@react.component
let make = () => {
  open HSAnalyticsUtils
  let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="analytics",
    (),
  )
  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  <div className="flex flex-col gap-4">
    <div className="flex flex-wrap items-start justify-between gap-4">
      <PageUtils.PageHeading
        title="Explorer"
        subTitle="Measure performance, segment results and filter data to understand what drives each metric."
      />
      <DynamicFilter
        title="Explorer"
        initialFilters=[]
        options=[]
        popupFilterFields=[]
        initialFixedFilters={initialFixedFilterFields(JSON.Encode.null)}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=[]
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        filtersDisplayOption=false
        refreshFilters=false
      />
    </div>
    <Explorer />
  </div>
}
