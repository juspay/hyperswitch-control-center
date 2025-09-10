@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "transformed-entries"} => <ReconEngineAccountsTransformedEntries />
  | _ => React.null
  }
}
