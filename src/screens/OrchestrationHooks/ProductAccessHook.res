type productAccess = {
  hasApiVersionAccess: UserInfoTypes.version => bool,
  hasProductAccess: ProductTypes.productTypes => bool,
}

let useProductAccess = () => {
  let featureFlags = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {
    isFeatureEnabledForAllowListMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()

  let hasApiVersionAccess = version => version->ProductAccess.hasApiVersionAccess(~featureFlags)

  let hasProductAccess = (product: ProductTypes.productTypes) => {
    let isMerchantAllowed = switch product {
    | Recon(V1) => isFeatureEnabledForAllowListMerchant(merchantSpecificConfig.devReconEngineV1)
    | _ => true
    }
    isMerchantAllowed && product->ProductAccess.hasProductAccess(~featureFlags)
  }

  {hasApiVersionAccess, hasProductAccess}
}
