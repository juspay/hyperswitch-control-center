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

let productionAccessComponent = (isProductionAccessEnabled, userHasAccess, hasAnyGroupAccess) =>
  isProductionAccessEnabled &&
  // TODO: Remove `MerchantDetailsManage` permission in future
  hasAnyGroupAccess(
    userHasAccess(~groupAccess=MerchantDetailsManage),
    userHasAccess(~groupAccess=AccountManage),
  ) === CommonAuthTypes.Access
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
        icon: "hswitch-operations",
        showSection: true,
        links,
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
    name: "3DS Authenticator",
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

let newAnalytics = SubLevelLink({
  name: "New Analytics",
  link: `/new-analytics-payment`,
  access: Access,
  searchOptions: [("New Analytics", "")],
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
  newAnalyticsflag,
  ~userHasResourceAccess,
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

  if newAnalyticsflag {
    links->Array.push(newAnalytics)
  }

  isAnalyticsEnabled
    ? Section({
        name: "Analytics",
        icon: "analytics",
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

  isWorkflowEnabled
    ? Section({
        name: "Workflow",
        icon: "3ds",
        showSection: true,
        links: defaultWorkFlow,
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

let businessDetails = userHasResourceAccess => {
  SubLevelLink({
    name: "Business Details",
    link: `/business-details`,
    access: userHasResourceAccess(~resourceAccess=Account),
    searchOptions: [("Configure business details", "")],
  })
}

let businessProfiles = userHasResourceAccess => {
  SubLevelLink({
    name: "Business Profiles",
    link: `/business-profiles`,
    access: userHasResourceAccess(~resourceAccess=Account),
    searchOptions: [("Configure business profiles", "")],
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
  let settingsLinkArray = [
    businessDetails(userHasResourceAccess),
    businessProfiles(userHasResourceAccess),
  ]

  if isConfigurePmtsEnabled {
    settingsLinkArray->Array.push(configurePMTs(userHasResourceAccess))->ignore
  }

  if complianceCertificate {
    settingsLinkArray->Array.push(complianceCertificateSection)->ignore
  }

  settingsLinkArray->Array.push(userManagement(userHasResourceAccess))->ignore

  Section({
    name: "Settings",
    icon: "hswitch-settings",
    showSection: true,
    links: settingsLinkArray,
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

let systemMetric = userHasResourceAccess => {
  SubLevelLink({
    name: "System Metrics",
    link: `/developer-system-metrics`,
    access: userHasResourceAccess(~resourceAccess=Analytics),
    iconTag: "betaTag",
    searchOptions: [("View System Metrics", "")],
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

let developers = (
  isDevelopersEnabled,
  systemMetrics,
  ~userHasResourceAccess,
  ~checkUserEntity,
  ~roleId,
) => {
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let isProfileUser = checkUserEntity([#Profile])
  let apiKeys = apiKeys(userHasResourceAccess)
  let paymentSettings = paymentSettings(userHasResourceAccess)
  let systemMetric = systemMetric(userHasResourceAccess)

  let defaultDevelopersOptions = [paymentSettings]

  if isInternalUser && systemMetrics {
    defaultDevelopersOptions->Array.push(systemMetric)
  }
  if !isProfileUser {
    defaultDevelopersOptions->Array.push(apiKeys)
  }

  isDevelopersEnabled
    ? Section({
        name: "Developers",
        icon: "developer",
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
let reconFileProcessor = {
  SubLevelLink({
    name: "File Processor",
    link: `/file-processor`,
    access: Access,
    searchOptions: [("Recon file processor", "")],
  })
}

let reconAndSettlement = (recon, isReconEnabled, checkUserEntity, userHasResourceAccess) => {
  switch (recon, isReconEnabled, checkUserEntity([#Merchant, #Organization])) {
  | (true, true, true) =>
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
  | (true, false, true) =>
    Link({
      name: "Reconciliation",
      icon: isReconEnabled ? "recon" : "recon-lock",
      link: `/recon`,
      access: userHasResourceAccess(~resourceAccess=Recon),
    })

  | _ => emptyComponent
  }
}

let useGetSidebarValues = (~isReconEnabled: bool) => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
  let {userHasResourceAccess} = GroupACLHooks.useUserGroupACLHook()
  let {userInfo: {userEntity, roleId}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
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
    performanceMonitor: performanceMonitorFlag,
    pmAuthenticationProcessor,
    taxProcessor,
    newAnalytics,
  } = featureFlagDetails
  let {
    useIsFeatureEnabledForMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()
  let isNewAnalyticsEnable =
    newAnalytics && useIsFeatureEnabledForMerchant(merchantSpecificConfig.newAnalytics)
  let sidebar = [
    productionAccessComponent(quickStart, userHasAccess, hasAnyGroupAccess),
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
      userJourneyAnalyticsFlag,
      authenticationAnalyticsFlag,
      disputeAnalytics,
      performanceMonitorFlag,
      isNewAnalyticsEnable,
      ~userHasResourceAccess,
    ),
    default->workflow(
      isSurchargeEnabled,
      ~userHasResourceAccess,
      ~isPayoutEnabled=payOut,
      ~userEntity,
    ),
    recon->reconAndSettlement(isReconEnabled, checkUserEntity, userHasResourceAccess),
    default->developers(systemMetrics, ~userHasResourceAccess, ~checkUserEntity, ~roleId),
    settings(~isConfigurePmtsEnabled=configurePmts, ~userHasResourceAccess, ~complianceCertificate),
  ]

  sidebar
}
