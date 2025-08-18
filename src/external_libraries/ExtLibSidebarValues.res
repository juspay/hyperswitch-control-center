open SidebarTypes

let deRouting = Link({
  name: "Debit Routing",
  icon: "nd-home",
  link: "/de-routing",
  access: Access,
  selectedIcon: "nd-fill-home",
})

let getExternalLibs = (featureFlagDetails: FeatureFlagUtils.featureFlag) => {
  let externalLibs = []

  if featureFlagDetails.extDeRouting {
    externalLibs->Array.push(deRouting)
  }
  externalLibs
}
