/*
 InternalEntityRoutes.res
  This file defines all the routes specific to the internal user, 
  accessible only to users with an entity type of "internal."
*/
@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

  <ErrorBoundary>
    {switch url.path->HSwitchUtils.urlPath {
    | list{"developer-system-metrics"} =>
      <AccessControl
        isEnabled={featureFlagDetails.systemMetrics} permission=userPermissionJson.analyticsView>
        <FilterContext key="SystemMetrics" index="SystemMetrics">
          <SystemMetricsAnalytics />
        </FilterContext>
      </AccessControl>
    | _ =>
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/home"))
      <MerchantAccountContainer />
    }}
  </ErrorBoundary>
}
