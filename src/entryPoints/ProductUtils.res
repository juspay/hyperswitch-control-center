open ProductTypes
let getProductVariantFromString = (product, ~version: UserInfoTypes.version) => {
  switch product->String.toLowerCase {
  | "recon" =>
    switch version {
    | V1 => Recon(V1)
    | V2 => Recon(V2)
    }
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
  | Recon(V2) => "Recon"
  | Recon(V1) => "Reconciliation"
  | Recovery => "Revenue Recovery"
  | Orchestration(V1) => "Orchestrator"
  | Vault => "Vault"
  | CostObservability => "Cost Observability"
  | DynamicRouting => "Intelligent Routing"
  | Orchestration(V2) => "Orchestrator V2"
  | OnBoarding(_) => ""
  | UnknownProduct => ""
  }

let getProductRouteName = product =>
  switch product {
  | Recon(V2)
  | Recon(V1) => "recon"
  | Recovery => "recovery"
  | Vault => "vault"
  | CostObservability => "cost-observability"
  | DynamicRouting => "dynamic-routing"
  | Orchestration(V1) => "orchestration"
  | Orchestration(V2) => "orchestration"
  | OnBoarding(_) => ""
  | UnknownProduct => ""
  }

let getProductStringName = product =>
  switch product {
  | Recon(V1)
  | Recon(V2) => "recon"
  | Recovery => "recovery"
  | Vault => "vault"
  | CostObservability => "cost_observability"
  | DynamicRouting => "dynamic_routing"
  | Orchestration(V1) => "orchestration"
  | Orchestration(V2) => "orchestration"
  | OnBoarding(_) => ""
  | UnknownProduct => ""
  }

let getProductStringDisplayName = product =>
  switch product {
  | Recon(V1)
  | Recon(V2) => "recon"
  | Recovery => "revenue_recovery"
  | Vault => "vault"
  | CostObservability => "cost_observability"
  | DynamicRouting => "intelligent_routing"
  | Orchestration(V1)
  | Orchestration(V2) => "orchestration"
  | OnBoarding(_) => ""
  | UnknownProduct => ""
  }

let getProductVariantFromDisplayName = product => {
  switch product {
  | "Reconciliation" => Recon(V1)
  | "Recon" => Recon(V2)
  | "Revenue Recovery" => Recovery
  | "Orchestrator" => Orchestration(V1)
  | "Vault" => Vault
  | "Cost Observability" => CostObservability
  | "Intelligent Routing" => DynamicRouting
  | "Orchestrator V2" => Orchestration(V2)
  | _ => Orchestration(V1)
  }
}

let productTypeIconMapper = productType => {
  switch productType {
  | Orchestration(V1)
  | Orchestration(V2) => "orchestrator-home"
  | Recovery => "recovery-home"
  | Vault => "vault-home"
  | CostObservability => "nd-piggy-bank"
  | DynamicRouting => "intelligent-routing-home"
  | Recon(V1) => "recon-engine-v1"
  | Recon(V2) => "recon-home"
  | OnBoarding(_) => ""
  | UnknownProduct => ""
  }
}

let getProductUrl = (~productType: ProductTypes.productTypes, ~isLiveMode) => {
  switch productType {
  | Orchestration(V1) => `/dashboard/home`
  | Recon(V2) => `/dashboard/v2/recon/overview`
  | Recon(V1) => `/dashboard/v1/recon-engine/overview`
  | Recovery =>
    if isLiveMode {
      "/dashboard/v2/recovery/invoices"
    } else {
      "/dashboard/v2/recovery/overview"
    }
  | Vault
  | CostObservability
  | DynamicRouting
  | Orchestration(V2) =>
    `/dashboard/v2/${productType->getProductRouteName}/home`
  | OnBoarding(_) => ""
  | UnknownProduct => ""
  }
}
