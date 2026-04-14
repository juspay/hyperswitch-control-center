open SidebarTypes
open UserManagementTypes

let reconEngineSidebars = (
  ~userHasAccess: (~groupAccess: groupAccessType) => CommonAuthTypes.authorization,
) => {
  let reconOverview = Link({
    name: "Overview",
    link: `/v1/recon-engine/overview`,
    access: Access,
    icon: "nd-overview",
    selectedIcon: "nd-overview-fill",
  })

  let reconTransactions = Link({
    name: "Transactions",
    link: `/v1/recon-engine/transactions`,
    access: userHasAccess(~groupAccess=ReconTransactionsView),
    icon: "nd-reports",
    selectedIcon: "nd-reports-fill",
  })

  let transformedEntriesExceptions = SubLevelLink({
    name: "Transformed Entries",
    link: "/v1/recon-engine/exceptions/transformed-entries",
    access: userHasAccess(~groupAccess=ReconExceptionsView),
  })

  let reconExceptions = SubLevelLink({
    name: "Recon",
    link: "/v1/recon-engine/exceptions/recon",
    access: userHasAccess(~groupAccess=ReconExceptionsView),
  })

  let exceptions = Section({
    name: "Exceptions",
    icon: "nd-operations",
    showSection: true,
    links: [reconExceptions, transformedEntriesExceptions],
    selectedIcon: "nd-operations-fill",
  })

  let reconRuleCreation = Link({
    name: "Rules Library",
    link: `/v1/recon-engine/rules`,
    access: userHasAccess(~groupAccess=ReconRulesView),
    icon: "nd-reports",
    selectedIcon: "nd-reports-fill",
  })

  let sources = SubLevelLink({
    name: "Sources",
    link: "/v1/recon-engine/sources",
    access: userHasAccess(~groupAccess=ReconSourcesView),
  })

  let transformation = SubLevelLink({
    name: "Transformation",
    link: "/v1/recon-engine/transformation",
    access: userHasAccess(~groupAccess=ReconSourcesView),
  })

  let transformedEntries = SubLevelLink({
    name: "Transformed Entries",
    link: "/v1/recon-engine/transformed-entries",
    access: userHasAccess(~groupAccess=ReconSourcesView),
  })

  let reconAccounts = Section({
    name: "Data",
    icon: "nd-connectors",
    showSection: true,
    links: [sources, transformation, transformedEntries],
    selectedIcon: "nd-connectors-fill",
  })

  [reconOverview, reconTransactions, exceptions, reconRuleCreation, reconAccounts]
}
