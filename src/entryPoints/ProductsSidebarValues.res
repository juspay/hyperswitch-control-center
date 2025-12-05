open SidebarTypes
let emptyComponent = CustomComponent({
  component: React.null,
})

let useGetProductSideBarValues = (~activeProduct: ProductTypes.productTypes) => {
  open ProductUtils
  let {
    devReconv2Product,
    devRecoveryV2Product,
    devVaultV2Product,
    devHypersenseV2Product,
    devIntelligentRoutingV2,
    devOrchestrationV2Product,
    devReconEngineV1,
  } =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let {
    useIsFeatureEnabledForAllowListMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()

  let isDevReconEngineV1Enabled =
    devReconEngineV1 &&
    useIsFeatureEnabledForAllowListMerchant(merchantSpecificConfig.devReconEngineV1)

  let sideBarValues = [
    Link({
      name: Orchestration(V1)->getProductDisplayName,
      icon: "orchestrator-home",
      link: "/v2/orchestrator/onboarding",
      access: Access,
    }),
  ]

  if devReconv2Product {
    sideBarValues->Array.push(
      Link({
        name: Recon(V2)->getProductDisplayName,
        icon: "recon-home",
        link: "/v2/recon/onboarding/",
        access: Access,
      }),
    )
  }

  let recoveryDefaultPath = RevenueRecoveryHooks.useGetDefaultPath()

  if devRecoveryV2Product {
    sideBarValues->Array.push(
      Link({
        name: Recovery->getProductDisplayName,
        icon: "recovery-home",
        link: recoveryDefaultPath,
        access: Access,
      }),
    )
  }

  if devVaultV2Product {
    sideBarValues->Array.push(
      Link({
        name: Vault->getProductDisplayName,
        icon: "vault-home",
        link: "/v2/vault/onboarding",
        access: Access,
      }),
    )
  }
  if devHypersenseV2Product {
    sideBarValues->Array.push(
      Link({
        name: CostObservability->getProductDisplayName,
        icon: "nd-piggy-bank",
        link: "/v2/cost-observability/onboarding",
        access: Access,
      }),
    )
  }
  if devIntelligentRoutingV2 {
    sideBarValues->Array.push(
      Link({
        name: DynamicRouting->getProductDisplayName,
        icon: "intelligent-routing-home",
        link: "/v2/intelligent-routing/onboarding",
        access: Access,
      }),
    )
  }
  if devOrchestrationV2Product {
    sideBarValues->Array.push(
      Link({
        name: Orchestration(V2)->getProductDisplayName,
        icon: "orchestrator-home",
        link: "/v2/orchestrator/onboarding",
        access: Access,
      }),
    )
  }
  if isDevReconEngineV1Enabled {
    sideBarValues->Array.push(
      Link({
        name: Recon(V1)->getProductDisplayName,
        icon: "recon-engine-v1",
        link: "/v1/recon-engine/onboarding",
        access: Access,
      }),
    )
  }

  let productName = activeProduct->getProductDisplayName

  sideBarValues->Array.filter(topLevelItem =>
    switch topLevelItem {
    | Link(optionType) => optionType.name != productName
    | _ => true
    }
  )
}
