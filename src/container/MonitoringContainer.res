@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {getResolvedUserInfo, getCommonSessionDetails} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let {roleId} = getResolvedUserInfo()
  let {merchantId, profileId} = getCommonSessionDetails()
  let path = url.path->HSwitchUtils.urlPath
  switch path {
  | list{"monitoring", viewId} =>
    switch viewId->MonitoringUtils.getDestinationFromRouteId {
    | Some(destination) =>
      <Monitoring key={`${viewId}:${merchantId}:${profileId}:${roleId}`} destination />
    | None => <NotFoundPage />
    }
  | _ => <NotFoundPage />
  }
}
