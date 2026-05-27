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
  /* Legacy drilldown — the file-centric story now lives in Sources. */
  | list{"v1", "recon-engine", "transformed-entries", "ingestion-history", ingestionHistoryId} =>
    <LegacyRedirect fileId={ingestionHistoryId} />
  | list{"v1", "recon-engine", "transformed-entries"} => <ReconEngineTransformedEntriesPage />
  | _ => React.null
  }
}
