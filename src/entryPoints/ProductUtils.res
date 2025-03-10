open ProductTypes
let getVariantFromString = product =>
  switch product->String.toLowerCase {
  | "recon" => Recon
  | "recovery" => Recovery
  | "vault" => Vault
  | "alternate payment methods" => AlternatePaymentMethods
  | "hypersense" => Hypersense
  | "intelligent Routing" => IntelligentRouting
  | _ => Orchestrator
  }

let getStringFromVariant = product =>
  switch product {
  | Recon => "Recon"
  | Recovery => "Recovery"
  | Orchestrator => "Orchestrator"
  | Vault => "Vault"
  | AlternatePaymentMethods => "Alternate Payment Methods"
  | Hypersense => "Hypersense"
  | IntelligentRouting => "Intelligent Routing"
  }
