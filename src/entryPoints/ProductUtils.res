open ProductTypes
let getProductVariantFromString = product => {
  switch product->String.toLowerCase {
  | "recon" => Recon
  | "recovery" => Recovery
  | "vault" => Vault
  | "cost_observability" => CostObservability
  | "dynamic_routing" => DynamicRouting
  | _ => Orchestration
  }
}

let getProductDisplayName = product =>
  switch product {
  | Recon => "Recon"
  | Recovery => "Revenue Recovery"
  | Orchestration => "Orchestrator"
  | Vault => "Vault"
  | CostObservability => "Cost Observability"
  | DynamicRouting => "Intelligent Routing"
  }

let getProductVariantFromDisplayName = product => {
  switch product {
  | "Recon" => Recon
  | "Revenue Recovery" => Recovery
  | "Orchestrator" => Orchestration
  | "Vault" => Vault
  | "Cost Observability" => CostObservability
  | "Intelligent Routing" => DynamicRouting
  | _ => Orchestration
  }
}
let preservedRoutes = ["organization-chart", "account-settings"]

let isPreservedRoute = url => {
  preservedRoutes->Array.some(route => url->String.includes(route))
}

let getDefaultProductRoute = (productType: ProductTypes.productTypes) => {
  switch productType {
  | Recon => `/dashboard/v2/recon/overview`
  | Recovery => `/dashboard/v2/recovery/overview`
  | Vault
  | CostObservability
  | DynamicRouting =>
    `/dashboard/v2/${(Obj.magic(productType) :> string)->LogicUtils.toKebabCase}/home`
  | Orchestration => `/dashboard/home` // default for orchestration
  }
}

let getProductUrl = (~productType: ProductTypes.productTypes, ~url) => {
  if isPreservedRoute(url) {
    url
  } else {
    switch productType {
    | Orchestration =>
      if url->String.includes("v2") {
        getDefaultProductRoute(Orchestration)
      } else {
        url
      }
    | _ => getDefaultProductRoute(productType)
    }
  }
}
