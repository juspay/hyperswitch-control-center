@react.component
let make = () => {
  open HSAnalyticsUtils
  let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let {updateAnalytcisEntity} = OMPSwitchHooks.useUserInfo()
  let {userInfo: {analyticsEntity}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )

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

  <>
    <div className="flex justify-between mb-6">
      <PageUtils.PageHeading title="Routing Analytics" />
      <div className="flex items-center gap-2">
        <div className="flex mt-2">
          <OMPSwitchHelper.OMPViews
            views={OMPSwitchUtils.analyticsViewList(~checkUserEntity)}
            selectedEntity={analyticsEntity}
            onChange={updateAnalytcisEntity}
            entityMapper=UserInfoUtils.analyticsEntityMapper
            disabledDisplayName="Hyperswitch_test"
          />
        </div>
        <DynamicFilter
          title="RoutingAnalytics"
          initialFilters=[]
          options=[]
          popupFilterFields=[]
          initialFixedFilters={initialFixedFilterFields(""->JSON.Encode.string, ~events=() => ())}
          defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
          tabNames=[]
          key="0"
          updateUrlWith=updateExistingKeys
          filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
          showCustomFilter=false
          refreshFilters=false
        />
      </div>
    </div>
    <RoutingAnalyticsDistribution />
    <RoutingAnalyticsTrends />
  </>
}
