@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "exceptions", ...remainingPath} =>
    <EntityScaffold
      entityName="Exceptions"
      remainingPath
      access=Access
      renderList={() => <ReconEngineExceptions />}
      renderShow={(id, _) => <ReconEngineExceptionsDetails id />}
    />
  | _ => React.null
  }
}
