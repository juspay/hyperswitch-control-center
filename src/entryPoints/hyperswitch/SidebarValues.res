open SidebarTypes

// * Custom Component

module GetProductionAccess = {
  @react.component
  let make = () => {
    let textStyles = HSwitchUtils.getTextClass(~textVariant=P2, ~paragraphTextVariant=Medium, ())
    let {isProdIntentCompleted, setShowProdIntentForm} = React.useContext(
      GlobalProvider.defaultContext,
    )
    let backgroundColor = isProdIntentCompleted ? "bg-light_green" : "bg-light_blue"
    let cursorStyles = isProdIntentCompleted ? "cursor-default" : "cursor-pointer"
    let productionAccessString = isProdIntentCompleted
      ? "Production Access Requested"
      : "Get Production Access"

    <div
      className={`flex items-center gap-2 ${backgroundColor} ${cursorStyles} px-4 py-3 m-2 ml-2 mb-3 !mx-4 whitespace-nowrap rounded`}
      onClick={_ => {
        isProdIntentCompleted ? () : setShowProdIntentForm(_ => true)
      }}>
      <div className={`text-white ${textStyles} !font-semibold`}>
        {productionAccessString->React.string}
      </div>
      <UIUtils.RenderIf condition={!isProdIntentCompleted}>
        <Icon name="thin-right-arrow" customIconColor="white" size=20 />
      </UIUtils.RenderIf>
    </div>
  }
}

let emptyComponent = CustomComponent({
  component: React.null,
})
let productionAccessComponent = isProductionAccessEnabled =>
  isProductionAccessEnabled
    ? CustomComponent({
        component: <GetProductionAccess />,
      })
    : emptyComponent

// * Main Features

let home = isHomeEnabled =>
  isHomeEnabled
    ? Link({
        name: "Home",
        icon: "hswitch-home",
        link: "/home",
        access: ReadWrite,
      })
    : emptyComponent

let payments = SubLevelLink({
  name: "Payments",
  link: `/payments`,
  access: ReadWrite,
  searchOptions: [("View payment operations", "")],
})

let refunds = SubLevelLink({
  name: "Refunds",
  link: `/refunds`,
  access: ReadWrite,
  searchOptions: [("View refund operations", "")],
})

let disputes = SubLevelLink({
  name: "Disputes",
  link: `/disputes`,
  access: ReadWrite,
  searchOptions: [("View dispute operations", "")],
})

let userManagement = SubLevelLink({
  name: "Users",
  link: `/users`,
  access: ReadWrite,
  searchOptions: [("View user management", "")],
})

let operations = (isOperationsEnabled, isUserManagementEnabled) => {
  let linksArray = if isUserManagementEnabled {
    [payments, refunds, disputes, userManagement]
  } else {
    [payments, refunds, disputes]
  }
  isOperationsEnabled
    ? Section({
        name: "Operations",
        icon: "hswitch-operations",
        showSection: true,
        links: linksArray,
      })
    : emptyComponent
}

let connectors = isConnectorsEnabled =>
  isConnectorsEnabled
    ? Link({
        name: "Processors",
        link: `/connectors`,
        icon: "connectors",
        access: ReadWrite,
        searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
          ~processorList=ConnectorUtils.connectorList,
          ~getNameFromString=ConnectorUtils.getConnectorNameString,
        ),
      })
    : emptyComponent

let paymentAnalytcis = SubLevelLink({
  name: "Payments",
  link: `/analytics-payments`,
  access: ReadWrite,
  searchOptions: [("View analytics", "")],
})

let refundAnalytics = SubLevelLink({
  name: "Refunds",
  link: `/analytics-refunds`,
  access: ReadWrite,
  searchOptions: [("View analytics", "")],
})

let userJourneyAnalytics = SubLevelLink({
  name: "User Journey",
  link: `/analytics-user-journey`,
  access: ReadWrite,
  iconTag: "betaTag",
  searchOptions: [("View analytics", "")],
})

let analytics = isAnalyticsEnabled =>
  isAnalyticsEnabled
    ? Section({
        name: "Analytics",
        icon: "analytics",
        showSection: true,
        links: [paymentAnalytcis, refundAnalytics],
      })
    : emptyComponent

