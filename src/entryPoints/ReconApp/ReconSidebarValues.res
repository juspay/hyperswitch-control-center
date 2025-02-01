open SidebarTypes

let reconOnBoarding = {
  Link({
    name: "Profile Setup",
    link: `/v2/recon/onboarding`,
    access: Access,
    icon: "user-circle",
  })
}
let reconHome = {
  Link({
    name: "Home",
    link: `/v2/recon/home`,
    access: Access,
    icon: "nd-home",
  })
}

let reconReports = {
  Link({
    name: "Reports",
    link: `/v2/recon/reports`,
    access: Access,
    icon: "nd-reports",
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
  let sidebar = [reconOnBoarding, reconReports, reconAnalytics]
  sidebar
}
