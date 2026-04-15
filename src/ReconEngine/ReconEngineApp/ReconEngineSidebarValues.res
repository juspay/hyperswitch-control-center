open SidebarTypes
open UserManagementTypes

let reconEngineSidebars = (
  ~userHasResourceAccess: (~resourceAccess: resourceAccessType) => CommonAuthTypes.authorization,
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
    access: userHasResourceAccess(~resourceAccess=ReconTransaction),
    icon: "nd-reports",
    selectedIcon: "nd-reports-fill",
  })

  let transformedEntriesExceptions = SubLevelLink({
    name: "Transformed Entries",
    link: "/v1/recon-engine/exceptions/transformed-entries",
    access: userHasResourceAccess(~resourceAccess=ReconException),
  })

  let reconExceptions = SubLevelLink({
    name: "Recon",
    link: "/v1/recon-engine/exceptions/recon",
    access: userHasResourceAccess(~resourceAccess=ReconException),
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
    access: userHasResourceAccess(~resourceAccess=ReconRule),
    icon: "nd-reports",
    selectedIcon: "nd-reports-fill",
  })

  let sources = SubLevelLink({
    name: "Sources",
    link: "/v1/recon-engine/sources",
    access: userHasResourceAccess(~resourceAccess=ReconIngestion),
  })

  let transformation = SubLevelLink({
    name: "Transformation",
    link: "/v1/recon-engine/transformation",
    access: userHasResourceAccess(~resourceAccess=ReconTransformation),
  })

  let transformedEntries = SubLevelLink({
    name: "Transformed Entries",
    link: "/v1/recon-engine/transformed-entries",
    access: userHasResourceAccess(~resourceAccess=ReconStagingEntry),
  })

  let reconData = Section({
    name: "Data",
    icon: "nd-connectors",
    showSection: userHasAccess(~groupAccess=ReconSourcesView) == Access,
    links: [sources, transformation, transformedEntries],
    selectedIcon: "nd-connectors-fill",
  })

  [reconOverview, reconTransactions, exceptions, reconRuleCreation, reconData]
}
