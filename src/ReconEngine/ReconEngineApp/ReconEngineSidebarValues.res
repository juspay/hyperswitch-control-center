open SidebarTypes

let reconOverview = {
  Link({
    name: "Overview",
    link: `/v1/recon-engine/overview`,
    access: Access,
    icon: "nd-overview",
    selectedIcon: "nd-overview-fill",
  })
}

let reconTransactions = {
  Link({
    name: "Transactions",
    link: `/v1/recon-engine/transactions`,
    access: Access,
    icon: "nd-reports",
    selectedIcon: "nd-reports-fill",
  })
}

let reconExceptions = {
  Link({
    name: "Exceptions",
    link: `/v1/recon-engine/exceptions`,
    access: Access,
    icon: "nd-operations",
    selectedIcon: "nd-operations-fill",
  })
}

let reconQueue = {
  Link({
    name: "File Management",
    link: `/v1/recon-engine/file-management`,
    access: Access,
    icon: "nd-workflow",
    selectedIcon: "nd-workflow-fill",
  })
}

let reconRuleCreation = {
  Link({
    name: "Rules Library",
    link: `/v1/recon-engine/rules`,
    access: Access,
    icon: "nd-reports",
    selectedIcon: "nd-reports-fill",
  })
}
let reconEngineSidebars = {
  let sidebar = [reconOverview, reconTransactions, reconExceptions, reconQueue, reconRuleCreation]
  sidebar
}
