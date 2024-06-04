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
                mixpanelEvent(~eventName="get_production_access", ())
              }
        }}>
        <div className={`text-white ${textStyles} !font-semibold`}>
          {productionAccessString->React.string}
        </div>
        <UIUtils.RenderIf condition={!isProdIntent}>
          <Icon name="thin-right-arrow" customIconColor="text-white" size=20 />
        </UIUtils.RenderIf>
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

let connectors = (
  isConnectorsEnabled,
  ~isLiveMode,
  ~isFrmEnabled,
  ~isPayoutsEnabled,
  ~isThreedsConnectorEnabled,
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

let accountSettings = permissionJson => {
  // Because it has delete sample data

  SubLevelLink({
    name: "Account Settings",
    link: `/account-settings`,
    access: permissionJson.merchantDetailsManage,
    searchOptions: [
      ("View profile", "/profile"),
      ("Change password", "/profile"),
      ("Manage your personal profile and preferences", "/profile"),
    ],
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
let settings = (~isSampleDataEnabled, ~isConfigurePmtsEnabled, ~permissionJson) => {
  let settingsLinkArray = [businessDetails(), businessProfiles()]

  if isSampleDataEnabled {
    settingsLinkArray->Array.push(accountSettings(permissionJson))->ignore
  }
  if isConfigurePmtsEnabled {
    settingsLinkArray->Array.push(configurePMTs(permissionJson))->ignore
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

let reconTag = (recon, isReconEnabled) =>
  recon
    ? Link({
        name: "Reconcilation",
        icon: isReconEnabled ? "recon" : "recon-lock",
        link: `/recon`,
        access: Access,
      })
    : emptyComponent

let useGetSidebarValues = (~isReconEnabled: bool) => {
  let {user_role: userRole} =
    CommonAuthHooks.useCommonAuthInfo()->Option.getOr(CommonAuthHooks.defaultAuthInfo)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let permissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

  let {
    frm,
    payOut,
    recon,
    default,
    sampleData,
    systemMetrics,
    userJourneyAnalytics: userJourneyAnalyticsFlag,
    authenticationAnalytics: authenticationAnalyticsFlag,
    surcharge: isSurchargeEnabled,
    isLiveMode,
    threedsAuthenticator,
    quickStart,
    disputeAnalytics,
    configurePmts,
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
      ~permissionJson,
    ),
    default->analytics(
      userJourneyAnalyticsFlag,
      authenticationAnalyticsFlag,
      disputeAnalytics,
      ~permissionJson,
    ),
    default->workflow(isSurchargeEnabled, ~permissionJson, ~isPayoutEnabled=payOut),
    recon->reconTag(isReconEnabled),
    default->developers(userRole, systemMetrics, ~permissionJson),
    settings(
      ~isSampleDataEnabled=sampleData,
      ~isConfigurePmtsEnabled=configurePmts,
      ~permissionJson,
    ),
  ]
  sidebar
}
