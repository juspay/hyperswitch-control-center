open SidebarTypes

// * Custom Component

module GetProductionAccess = {
  @react.component
  let make = () => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
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
        isProdIntentCompleted
          ? ()
          : {
              setShowProdIntentForm(_ => true)
              mixpanelEvent(~eventName="get_production_access", ())
            }
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

let customers = SubLevelLink({
  name: "Customers",
  link: `/customers`,
  access: ReadWrite,
  searchOptions: [("View customers", "")],
})

let operations = (isOperationsEnabled, customersModule) => {
  isOperationsEnabled
    ? Section({
        name: "Operations",
        icon: "hswitch-operations",
        showSection: true,
        links: customersModule
          ? [payments, refunds, disputes, customers]
          : [payments, refunds, disputes],
      })
    : emptyComponent
}

let connectors = (isConnectorsEnabled, isLiveMode) => {
  isConnectorsEnabled
    ? Link({
        name: "Processors",
        link: `/connectors`,
        icon: "connectors",
        access: ReadWrite,
        searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
          ~processorList=isLiveMode
            ? ConnectorUtils.connectorListForLive
            : ConnectorUtils.connectorList,
          ~getNameFromString=ConnectorUtils.getConnectorNameString,
        ),
      })
    : emptyComponent
}

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

let analytics = (isAnalyticsEnabled, userJourneyAnalyticsFlag) =>
  isAnalyticsEnabled
    ? Section({
        name: "Analytics",
        icon: "analytics",
        showSection: true,
        links: userJourneyAnalyticsFlag
          ? [paymentAnalytcis, refundAnalytics, userJourneyAnalytics]
          : [paymentAnalytcis, refundAnalytics],
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

let surcharge = SubLevelLink({
  name: "Surcharge",
  link: `/surcharge`,
  access: ReadWrite,
  searchOptions: [("Add Surcharge", "")],
})

let workflow = (isWorkflowEnabled, isSurchargeEnabled) =>
  isWorkflowEnabled
    ? Section({
        name: "Workflow",
        icon: "3ds",
        showSection: true,
        links: isSurchargeEnabled ? [routing, threeDs, surcharge] : [routing, threeDs],
      })
    : emptyComponent

let userManagement = SubLevelLink({
  name: "Team",
  link: `/users`,
  access: ReadWrite,
  searchOptions: [("View team management", "")],
})

let accountSettings = SubLevelLink({
  name: "Account Settings",
  link: `/account-settings`,
  access: ReadWrite,
  searchOptions: [
    ("View profile", "/profile"),
    ("Change password", "/profile"),
    ("Manage your personal profile and preferences", "/profile"),
  ],
})

let businessDetails = SubLevelLink({
  name: "Business Details",
  link: `/business-details`,
  access: ReadWrite,
  searchOptions: [("Configure business details", "")],
})

let businessProfiles = SubLevelLink({
  name: "Business Profiles",
  link: `/business-profiles`,
  access: ReadWrite,
  searchOptions: [("Configure business profiles", "")],
})

let settings = (~isSampleDataEnabled, ~isUserManagementEnabled, ~isBusinessProfileEnabled) => {
  let settingsLinkArray = [businessDetails]

  if isBusinessProfileEnabled {
    settingsLinkArray->Array.push(businessProfiles)->ignore
  }
  if isSampleDataEnabled {
    settingsLinkArray->Array.push(accountSettings)->ignore
  }
  if isUserManagementEnabled {
    settingsLinkArray->Array.push(userManagement)->ignore
  }

  Section({
    name: "Settings",
    icon: "hswitch-settings",
    showSection: true,
    links: settingsLinkArray,
  })
}

let apiKeys = SubLevelLink({
  name: "API Keys",
  link: `/developer-api-keys`,
  access: ReadWrite,
  searchOptions: [("View API Keys", "")],
})

let systemMetric = SubLevelLink({
  name: "System Metrics",
  link: `/developer-system-metrics`,
  access: ReadWrite,
  iconTag: "betaTag",
  searchOptions: [("View System Metrics", "")],
})

let paymentSettings = SubLevelLink({
  name: "Payment Settings",
  link: `/payment-settings`,
  access: ReadWrite,
  searchOptions: [("View payment settings", ""), ("View webhooks", ""), ("View return url", "")],
})

let developers = (isDevelopersEnabled, userRole, systemMetrics) => {
  let isInternalUser = userRole->String.includes("internal_")

  isDevelopersEnabled
    ? Section({
        name: "Developers",
        icon: "developer",
        showSection: true,
        links: isInternalUser && systemMetrics
          ? [apiKeys, paymentSettings, systemMetric]
          : [apiKeys, paymentSettings],
      })
    : emptyComponent
}

let fraudAndRisk = isfraudAndRiskEnabled =>
  isfraudAndRiskEnabled
    ? Link({
        name: "Fraud & Risk",
        icon: "shield-alt",
        link: `/fraud-risk-management`,
        access: isfraudAndRiskEnabled ? ReadWrite : NoAccess,
        searchOptions: [],
      })
    : emptyComponent

let payoutConnectors = isPayoutConnectorsEnabled =>
  isPayoutConnectorsEnabled
    ? Link({
        name: "Payout Processors",
        link: `/payoutconnectors`,
        icon: "connectors",
        access: ReadWrite,
        searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
          ~processorList=ConnectorUtils.payoutConnectorList,
          ~getNameFromString=ConnectorUtils.getConnectorNameString,
        ),
      })
    : emptyComponent

let reconTag = (recon, isReconEnabled) =>
  recon
    ? Link({
        name: "Reconcilation",
        icon: isReconEnabled ? "recon" : "recon-lock",
        link: `/recon`,
        access: ReadWrite,
      })
    : emptyComponent

let getHyperSwitchAppSidebars = (
  ~isReconEnabled: bool,
  ~featureFlagDetails: FeatureFlagUtils.featureFlag,
  ~userRole,
  (),
) => {
  let {
    productionAccess,
    frm,
    payOut,
    recon,
    default,
    userManagement,
    sampleData,
    businessProfile,
    systemMetrics,
    userJourneyAnalytics: userJourneyAnalyticsFlag,
    surcharge: isSurchargeEnabled,
    isLiveMode,
    customersModule,
  } = featureFlagDetails
  let sidebar = [
    productionAccess->productionAccessComponent,
    default->home,
    default->operations(customersModule),
    default->analytics(userJourneyAnalyticsFlag),
    default->connectors(isLiveMode),
    default->workflow(isSurchargeEnabled),
    frm->fraudAndRisk,
    payOut->payoutConnectors,
    recon->reconTag(isReconEnabled),
    default->developers(userRole, systemMetrics),
    settings(
      ~isUserManagementEnabled=userManagement,
      ~isBusinessProfileEnabled=businessProfile,
      ~isSampleDataEnabled=sampleData,
    ),
  ]
  sidebar
}
