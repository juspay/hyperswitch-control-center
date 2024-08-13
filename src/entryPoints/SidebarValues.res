open SidebarTypes
open UserManagementTypes

// * Custom Component

module GetProductionAccess = {
  @react.component
  let make = () => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let textStyles = HSwitchUtils.getTextClass((P2, Medium))
    let {isProdIntentCompleted, setShowProdIntentForm} = React.useContext(
      GlobalProvider.defaultContext,
    )
    let isProdIntent = isProdIntentCompleted->Option.getOr(false)
    let backgroundColor = isProdIntent ? "bg-light_green" : "bg-light_blue"
    let cursorStyles = isProdIntent ? "cursor-default" : "cursor-pointer"
    let productionAccessString = isProdIntent
      ? "Production Access Requested"
      : "Get Production Access"

    switch isProdIntentCompleted {
    | Some(_) =>
      <div
        className={`flex items-center gap-2 ${backgroundColor} ${cursorStyles} px-4 py-3 m-2 ml-2 mb-3 !mx-4 whitespace-nowrap rounded`}
        onClick={_ => {
          isProdIntent
            ? ()
            : {
                setShowProdIntentForm(_ => true)
                mixpanelEvent(~eventName="get_production_access")
              }
        }}>
        <div className={`text-white ${textStyles} !font-semibold`}>
          {productionAccessString->React.string}
        </div>
        <RenderIf condition={!isProdIntent}>
          <Icon name="thin-right-arrow" customIconColor="text-white" size=20 />
        </RenderIf>
      </div>
    | None =>
      <Shimmer
        styleClass="h-10 px-4 py-3 m-2 ml-2 mb-3 dark:bg-black bg-white rounded" shimmerType={Small}
      />
    }
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
        access: Access,
      })
    : emptyComponent

let payments = permissionJson => {
  SubLevelLink({
    name: "Payments",
    link: `/payments`,
    access: permissionJson.operationsView,
    searchOptions: [("View payment operations", "")],
  })
}

let refunds = permissionJson => {
  SubLevelLink({
    name: "Refunds",
    link: `/refunds`,
    access: permissionJson.operationsView,
    searchOptions: [("View refund operations", "")],
  })
}

let disputes = permissionJson => {
  SubLevelLink({
    name: "Disputes",
    link: `/disputes`,
    access: permissionJson.operationsView,
    searchOptions: [("View dispute operations", "")],
  })
}

let customers = permissionJson => {
  SubLevelLink({
    name: "Customers",
    link: `/customers`,
    access: permissionJson.operationsView,
    searchOptions: [("View customers", "")],
  })
}

let payouts = permissionJson => {
  SubLevelLink({
    name: "Payouts",
    link: `/payouts`,
    access: permissionJson.operationsView,
    searchOptions: [("View payouts operations", "")],
  })
}

let operations = (isOperationsEnabled, ~permissionJson, ~isPayoutsEnabled) => {
  let payments = payments(permissionJson)
  let refunds = refunds(permissionJson)
  let disputes = disputes(permissionJson)
  let customers = customers(permissionJson)
  let payouts = payouts(permissionJson)

  let links = [payments, refunds, disputes, customers]

  if isPayoutsEnabled {
    links->Array.push(payouts)->ignore
  }

  isOperationsEnabled
    ? Section({
        name: "Operations",
        icon: "hswitch-operations",
        showSection: true,
        links,
      })
    : emptyComponent
}

let paymentProcessor = (isLiveMode, permissionJson) => {
  SubLevelLink({
    name: "Payment Processors",
    link: `/connectors`,
    access: permissionJson.connectorsView,
    searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
      ~processorList=isLiveMode
        ? ConnectorUtils.connectorListForLive
        : ConnectorUtils.connectorList,
      ~getNameFromString=ConnectorUtils.getConnectorNameString,
    ),
  })
}

let payoutConnectors = (~permissionJson) => {
  SubLevelLink({
    name: "Payout Processors",
    link: `/payoutconnectors`,
    access: permissionJson.connectorsView,
    searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
      ~processorList=ConnectorUtils.payoutConnectorList,
      ~getNameFromString=ConnectorUtils.getConnectorNameString,
    ),
  })
}

