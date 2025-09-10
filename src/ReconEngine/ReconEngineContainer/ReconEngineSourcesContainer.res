@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "sources", "ingestion-history", id} =>
    <ReconEngineAccountsOverview id={id} />
  | list{"v1", "recon-engine", "sources", ...remainingPath} =>
    <EntityScaffold
      entityName="IngestionHistory"
      remainingPath
      access=Access
      renderList={() => <ReconEngineAccountsSources />}
      renderShow={(accountId, _) => <ReconEngineAccountSourceDetails accountId={accountId} />}
    />
  | _ => React.null
  }
}
