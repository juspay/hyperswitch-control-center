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
  /* Legacy drilldown — file lineage moved into Sources. */
  | list{"v1", "recon-engine", "transformation", "ingestion-history", ingestionHistoryId} =>
    <LegacyRedirect fileId={ingestionHistoryId} />
  /* Per-account legacy detail page now collapsed into the single Transformation page —
   the left rail handles selection. */
  | list{"v1", "recon-engine", "transformation", ..._} => <ReconEngineTransformationPage />
  | _ => React.null
  }
}
