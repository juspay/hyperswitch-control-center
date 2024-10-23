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

let productionAccessComponent = (isProductionAccessEnabled, userHasAccess) =>
  isProductionAccessEnabled &&
  userHasAccess(~groupAccess=MerchantDetailsManage) === CommonAuthTypes.Access
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

let payments = userHasAccess => {
  SubLevelLink({
    name: "Payments",
    link: `/payments`,
    access: userHasAccess(~groupAccess=OperationsView),
    searchOptions: [("View payment operations", "")],
  })
}

let refunds = userHasAccess => {
  SubLevelLink({
    name: "Refunds",
    link: `/refunds`,
    access: userHasAccess(~groupAccess=OperationsView),
    searchOptions: [("View refund operations", "")],
  })
}

let disputes = userHasAccess => {
  SubLevelLink({
    name: "Disputes",
    link: `/disputes`,
    access: userHasAccess(~groupAccess=OperationsView),
    searchOptions: [("View dispute operations", "")],
  })
}

let customers = userHasAccess => {
  SubLevelLink({
    name: "Customers",
    link: `/customers`,
    access: userHasAccess(~groupAccess=OperationsView),
    searchOptions: [("View customers", "")],
  })
}

let payouts = userHasAccess => {
  SubLevelLink({
    name: "Payouts",
    link: `/payouts`,
    access: userHasAccess(~groupAccess=OperationsView),
    searchOptions: [("View payouts operations", "")],
  })
}

let operations = (isOperationsEnabled, ~userHasAccess, ~isPayoutsEnabled, ~userEntity) => {
  let payments = payments(userHasAccess)
  let refunds = refunds(userHasAccess)
  let disputes = disputes(userHasAccess)
  let customers = customers(userHasAccess)
  let payouts = payouts(userHasAccess)

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

let paymentProcessor = (isLiveMode, userHasAccess) => {
  SubLevelLink({
    name: "Payment Processors",
    link: `/connectors`,
    access: userHasAccess(~groupAccess=ConnectorsView),
    searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
      ~processorList=isLiveMode
        ? ConnectorUtils.connectorListForLive
        : ConnectorUtils.connectorList,
      ~getNameFromString=ConnectorUtils.getConnectorNameString,
    ),
  })
}

let payoutConnectors = (~userHasAccess) => {
  SubLevelLink({
    name: "Payout Processors",
    link: `/payoutconnectors`,
    access: userHasAccess(~groupAccess=ConnectorsView),
    searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
      ~processorList=ConnectorUtils.payoutConnectorList,
      ~getNameFromString=ConnectorUtils.getConnectorNameString,
    ),
  })
}

let fraudAndRisk = (~userHasAccess) => {
  SubLevelLink({
    name: "Fraud & Risk",
    link: `/fraud-risk-management`,
    access: userHasAccess(~groupAccess=ConnectorsView),
    searchOptions: [],
  })
}

let threeDsConnector = (~userHasAccess) => {
  SubLevelLink({
    name: "3DS Authenticator",
    link: "/3ds-authenticators",
    access: userHasAccess(~groupAccess=ConnectorsView),
    searchOptions: [
      ("Connect 3dsecure.io", "/new?name=threedsecureio"),
      ("Connect threedsecureio", "/new?name=threedsecureio"),
    ],
  })
}

let pmAuthenticationProcessor = (~userHasAccess) => {
  SubLevelLink({
    name: "PM Authentication Processor",
    link: `/pm-authentication-processor`,
    access: userHasAccess(~groupAccess=ConnectorsView),
    searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
      ~processorList=ConnectorUtils.pmAuthenticationConnectorList,
      ~getNameFromString=ConnectorUtils.getConnectorNameString,
    ),
  })
}

