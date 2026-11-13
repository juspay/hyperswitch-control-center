@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {merchantId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "api-keys", ...remainingPath} =>
    <EntityScaffold
      entityName="ReconApiKeys"
      remainingPath
      access=Access
      renderList={() => <ReconEngineApiKeys key=merchantId />}
    />
  | _ => React.null
  }
}