let fraudAndRisk = (~permissionJson) => {
  SubLevelLink({
    name: "Fraud & Risk",
    link: `/fraud-risk-management`,
    access: permissionJson.connectorsView,
    searchOptions: [],
  })
}

let threeDsConnector = (~permissionJson) => {
  SubLevelLink({
    name: "3DS Authenticator",
    link: "/3ds-authenticators",
    access: permissionJson.connectorsView,
    searchOptions: [
      ("Connect 3dsecure.io", "/new?name=threedsecureio"),
      ("Connect threedsecureio", "/new?name=threedsecureio"),
    ],
  })
}

let pmAuthenticationProcessor = (~permissionJson) => {
  SubLevelLink({
    name: "PM Authentication Processor",
    link: `/pm-authentication-processor`,
    access: permissionJson.connectorsView,
    searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
      ~processorList=ConnectorUtils.pmAuthenticationConnectorList,
      ~getNameFromString=ConnectorUtils.getConnectorNameString,
    ),
  })
}

let connectors = (
  isConnectorsEnabled,
  ~isLiveMode,
  ~isFrmEnabled,
  ~isPayoutsEnabled,
  ~isThreedsConnectorEnabled,
  ~isPMAuthenticationProcessor,
  ~permissionJson,
) => {
  let connectorLinkArray = [paymentProcessor(isLiveMode, permissionJson)]

  if isPayoutsEnabled {
    connectorLinkArray->Array.push(payoutConnectors(~permissionJson))->ignore
  }
  if isThreedsConnectorEnabled {
    connectorLinkArray->Array.push(threeDsConnector(~permissionJson))->ignore
  }

  if isFrmEnabled {
    connectorLinkArray->Array.push(fraudAndRisk(~permissionJson))->ignore
  }

  if isPMAuthenticationProcessor {
    connectorLinkArray->Array.push(pmAuthenticationProcessor(~permissionJson))->ignore
  }

  isConnectorsEnabled
    ? Section({
        name: "Connectors",
        icon: "connectors",
        showSection: true,
        links: connectorLinkArray,
      })
    : emptyComponent
}

let paymentAnalytcis = SubLevelLink({
  name: "Payments",
  link: `/analytics-payments`,
  access: Access,
  searchOptions: [("View analytics", "")],
})

let performanceMonitor = SubLevelLink({
  name: "Performance Monitor",
  link: `/performance-monitor`,
  access: Access,
  searchOptions: [("View Performance Monitor", "")],
})

let disputeAnalytics = SubLevelLink({
  name: "Disputes",
  link: `/analytics-disputes`,
  access: Access,
  searchOptions: [("View Dispute analytics", "")],
})

let refundAnalytics = SubLevelLink({
  name: "Refunds",
  link: `/analytics-refunds`,
  access: Access,
  searchOptions: [("View analytics", "")],
})

let userJourneyAnalytics = SubLevelLink({
  name: "User Journey",
  link: `/analytics-user-journey`,
  access: Access,
  iconTag: "betaTag",
  searchOptions: [("View analytics", "")],
})

let authenticationAnalytics = SubLevelLink({
  name: "Authentication",
  link: `/analytics-authentication`,
  access: Access,
  iconTag: "betaTag",
  searchOptions: [("View analytics", "")],
})

let analytics = (
  isAnalyticsEnabled,
  userJourneyAnalyticsFlag,
  authenticationAnalyticsFlag,
  disputeAnalyticsFlag,
  performanceMonitorFlag,
  ~permissionJson,
) => {
  let links = [paymentAnalytcis, refundAnalytics]

  if userJourneyAnalyticsFlag {
    links->Array.push(userJourneyAnalytics)
  }

  if authenticationAnalyticsFlag {
    links->Array.push(authenticationAnalytics)
  }

  if disputeAnalyticsFlag {
    links->Array.push(disputeAnalytics)
  }
  if performanceMonitorFlag {
    links->Array.push(performanceMonitor)
  }

  isAnalyticsEnabled
    ? Section({
        name: "Analytics",
        icon: "analytics",
        showSection: permissionJson.analyticsView === Access,
        links,
      })
    : emptyComponent
}
let routing = permissionJson => {
  SubLevelLink({
    name: "Routing",
    link: `/routing`,
    access: permissionJson.workflowsView,
    searchOptions: [
      ("Manage default routing configuration", "/default"),
      ("Create new volume based routing", "/volume"),
      ("Create new rule based routing", "/rule"),
      ("Manage smart routing", ""),
    ],
  })
}

