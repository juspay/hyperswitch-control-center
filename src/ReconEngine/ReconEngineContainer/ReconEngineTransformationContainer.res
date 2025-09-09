@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "transformation"} => <ReconEngineAccountsTransformation />
  | _ => React.null
  }
}
