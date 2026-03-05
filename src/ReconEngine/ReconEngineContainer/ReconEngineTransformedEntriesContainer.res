@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  let breadCrumbNavigationPath: array<BreadCrumbNavigation.breadcrumb> = [
    {title: "Transformed Entries", link: `/v1/recon-engine/transformed-entries`},
  ]
  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "transformed-entries", "ingestion-history", ingestionHistoryId} =>
    <ReconEngineDataOverview breadCrumbNavigationPath ingestionHistoryId={ingestionHistoryId} />
  | list{"v1", "recon-engine", "transformed-entries"} =>
    <FilterContext
      key="recon-engine-accounts-transformed-entries"
      index="recon-engine-accounts-transformed-entries">
      <ReconEngineDataTransformedEntries />
    </FilterContext>
  | _ => React.null
  }
}
