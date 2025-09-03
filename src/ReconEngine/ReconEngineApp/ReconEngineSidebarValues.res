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

let reconConnection = {
  Link({
    name: "Connections",
    link: `/v1/recon-engine/connection`,
    access: Access,
    icon: "nd-workflow",
    selectedIcon: "nd-workflow-fill",
  })
}

let sources = {
  SubLevelLink({
    name: "Sources",
    link: "/v1/recon-engine/accounts/sources",
    searchOptions: [],
    access: Access,
  })
}

let transformation = {
  SubLevelLink({
    name: "Transformation",
    link: "/v1/recon-engine/accounts/transformation",
    searchOptions: [],
    access: Access,
  })
}

let transformedEntries = {
  SubLevelLink({
    name: "Transformed Entries",
    link: "/v1/recon-engine/accounts/transformed-entries",
    searchOptions: [],
    access: Access,
  })
}

let reconAccounts = {
  Section({
    name: "Accounts",
    icon: "nd-connectors",
    showSection: true,
    links: [sources, transformation, transformedEntries],
    selectedIcon: "nd-connectors-fill",
  })
}

let reconEngineSidebars = {
  let sidebar = [
    reconOverview,
    reconTransactions,
    reconExceptions,
    reconRuleCreation,
    reconAccounts,
  ]
  sidebar
}
