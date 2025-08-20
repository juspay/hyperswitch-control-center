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

  products
}

let useGetAllProductSections = (~isReconEnabled, ~products: array<ProductTypes.productTypes>) => {
  let orchestratorSidebars = useGetOrchestratorSidebars(~isReconEnabled)
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  products->Array.map(productType => {
    let links = switch productType {
    | Recon(V1) => ReconEngineSidebarValues.reconEngineSidebars
    | Recon(V2) => ReconSidebarValues.reconSidebars
    | Recovery => RevenueRecoverySidebarValues.recoverySidebars(isLiveMode)
    | Vault => VaultSidebarValues.vaultSidebars
    | CostObservability => HypersenseSidebarValues.hypersenseSidebars
    | DynamicRouting => IntelligentRoutingSidebarValues.intelligentRoutingSidebars
    | Orchestration(V2) => OrchestrationV2SidebarValues.useGetOrchestrationV2SidebarValues()
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
  // let merchantListProducts = merchantList->Array.map(merchant => merchant.productType)
  let merchantListProducts = merchantList->Array.reduce([], (acc, merchant) => {
    switch merchant.productType {
    | Some(productType) => {
        let alreadyExists = acc->Array.some((existing: ProductTypes.productTypes) => {
          switch (existing, productType) {
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
        if alreadyExists {
          acc
        } else {
          acc->Array.push(productType)->ignore
          acc
        }
      }
    | None => acc
    }
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

// open SidebarValues
// open SidebarTypes
// open FeatureFlagUtils

// let useGetHsSidebarValues = (~isReconEnabled: bool) => {
//   let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
//   let {userHasResourceAccess} = GroupACLHooks.useUserGroupACLHook()
//   let {userInfo: {userEntity}, checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
//   let {
//     frm,
//     payOut,
//     recon,
//     default,
//     surcharge: isSurchargeEnabled,
//     isLiveMode,
//     threedsAuthenticator,
//     disputeAnalytics,
//     configurePmts,
//     complianceCertificate,
//     performanceMonitor: performanceMonitorFlag,
//     pmAuthenticationProcessor,
//     taxProcessor,
//     newAnalytics,
//     authenticationAnalytics,
//     devAltPaymentMethods,
//     devWebhooks,
//     threedsExemptionRules,
//     paymentSettingsV2,
//     routingAnalytics,
//   } = featureFlagDetails
//   let {
//     useIsFeatureEnabledForBlackListMerchant,
//     merchantSpecificConfig,
//   } = MerchantSpecificConfigHook.useMerchantSpecificConfig()
//   let isNewAnalyticsEnable =
//     newAnalytics && useIsFeatureEnabledForBlackListMerchant(merchantSpecificConfig.newAnalytics)
//   let sidebar = [
//     default->home,
//     default->operations(~userHasResourceAccess, ~isPayoutsEnabled=payOut, ~userEntity),
//     default->connectors(
//       ~isLiveMode,
//       ~isFrmEnabled=frm,
//       ~isPayoutsEnabled=payOut,
//       ~isThreedsConnectorEnabled=threedsAuthenticator,
//       ~isPMAuthenticationProcessor=pmAuthenticationProcessor,
//       ~isTaxProcessor=taxProcessor,
//       ~userHasResourceAccess,
//     ),
//     default->analytics(
//       disputeAnalytics,
//       performanceMonitorFlag,
//       isNewAnalyticsEnable,
//       routingAnalytics,
//       ~authenticationAnalyticsFlag=authenticationAnalytics,
//       ~userHasResourceAccess,
//     ),
//     default->workflow(
//       isSurchargeEnabled,
//       threedsExemptionRules,
//       ~userHasResourceAccess,
//       ~isPayoutEnabled=payOut,
//       ~userEntity,
//     ),
//     devAltPaymentMethods->alternatePaymentMethods,
//     recon->reconAndSettlement(isReconEnabled, checkUserEntity, userHasResourceAccess),
//     default->developers(
//       ~isWebhooksEnabled=devWebhooks,
//       ~userHasResourceAccess,
//       ~checkUserEntity,
//       ~isPaymentSettingsV2Enabled=paymentSettingsV2,
//     ),
//     settings(~isConfigurePmtsEnabled=configurePmts, ~userHasResourceAccess, ~complianceCertificate),
//   ]

//   sidebar
// }

// let useGetOrchestratorSidebars = (~isReconEnabled) => useGetHsSidebarValues(~isReconEnabled)

// let getAllProductsBasedOnFeatureFlags = (featureFlagDetails: featureFlag) => {
//   let products = [ProductTypes.Orchestration(V1)]

//   if featureFlagDetails.devReconv2Product {
//     products->Array.push(ProductTypes.Recon(V2))->ignore
//   }

//   if featureFlagDetails.devRecoveryV2Product {
//     products->Array.push(ProductTypes.Recovery)->ignore
//   }

//   if featureFlagDetails.devVaultV2Product {
//     products->Array.push(ProductTypes.Vault)->ignore
//   }

//   if featureFlagDetails.devHypersenseV2Product {
//     products->Array.push(ProductTypes.CostObservability)->ignore
//   }

//   if featureFlagDetails.devIntelligentRoutingV2 {
//     products->Array.push(ProductTypes.DynamicRouting)->ignore
//   }

//   products
// }

// let useGetAllProductSections = (
//   ~isReconEnabled,
//   ~products: array<ProductTypes.productTypes>,
//   ~version: UserInfoTypes.version,
// ) => {
//   let orchestratorSidebars = useGetOrchestratorSidebars(~isReconEnabled)
//   let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode

//   products->Array.map(productType => {
//     let links = switch productType {
//     // | Orchestration(V1) => orchestratorSidebars
//     // | Orchestration(V2) => orchestratorSidebars
//     | Recon(V1) => ReconEngineSidebarValues.reconEngineSidebars
//     | Recon(V2) => ReconSidebarValues.reconSidebars
//     | Recovery => RevenueRecoverySidebarValues.recoverySidebars(isLiveMode)
//     | Vault => VaultSidebarValues.vaultSidebars
//     | CostObservability => HypersenseSidebarValues.hypersenseSidebars
//     | DynamicRouting => IntelligentRoutingSidebarValues.intelligentRoutingSidebars

//     | _ => orchestratorSidebars
//     }

//     {
//       name: productType->ProductUtils.getProductDisplayName,
//       icon: productType->ProductUtils.productTypeIconMapper,
//       links,
//       showSection: true,
//     }
//   })
// }

// let useGetSidebarValuesForCurrentActive = (~isReconEnabled) => {
//   let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
//   let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
//   let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
//   let hsSidebars = useGetHsSidebarValues(~isReconEnabled)
//   let orchestratorV2Sidebars = OrchestrationV2SidebarValues.useGetOrchestrationV2SidebarValues()
//   let defaultSidebar = []

//   if featureFlagDetails.devModularityV2 {
//     defaultSidebar->Array.pushMany([
//       Link({
//         name: "Home",
//         icon: "nd-home",
//         link: "/v2/home",
//         access: Access,
//         selectedIcon: "nd-fill-home",
//       }),
//       CustomComponent({
//         component: <ProductHeaderComponent />,
//       }),
//     ])
//   }

//   let sidebarValuesForProduct = switch activeProduct {
//   | Orchestration(V1) => hsSidebars
//   | Recon(V2) => ReconSidebarValues.reconSidebars
//   | Recovery => RevenueRecoverySidebarValues.recoverySidebars(isLiveMode)
//   | Vault => VaultSidebarValues.vaultSidebars
//   | CostObservability => HypersenseSidebarValues.hypersenseSidebars
//   | DynamicRouting => IntelligentRoutingSidebarValues.intelligentRoutingSidebars
//   | Orchestration(V2) => orchestratorV2Sidebars
//   | Recon(V1) => ReconEngineSidebarValues.reconEngineSidebars
//   | OnBoarding(_) => []
//   | UnknownProduct => []
//   }
//   defaultSidebar->Array.concat(sidebarValuesForProduct)
// }
