open SidebarTypes
open UserManagementTypes

let emptyComponent = CustomComponent({
  component: React.null,
})

let home = Link({
  name: "Overview",
  icon: "nd-home",
  link: "v2/orchestration/home",
  access: Access,
  selectedIcon: "nd-fill-home",
})

let payments = userHasResourceAccess => {
  SubLevelLink({
    name: "Payments",
    link: `v2/orchestration/payments`,
    access: userHasResourceAccess(~resourceAccess=Payment),
    searchOptions: [("View payment operations", "")],
  })
}

let operations = (isOperationsEnabled, ~userHasResourceAccess) => {
  let payments = payments(userHasResourceAccess)

  let links = [payments]

  isOperationsEnabled
    ? Section({
        name: "Operations",
        icon: "nd-operations",
        showSection: true,
        links,
        selectedIcon: "nd-operations-fill",
      })
    : emptyComponent
}

let paymentProcessor = (_isLiveMode, userHasResourceAccess) => {
  SubLevelLink({
    name: "Payment Processors",
    link: `v2/orchestration/connectors`,
    access: userHasResourceAccess(~resourceAccess=Connector),
    // searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
    //   ~processorList=isLiveMode
    //     ? ConnectorUtils.connectorListForLive
    //     : ConnectorUtils.connectorList,
    //   ~getNameFromString=ConnectorUtils.getConnectorNameString,
    // ),
  })
}

let connectors = (isConnectorsEnabled, ~isLiveMode, ~userHasResourceAccess) => {
  let connectorLinkArray = [paymentProcessor(isLiveMode, userHasResourceAccess)]

  isConnectorsEnabled
    ? Section({
        name: "Connectors",
        icon: "nd-connectors",
        showSection: true,
        links: connectorLinkArray,
        selectedIcon: "nd-connectors-fill",
      })
    : emptyComponent
}

let useGetOrchestrationV2SidebarValues = () => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasResourceAccess} = GroupACLHooks.useUserGroupACLHook()
  let {default, isLiveMode} = featureFlagDetails

  let sidebar = [
    home,
    default->connectors(~isLiveMode, ~userHasResourceAccess),
    default->operations(~userHasResourceAccess),
  ]

  sidebar
}
