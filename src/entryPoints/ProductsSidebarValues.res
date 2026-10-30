open SidebarTypes
let emptyComponent = CustomComponent({
  component: React.null,
})

let useGetProductSideBarValues = (~activeProduct: ProductTypes.productTypes) => {
  open ProductUtils
  let {hasProductAccess} = ProductAccessHook.useProductAccess()

  let sideBarValues = [
    Link({
      name: Orchestration(V1)->getProductDisplayName,
      icon: "orchestrator-home",
      link: "/v2/orchestrator/onboarding",
      access: Access,
    }),
  ]

  if Recon(V2)->hasProductAccess {
    sideBarValues->Array.push(
      Link({
        name: Recon(V2)->getProductDisplayName,
        icon: "recon-home",
        link: "/v2/recon/onboarding/",
        access: Access,
      }),
    )
  }

  if Recovery->hasProductAccess {
    sideBarValues->Array.push(
      Link({
        name: Recovery->getProductDisplayName,
        icon: "recovery-home",
        link: RevenueRecoverySidebarValues.defaultPath,
        access: Access,
      }),
    )
  }

  if Vault->hasProductAccess {
    sideBarValues->Array.push(
      Link({
        name: Vault->getProductDisplayName,
        icon: "vault-home",
        link: "/v2/vault/onboarding",
        access: Access,
      }),
    )
  }
  if CostObservability->hasProductAccess {
    sideBarValues->Array.push(
      Link({
        name: CostObservability->getProductDisplayName,
        icon: "nd-piggy-bank",
        link: "/v2/cost-observability/onboarding",
        access: Access,
      }),
    )
  }
  if DynamicRouting->hasProductAccess {
    sideBarValues->Array.push(
      Link({
        name: DynamicRouting->getProductDisplayName,
        icon: "intelligent-routing-home",
        link: "/v2/intelligent-routing/onboarding",
        access: Access,
      }),
    )
  }
  if Orchestration(V2)->hasProductAccess {
    sideBarValues->Array.push(
      Link({
        name: Orchestration(V2)->getProductDisplayName,
        icon: "orchestrator-home",
        link: "/v2/orchestrator/onboarding",
        access: Access,
      }),
    )
  }
  if Recon(V1)->hasProductAccess {
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