let routing = SubLevelLink({
  name: "Routing",
  link: `/routing`,
  access: ReadWrite,
  searchOptions: [
    ("Manage default routing configuration", "/default"),
    ("Create new volume based routing", "/volume"),
    ("Create new rule based routing", "/rule"),
    ("Manage smart routing", ""),
  ],
})

let threeDs = SubLevelLink({
  name: "3DS Decision Manager",
  link: `/3ds`,
  access: ReadWrite,
  searchOptions: [("Configure 3ds", "")],
})

let workflow = isWorkflowEnabled =>
  isWorkflowEnabled
    ? Section({
        name: "Workflow",
        icon: "3ds",
        showSection: true,
        links: [routing, threeDs],
      })
    : emptyComponent

let settings = isSettingsEnabled =>
  isSettingsEnabled
    ? Link({
        name: "Settings",
        icon: "hswitch-settings",
        link: `/settings`,
        access: ReadWrite,
        searchOptions: [
          ("Configure business units ", "?type=units"),
          ("Configure business settings", "?type=business"),
          ("View profile ", "/profile"),
          ("Change password", "/profile"),
          ("Manage your personal profile and preferences", "/profile"),
        ],
      })
    : emptyComponent

let apiKeys = SubLevelLink({
  name: "API Keys",
  link: `/developer-api-keys`,
  access: ReadWrite,
  searchOptions: [("View API Keys", "")],
})

let systemMetrics = SubLevelLink({
  name: "System Metrics",
  link: `/developer-system-metrics`,
  access: ReadWrite,
  iconTag: "betaTag",
  searchOptions: [("View System Metrics", "")],
})

let webhooks = SubLevelLink({
  name: "Webhooks",
  link: `/webhooks`,
  access: ReadWrite,
  searchOptions: [("View Webhooks", "")],
})

let developers = isDevelopersEnabled =>
  isDevelopersEnabled
    ? Section({
        name: "Developers",
        icon: "developer",
        showSection: true,
        links: [apiKeys, webhooks, systemMetrics],
      })
    : emptyComponent

// *  PRO Features

let proFeatures = isProFeaturesEnabled =>
  isProFeaturesEnabled
    ? Heading({
        name: "PRO FEATURES",
      })
    : emptyComponent

let fraudAndRisk = isfraudAndRiskEnabled =>
  isfraudAndRiskEnabled
    ? LinkWithTag({
        name: "Fraud & Risk",
        icon: "shield-alt",
        iconTag: "sidebar-lock",
        iconStyles: "w-15 h-15",
        iconSize: 15,
        link: `/fraud-risk-management`,
        access: isfraudAndRiskEnabled ? ReadWrite : NoAccess,
        searchOptions: [],
      })
    : emptyComponent

let payoutConnectors = isPayoutConnectorsEnabled =>
  isPayoutConnectorsEnabled
    ? LinkWithTag({
        name: "Payout Processors",
        link: `/payoutconnectors`,
        icon: "connectors",
        iconTag: "sidebar-lock",
        iconStyles: "w-15 h-15",
        iconSize: 15,
        access: ReadWrite,
        searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
          ~processorList=ConnectorUtils.payoutConnectorList,
          ~getNameFromString=ConnectorUtils.getConnectorNameString,
        ),
      })
    : emptyComponent

let reconTag = (recon, isReconEnabled) =>
  recon
    ? LinkWithTag({
        name: "Reconcilation",
        icon: isReconEnabled ? "recon" : "recon-lock",
        iconTag: "sidebar-lock",
        iconStyles: "w-15 h-15",
        iconSize: 15,
        link: `/recon`,
        access: ReadWrite,
      })
    : emptyComponent

let getHyperSwitchAppSidebars = (
  ~isReconEnabled=false,
  ~featureFlagDetails: FeatureFlagUtils.featureFlag,
  (),
) => {
  let {productionAccess, frm, payOut, recon, default, userManagement} = featureFlagDetails
  let sidebar = [
    productionAccess->productionAccessComponent,
    default->home,
    default->operations(userManagement),
    default->analytics,
    default->connectors,
    default->workflow,
    default->developers,
    default->settings,
    [frm, payOut, recon]->Js.Array2.includes(true)->proFeatures,
    frm->fraudAndRisk,
    payOut->payoutConnectors,
    recon->reconTag(isReconEnabled),
  ]
  sidebar
}
