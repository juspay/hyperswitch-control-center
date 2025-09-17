@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  let breadCrumbNavigationPath: array<BreadCrumbNavigation.breadcrumb> = [
    {title: "Transformation", link: `/v1/recon-engine/transformation`},
  ]

  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "transformation", "ingestion-history", ingestionHistoryId} =>
    <ReconEngineAccountsOverview
      breadCrumbNavigationPath={breadCrumbNavigationPath} ingestionHistoryId={ingestionHistoryId}
    />
  | list{"v1", "recon-engine", "transformation", ...remainingPath} =>
    <EntityScaffold
      entityName="IngestionHistory"
      remainingPath
      access=Access
      renderList={() => <ReconEngineAccountsTransformation />}
      renderShow={(accountId, _) =>
        <ReconEngineAccountsTransformationDetails accountId={accountId} />}
    />
  | _ => React.null
  }
}
