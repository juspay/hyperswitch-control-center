open ProductTypes
let getProductVariantFromString = (product, ~version: UserInfoTypes.version) => {
  switch product->String.toLowerCase {
  | "recon" => Recon
  | "recovery" => Recovery
  | "vault" => Vault
  | "cost_observability" => CostObservability
  | "dynamic_routing" => DynamicRouting
  | _ =>
    switch version {
    | V1 => Orchestration(V1)
    | V2 => Orchestration(V2)
    }
  }
}

let getProductDisplayName = product =>
  switch product {
  | Recon => "Recon"
  | Recovery => "Revenue Recovery"
  | Orchestration(V1) => "Orchestrator"
  | Vault => "Vault"
  | CostObservability => "Cost Observability"
  | DynamicRouting => "Intelligent Routing"
  | Orchestration(V2) => "Orchestrator V2"
  }

let getProductRouteName = product =>
  switch product {
  | Recon => "recon"
  | Recovery => "recovery"
  | Vault => "vault"
  | CostObservability => "cost-observability"
  | DynamicRouting => "dynamic-routing"
  | Orchestration(V1) => "orchestration"
  | Orchestration(V2) => "orchestration"
  }

let getProductStringName = product =>
  switch product {
  | Recon => "recon"
  | Recovery => "recovery"
  | Vault => "vault"
  | CostObservability => "cost_observability"
  | DynamicRouting => "dynamic_routing"
  | Orchestration(V1) => "orchestration"
  | Orchestration(V2) => "orchestration"
  }

let getProductStringDisplayName = product =>
  switch product {
  | Recon => "recon"
  | Recovery => "revenue_recovery"
  | Vault => "vault"
  | CostObservability => "cost_observability"
  | DynamicRouting => "intelligent_routing"
  | Orchestration(V1)
  | Orchestration(V2) => "orchestration"
  }

let getProductVariantFromDisplayName = product => {
  switch product {
  | "Recon" => Recon
  | "Revenue Recovery" => Recovery
  | "Orchestrator" => Orchestration(V1)
  | "Vault" => Vault
  | "Cost Observability" => CostObservability
  | "Intelligent Routing" => DynamicRouting
  | "Orchestrator V2" => Orchestration(V2)
  | _ => Orchestration(V1)
  }
}

let getProductUrl = (~productType: ProductTypes.productTypes, ~url) => {
  switch productType {
  | Orchestration(V1) =>
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
  | Orchestration(V2) =>
    `/dashboard/v2/${productType->getProductRouteName}/home`
  }
}