let payoutRouting = permissionJson => {
  SubLevelLink({
    name: "Payout Routing",
    link: `/payoutrouting`,
    access: permissionJson.workflowsView,
    searchOptions: [
      ("Manage default routing configuration", "/default"),
      ("Create new volume based routing", "/volume"),
      ("Create new rule based routing", "/rule"),
      ("Manage smart routing", ""),
    ],
  })
}

let threeDs = permissionJson => {
  SubLevelLink({
    name: "3DS Decision Manager",
    link: `/3ds`,
    access: permissionJson.workflowsView,
    searchOptions: [("Configure 3ds", "")],
  })
}
let surcharge = permissionJson => {
  SubLevelLink({
    name: "Surcharge",
    link: `/surcharge`,
    access: permissionJson.workflowsView,
    searchOptions: [("Add Surcharge", "")],
  })
}

let workflow = (isWorkflowEnabled, isSurchargeEnabled, ~permissionJson, ~isPayoutEnabled) => {
  let routing = routing(permissionJson)
  let threeDs = threeDs(permissionJson)
  let payoutRouting = payoutRouting(permissionJson)
  let surcharge = surcharge(permissionJson)

  let defaultWorkFlow = [routing, threeDs]

  if isSurchargeEnabled {
    defaultWorkFlow->Array.push(surcharge)->ignore
  }
  if isPayoutEnabled {
    defaultWorkFlow->Array.push(payoutRouting)->ignore
  }

  isWorkflowEnabled
    ? Section({
        name: "Workflow",
        icon: "3ds",
        showSection: true,
        links: defaultWorkFlow,
      })
    : emptyComponent
}

let userManagement = permissionJson => {
  SubLevelLink({
    name: "Team",
    link: `/users`,
    access: permissionJson.usersView,
    searchOptions: [("View team management", "")],
  })
}
let teamRevamp = permissionJson => {
  SubLevelLink({
    name: "Team Revamp",
    link: `/users-revamp`,
    access: permissionJson.usersView,
    searchOptions: [("View team management", "")],
  })
}

let businessDetails = () => {
  SubLevelLink({
    name: "Business Details",
    link: `/business-details`,
    access: Access,
    searchOptions: [("Configure business details", "")],
  })
}

let businessProfiles = () => {
  SubLevelLink({
    name: "Business Profiles",
    link: `/business-profiles`,
    access: Access,
    searchOptions: [("Configure business profiles", "")],
  })
}

let configurePMTs = permissionJson => {
  SubLevelLink({
    name: "Configure PMTs",
    link: `/configure-pmts`,
    access: permissionJson.connectorsView,
    searchOptions: [("Configure payment methods", "Configure country currency")],
  })
}

let complianceCertificateSection = {
  SubLevelLink({
    name: "Compliance ",
    link: `/compliance`,
    access: Access,
    searchOptions: [("PCI certificate", "")],
  })
}

let settings = (
  ~isConfigurePmtsEnabled,
  ~permissionJson,
  ~complianceCertificate,
  ~userManagementRevamp,
) => {
  let settingsLinkArray = [businessDetails(), businessProfiles()]

  if isConfigurePmtsEnabled {
    settingsLinkArray->Array.push(configurePMTs(permissionJson))->ignore
  }

  if complianceCertificate {
    settingsLinkArray->Array.push(complianceCertificateSection)->ignore
  }

  if userManagementRevamp {
    settingsLinkArray->Array.push(teamRevamp(permissionJson))->ignore
  }

  settingsLinkArray->Array.push(userManagement(permissionJson))->ignore

  Section({
    name: "Settings",
    icon: "hswitch-settings",
    showSection: true,
    links: settingsLinkArray,
  })
}

let apiKeys = permissionJson => {
  SubLevelLink({
    name: "API Keys",
    link: `/developer-api-keys`,
    access: permissionJson.merchantDetailsManage,
    searchOptions: [("View API Keys", "")],
  })
}

let systemMetric = permissionJson => {
  SubLevelLink({
    name: "System Metrics",
    link: `/developer-system-metrics`,
    access: permissionJson.analyticsView,
    iconTag: "betaTag",
    searchOptions: [("View System Metrics", "")],
  })
}

