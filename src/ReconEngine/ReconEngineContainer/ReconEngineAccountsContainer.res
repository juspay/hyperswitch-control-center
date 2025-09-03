@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "accounts", "sources"} => <ReconEngineAccountsSources />
  | list{"v1", "recon-engine", "accounts", "transformation"} =>
    <ReconEngineAccountsTransformation />
  | list{"v1", "recon-engine", "accounts", "transformed-entries"} =>
    <ReconEngineAccountsTransformedEntries />
  | _ => React.null
  }
}
