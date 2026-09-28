@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {devAlerts} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {roleId} = React.useContext(UserInfoProvider.defaultContext).getResolvedUserInfo()
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser

  switch url.path->HSwitchUtils.urlPath {
  | list{"alerts-business-insights", ...remainingPath} =>
    // TODO: switch to the dedicated alerts permission once it is added
    <AccessControl isEnabled={devAlerts && isInternalUser} authorization=Access>
      <FilterContext key="Alerts" index="Alerts">
        <EntityScaffold
          entityName="Alerts"
          remainingPath
          access=Access
          renderList={() => <Alerts />}
          renderShow={(id, _) => <ShowAlert id={id->decodeURIComponent} />}
        />
      </FilterContext>
    </AccessControl>
  | list{"unauthorized"} => <UnauthorizedPage />
  | _ => <NotFoundPage />
  }
}
