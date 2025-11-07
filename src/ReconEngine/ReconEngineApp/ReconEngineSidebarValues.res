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

let transformedEntriesExceptions = {
  SubLevelLink({
    name: "Transformed Entries",
    link: "/v1/recon-engine/transformed-entry-exceptions",
    searchOptions: [],
    access: Access,
  })
}

let reconExceptions = {
  SubLevelLink({
    name: "Recon",
    link: "/v1/recon-engine/transaction-exceptions",
    searchOptions: [],
    access: Access,
  })
}

let exceptions = {
  Section({
    name: "Exceptions",
    icon: "nd-operations",
    showSection: true,
    links: [reconExceptions, transformedEntriesExceptions],
    selectedIcon: "nd-operations-fill",
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

let sources = {
  SubLevelLink({
    name: "Sources",
    link: "/v1/recon-engine/sources",
    searchOptions: [],
    access: Access,
  })
}

let transformation = {
  SubLevelLink({
    name: "Transformation",
    link: "/v1/recon-engine/transformation",
    searchOptions: [],
    access: Access,
  })
}

let transformedEntries = {
  SubLevelLink({
    name: "Transformed Entries",
    link: "/v1/recon-engine/transformed-entries",
    searchOptions: [],
    access: Access,
  })
}

let reconAccounts = {
  Section({
    name: "Data",
    icon: "nd-connectors",
    showSection: true,
    links: [sources, transformation, transformedEntries],
    selectedIcon: "nd-connectors-fill",
  })
}

let reconEngineSidebars = {
  let sidebar = [reconOverview, reconTransactions, exceptions, reconRuleCreation, reconAccounts]
  sidebar
}
