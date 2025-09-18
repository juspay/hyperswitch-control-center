@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  let breadCrumbNavigationPath: array<BreadCrumbNavigation.breadcrumb> = [
    {title: "Sources", link: `/v1/recon-engine/sources`},
  ]

  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "sources", "ingestion-history", ingestionHistoryId} =>
    <ReconEngineAccountsOverview
      breadCrumbNavigationPath={breadCrumbNavigationPath} ingestionHistoryId={ingestionHistoryId}
    />
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
