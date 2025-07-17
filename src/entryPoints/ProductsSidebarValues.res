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
    useIsFeatureWhitelistedForMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()

  let isDevReconEngineV1Enabled =
    devReconEngineV1 && useIsFeatureWhitelistedForMerchant(merchantSpecificConfig.devReconEngineV1)

  let sideBarValues = [
    Link({
      name: Orchestration(V1)->getProductDisplayName,
      icon: "orchestrator-home",
      link: "/v2/onboarding/orchestrator",
      access: Access,
    }),
  ]

  if devReconv2Product {
    sideBarValues->Array.push(
      Link({
        name: Recon(V2)->getProductDisplayName,
        icon: "recon-home",
        link: "/v2/onboarding/recon",
        access: Access,
      }),
    )
  }

  if devRecoveryV2Product {
    sideBarValues->Array.push(
      Link({
        name: Recovery->getProductDisplayName,
        icon: "recovery-home",
        link: "/v2/onboarding/recovery",
        access: Access,
      }),
    )
  }
  if devVaultV2Product {
    sideBarValues->Array.push(
      Link({
        name: Vault->getProductDisplayName,
        icon: "vault-home",
        link: "/v2/onboarding/vault",
        access: Access,
      }),
    )
  }
  if devHypersenseV2Product {
    sideBarValues->Array.push(
      Link({
        name: CostObservability->getProductDisplayName,
        icon: "nd-piggy-bank",
        link: "/v2/onboarding/cost-observability",
        access: Access,
      }),
    )
  }
  if devIntelligentRoutingV2 {
    sideBarValues->Array.push(
      Link({
        name: DynamicRouting->getProductDisplayName,
        icon: "intelligent-routing-home",
        link: "/v2/onboarding/intelligent-routing",
        access: Access,
      }),
    )
  }
  if devOrchestrationV2Product {
    sideBarValues->Array.push(
      Link({
        name: Orchestration(V2)->getProductDisplayName,
        icon: "orchestrator-home",
        link: "/v2/onboarding/orchestrator",
        access: Access,
      }),
    )
  }
  if isDevReconEngineV1Enabled {
    sideBarValues->Array.push(
      Link({
        name: Recon(V1)->getProductDisplayName,
        icon: "recon-engine-v1",
        link: "/v1/onboarding/recon-engine",
        access: Access,
      }),
    )
  }
  // Need to be refactored
  let productName = activeProduct->getProductDisplayName

  sideBarValues->Array.filter(topLevelItem =>
    switch topLevelItem {
    | Link(optionType) => optionType.name != productName
    | _ => true
    }
  )
}
