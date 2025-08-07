@react.component
let make = () => {
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
  switch activeProduct {
  | Orchestration(V1) => <EmptyPage path="/home" />
  | Orchestration(V2) => <EmptyPage path="/v2/orchestration/home" />
  | Recon(V1) => <EmptyPage path="/v1/recon-engine/overview" />
  | Recon(V2) => <EmptyPage path="/v2/recon/overview" />
  | Recovery => <EmptyPage path="/v2/recovery/overview" />
  | Vault => <EmptyPage path="/v2/vault/home" />
  | CostObservability => <EmptyPage path="/v2/cost-observability/home" />
  | DynamicRouting => <EmptyPage path="/v2/dynamic-routing" />
  | UnknownProduct => React.null
  }
}
