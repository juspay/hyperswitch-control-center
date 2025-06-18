open SidebarTypes
let emptyComponent = CustomComponent({
  component: React.null,
})

let useGetSideBarValues = () => {
  let {devReconv2Product, devRecoveryV2Product} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let sideBarValues = []

  if devReconv2Product {
    sideBarValues->Array.pushMany(ReconSidebarValues.reconSidebars)
  }

  if devRecoveryV2Product {
    sideBarValues->Array.pushMany(RevenueRecoverySidebarValues.recoverySidebars)
  }

  sideBarValues
}

let useGetProductSideBarValues = (~activeProduct: ProductTypes.productTypes) => {
  open ProductUtils
  let {
    devReconv2Product,
    devRecoveryV2Product,
    devVaultV2Product,
    devHypersenseV2Product,
    devIntelligentRoutingV2,
    devOrchestrationV2Product,
  } =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let sideBarValues = [
    Link({
      name: Orchestration->getProductDisplayName,
      icon: "orchestrator-home",
      link: "/v2/onboarding/orchestrator",
      access: Access,
    }),
  ]

  if devReconv2Product {
    sideBarValues->Array.push(
      Link({
        name: Recon->getProductDisplayName,
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
        name: OrchestrationV2->getProductDisplayName,
        icon: "orchestrator-home",
        link: "/v2/onboarding/orchestrator-v2",
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
