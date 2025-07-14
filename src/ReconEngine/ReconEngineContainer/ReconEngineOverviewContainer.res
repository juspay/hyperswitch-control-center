@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "overview", ...remainingPath} =>
    <EntityScaffold
      entityName="ReconEngine"
      remainingPath
      access=Access
      renderList={() => <ReconEngineOverview />}
      renderShow={(id, _) => <ReconEngineAccount id />}
    />
  | _ => React.null
  }
}
