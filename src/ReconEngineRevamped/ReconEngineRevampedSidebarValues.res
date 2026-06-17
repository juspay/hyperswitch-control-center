open SidebarTypes
open UserManagementTypes

let reconEngineRevampedSidebars = (
  ~userHasResourceAccess: (~resourceAccess: resourceAccessType) => CommonAuthTypes.authorization,
  ~userHasAccess: (~groupAccess: groupAccessType) => CommonAuthTypes.authorization,
) => {
  let reconOverview = Link({
    name: "Overview",
    link: `/v1/recon-engine/overview`,
    access: Access,
    icon: "nd-overview",
    selectedIcon: "nd-overview-fill",
    showIcon: true,
  })

  let reconInbox = Link({
    name: "Inbox",
    link: `/v1/recon-engine/inbox`,
    access: userHasResourceAccess(~resourceAccess=ReconException),
    icon: "nd-inbox",
    selectedIcon: "nd-inbox-fill",
    showIcon: true,
  })

  let reconTransactions = Link({
    name: "Transactions",
    link: `/v1/recon-engine/transactions`,
    access: userHasResourceAccess(~resourceAccess=ReconTransaction),
    icon: "nd-reports",
    selectedIcon: "nd-reports-fill",
    showIcon: true,
  })

  let reconPipelines = Link({
    name: "Pipelines",
    icon: "nd-connectors",
    link: `/v1/recon-engine/pipelines`,
    access: userHasAccess(~groupAccess=ReconSourcesView),
    selectedIcon: "nd-connectors-fill",
    showIcon: true,
  })

  let operateHeading = Heading({
    name: "OPERATE",
  })

  let exploreHeading = Heading({
    name: "EXPLORE",
  })

  let configureHeading = Heading({
    name: "CONFIGURE",
  })

  let reconRules = Link({
    name: "Rules Studio",
    link: `/v1/recon-engine/rules`,
    access: userHasResourceAccess(~resourceAccess=ReconRule),
    icon: "nd-workflow",
    selectedIcon: "nd-workflow-fill",
    showIcon: true,
  })

  let reconTransformations = Link({
    name: "Transformations",
    link: `/v1/recon-engine/transformations`,
    access: userHasResourceAccess(~resourceAccess=ReconTransformation),
    icon: "nd-settings",
    selectedIcon: "nd-settings-fill",
    showIcon: true,
  })

  [
    operateHeading,
    reconOverview,
    reconInbox,
    exploreHeading,
    reconTransactions,
    reconPipelines,
    configureHeading,
    reconRules,
    reconTransformations,
  ]
}
