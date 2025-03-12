open ProductTypes
let getVariantFromString = product =>
  switch product->String.toLowerCase {
  | "recon" => Recon
  | "recovery" => Recovery
  | "vault" => Vault
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
  | CostObservability => "Hypersense"
  | DynamicRouting => "Intelligent Routing"
  | AlternatePaymentMethods => "Alternate Payment Methods"
  }

let getProductUrl = (~productType: ProductTypes.productTypes, ~url) => {
  switch productType {
  | Orchestration => url
  | _ =>
    `/v2/${productType
      ->getStringFromVariant
      ->LogicUtils.toKebabCase}/home`
  }
}
