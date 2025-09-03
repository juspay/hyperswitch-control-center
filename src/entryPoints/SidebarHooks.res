open SidebarValues
open SidebarTypes
open FeatureFlagUtils
open ProductTypes

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
    routingAnalytics,
  } = featureFlagDetails
  let {
    useIsFeatureEnabledForBlackListMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()
  let isNewAnalyticsEnable =
    newAnalytics && useIsFeatureEnabledForBlackListMerchant(merchantSpecificConfig.newAnalytics)
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
      routingAnalytics,
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
  let products = [ProductTypes.Orchestration(V1)]

  if featureFlagDetails.devReconv2Product {
    products->Array.push(ProductTypes.Recon(V2))->ignore
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

  if featureFlagDetails.devOrchestrationV2Product {
    products->Array.push(ProductTypes.Orchestration(V2))->ignore
  }

  if featureFlagDetails.devReconEngineV1 {
    products->Array.push(ProductTypes.Recon(V1))->ignore
  }

  products
}

let useGetAllProductSections = (~isReconEnabled, ~products: array<ProductTypes.productTypes>) => {
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode

  let orchestratorSidebars = useGetOrchestratorSidebars(~isReconEnabled)
  let orchestratorV2Sidebars = OrchestrationV2SidebarValues.useGetOrchestrationV2SidebarValues()

  products->Array.map(productType => {
    let links = switch productType {
    | Recon(V1) => ReconEngineSidebarValues.reconEngineSidebars
    | Recon(V2) => ReconSidebarValues.reconSidebars
    | Recovery => RevenueRecoverySidebarValues.recoverySidebars(isLiveMode)
    | Vault => VaultSidebarValues.vaultSidebars
    | CostObservability => HypersenseSidebarValues.hypersenseSidebars
    | DynamicRouting => IntelligentRoutingSidebarValues.intelligentRoutingSidebars
    | Orchestration(V2) => orchestratorV2Sidebars
    | _ => orchestratorSidebars
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
  let merchantListProducts =
    merchantList->Array.map(merchant => merchant.productType->Option.getOr(UnknownProduct))

  let uniqueMerchantListProducts = merchantListProducts->Array.reduce([], (acc, product) => {
    let alreadyExists = acc->Array.some(existingProduct => {
      switch (existingProduct, product) {
      | (Orchestration(V1), Orchestration(V1)) => true
      | (Orchestration(V2), Orchestration(V2)) => true
      | (Recon(V1), Recon(V1)) => true
      | (Recon(V2), Recon(V2)) => true
      | (Recovery, Recovery) => true
      | (Vault, Vault) => true
      | (CostObservability, CostObservability) => true
      | (DynamicRouting, DynamicRouting) => true
      | (UnknownProduct, UnknownProduct) => true
      | _ => false
      }
    })
    alreadyExists ? acc : acc->Array.concat([product])
  })
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let allProducts = getAllProductsBasedOnFeatureFlags(featureFlagDetails)
  let filteredProducts = allProducts->Array.filter(productType => {
    let hasProduct = merchantListProducts->Array.some(merchantProductType => {
      switch (merchantProductType, productType) {
      | (Orchestration(V1), Orchestration(V1)) => true
      | (Orchestration(V2), Orchestration(V2)) => true
      | (Recon(V1), Recon(V1)) => true
      | (Recon(V2), Recon(V2)) => true
      | (Recovery, Recovery) => true
      | (Vault, Vault) => true
      | (CostObservability, CostObservability) => true
      | (DynamicRouting, DynamicRouting) => true
      | _ => false
      }
    })
    isExplored ? hasProduct : !hasProduct
  })

  filteredProducts
}
