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

let reconHistory = {
  Link({
    name: "History",
    link: `/v2/recon/run-recon`,
    access: Access,
    icon: "history",
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
  let sidebar = [reconOnBoarding, reconReports, reconAnalytics, reconHistory]
  sidebar
}
