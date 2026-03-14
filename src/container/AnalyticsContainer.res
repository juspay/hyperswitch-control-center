@react.component
let make = () => {
  open HSwitchUtils
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {getResolvedUserInfo, checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let {analyticsEntity} = getResolvedUserInfo()
  let {performanceMonitor, disputeAnalytics, authenticationAnalytics, routingAnalytics} =
    featureFlagAtom->Recoil.useRecoilValueFromAtom
  <div key={(analyticsEntity :> string)}>
    {switch url.path->urlPath {
    | list{"analytics-payments"} =>
      <AccessControl authorization={userHasAccess(~groupAccess=AnalyticsView)}>
        <FilterContext key="PaymentsAnalytics" index="PaymentsAnalytics">
          <PaymentAnalytics />
        </FilterContext>
      </AccessControl>
    | list{"analytics-refunds"} =>
      <AccessControl authorization={userHasAccess(~groupAccess=AnalyticsView)}>
        <FilterContext key="PaymentsRefunds" index="PaymentsRefunds">
          <RefundsAnalytics />
        </FilterContext>
      </AccessControl>
    | list{"analytics-disputes"} =>
      <AccessControl
        isEnabled={disputeAnalytics} authorization={userHasAccess(~groupAccess=AnalyticsView)}>
        <FilterContext key="DisputeAnalytics" index="DisputeAnalytics">
          <DisputeAnalytics />
        </FilterContext>
      </AccessControl>
    | list{"analytics-authentication"} =>
      <AccessControl
        isEnabled={authenticationAnalytics && [#Tenant, #Organization, #Merchant]->checkUserEntity}
        authorization={userHasAccess(~groupAccess=AnalyticsView)}>
        <FilterContext key="AuthenticationAnalytics" index="AuthenticationAnalytics">
          <NewAuthenticationAnalytics />
        </FilterContext>
      </AccessControl>
    | list{"performance-monitor"} =>
      <AccessControl
        authorization={userHasAccess(~groupAccess=AnalyticsView)} isEnabled={performanceMonitor}>
        <FilterContext key="PerformanceMonitor" index="PerformanceMonitor">
          <PerformanceMonitor domain="payments" />
        </FilterContext>
      </AccessControl>
    | list{"analytics-routing"}
    | list{"analytics-routing", "overall-routing"}
    | list{"analytics-routing", "least-cost-routing"} =>
      <AccessControl
        isEnabled={routingAnalytics} authorization={userHasAccess(~groupAccess=AnalyticsView)}>
        <FilterContext key="RoutingAnalytics" index="RoutingAnalytics">
          <RoutingAnalytics />
        </FilterContext>
      </AccessControl>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
  </div>
}
