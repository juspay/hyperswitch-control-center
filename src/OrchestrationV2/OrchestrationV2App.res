@react.component
let make = () => {
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)

  {
    switch merchantDetailsTypedValue.product_type {
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
