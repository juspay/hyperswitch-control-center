@react.component
let make = () => {
  open HSwitchUtils
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = PermissionHooks.useUserPermissionHook()
  let {userInfo: {analyticsEntity}} = React.useContext(UserInfoProvider.defaultContext)
  let {performanceMonitor, disputeAnalytics} = featureFlagAtom->Recoil.useRecoilValueFromAtom
  <div key={(analyticsEntity :> string)}>
    {switch url.path->urlPath {
    | list{"analytics-payments"} =>
      <AccessControl permission={userHasAccess(~permission=AnalyticsView)}>
        <FilterContext key="PaymentsAnalytics" index="PaymentsAnalytics">
          <PaymentAnalytics />
        </FilterContext>
      </AccessControl>
    | list{"analytics-refunds"} =>
      <AccessControl permission={userHasAccess(~permission=AnalyticsView)}>
        <FilterContext key="PaymentsRefunds" index="PaymentsRefunds">
          <RefundsAnalytics />
        </FilterContext>
      </AccessControl>
    | list{"analytics-disputes"} =>
      <AccessControl
        isEnabled={disputeAnalytics} permission={userHasAccess(~permission=AnalyticsView)}>
        <FilterContext key="DisputeAnalytics" index="DisputeAnalytics">
          <DisputeAnalytics />
        </FilterContext>
      </AccessControl>
    | list{"performance-monitor"} =>
      <AccessControl
        permission={userHasAccess(~permission=AnalyticsView)} isEnabled={performanceMonitor}>
        <FilterContext key="PerformanceMonitor" index="PerformanceMonitor">
          <PerformanceMonitor domain="payments" />
        </FilterContext>
      </AccessControl>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
  </div>
}
