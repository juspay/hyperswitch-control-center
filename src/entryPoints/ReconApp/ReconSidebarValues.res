open SidebarTypes

let reconOnBoarding = {
  Link({
    name: "Overview",
    link: `/v2/recon/onboarding`,
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

let reconConnectors = {
  Link({
    name: "Connectors",
    link: `/v2/recon/run-recon`,
    access: Access,
    icon: "nd-connectors",
    selectedIcon: "nd-connectors-fill",
  })
}

let reconAnalytics = {
  Link({
    name: "Analytics",
    link: `/v2/recon/analytics`,
    access: Access,
    icon: "nd-analytics",
  })
}

let reconSidebars = {
  let sidebar = [reconOnBoarding, reconReports, reconConnectors]
  sidebar
}
