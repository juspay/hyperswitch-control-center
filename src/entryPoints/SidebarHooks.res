open SidebarValues
open SidebarTypes
open FeatureFlagUtils
open ProductTypes
open HyperswitchAtom

let useGetHsSidebarValues = (~isReconEnabled: bool) => {
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasResourceAccess, userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {getResolvedUserInfo, checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let {userEntity} = getResolvedUserInfo()
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
    routingAnalytics,
    billingProcessor,
    paymentLinkThemeConfigurator,
    vaultProcessor,
    devModularityV2,
    devTheme,
    devVault,
    devUsers,
  } = featureFlagDetails
  let {
    isFeatureEnabledForDenyListMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()
  let isNewAnalyticsEnable =
    newAnalytics && isFeatureEnabledForDenyListMerchant(merchantSpecificConfig.newAnalytics)
  let (isCurrentMerchantPlatform, _) = OMPSwitchHooks.useOMPType()

  let standardModules = !isCurrentMerchantPlatform
    ? [
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
        devVault->vault(~userHasResourceAccess),
        devAltPaymentMethods->alternatePaymentMethods,
      ]
    : []

  [
    default->home,
    default->operations(
      ~userHasResourceAccess,
      ~isPayoutsEnabled=payOut,
      ~userEntity,
      ~isCurrentMerchantPlatform,
    ),
    ...standardModules,
    recon->reconAndSettlement(isReconEnabled, checkUserEntity, userHasResourceAccess),
    default->developers(
      ~isWebhooksEnabled=devWebhooks,
      ~userHasResourceAccess,
      ~checkUserEntity,
      ~paymentLinkThemeConfigurator,
      ~isCurrentMerchantPlatform,
    ),
    settings(
      ~isConfigurePmtsEnabled=configurePmts,
      ~userHasResourceAccess,
      ~userHasAccess,
      ~checkUserEntity,
      ~complianceCertificate,
      ~devModularityV2Enabled=devModularityV2,
      ~devThemeEnabled=devTheme,
      ~devUsers,
    ),
  ]
}

let useGetOrchestratorSidebars = (~isReconEnabled) => useGetHsSidebarValues(~isReconEnabled)

let getAllProductsBasedOnFeatureFlags = (
  ~featureFlagDetails,
  ~isFeatureEnabledForAllowListMerchant,
  ~merchantSpecificConfig: FeatureFlagUtils.merchantSpecificConfig,
) => {
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

  if (
    featureFlagDetails.devReconEngineV1 &&
    isFeatureEnabledForAllowListMerchant(merchantSpecificConfig.devReconEngineV1)
  ) {
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
  let {
    isFeatureEnabledForAllowListMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()

  let allProducts = getAllProductsBasedOnFeatureFlags(
    ~featureFlagDetails,
    ~isFeatureEnabledForAllowListMerchant,
    ~merchantSpecificConfig,
  )

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
  let {userHasResourceAccess} = GroupACLHooks.useUserGroupACLHook()
  let defaultSidebar = []
  if featureFlagDetails.devModularityV2 {
    // show Home when modularity is enabled
    defaultSidebar->Array.push(
      Link({
        name: "Home",
        icon: "nd-home",
        link: "/v2/home",
        access: Access,
        selectedIcon: "nd-fill-home",
      }),
    )

    // Show Users only if devUsers flag is enabled
    if featureFlagDetails.devUsers {
      defaultSidebar->Array.push(
        Link({
          name: "Users",
          icon: "nd-user",
          link: "/users",
          access: Access,
          selectedIcon: "nd-user",
        }),
      )
    }

    // Show Theme only if devTheme flag is enabled
    if featureFlagDetails.devTheme {
      defaultSidebar->Array.push(ThemeSidebarValues.themeTopLevelLink(~userHasResourceAccess))
    }

    // Always show product header when modularity is enabled
    defaultSidebar->Array.push(
      CustomComponent({
        component: <ProductHeaderComponent />,
      }),
    )
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
