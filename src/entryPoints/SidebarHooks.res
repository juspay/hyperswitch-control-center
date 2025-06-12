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
      ~userHasResourceAccess,
      ~isPayoutEnabled=payOut,
      ~userEntity,
    ),
    devAltPaymentMethods->alternatePaymentMethods,
    recon->reconAndSettlement(isReconEnabled, checkUserEntity, userHasResourceAccess),
    default->developers(~isWebhooksEnabled=devWebhooks, ~userHasResourceAccess, ~checkUserEntity),
    settings(~isConfigurePmtsEnabled=configurePmts, ~userHasResourceAccess, ~complianceCertificate),
  ]

  sidebar
}

let useGetSidebarValuesForCurrentActive = (
  ~isReconEnabled,
  ~productType: ProductTypes.productTypes,
) => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let hsSidebars = useGetHsSidebarValues(~isReconEnabled)
  let defaultSidebar = []

  let sidebarValuesForProduct = switch productType {
  | Orchestration => hsSidebars
  | Recon => ReconSidebarValues.reconSidebars
  | Recovery =>
    RevenueRecoverySidebarValues.recoverySidebars(featureFlagDetails.devRecoveryV2ProductAnalytics)
  | Vault => VaultSidebarValues.vaultSidebars
  | CostObservability => HypersenseSidebarValues.hypersenseSidebars
  | DynamicRouting => IntelligentRoutingSidebarValues.intelligentRoutingSidebars
  }
  defaultSidebar->Array.concat(sidebarValuesForProduct)
}

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
  products->Array.map(productType => {
    let links = useGetSidebarValuesForCurrentActive(~isReconEnabled, ~productType)
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
