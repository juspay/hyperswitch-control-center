open SidebarTypes
open UserManagementTypes

// * Custom Component
module ProductHeaderComponent = {
  @react.component
  let make = () => {
    let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)

    <div className={`text-xs font-semibold px-3 py-2 text-nd_gray-400 tracking-widest`}>
      {React.string(activeProduct->ProductUtils.getProductDisplayName->String.toUpperCase)}
    </div>
  }
}

let emptyComponent = CustomComponent({
  component: React.null,
})

// * Main Features

let home = isHomeEnabled =>
  isHomeEnabled
    ? Link({
        name: "Overview",
        icon: "nd-home",
        link: "/home",
        access: Access,
        selectedIcon: "nd-fill-home",
      })
    : emptyComponent

let payments = userHasResourceAccess => {
  SubLevelLink({
    name: "Payments",
    link: `/payments`,
    access: userHasResourceAccess(~resourceAccess=Payment),
    searchOptions: [("View payment operations", "")],
  })
}

let refunds = userHasResourceAccess => {
  SubLevelLink({
    name: "Refunds",
    link: `/refunds`,
    access: userHasResourceAccess(~resourceAccess=Refund),
    searchOptions: [("View refund operations", "")],
  })
}

let disputes = userHasResourceAccess => {
  SubLevelLink({
    name: "Disputes",
    link: `/disputes`,
    access: userHasResourceAccess(~resourceAccess=Dispute),
    searchOptions: [("View dispute operations", "")],
  })
}

let customers = userHasResourceAccess => {
  SubLevelLink({
    name: "Customers",
    link: `/customers`,
    access: userHasResourceAccess(~resourceAccess=Customer),
    searchOptions: [("View customers", "")],
  })
}

let payouts = userHasResourceAccess => {
  SubLevelLink({
    name: "Payouts",
    link: `/payouts`,
    access: userHasResourceAccess(~resourceAccess=Payout),
    searchOptions: [("View payouts operations", "")],
  })
}

let alternatePaymentMethods = isApmEnabled =>
  isApmEnabled
    ? Link({
        name: "Alt Payment Methods",
        icon: "nd-apm",
        link: "/apm",
        access: Access,
        selectedIcon: "nd-fill-apm",
      })
    : emptyComponent

let operations = (isOperationsEnabled, ~userHasResourceAccess, ~isPayoutsEnabled, ~userEntity) => {
  let payments = payments(userHasResourceAccess)
  let refunds = refunds(userHasResourceAccess)
  let disputes = disputes(userHasResourceAccess)
  let customers = customers(userHasResourceAccess)
  let payouts = payouts(userHasResourceAccess)

  let links = [payments, refunds, disputes]
  let isCustomersEnabled = userEntity !== #Profile

  if isPayoutsEnabled {
    links->Array.push(payouts)->ignore
  }
  if isCustomersEnabled {
    links->Array.push(customers)->ignore
  }

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

let paymentProcessor = (isLiveMode, userHasResourceAccess) => {
  SubLevelLink({
    name: "Payment Processors",
    link: `/connectors`,
    access: userHasResourceAccess(~resourceAccess=Connector),
    searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
      ~processorList=isLiveMode
        ? ConnectorUtils.connectorListForLive
        : ConnectorUtils.connectorList,
      ~getNameFromString=ConnectorUtils.getConnectorNameString,
    ),
  })
}

let payoutConnectors = (~userHasResourceAccess) => {
  SubLevelLink({
    name: "Payout Processors",
    link: `/payoutconnectors`,
    access: userHasResourceAccess(~resourceAccess=Connector),
    searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
      ~processorList=ConnectorUtils.payoutConnectorList,
      ~getNameFromString=ConnectorUtils.getConnectorNameString,
    ),
  })
}

let fraudAndRisk = (~userHasResourceAccess) => {
  SubLevelLink({
    name: "Fraud & Risk",
    link: `/fraud-risk-management`,
    access: userHasResourceAccess(~resourceAccess=Connector),
    searchOptions: [],
  })
}

