@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "transformed-entry-exceptions", ...remainingPath} =>
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
      renderShow={(_id, _) => React.null}
    />
  | _ => React.null
  }
}
