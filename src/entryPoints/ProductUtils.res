open ProductTypes
let getVariantFromString = product =>
  switch product {
  | "Recon" => Recon
  | "Recovery" => Recovery
  | "Vault" => Vault
  | "Alt Payment Methods" => AltPaymentMethods
  | _ => Orchestrator
  }

let getStringFromVariant = product =>
  switch product {
  | Recon => "Recon"
  | Recovery => "Recovery"
  | Orchestrator => "Orchestrator"
  | Vault => "Vault"
  | AltPaymentMethods => "Alt Payment Methods"
  }
