@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "rules", ...remainingPath} =>
    <EntityScaffold
      entityName="ReconEngine" remainingPath access=Access renderList={() => <ReconEngineRule />}
    />
  | _ => React.null
  }
}
