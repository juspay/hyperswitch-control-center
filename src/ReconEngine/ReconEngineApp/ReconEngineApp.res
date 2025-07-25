@react.component
let make = () => {
  open HSwitchUtils
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->urlPath {
    | list{"v1", "recon-engine", "overview"} => <ReconEngineOverviewContainer />
    | list{"v1", "recon-engine", "transactions", ..._} => <ReconEngineTransactionContainer />
    | list{"v1", "recon-engine", "exceptions", ..._} => <ReconEngineExceptionContainer />
    | list{"v1", "recon-engine", "queue"} => <ReconEngineQueueContainer />
    | list{"v1", "recon-engine", "rules", ..._} => <ReconEngineRulesContainer />
    | list{"v1", "recon-engine", "connection", ..._} => <ReconEngineConnectionContainer />
    | _ => React.null
    }
  }
}
