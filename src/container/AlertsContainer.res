@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {devAlerts} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {roleId} = React.useContext(UserInfoProvider.defaultContext).getResolvedUserInfo()
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser

  switch url.path->HSwitchUtils.urlPath {
  | list{"alerts-merchant-success", ...remainingPath} =>
    <AccessControl
      isEnabled={devAlerts && isInternalUser}
      authorization={userHasAccess(~groupAccess=OperationsView)}>
      <FilterContext key="Alerts" index="Alerts">
        <EntityScaffold
          entityName="Alerts"
          remainingPath
          access=Access
          renderList={() => <Alerts />}
          renderShow={(id, _) => <ShowAlert id />}
        />
      </FilterContext>
    </AccessControl>
  | list{"unauthorized"} => <UnauthorizedPage />
  | _ => <NotFoundPage />
  }
}