let threeDsConnector = (~userHasResourceAccess) => {
  SubLevelLink({
    name: "3DS Authenticators",
    link: "/3ds-authenticators",
    access: userHasResourceAccess(~resourceAccess=Connector),
    searchOptions: [
      ("Connect 3dsecure.io", "/new?name=threedsecureio"),
      ("Connect threedsecureio", "/new?name=threedsecureio"),
    ],
  })
}

let pmAuthenticationProcessor = (~userHasResourceAccess) => {
  SubLevelLink({
    name: "PM Authentication Processor",
    link: `/pm-authentication-processor`,
    access: userHasResourceAccess(~resourceAccess=Connector),
    searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
      ~processorList=ConnectorUtils.pmAuthenticationConnectorList,
      ~getNameFromString=ConnectorUtils.getConnectorNameString,
    ),
  })
}

let taxProcessor = (~userHasResourceAccess) => {
  SubLevelLink({
    name: "Tax Processor",
    link: `/tax-processor`,
    access: userHasResourceAccess(~resourceAccess=Connector),
    searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
      ~processorList=ConnectorUtils.taxProcessorList,
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
  ~isTaxProcessor,
  ~userHasResourceAccess,
) => {
  let connectorLinkArray = [paymentProcessor(isLiveMode, userHasResourceAccess)]

  if isPayoutsEnabled {
    connectorLinkArray->Array.push(payoutConnectors(~userHasResourceAccess))->ignore
  }
  if isThreedsConnectorEnabled {
    connectorLinkArray->Array.push(threeDsConnector(~userHasResourceAccess))->ignore
  }

  if isFrmEnabled {
    connectorLinkArray->Array.push(fraudAndRisk(~userHasResourceAccess))->ignore
  }

  if isPMAuthenticationProcessor {
    connectorLinkArray->Array.push(pmAuthenticationProcessor(~userHasResourceAccess))->ignore
  }

  if isTaxProcessor {
    connectorLinkArray->Array.push(taxProcessor(~userHasResourceAccess))->ignore
  }

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

let paymentAnalytcis = SubLevelLink({
  name: "Payments",
  link: `/analytics-payments`,
  access: Access,
  searchOptions: [("View analytics", "")],
})

let performanceMonitor = SubLevelLink({
  name: "Performance",
  link: `/performance-monitor`,
  access: Access,
  searchOptions: [("View Performance", "")],
})

let newAnalytics = SubLevelLink({
  name: "Insights",
  link: `/new-analytics`,
  access: Access,
  searchOptions: [("Insights", "")],
})

let disputeAnalytics = SubLevelLink({
  name: "Disputes",
  link: `/analytics-disputes`,
  access: Access,
  searchOptions: [("View Dispute analytics", "")],
})
let routingAnalytics = SubLevelLink({
  name: "Routing",
  link: `/analytics-routing`,
  access: Access,
  searchOptions: [("View routing analytics", "")],
})

let refundAnalytics = SubLevelLink({
  name: "Refunds",
  link: `/analytics-refunds`,
  access: Access,
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
  disputeAnalyticsFlag,
  performanceMonitorFlag,
  newAnalyticsflag,
  routingAnalyticsFlag,
  ~authenticationAnalyticsFlag,
  ~userHasResourceAccess,
) => {
  let links = [paymentAnalytcis, refundAnalytics]
  if authenticationAnalyticsFlag {
    links->Array.push(authenticationAnalytics)
  }
  if disputeAnalyticsFlag {
    links->Array.push(disputeAnalytics)
  }

  if newAnalyticsflag {
    links->Array.unshift(newAnalytics)
  }

  if performanceMonitorFlag {
    links->Array.push(performanceMonitor)
  }
  if routingAnalyticsFlag {
    links->Array.push(routingAnalytics)
  }

  isAnalyticsEnabled
    ? Section({
        name: "Analytics",
        icon: "nd-analytics",
        showSection: userHasResourceAccess(~resourceAccess=Analytics) === CommonAuthTypes.Access,
        links,
      })
    : emptyComponent
}
let routing = userHasResourceAccess => {
  SubLevelLink({
    name: "Routing",
    link: `/routing`,
    access: userHasResourceAccess(~resourceAccess=Routing),
    searchOptions: [
      ("Manage default routing configuration", "/default"),
      ("Create new volume based routing", "/volume"),
      ("Create new rule based routing", "/rule"),
      ("Manage smart routing", ""),
    ],
  })
}

let payoutRouting = userHasResourceAccess => {
  SubLevelLink({
    name: "Payout Routing",
    link: `/payoutrouting`,
    access: userHasResourceAccess(~resourceAccess=Routing),
    searchOptions: [
      ("Manage default routing configuration", "/default"),
      ("Create new volume based routing", "/volume"),
      ("Create new rule based routing", "/rule"),
      ("Manage smart routing", ""),
    ],
  })
}

let threeDsExemption = userHasResourceAccess => {
  SubLevelLink({
    name: "3DS Exemption Manager",
    iconTag: "betaTag",
    link: `/3ds-exemption`,
    access: userHasResourceAccess(~resourceAccess=ThreeDsDecisionManager), // Assuming same access as 3DS Decision Manager for now
    searchOptions: [("View 3DS Exemption", "")],
  })
}

let threeDs = userHasResourceAccess => {
  SubLevelLink({
    name: "3DS Decision Manager",
    link: `/3ds`,
    access: userHasResourceAccess(~resourceAccess=ThreeDsDecisionManager),
    searchOptions: [("Configure 3ds", "")],
  })
}
let surcharge = userHasResourceAccess => {
  SubLevelLink({
    name: "Surcharge",
    link: `/surcharge`,
    access: userHasResourceAccess(~resourceAccess=SurchargeDecisionManager),
    searchOptions: [("Add Surcharge", "")],
  })
}

let workflow = (
  isWorkflowEnabled,
  isSurchargeEnabled,
  threedsExemptionRules,
  ~userHasResourceAccess,
  ~isPayoutEnabled,
  ~userEntity,
) => {
  let routing = routing(userHasResourceAccess)
  let threeDs = threeDs(userHasResourceAccess)
  let payoutRouting = payoutRouting(userHasResourceAccess)
  let surcharge = surcharge(userHasResourceAccess)

  let defaultWorkFlow = [routing]
  let isNotProfileEntity = userEntity !== #Profile

  if isSurchargeEnabled && isNotProfileEntity {
    defaultWorkFlow->Array.push(surcharge)->ignore
  }
  if isNotProfileEntity {
    defaultWorkFlow->Array.push(threeDs)->ignore
  }
  if isPayoutEnabled {
    defaultWorkFlow->Array.push(payoutRouting)->ignore
  }
  if threedsExemptionRules {
    defaultWorkFlow->Array.push(threeDsExemption(userHasResourceAccess))->ignore
  }

  isWorkflowEnabled
    ? Section({
        name: "Workflow",
        icon: "nd-workflow",
        showSection: true,
        links: defaultWorkFlow,
        selectedIcon: "nd-workflow-fill",
      })
    : emptyComponent
}

let userManagement = userHasResourceAccess => {
  SubLevelLink({
    name: "Users",
    link: `/users`,
    access: userHasResourceAccess(~resourceAccess=User),
    searchOptions: [("View user management", "")],
  })
}
let configurePMTs = userHasResourceAccess => {
  SubLevelLink({
    name: "Configure PMTs",
    link: `/configure-pmts`,
    access: userHasResourceAccess(~resourceAccess=Connector),
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

let settings = (~isConfigurePmtsEnabled, ~userHasResourceAccess, ~complianceCertificate) => {
  let settingsLinkArray = []

  if isConfigurePmtsEnabled {
    settingsLinkArray->Array.push(configurePMTs(userHasResourceAccess))->ignore
  }

  if complianceCertificate {
    settingsLinkArray->Array.push(complianceCertificateSection)->ignore
  }

  settingsLinkArray->Array.push(userManagement(userHasResourceAccess))->ignore

  Section({
    name: "Settings",
    icon: "nd-settings",
    showSection: true,
    links: settingsLinkArray,
    selectedIcon: "nd-settings-fill",
  })
}

let apiKeys = userHasResourceAccess => {
  SubLevelLink({
    name: "API Keys",
    link: `/developer-api-keys`,
    access: userHasResourceAccess(~resourceAccess=ApiKey),
    searchOptions: [("View API Keys", "")],
  })
}

let paymentSettings = userHasResourceAccess => {
  SubLevelLink({
    name: "Payment Settings",
    link: `/payment-settings`,
    access: userHasResourceAccess(~resourceAccess=Account),
    searchOptions: [("View payment settings", ""), ("View webhooks", ""), ("View return url", "")],
  })
}
let paymentSettingsV2 = userHasResourceAccess => {
  SubLevelLink({
    name: "Payment Settings V2",
    link: `/payment-settings-new`,
    access: userHasResourceAccess(~resourceAccess=Account),
    searchOptions: [("View payment settings", ""), ("View webhooks", ""), ("View return url", "")],
  })
}

let webhooks = userHasResourceAccess => {
  SubLevelLink({
    name: "Webhooks",
    link: `/webhooks`,
    access: userHasResourceAccess(~resourceAccess=Account),
    searchOptions: [("Webhooks", ""), ("Retry webhooks", "")],
  })
}

let developers = (
  isDevelopersEnabled,
  ~isWebhooksEnabled,
  ~userHasResourceAccess,
  ~checkUserEntity,
  ~isPaymentSettingsV2Enabled,
) => {
  let isProfileUser = checkUserEntity([#Profile])
  let apiKeys = apiKeys(userHasResourceAccess)
  let paymentSettings = paymentSettings(userHasResourceAccess)
  let paymentSettingsV2 = paymentSettingsV2(userHasResourceAccess)
  let webhooks = webhooks(userHasResourceAccess)

  let defaultDevelopersOptions = [paymentSettings]
  if isWebhooksEnabled {
    defaultDevelopersOptions->Array.push(webhooks)
  }
  if isPaymentSettingsV2Enabled {
    defaultDevelopersOptions->Array.push(paymentSettingsV2)
  }

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
// Commented as not needed now
// let reconFileProcessor = {
//   SubLevelLink({
//     name: "File Processor",
//     link: `/file-processor`,
//     access: Access,
//     searchOptions: [("Recon file processor", "")],
//   })
// }

let reconAndSettlement = (recon, isReconEnabled, checkUserEntity, userHasResourceAccess) => {
  switch (recon, isReconEnabled, checkUserEntity([#Merchant, #Organization, #Tenant])) {
  | (true, true, true) => {
      let links = []
      if userHasResourceAccess(~resourceAccess=ReconFiles) == CommonAuthTypes.Access {
        links->Array.push(uploadReconFiles)
      }
      if userHasResourceAccess(~resourceAccess=RunRecon) == CommonAuthTypes.Access {
        links->Array.push(runRecon)
      }
      if (
        userHasResourceAccess(~resourceAccess=ReconAndSettlementAnalytics) == CommonAuthTypes.Access
      ) {
        links->Array.push(reconAnalytics)
      }
      if userHasResourceAccess(~resourceAccess=ReconReports) == CommonAuthTypes.Access {
        links->Array.push(reconReports)
      }
      if userHasResourceAccess(~resourceAccess=ReconConfig) == CommonAuthTypes.Access {
        links->Array.push(reconConfigurator)
      }
      // Commented as not needed now
      // if userHasResourceAccess(~resourceAccess=ReconFiles) == CommonAuthTypes.Access {
      //   links->Array.push(reconFileProcessor)
      // }
      Section({
        name: "Recon And Settlement",
        icon: "recon",
        showSection: true,
        links,
      })
    }
  | (true, false, true) =>
    Link({
      name: "Reconciliation",
      icon: isReconEnabled ? "recon" : "recon-lock",
      link: `/recon`,
      access: userHasResourceAccess(~resourceAccess=ReconToken),
    })

  | _ => emptyComponent
  }
}

let useGetHsSidebarValues = (~isReconEnabled: bool) => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasResourceAccess} = GroupACLHooks.useUserGroupACLHook()
  let {userInfo: {userEntity}, checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let {
    frm,
    payOut,
    recon,
    default,
    surcharge: isSurchargeEnabled,
    isLiveMode,
    threedsAuthenticator,
    disputeAnalytics,
    configurePmts,
    complianceCertificate,
    performanceMonitor: performanceMonitorFlag,
    pmAuthenticationProcessor,
    taxProcessor,
    newAnalytics,
    authenticationAnalytics,
    devAltPaymentMethods,
    devWebhooks,
    threedsExemptionRules,
    paymentSettingsV2,
    routingAnalytics,
  } = featureFlagDetails
  let {
    useIsFeatureEnabledForBlackListMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()
  let isNewAnalyticsEnable =
    newAnalytics && useIsFeatureEnabledForBlackListMerchant(merchantSpecificConfig.newAnalytics)
  let sidebar = [
    default->home,
    default->operations(~userHasResourceAccess, ~isPayoutsEnabled=payOut, ~userEntity),
    default->connectors(
      ~isLiveMode,
      ~isFrmEnabled=frm,
      ~isPayoutsEnabled=payOut,
      ~isThreedsConnectorEnabled=threedsAuthenticator,
      ~isPMAuthenticationProcessor=pmAuthenticationProcessor,
      ~isTaxProcessor=taxProcessor,
      ~userHasResourceAccess,
    ),
    default->analytics(
      disputeAnalytics,
      performanceMonitorFlag,
      isNewAnalyticsEnable,
      routingAnalytics,
      ~authenticationAnalyticsFlag=authenticationAnalytics,
      ~userHasResourceAccess,
    ),
    default->workflow(
      isSurchargeEnabled,
      threedsExemptionRules,
      ~userHasResourceAccess,
      ~isPayoutEnabled=payOut,
      ~userEntity,
    ),
    devAltPaymentMethods->alternatePaymentMethods,
    recon->reconAndSettlement(isReconEnabled, checkUserEntity, userHasResourceAccess),
    default->developers(
      ~isWebhooksEnabled=devWebhooks,
      ~userHasResourceAccess,
      ~checkUserEntity,
      ~isPaymentSettingsV2Enabled=paymentSettingsV2,
    ),
    settings(~isConfigurePmtsEnabled=configurePmts, ~userHasResourceAccess, ~complianceCertificate),
  ]

  sidebar
}

let useGetSidebarValuesForCurrentActive = (~isReconEnabled) => {
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let hsSidebars = useGetHsSidebarValues(~isReconEnabled)
  let orchestratorV2Sidebars = OrchestrationV2SidebarValues.useGetOrchestrationV2SidebarValues()
  let defaultSidebar = []

  if featureFlagDetails.devModularityV2 {
    defaultSidebar->Array.pushMany([
      Link({
        name: "Home",
        icon: "nd-home",
        link: "/v2/home",
        access: Access,
        selectedIcon: "nd-fill-home",
      }),
      CustomComponent({
        component: <ProductHeaderComponent />,
      }),
    ])
  }

  let sidebarValuesForProduct = switch activeProduct {
  | Orchestration(V1) => hsSidebars
  | Recon(V2) => ReconSidebarValues.reconSidebars
  | Recovery => RevenueRecoverySidebarValues.recoverySidebars
  | Vault => VaultSidebarValues.vaultSidebars
  | CostObservability => HypersenseSidebarValues.hypersenseSidebars
  | DynamicRouting => IntelligentRoutingSidebarValues.intelligentRoutingSidebars
  | Orchestration(V2) => orchestratorV2Sidebars
  | Recon(V1) => ReconEngineSidebarValues.reconEngineSidebars
  }
  defaultSidebar->Array.concat(sidebarValuesForProduct)
}
