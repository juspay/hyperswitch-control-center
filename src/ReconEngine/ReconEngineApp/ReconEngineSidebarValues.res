open SidebarTypes
open UserManagementTypes

let reconEngineSidebars = (
  ~userHasResourceAccess: (~resourceAccess: resourceAccessType) => CommonAuthTypes.authorization,
  ~userHasAccess: (~groupAccess: groupAccessType) => CommonAuthTypes.authorization,
  ~isReconEnginePipelinesEnabled: bool,
) => {
  let reconOverview = Link({
    name: "Overview",
    link: `/v1/recon-engine/overview`,
    access: Access,
    icon: "nd-home",
    selectedIcon: "nd-fill-home",
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
    icon: "nd-inbox",
    showSection: true,
    links: [reconExceptions, transformedEntriesExceptions],
    selectedIcon: "nd-inbox",
  })

  let reconRuleCreation = Link({
    name: "Rules Library",
    link: `/v1/recon-engine/rules`,
    access: userHasResourceAccess(~resourceAccess=ReconRule),
    icon: "nd-settings",
    selectedIcon: "nd-settings-fill",
  })

  let reconTransformedEntries = Link({
    name: "Transformed Entries",
    link: `/v1/recon-engine/transformed-entries`,
    access: userHasResourceAccess(~resourceAccess=ReconStagingEntry),
    icon: "nd-connectors",
    selectedIcon: "nd-connectors-fill",
  })

  let reconPipelines = Link({
    name: "Pipelines",
    link: `/v1/recon-engine/pipelines`,
    access: userHasAccess(~groupAccess=ReconSourcesView),
    icon: "nd-workflow",
    selectedIcon: "nd-workflow-fill",
  })

  let sidebars = [
    Heading({name: "Operate"}),
    reconOverview,
    exceptions,
    Heading({name: "Monitor"}),
    reconTransactions,
    reconTransformedEntries,
  ]

  if isReconEnginePipelinesEnabled {
    sidebars->Array.push(reconPipelines)
  }

  sidebars->Array.push(Heading({name: "Configure"}))
  sidebars->Array.push(reconRuleCreation)

  sidebars
}
