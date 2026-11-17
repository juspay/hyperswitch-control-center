@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {devAlerts} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let alertsViewAccess = userHasAccess(~groupAccess=AlertsView)

  switch url.path->HSwitchUtils.urlPath {
  | list{"alerts-business-insights", ...remainingPath} =>
    <AccessControl isEnabled=devAlerts authorization=alertsViewAccess>
      <FilterContext key="Alerts" index="Alerts">
        <EntityScaffold
          entityName="Alerts"
          remainingPath
          access=alertsViewAccess
          renderList={() => <Alerts />}
          renderShow={(id, _) => <ShowAlert id={id->decodeURIComponent} />}
        />
      </FilterContext>
    </AccessControl>
  | list{"unauthorized"} => <UnauthorizedPage />
  | _ => <NotFoundPage />
  }
}
