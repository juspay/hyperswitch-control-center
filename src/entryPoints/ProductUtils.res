open ProductTypes
let getProductVariantFromString = product => {
  switch product->String.toLowerCase {
  | "recon" => Recon
  | "recovery" => Recovery
  | "vault" => Vault
  | "cost_observability" => CostObservability
  | "dynamic_routing" => DynamicRouting
  | _ => Orchestration
  }
}

let getProductDisplayName = product =>
  switch product {
  | Recon => "Reconciliation"
  | Recovery => "Revenue Recovery"
  | Orchestration => "Orchestrator"
  | Vault => "Vault"
  | CostObservability => "Cost Observability"
  | DynamicRouting => "Intelligent Routing"
  }

let getProductVariantFromDisplayName = product => {
  switch product {
  | "Reconciliation" => Recon
  | "Revenue Recovery" => Recovery
  | "Orchestrator" => Orchestration
  | "Vault" => Vault
  | "Cost Observability" => CostObservability
  | "Intelligent Routing" => DynamicRouting
  | _ => Orchestration
  }
}

let productTypeIconMapper = productType => {
  switch productType {
  | Orchestration => "orchestrator-home"
  | Recon => "recon-home"
  | Recovery => "recovery-home"
  | Vault => "vault-home"
  | CostObservability => "cost-observability-home"
  | DynamicRouting => "intelligent-routing-home"
  }
}

let getProductUrl = (~productType: ProductTypes.productTypes, ~url) => {
  switch productType {
  | Orchestration => `/dashboard/home`
  | Recon => `/dashboard/v2/recon/overview`
  | Recovery => `/dashboard/v2/recovery/overview`
  | Vault
  | CostObservability
  | DynamicRouting =>
    `/dashboard/v2/${(Obj.magic(productType) :> string)->LogicUtils.toKebabCase}/home`
  }
}
