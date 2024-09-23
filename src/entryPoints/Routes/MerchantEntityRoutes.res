/*
 MerchantEntityRoutes.res
  This file defines all the routes specific to the merchant level, 
  accessible only to users with an entity type of "merchant."
*/

@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

  <ErrorBoundary>
    {switch url.path->HSwitchUtils.urlPath {
    | list{"customers", ...remainingPath} =>
      <AccessControl permission={userPermissionJson.operationsView}>
        <EntityScaffold
          entityName="Customers"
          remainingPath
          access=Access
          renderList={() => <Customers />}
          renderShow={(id, _) => <ShowCustomers id />}
        />
      </AccessControl>
    | list{"recon"}
    | list{"upload-files"}
    | list{"run-recon"}
    | list{"recon-analytics"}
    | list{"reports"}
    | list{"config-settings"}
    | list{"file-processor"} =>
      <MerchantAccountContainer />
    | list{"analytics-user-journey"} =>
      <AccessControl
        isEnabled=featureFlagDetails.userJourneyAnalytics
        permission=userPermissionJson.analyticsView>
        <FilterContext key="UserJourneyAnalytics" index="UserJourneyAnalytics">
          <UserJourneyAnalytics />
        </FilterContext>
      </AccessControl>
    | list{"analytics-authentication"} =>
      <AccessControl
        isEnabled=featureFlagDetails.authenticationAnalytics
        permission=userPermissionJson.analyticsView>
        <FilterContext key="AuthenticationAnalytics" index="AuthenticationAnalytics">
          <AuthenticationAnalytics />
        </FilterContext>
      </AccessControl>
    | list{"developer-api-keys"} =>
      <AccessControl permission=userPermissionJson.merchantDetailsManage>
        <KeyManagement.KeysManagement />
      </AccessControl>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ =>
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/home"))
      <MerchantAccountContainer />
    }}
  </ErrorBoundary>
}
