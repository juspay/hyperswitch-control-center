open ProductTypes
let getVariantFromString = product =>
  switch product->String.toLowerCase {
  | "recon" => Recon
  | "recovery" => Recovery
  | "vault" => Vault
  | "hypersense" => CostObservability
  | "intelligent routing" => IntelligentRouting
  | _ => Orchestration
  }

let getStringFromVariant = product =>
  switch product {
  | Recon => "Recon"
  | Recovery => "Recovery"
  | Orchestration => "Orchestrator"
  | Vault => "Vault"
  | CostObservability => "Hypersense"
  | IntelligentRouting => "Intelligent Routing"
  }
