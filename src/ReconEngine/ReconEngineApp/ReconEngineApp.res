@react.component
let make = () => {
  open HSwitchUtils
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->urlPath {
    | list{"v1", "recon-engine", "overview"} => <ReconEngineOverviewContainer />
    | list{"v1", "recon-engine", "transactions", ..._} => <ReconEngineTransactionContainer />
    | list{"v1", "recon-engine", "exceptions", ..._} => <ReconEngineExceptionContainer />
    | list{"v1", "recon-engine", "file-management", ..._} => <ReconEngineFileManagementContainer />
    | list{"v1", "recon-engine", "rules", ..._} => <ReconEngineRulesContainer />
    | _ => React.null
    }
  }
}
