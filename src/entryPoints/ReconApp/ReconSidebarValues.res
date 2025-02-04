open SidebarTypes

let reconOnBoarding = {
  SubLevelLink({
    name: "Profile Setup",
    link: `/v2/recon/onboarding`,
    access: Access,
    searchOptions: [("Recon onboarding", "")],
  })
}
let reconHome = {
  SubLevelLink({
    name: "Home",
    link: `/v2/recon/home`,
    access: Access,
    searchOptions: [("Recon home", "")],
  })
}
let reconAnalytics = {
  SubLevelLink({
    name: "Analytics",
    link: `/v2/recon/analytics`,
    access: Access,
    searchOptions: [("Recon analytics", "")],
  })
}

let reconSidebars = {
  let links = [reconOnBoarding, reconAnalytics]
  Section({
    name: "Recon And Settlement",
    icon: "/v2/recon",
    showSection: true,
    links,
  })
}
