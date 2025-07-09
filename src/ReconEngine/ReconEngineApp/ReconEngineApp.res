@react.component
let make = () => {
  open HSwitchUtils
  let url = RescriptReactRouter.useUrl()

  Js.log2("ReconEngineApp url", url)

  {
    switch url.path->urlPath {
    | list{"v2", "recon-engine", "overview"} => <ReconEngineOverviewContainer />
    | list{"v2", "recon-engine", "transactions"} => <ReconEngineTransactionContainer />
    | list{"v2", "recon-engine", "exceptions"} => <ReconEngineExceptionContainer />
    | list{"v2", "recon-engine", "queue"} => <ReconEngineQueueContainer />
    | list{"v2", "recon-engine", "rules"} => <ReconEngineRulesContainer />
    | _ => React.null
    }
  }
}
