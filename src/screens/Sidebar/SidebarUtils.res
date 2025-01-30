open ProviderTypes
let getVariantFromString = product =>
  switch product {
  | "Recon" => Recon
  | "Recovery" => Recovery
  | _ => Orchestrator
  }

let getStringFromVariant = product =>
  switch product {
  | Recon => "Recon"
  | Recovery => "Recovery"
  | Orchestrator => "Orchestrator"
  }
