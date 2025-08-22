@react.component
let make = () => {
  open Typography

  let {updateAnalytcisEntity} = OMPSwitchHooks.useUserInfo()
  let {userInfo: {analyticsEntity}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )

  <div className="flex flex-col gap-8">
    <div className="flex items-center justify-between ">
      <PageUtils.PageHeading
        title="Routing Analytics"
        subTitle="Get a comprehensive view of how your payment routing strategies are performing across different processors and routing logics."
        customHeadingStyle={`${body.lg.semibold} !text-nd_gray-800`}
        customSubTitleStyle={`${body.lg.medium} !text-nd_gray-400 !opacity-100 !mt-1`}
      />
      <div className="mr-4">
        <Portal to="RoutingAnalyticsOMPView">
          <OMPSwitchHelper.OMPViews
            views={OMPSwitchUtils.analyticsViewList(~checkUserEntity)}
            selectedEntity={analyticsEntity}
            onChange={updateAnalytcisEntity}
            entityMapper=UserInfoUtils.analyticsEntityMapper
            disabledDisplayName="Hyperswitch_test"
          />
        </Portal>
      </div>
    </div>
    <OverallRoutingAnalytics />
  </div>
}
