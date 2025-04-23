open SidebarTypes

let reconOnBoarding = {
  Link({
    name: "Overview",
    link: `/v2/recon/overview`,
    access: Access,
    icon: "nd-overview",
    selectedIcon: "nd-overview-fill",
  })
}

let reconReports = {
  Link({
    name: "Reconciliation Report",
    link: `/v2/recon/reports`,
    access: Access,
    icon: "nd-reports",
    selectedIcon: "nd-reports-fill",
  })
}

let reconSidebars = {
  let sidebar = [reconOnBoarding, reconReports]
  sidebar
}