let taxProcessor = (~userHasAccess) => {
  SubLevelLink({
    name: "Tax Processor",
    link: `/tax-processor`,
    access: userHasAccess(~groupAccess=ConnectorsView),
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
  ~userHasAccess,
) => {
  let connectorLinkArray = [paymentProcessor(isLiveMode, userHasAccess)]

  if isPayoutsEnabled {
    connectorLinkArray->Array.push(payoutConnectors(~userHasAccess))->ignore
  }
  if isThreedsConnectorEnabled {
    connectorLinkArray->Array.push(threeDsConnector(~userHasAccess))->ignore
  }

  if isFrmEnabled {
    connectorLinkArray->Array.push(fraudAndRisk(~userHasAccess))->ignore
  }

  if isPMAuthenticationProcessor {
    connectorLinkArray->Array.push(pmAuthenticationProcessor(~userHasAccess))->ignore
  }

  if isTaxProcessor {
    connectorLinkArray->Array.push(taxProcessor(~userHasAccess))->ignore
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
  ~userHasAccess,
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
        showSection: userHasAccess(~groupAccess=AnalyticsView) === CommonAuthTypes.Access,
        links,
      })
    : emptyComponent
}
let routing = userHasAccess => {
  SubLevelLink({
    name: "Routing",
    link: `/routing`,
    access: userHasAccess(~groupAccess=WorkflowsView),
    searchOptions: [
      ("Manage default routing configuration", "/default"),
      ("Create new volume based routing", "/volume"),
      ("Create new rule based routing", "/rule"),
      ("Manage smart routing", ""),
    ],
  })
}

let payoutRouting = userHasAccess => {
  SubLevelLink({
    name: "Payout Routing",
    link: `/payoutrouting`,
    access: userHasAccess(~groupAccess=WorkflowsView),
    searchOptions: [
      ("Manage default routing configuration", "/default"),
      ("Create new volume based routing", "/volume"),
      ("Create new rule based routing", "/rule"),
      ("Manage smart routing", ""),
    ],
  })
}

let threeDs = userHasAccess => {
  SubLevelLink({
    name: "3DS Decision Manager",
    link: `/3ds`,
    access: userHasAccess(~groupAccess=WorkflowsView),
    searchOptions: [("Configure 3ds", "")],
  })
}
let surcharge = userHasAccess => {
  SubLevelLink({
    name: "Surcharge",
    link: `/surcharge`,
    access: userHasAccess(~groupAccess=WorkflowsView),
    searchOptions: [("Add Surcharge", "")],
  })
}

let workflow = (
  isWorkflowEnabled,
  isSurchargeEnabled,
  ~userHasAccess,
  ~isPayoutEnabled,
  ~userEntity,
) => {
  let routing = routing(userHasAccess)
  let threeDs = threeDs(userHasAccess)
  let payoutRouting = payoutRouting(userHasAccess)
  let surcharge = surcharge(userHasAccess)

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

let userManagement = userHasAccess => {
  SubLevelLink({
    name: "Users",
    link: `/users`,
    access: userHasAccess(~groupAccess=UsersView),
    searchOptions: [("View user management", "")],
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

let configurePMTs = userHasAccess => {
  SubLevelLink({
    name: "Configure PMTs",
    link: `/configure-pmts`,
    access: userHasAccess(~groupAccess=ConnectorsView),
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

let settings = (~isConfigurePmtsEnabled, ~userHasAccess, ~complianceCertificate) => {
  let settingsLinkArray = [businessDetails(), businessProfiles()]

  if isConfigurePmtsEnabled {
    settingsLinkArray->Array.push(configurePMTs(userHasAccess))->ignore
  }

  if complianceCertificate {
    settingsLinkArray->Array.push(complianceCertificateSection)->ignore
  }

  settingsLinkArray->Array.push(userManagement(userHasAccess))->ignore

  Section({
    name: "Settings",
    icon: "hswitch-settings",
    showSection: true,
    links: settingsLinkArray,
  })
}

let apiKeys = userHasAccess => {
  SubLevelLink({
    name: "API Keys",
    link: `/developer-api-keys`,
    access: userHasAccess(~groupAccess=MerchantDetailsManage),
    searchOptions: [("View API Keys", "")],
  })
}

let systemMetric = userHasAccess => {
  SubLevelLink({
    name: "System Metrics",
    link: `/developer-system-metrics`,
    access: userHasAccess(~groupAccess=AnalyticsView),
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

let developers = (
  isDevelopersEnabled,
  systemMetrics,
  ~userHasAccess,
  ~checkUserEntity,
  ~roleId,
) => {
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let isProfileUser = checkUserEntity([#Profile])
  let apiKeys = apiKeys(userHasAccess)
  let paymentSettings = paymentSettings()
  let systemMetric = systemMetric(userHasAccess)

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

let reconAndSettlement = (recon, isReconEnabled, checkUserEntity) => {
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
      access: Access,
    })

  | _ => emptyComponent
  }
}

let useGetSidebarValues = (~isReconEnabled: bool) => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
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
    useHasEnabledForMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()
  let isNewAnalyticsEnable =
    newAnalytics && useHasEnabledForMerchant(merchantSpecificConfig.newAnalytics)
  let sidebar = [
    productionAccessComponent(quickStart, userHasAccess),
    default->home,
    default->operations(~userHasAccess, ~isPayoutsEnabled=payOut, ~userEntity),
    default->connectors(
      ~isLiveMode,
      ~isFrmEnabled=frm,
      ~isPayoutsEnabled=payOut,
      ~isThreedsConnectorEnabled=threedsAuthenticator,
      ~isPMAuthenticationProcessor=pmAuthenticationProcessor,
      ~isTaxProcessor=taxProcessor,
      ~userHasAccess,
    ),
    default->analytics(
      userJourneyAnalyticsFlag,
      authenticationAnalyticsFlag,
      disputeAnalytics,
      performanceMonitorFlag,
      isNewAnalyticsEnable,
      ~userHasAccess,
    ),
    default->workflow(isSurchargeEnabled, ~userHasAccess, ~isPayoutEnabled=payOut, ~userEntity),
    recon->reconAndSettlement(isReconEnabled, checkUserEntity),
    default->developers(systemMetrics, ~userHasAccess, ~checkUserEntity, ~roleId),
    settings(~isConfigurePmtsEnabled=configurePmts, ~userHasAccess, ~complianceCertificate),
  ]

  sidebar
}
