open ProductTypes
let getVariantFromString = product =>
  switch product {
  | "Recon" => Recon
  | "Recovery" => Recovery
  | "Vault" => Vault
  | "Alternate Payment Methods" => AlternatePaymentMethods
  | _ => Orchestrator
  }

let getStringFromVariant = product =>
  switch product {
  | Recon => "Recon"
  | Recovery => "Recovery"
  | Orchestrator => "Orchestrator"
  | Vault => "Vault"
  | AlternatePaymentMethods => "Alternate Payment Methods"
  }
