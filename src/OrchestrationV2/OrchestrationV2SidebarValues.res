open SidebarTypes
open UserManagementTypes

let emptyComponent = CustomComponent({
  component: React.null,
})

let home = Link({
  name: "Overview",
  icon: "nd-home",
  link: "/v2/orchestration/home",
  access: Access,
  selectedIcon: "nd-fill-home",
})

let payments = userHasResourceAccess => {
  SubLevelLink({
    name: "Payments",
    link: `/v2/orchestration/payments`,
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
    link: `/v2/orchestration/connectors`,
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

let apiKeys = userHasResourceAccess => {
  SubLevelLink({
    name: "API Keys",
    link: `/v2/orchestration/developer-api-keys`,
    access: userHasResourceAccess(~resourceAccess=ApiKey),
    searchOptions: [("View API Keys", ""), ("Create API Key", "")],
  })
}
let paymentSettings = userHasResourceAccess => {
  SubLevelLink({
    name: "Payment Settings",
    link: `/v2/orchestration/payment-settings`,
    access: userHasResourceAccess(~resourceAccess=Account),
  })
}

let developers = (isDevelopersEnabled, ~userHasResourceAccess, ~checkUserEntity) => {
  let isProfileUser = checkUserEntity([#Profile])
  let apiKeys = apiKeys(userHasResourceAccess)
  let paymentSettings = paymentSettings(userHasResourceAccess)
  let defaultDevelopersOptions = []
  defaultDevelopersOptions->Array.push(paymentSettings)
  if !isProfileUser {
    defaultDevelopersOptions->Array.push(apiKeys)
  }

  isDevelopersEnabled
    ? Section({
        name: "Developers",
        icon: "nd-developers",
        showSection: true,
        links: defaultDevelopersOptions,
      })
    : emptyComponent
}

let useGetOrchestrationV2SidebarValues = () => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasResourceAccess} = GroupACLHooks.useUserGroupACLHook()
  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let {default, isLiveMode} = featureFlagDetails

  let sidebar = [
    home,
    default->operations(~userHasResourceAccess),
    default->connectors(~isLiveMode, ~userHasResourceAccess),
    default->developers(~userHasResourceAccess, ~checkUserEntity),
  ]

  sidebar
}
