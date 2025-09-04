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
    | list{"v1", "recon-engine", "accounts", ..._} => <ReconEngineAccountsContainer />
    | _ => <EmptyPage path="/v1/recon-engine/overview" />
    }
  }
}
