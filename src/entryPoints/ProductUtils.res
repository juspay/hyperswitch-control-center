open ProductTypes
let getProductVariantFromString = product => {
  switch product->String.toLowerCase {
  | "recon" => Recon
  | "recovery" => Recovery
  | "vault" => Vault
  | "cost_observability" => CostObservability
  | "dynamic_routing" => DynamicRouting
  | "alternate_payment_methods" => AlternatePaymentMethods
  | _ => Orchestration
  }
}

let getProductDisplayName = product =>
  switch product {
  | Recon => "Recon"
  | Recovery => "Recovery"
  | Orchestration => "Orchestrator"
  | Vault => "Vault"
  | CostObservability => "Cost Observability"
  | DynamicRouting => "Intelligent Routing"
  | AlternatePaymentMethods => "Alternate Payment Methods"
  }

let getProductVariantFromDisplayName = product => {
  switch product {
  | "Recon" => Recon
  | "Recovery" => Recovery
  | "Orchestrator" => Orchestration
  | "Vault" => Vault
  | "Cost Observability" => CostObservability
  | "Intelligent Routing" => DynamicRouting
  | "Alternate Payment Methods" => AlternatePaymentMethods
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
  | Recovery => `/dashboard/v2/recovery/overview`
  | _ => `/dashboard/v2/${(Obj.magic(productType) :> string)->LogicUtils.toKebabCase}/home`
  }
}
