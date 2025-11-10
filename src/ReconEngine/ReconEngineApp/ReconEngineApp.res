@react.component
let make = () => {
  open HSwitchUtils
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->urlPath {
    | list{"v1", "recon-engine", "overview"} => <ReconEngineOverviewContainer />
    | list{"v1", "recon-engine", "transactions", ..._} => <ReconEngineTransactionContainer />
    | list{"v1", "recon-engine", "exceptions", ..._} => <ReconEngineExceptionContainer />
    | list{"v1", "recon-engine", "rules", ..._} => <ReconEngineRulesContainer />
    | list{"v1", "recon-engine", "sources", ..._} => <ReconEngineSourcesContainer />
    | list{"v1", "recon-engine", "transformation", ..._} => <ReconEngineTransformationContainer />
    | list{"v1", "recon-engine", "transformed-entries", ..._} =>
      <ReconEngineTransformedEntriesContainer />
    | _ => <EmptyPage path="/v1/recon-engine/overview" />
    }
  }
}
