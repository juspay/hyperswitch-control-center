open SidebarTypes
let emptyComponent = CustomComponent({
  component: React.null,
})

let useGetSideBarValues = () => {
  let {devReconv2Product, devRecoveryV2Product} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let sideBarValues = []

  if devReconv2Product {
    sideBarValues->Array.push(ReconSidebarValues.reconSidebars)
  }

  if devRecoveryV2Product {
    sideBarValues->Array.pushMany(RevenueRecoverySidebarValues.recoverySidebars)
  }

  sideBarValues
}

let useGetProductSideBarValues = (~currentProduct: ProductTypes.productTypes) => {
  open ProductUtils
  let {devReconv2Product, devRecoveryV2Product, devVaultV2Product, devIntelligentRoutingV2} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let sideBarValues = [
    Link({
      name: Orchestrator->getStringFromVariant,
      icon: "orchestrator-home",
      link: "/home",
      access: Access,
    }),
  ]

  if devReconv2Product {
    sideBarValues->Array.push(
      Link({
        name: Recon->getStringFromVariant,
        icon: "recon-home",
        link: "/v2/recon/onboarding",
        access: Access,
      }),
    )
  }

  if devRecoveryV2Product {
    sideBarValues->Array.push(
      Link({
        name: Recovery->getStringFromVariant,
        icon: "recovery-home",
        link: "/v2/recovery",
        access: Access,
      }),
    )
  }
  if devVaultV2Product {
    sideBarValues->Array.push(
      Link({
        name: Vault->getStringFromVariant,
        icon: "vault-home",
        link: "/v2/vault/home",
        access: Access,
      }),
    )
  }
  if devIntelligentRoutingV2 {
    sideBarValues->Array.push(
      Link({
        name: IntelligentRouting->getStringFromVariant,
        icon: "intelligent-routing-home",
        link: "/v2/intelligent-routing/home",
        access: Access,
      }),
    )
  }

  let productName = currentProduct->ProductUtils.getStringFromVariant

  sideBarValues->Array.filter(topLevelItem =>
    switch topLevelItem {
    | Link(optionType) => optionType.name != productName
    | _ => true
    }
  )
}
