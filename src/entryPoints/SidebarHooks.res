open SidebarValues
open SidebarTypes
open FeatureFlagUtils
open ProductTypes
open HyperswitchAtom

let useGetHsSidebarValues = (~isReconEnabled: bool) => {
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
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
    billingProcessor,
    paymentLinkThemeConfigurator,
    vaultProcessor,
  } = featureFlagDetails
  let {
    useIsFeatureEnabledForBlackListMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()
  let isNewAnalyticsEnable =
    newAnalytics && useIsFeatureEnabledForBlackListMerchant(merchantSpecificConfig.newAnalytics)

  [
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
      ~isBillingProcessor=billingProcessor,
      ~isVaultProcessor=vaultProcessor,
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
      ~paymentLinkThemeConfigurator,
    ),
    settings(~isConfigurePmtsEnabled=configurePmts, ~userHasResourceAccess, ~complianceCertificate),
  ]
}

let useGetOrchestratorSidebars = (~isReconEnabled) => useGetHsSidebarValues(~isReconEnabled)

let getAllProductsBasedOnFeatureFlags = (featureFlagDetails: featureFlag) => {
  let products = [Orchestration(V1)]

  if featureFlagDetails.devReconv2Product {
    products->Array.push(Recon(V2))->ignore
  }

  if featureFlagDetails.devRecoveryV2Product {
    products->Array.push(Recovery)->ignore
  }

  if featureFlagDetails.devVaultV2Product {
    products->Array.push(Vault)->ignore
  }

  if featureFlagDetails.devHypersenseV2Product {
    products->Array.push(CostObservability)->ignore
  }

  if featureFlagDetails.devIntelligentRoutingV2 {
    products->Array.push(DynamicRouting)->ignore
  }

  if featureFlagDetails.devOrchestrationV2Product {
    products->Array.push(Orchestration(V2))->ignore
  }

  if featureFlagDetails.devReconEngineV1 {
    products->Array.push(Recon(V1))->ignore
  }

  products
}

let useGetAllProductSections = (~isReconEnabled, ~products: array<productTypes>) => {
  open ProductUtils

  let isLiveMode = (featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode

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
      name: productType->getProductDisplayName,
      links,
      icon: productType->productTypeIconMapper,
      showSection: true,
    }
  })
}

let useGetSidebarProductModules = () => {
  let merchantList = Recoil.useRecoilValueFromAtom(merchantListAtom)
  let merchantListProducts =
    merchantList->Array.map(merchant => merchant.productType->Option.getOr(UnknownProduct))
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let allProducts = getAllProductsBasedOnFeatureFlags(featureFlagDetails)

  let uniqueMerchantListProducts = merchantListProducts->Array.reduce([], (
    productList,
    product,
  ) => {
    let alreadyExists = productList->Array.some(existingProduct => {
      existingProduct == product
    })
    alreadyExists ? productList : productList->Array.concat([product])
  })

  allProducts->Array.reduce(([], []), ((explored, unexplored), productType) => {
    let hasProduct = uniqueMerchantListProducts->Array.some(merchantProductType => {
      merchantProductType == productType
    })
    hasProduct
      ? (explored->Array.concat([productType]), unexplored)
      : (explored, unexplored->Array.concat([productType]))
  })
}

let useGetSidebarValuesForCurrentActive = (~isReconEnabled) => {
  let isLiveMode = (featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let hsSidebars = useGetHsSidebarValues(~isReconEnabled)
  let orchestratorV2Sidebars = OrchestrationV2SidebarValues.useGetOrchestrationV2SidebarValues()
  let defaultSidebar = []

  if featureFlagDetails.devModularityV2 {
    defaultSidebar->Array.pushMany([
      Link({
        name: "Home",
        icon: "nd-home",
        link: "/v2/home",
        access: Access,
        selectedIcon: "nd-fill-home",
      }),
      CustomComponent({
        component: <ProductHeaderComponent />,
      }),
    ])
  }

  let sidebarValuesForProduct = switch activeProduct {
  | Orchestration(V1) => hsSidebars
  | Recon(V2) => ReconSidebarValues.reconSidebars
  | Recovery => RevenueRecoverySidebarValues.recoverySidebars(isLiveMode)
  | Vault => VaultSidebarValues.vaultSidebars
  | CostObservability => HypersenseSidebarValues.hypersenseSidebars
  | DynamicRouting => IntelligentRoutingSidebarValues.intelligentRoutingSidebars
  | Orchestration(V2) => orchestratorV2Sidebars
  | Recon(V1) => ReconEngineSidebarValues.reconEngineSidebars
  | OnBoarding(_)
  | UnknownProduct => []
  }
  defaultSidebar->Array.concat(sidebarValuesForProduct)
}
