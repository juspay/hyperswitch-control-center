open ProductTypes
let getVariantFromString = product =>
  switch product->String.toLowerCase {
  | "recon" => Recon
  | "recovery" => Recovery
  | "vault" => Vault
  | "alternate payment methods" => AlternatePaymentMethods
  | "hypersense" => CostObservability
  | "intelligent Routing" => DynamicRouting
  | _ => Orchestration
  }

let getStringFromVariant = product =>
  switch product {
  | Recon => "Recon"
  | Recovery => "Recovery"
  | Orchestration => "Orchestrator"
  | Vault => "Vault"
  | AlternatePaymentMethods => "Alternate Payment Methods"
  | CostObservability => "Hypersense"
  | DynamicRouting => "Intelligent Routing"
  }
