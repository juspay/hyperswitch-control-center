open SidebarTypes

let reconOnBoarding = {
  SubLevelLink({
    name: "Home",
    link: `v2/recon/onboarding`,
    access: Access,
    searchOptions: [("Recon onboarding", "")],
  })
}
let reconHome = {
  SubLevelLink({
    name: "Home",
    link: `v2/recon/home`,
    access: Access,
    searchOptions: [("Recon home", "")],
  })
}
let reconAnalytics = {
  SubLevelLink({
    name: "Analytics",
    link: `v2/recon/analytics`,
    access: Access,
    searchOptions: [("Recon analytics", "")],
  })
}

let recon = () => {
  let links = [reconOnBoarding, reconHome, reconAnalytics]
  Section({
    name: "Recon And Settlement",
    icon: "v2/recon",
    showSection: true,
    links,
  })
}
let emptyComponent = CustomComponent({
  component: React.null,
})

let useGetReconSideBar = () => {
  let {devReconv2Product} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let sidebar = [devReconv2Product ? recon() : emptyComponent]
  sidebar
}
