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
  let isMonitoringRoot = switch path {
  | list{"monitoring"} => true
  | _ => false
  }

  React.useEffect(() => {
    if isMonitoringRoot && devAlerts && isInternalUser {
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/monitoring/explore"))
    }
    None
  }, (isMonitoringRoot, devAlerts, isInternalUser))

  <AccessControl isEnabled={devAlerts && isInternalUser} authorization=Access>
    {switch path {
    | list{"monitoring"} => React.null
    | list{"monitoring", slug} =>
      switch slug->MonitoringUtils.fromSlug {
      | Some(destination) =>
        <Monitoring key={`${slug}:${merchantId}:${profileId}:${roleId}`} destination />
      | None => <NotFoundPage />
      }
    | _ => <NotFoundPage />
    }}
  </AccessControl>
}