let paymentSettings = () => {
  SubLevelLink({
    name: "Payment Settings",
    link: `/payment-settings`,
    access: Access,
    searchOptions: [("View payment settings", ""), ("View webhooks", ""), ("View return url", "")],
  })
}

let developers = (isDevelopersEnabled, userRole, systemMetrics, ~permissionJson) => {
  let isInternalUser = userRole->String.includes("internal_")
  let apiKeys = apiKeys(permissionJson)
  let paymentSettings = paymentSettings()
  let systemMetric = systemMetric(permissionJson)

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

let uploadReconFiles = {
  SubLevelLink({
    name: "Upload Recon Files",
    link: `/upload-files`,
    access: Access,
    searchOptions: [("Upload recon files", "")],
  })
}

let runRecon = {
  SubLevelLink({
    name: "Run Recon",
    link: `/run-recon`,
    access: Access,
    searchOptions: [("Run recon", "")],
  })
}

let reconAnalytics = {
  SubLevelLink({
    name: "Analytics",
    link: `/recon-analytics`,
    access: Access,
    searchOptions: [("Recon analytics", "")],
  })
}
let reconReports = {
  SubLevelLink({
    name: "Reports",
    link: `/reports`,
    access: Access,
    searchOptions: [("Recon reports", "")],
  })
}

let reconConfigurator = {
  SubLevelLink({
    name: "Configurator",
    link: `/config-settings`,
    access: Access,
    searchOptions: [("Recon configurator", "")],
  })
}
let reconFileProcessor = {
  SubLevelLink({
    name: "File Processor",
    link: `/file-processor`,
    access: Access,
    searchOptions: [("Recon file processor", "")],
  })
}

let reconAndSettlement = (recon, isReconEnabled) => {
  switch (recon, isReconEnabled) {
  | (true, true) =>
    Section({
      name: "Recon And Settlement",
      icon: "recon",
      showSection: true,
      links: [
        uploadReconFiles,
        runRecon,
        reconAnalytics,
        reconReports,
        reconConfigurator,
        reconFileProcessor,
      ],
    })
  | (true, false) =>
    Link({
      name: "Reconcilation",
      icon: isReconEnabled ? "recon" : "recon-lock",
      link: `/recon`,
      access: Access,
    })

  | (_, _) => emptyComponent
  }
}

let useGetSidebarValues = (~isReconEnabled: bool) => {
  let {userRole} =
    CommonAuthHooks.useCommonAuthInfo()->Option.getOr(CommonAuthHooks.defaultAuthInfo)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let permissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

  let {
    frm,
    payOut,
    recon,
    default,
    systemMetrics,
    userJourneyAnalytics: userJourneyAnalyticsFlag,
    authenticationAnalytics: authenticationAnalyticsFlag,
    surcharge: isSurchargeEnabled,
    isLiveMode,
    threedsAuthenticator,
    quickStart,
    disputeAnalytics,
    configurePmts,
    complianceCertificate,
    userManagementRevamp,
    performanceMonitor: performanceMonitorFlag,
    pmAuthenticationProcessor,
  } = featureFlagDetails

  let sidebar = [
    productionAccessComponent(quickStart),
    default->home,
    default->operations(~permissionJson, ~isPayoutsEnabled=payOut),
    default->connectors(
      ~isLiveMode,
      ~isFrmEnabled=frm,
      ~isPayoutsEnabled=payOut,
      ~isThreedsConnectorEnabled=threedsAuthenticator,
      ~isPMAuthenticationProcessor=pmAuthenticationProcessor,
      ~permissionJson,
    ),
    default->analytics(
      userJourneyAnalyticsFlag,
      authenticationAnalyticsFlag,
      disputeAnalytics,
      performanceMonitorFlag,
      ~permissionJson,
    ),
    default->workflow(isSurchargeEnabled, ~permissionJson, ~isPayoutEnabled=payOut),
    recon->reconAndSettlement(isReconEnabled),
    default->developers(userRole, systemMetrics, ~permissionJson),
    settings(
      ~isConfigurePmtsEnabled=configurePmts,
      ~permissionJson,
      ~complianceCertificate,
      ~userManagementRevamp,
    ),
  ]

  sidebar
}
