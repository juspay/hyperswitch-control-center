@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path->HSwitchUtils.urlPath {
  | list{"v2", "orchestration", "home", ..._} => <OrchestrationV2Home />
  | list{"v2", "orchestration", "connectors", ..._} => <ConnectorContainerV2 />
  | list{"v2", "orchestration", "payments", ..._} => <TransactionContainerV2 />
  | list{"v2", "orchestration", "developer-api-keys", ..._} => <KeyManagement />
  | _ => React.null
  }
}
