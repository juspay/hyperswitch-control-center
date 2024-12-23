open SidebarTypes

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
  let links = [reconHome, reconAnalytics]
  Section({
    name: "Recon And Settlement",
    icon: "v2/recon",
    showSection: true,
    links,
  })
}

let useGetReconSideBar = () => {
  let sidebar = [recon()]

  sidebar
}
