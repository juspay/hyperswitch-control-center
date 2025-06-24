open SidebarValues
open SidebarTypes
open FeatureFlagUtils

let useGetHsSidebarValues = (~isReconEnabled: bool) => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasResourceAccess} = GroupACLHooks.useUserGroupACLHook()
  let {userInfo: {userEntity}, checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let {
    frm,
    payOut,
    recon,
    default,
    surcharge: isSurchargeEnabled,
    isLiveMode,
    threedsAuthenticator,
    disputeAnalytics,
    configurePmts,
    complianceCertificate,
    performanceMonitor: performanceMonitorFlag,
    pmAuthenticationProcessor,
    taxProcessor,
    newAnalytics,
    authenticationAnalytics,
    devAltPaymentMethods,
    devWebhooks,
    threedsExemptionRules,
    paymentSettingsV2,
  } = featureFlagDetails
  let {
    useIsFeatureEnabledForMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()
  let isNewAnalyticsEnable =
    newAnalytics && useIsFeatureEnabledForMerchant(merchantSpecificConfig.newAnalytics)
  let sidebar = [
    default->home,
    default->operations(~userHasResourceAccess, ~isPayoutsEnabled=payOut, ~userEntity),
    default->connectors(
      ~isLiveMode,
      ~isFrmEnabled=frm,
      ~isPayoutsEnabled=payOut,
      ~isThreedsConnectorEnabled=threedsAuthenticator,
      ~isPMAuthenticationProcessor=pmAuthenticationProcessor,
      ~isTaxProcessor=taxProcessor,
      ~userHasResourceAccess,
    ),
    default->analytics(
      disputeAnalytics,
      performanceMonitorFlag,
      isNewAnalyticsEnable,
      ~authenticationAnalyticsFlag=authenticationAnalytics,
      ~userHasResourceAccess,
    ),
    default->workflow(
      isSurchargeEnabled,
      threedsExemptionRules,
      ~userHasResourceAccess,
      ~isPayoutEnabled=payOut,
      ~userEntity,
    ),
    devAltPaymentMethods->alternatePaymentMethods,
    recon->reconAndSettlement(isReconEnabled, checkUserEntity, userHasResourceAccess),
    default->developers(
      ~isWebhooksEnabled=devWebhooks,
      ~userHasResourceAccess,
      ~checkUserEntity,
      ~isPaymentSettingsV2Enabled=paymentSettingsV2,
    ),
    settings(~isConfigurePmtsEnabled=configurePmts, ~userHasResourceAccess, ~complianceCertificate),
  ]

  sidebar
}

let useGetOrchestratorSidebars = (~isReconEnabled) => useGetHsSidebarValues(~isReconEnabled)

let getAllProductsBasedOnFeatureFlags = (featureFlagDetails: featureFlag) => {
  let products = [ProductTypes.Orchestration]

  if featureFlagDetails.devReconv2Product {
    products->Array.push(ProductTypes.Recon)->ignore
  }

  if featureFlagDetails.devRecoveryV2Product {
    products->Array.push(ProductTypes.Recovery)->ignore
  }

  if featureFlagDetails.devVaultV2Product {
    products->Array.push(ProductTypes.Vault)->ignore
  }

  if featureFlagDetails.devHypersenseV2Product {
    products->Array.push(ProductTypes.CostObservability)->ignore
  }

  if featureFlagDetails.devIntelligentRoutingV2 {
    products->Array.push(ProductTypes.DynamicRouting)->ignore
  }

  products
}

let useGetAllProductSections = (~isReconEnabled, ~products: array<ProductTypes.productTypes>) => {
  let orchestratorSidebars = useGetOrchestratorSidebars(~isReconEnabled)

  products->Array.map(productType => {
    let links = switch productType {
    | Orchestration => orchestratorSidebars
    | Recon => ReconSidebarValues.reconSidebars
    | Recovery => RevenueRecoverySidebarValues.recoverySidebars
    | Vault => VaultSidebarValues.vaultSidebars
    | CostObservability => HypersenseSidebarValues.hypersenseSidebars
    | DynamicRouting => IntelligentRoutingSidebarValues.intelligentRoutingSidebars
    }

    {
      name: productType->ProductUtils.getProductDisplayName,
      icon: productType->ProductUtils.productTypeIconMapper,
      links,
      showSection: true,
    }
  })
}

let useGetSidebarProductModules = (~isExplored) => {
  let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let allProducts = getAllProductsBasedOnFeatureFlags(featureFlagDetails)

  let filteredProducts = allProducts->Array.filter(productType => {
    let hasProduct = merchantList->Array.some(merchant => {
      switch merchant.productType {
      | Some(merchantProductType) => merchantProductType === productType
      | None => false
      }
    })
    isExplored ? hasProduct : !hasProduct
  })

  filteredProducts
}
