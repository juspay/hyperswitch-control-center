@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)

  {
    switch activeProduct {
    | Orchestration(V2) =>
      switch url.path->HSwitchUtils.urlPath {
      | list{"v2", "orchestration", "home", ..._} => <OrchestrationV2Home />
      | list{"v2", "orchestration", "connectors", ..._} => <ConnectorContainerV2 />
      | list{"v2", "orchestration", "payments", ..._} => <TransactionContainerV2 />
      | _ => <EmptyPage path="/v2/orchestration/home" />
      }
    | _ => React.null
    }
  }
}
