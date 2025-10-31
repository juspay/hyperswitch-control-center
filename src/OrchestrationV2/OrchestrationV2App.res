@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path->HSwitchUtils.urlPath {
  | list{"v2", "orchestration", "home", ..._} => <OrchestrationV2Home />
  | list{"v2", "orchestration", "connectors", ..._}
  | list{"v2", "orchestration", "payment-settings", ..._} =>
    <ConnectorContainerV2 />
  | list{"v2", "orchestration", "payments", ..._} => <TransactionContainerV2 />
  | list{"v2", "orchestration", "developer-api-keys", ..._} => <KeyManagement />
  | _ => <EmptyPage path="/v2/orchestration/home" />
  }
}
