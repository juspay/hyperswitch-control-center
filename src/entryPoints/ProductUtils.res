open ProductTypes
let getVariantFromString = product =>
  switch product {
  | "Recon" => Recon
  | "Recovery" => Recovery
  | "Vault" => Vault
  | "Intelligent Routing" => IntelligentRouting
  | _ => Orchestrator
  }

let getStringFromVariant = product =>
  switch product {
  | Recon => "Recon"
  | Recovery => "Recovery"
  | Orchestrator => "Orchestrator"
  | Vault => "Vault"
  | IntelligentRouting => "Intelligent Routing"
  }
