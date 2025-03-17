open SidebarTypes

let reconOnBoarding = {
  Link({
    name: "Overview",
    link: `/v2/recon`,
    access: Access,
    icon: "nd-overview",
    selectedIcon: "nd-overview-fill",
  })
}

let reconReports = {
  Link({
    name: "Reconciliation Report",
    link: `/v2/recon/reports?tab=all`,
    access: Access,
    icon: "nd-reports",
    selectedIcon: "nd-reports-fill",
  })
}

let reconSidebars = {
  let sidebar = [reconOnBoarding, reconReports]
  sidebar
}
