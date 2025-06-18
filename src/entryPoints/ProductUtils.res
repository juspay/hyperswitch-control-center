open ProductTypes
let getProductVariantFromString = product => {
  switch product->String.toLowerCase {
  | "recon" => Recon
  | "recovery" => Recovery
  | "vault" => Vault
  | "cost_observability" => CostObservability
  | "dynamic_routing" => DynamicRouting
  | "orchestration_v2" => OrchestrationV2
  | _ => Orchestration
  }
}

let getProductDisplayName = product =>
  switch product {
  | Recon => "Recon"
  | Recovery => "Revenue Recovery"
  | Orchestration => "Orchestrator"
  | Vault => "Vault"
  | CostObservability => "Cost Observability"
  | DynamicRouting => "Intelligent Routing"
  | OrchestrationV2 => "Orchestrator V2"
  }

let getProductVariantFromDisplayName = product => {
  switch product {
  | "Recon" => Recon
  | "Revenue Recovery" => Recovery
  | "Orchestrator" => Orchestration
  | "Vault" => Vault
  | "Cost Observability" => CostObservability
  | "Intelligent Routing" => DynamicRouting
  | "Orchestrator V2" => OrchestrationV2
  | _ => Orchestration
  }
}

let getProductUrl = (~productType: ProductTypes.productTypes, ~url) => {
  switch productType {
  | Orchestration =>
    if url->String.includes("v2") {
      `/dashboard/home`
    } else {
      url
    }
  | Recon => `/dashboard/v2/recon/overview`
  | Recovery => `/dashboard/v2/recovery/overview`
  | Vault
  | CostObservability
  | DynamicRouting
  | OrchestrationV2 =>
    `/dashboard/v2/${(Obj.magic(productType) :> string)->LogicUtils.toKebabCase}/home`
  }
}
