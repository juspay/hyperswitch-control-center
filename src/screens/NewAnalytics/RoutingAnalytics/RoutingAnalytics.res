@react.component
let make = () => {
  open Typography
  open HSAnalyticsUtils

  let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let {updateAnalytcisEntity} = OMPSwitchHooks.useUserInfo()
  let {userInfo: {analyticsEntity}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="routing_analytics_date_filter_opened")
  }
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
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
  let tabs: array<Tabs.tab> = [
    {
      title: "Overall Routing",
      renderContent: () => <OverallRoutingAnalytics />,
    },
    {
      title: "Least Cost Routing",
      renderContent: () => <LeastCostRoutingAnalytics />,
    },
  ]
  <div className="flex flex-col gap-8">
    <div className="flex flex-col 2xl:flex-row gap-2">
      <PageUtils.PageHeading
        title="Routing Analytics"
        subTitle="Get a comprehensive view of how your payment routing strategies are performing across different processors and routing logics."
        customHeadingStyle={`${body.lg.semibold} !text-nd_gray-800`}
        customSubTitleStyle={`${body.lg.medium} !text-nd_gray-400 !opacity-100 !mt-1`}
      />
      <div className="flex items-center 2xl:ml-4">
        <div className="mt-2">
          <OMPSwitchHelper.OMPViews
            views={OMPSwitchUtils.analyticsViewList(~checkUserEntity)}
            selectedEntity={analyticsEntity}
            onChange={updateAnalytcisEntity}
            entityMapper=UserInfoUtils.analyticsEntityMapper
            disabledDisplayName="Hyperswitch_test"
          />
        </div>
        <div className="-mr-2">
          <DynamicFilter
            title="RoutingAnalytics"
            initialFilters=[]
            options=[]
            popupFilterFields=[]
            initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
              null,
              ~events=dateDropDownTriggerMixpanelCallback,
            )}
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
    </div>
    <Tabs
      initialIndex={tabIndex}
      tabs
      onTitleClick={tabId => setTabIndex(_ => tabId)}
      includeMargin=false
      textStyle="text-blue-600"
      selectTabBottomBorderColor="bg-blue-600"
    />
  </div>
}
