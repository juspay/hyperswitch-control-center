@react.component
let make = () => {
  open HSwitchUtils
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->urlPath {
    | list{"v1", "recon-engine", "overview"} => <ReconEngineOverviewContainer />
    | list{"v1", "recon-engine", "transactions"} => <ReconEngineTransactionContainer />
    | list{"v1", "recon-engine", "exceptions"} => <ReconEngineExceptionContainer />
    | list{"v1", "recon-engine", "queue"} => <ReconEngineQueueContainer />
    | list{"v1", "recon-engine", "rules"} => <ReconEngineRulesContainer />
    | _ => React.null
    }
  }
}
