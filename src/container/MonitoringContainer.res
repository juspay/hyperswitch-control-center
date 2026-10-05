module DefaultView = {
  @react.component
  let make = () => {
    React.useEffect0(() => {
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/monitoring/explore"))
      None
    })

    React.null
  }
}

@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {devAlerts} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {getResolvedUserInfo, getCommonSessionDetails} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let {roleId} = getResolvedUserInfo()
  let {merchantId, profileId} = getCommonSessionDetails()
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let path = url.path->HSwitchUtils.urlPath
  <AccessControl isEnabled={devAlerts && isInternalUser} authorization=Access>
    {switch path {
    | list{"monitoring"} => <DefaultView />
    | list{"monitoring", viewId} =>
      switch viewId->MonitoringUtils.getDestinationFromRouteId {
      | Some(destination) =>
        <Monitoring key={`${viewId}:${merchantId}:${profileId}:${roleId}`} destination />
      | None => <NotFoundPage />
      }
    | _ => <NotFoundPage />
    }}
  </AccessControl>
}
