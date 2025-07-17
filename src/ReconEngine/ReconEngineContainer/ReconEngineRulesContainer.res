@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "rules", ...remainingPath} =>
    <EntityScaffold
      entityName="ReconEngine"
      remainingPath
      access=Access
      renderList={() => <ReconEngineRule />}
      renderShow={(id, _) => <ReconEngineRuleDetails id />}
    />
  | _ => React.null
  }
}
