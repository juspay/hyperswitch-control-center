module LegacyRedirect = {
  @react.component
  let make = (~fileId: string) => {
    React.useEffect0(() => {
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url=`/v1/recon-engine/sources?file=${fileId}`),
      )
      None
    })
    React.null
  }
}

@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path->HSwitchUtils.urlPath {
  /* Legacy drilldown URL — collapse into the new Sources page with the file pre-selected. */
  | list{"v1", "recon-engine", "sources", "ingestion-history", ingestionHistoryId} =>
    <LegacyRedirect fileId={ingestionHistoryId} />
  /* "manage" is a sentinel route: the source-detail page in cross-account mode.
   Intercepted before EntityScaffold so it never gets treated as an accountId. */
  | list{"v1", "recon-engine", "sources", "manage"} => <ReconEngineSourceDetailPage accountId="" />
  | list{"v1", "recon-engine", "sources", ...remainingPath} =>
    <EntityScaffold
      entityName="ReconEngineSources"
      remainingPath
      access=Access
      renderList={() => <ReconEngineSourcesPage />}
      renderShow={(accountId, _) => <ReconEngineSourceDetailPage accountId />}
    />
  | _ => React.null
  }
}
