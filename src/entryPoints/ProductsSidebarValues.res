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
    sideBarValues->Array.push(RevenueRecoverySidebarValues.recoverySidebars)
  }

  sideBarValues
}

let useGetProductSideBarValues = (~currentProduct: ProductTypes.productTypes) => {
  let {devReconv2Product, devRecoveryV2Product} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let sideBarValues = [
    Link({
      name: "Orchestrator",
      icon: "home",
      link: "/home",
      access: Access,
    }),
  ]

  if devReconv2Product {
    sideBarValues->Array.push(
      Link({
        name: "Recon",
        icon: "recon-home",
        link: "/v2/recon/onboarding",
        access: Access,
      }),
    )
  }

  if devRecoveryV2Product {
    sideBarValues->Array.push(
      Link({
        name: "Recovery",
        icon: "recovery-home",
        link: "/v2/recovery",
        access: Access,
      }),
    )
  }

  let productName = currentProduct->ProductUtils.getStringFromVariant

  sideBarValues->Array.filter(topLevelItem =>
    switch topLevelItem {
    | Heading(headingType) => headingType.name != productName
    | RemoteLink(optionType)
    | Link(optionType) =>
      optionType.name != productName
    | LinkWithTag(optionTypeWithTag) => optionTypeWithTag.name != productName
    | Section(sectionType) => sectionType.name != productName
    | _ => true
    }
  )
}
