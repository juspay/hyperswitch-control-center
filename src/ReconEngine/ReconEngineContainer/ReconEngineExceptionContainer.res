@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "exceptions", "recon", ...remainingPath} =>
    <EntityScaffold
      entityName="Exceptions"
      remainingPath
      access=Access
      renderList={() =>
        <FilterContext key="recon-engine-exceptions" index="recon-engine-exception">
          <ReconEngineExceptions />
        </FilterContext>}
      renderShow={(id, _) => <ReconEngineExceptionsDetails id />}
    />
  | list{"v1", "recon-engine", "exceptions", "transformed-entries", ...remainingPath} =>
    <EntityScaffold
      entityName="Exceptions"
      remainingPath
      access=Access
      renderList={() =>
        <FilterContext
          key="recon-engine-transformed-entry-exceptions"
          index="recon-engine-transformed-entry-exceptions">
          <ReconEngineTransformedEntryExceptions />
        </FilterContext>}
      renderShow={(id, _) => <ReconEngineTransformedEntryExceptionsDetails id />}
    />
  | _ => React.null
  }
}
