@react.component
let make = () => {
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
  Js.log2(activeProduct, "ACTIVE PRODUCT")
  switch activeProduct {
  | Orchestration(V1) => <EmptyPage path="/home" />
  | Orchestration(V2) => <EmptyPage path="/v2/orchestration/home" />
  | Recon => <EmptyPage path="/v2/recon/overview" />
  | Recovery => <EmptyPage path="/v2/recovery/overview" />
  | Vault => <EmptyPage path="/v2/vault/home" />
  | CostObservability => <EmptyPage path="/v2/cost-observability/home" />
  | DynamicRouting => <EmptyPage path="/v2/dynamic-routing/home" />
  | Invalid => React.null
  }
}
