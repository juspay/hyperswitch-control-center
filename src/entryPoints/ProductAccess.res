open FeatureFlagUtils
open ProductTypes

type productAccessConfig = {
  apiVersion: UserInfoTypes.version,
  isFlagEnabled: featureFlag => bool,
}

let getProductAccessConfig = (product: productTypes): productAccessConfig =>
  switch product {
  | Orchestration(V1) => {apiVersion: V1, isFlagEnabled: _ => true}
  | Orchestration(V2) => {apiVersion: V2, isFlagEnabled: flags => flags.devOrchestrationV2Product}
  | Recon(V1) => {apiVersion: V1, isFlagEnabled: flags => flags.devReconEngineV1}
  | Recon(V2) => {apiVersion: V2, isFlagEnabled: flags => flags.devReconv2Product}
  | Recovery => {apiVersion: V2, isFlagEnabled: flags => flags.devRecoveryV2Product}
  | Vault => {apiVersion: V2, isFlagEnabled: flags => flags.devVaultV2Product}
  | CostObservability => {apiVersion: V1, isFlagEnabled: flags => flags.devHypersenseV2Product}
  | DynamicRouting => {apiVersion: V1, isFlagEnabled: flags => flags.devIntelligentRoutingV2}
  | OnBoarding(_)
  | UnknownProduct => {apiVersion: V1, isFlagEnabled: _ => true}
  }

let hasApiVersionAccess = (version: UserInfoTypes.version, ~featureFlags: featureFlag) =>
  switch version {
  | V1 => true
  | V2 => featureFlags.apiV2Enabled
  }

let hasProductAccess = (product, ~featureFlags) => {
  let {apiVersion, isFlagEnabled} = product->getProductAccessConfig
  apiVersion->hasApiVersionAccess(~featureFlags) && featureFlags->isFlagEnabled
}

let hasMerchantAccess = (~version, ~product, ~featureFlags) =>
  version->hasApiVersionAccess(~featureFlags) && product->hasProductAccess(~featureFlags)
