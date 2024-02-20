open SidebarTypes
open PermissionUtils

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
          <Icon name="thin-right-arrow" customIconColor="white" size=20 />
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
    access: permissionJson.paymentRead,
    searchOptions: [("View payment operations", "")],
  })
}

let refunds = permissionJson => {
  SubLevelLink({
    name: "Refunds",
    link: `/refunds`,
    access: permissionJson.refundRead,
    searchOptions: [("View refund operations", "")],
  })
}

let disputes = permissionJson => {
  SubLevelLink({
    name: "Disputes",
    link: `/disputes`,
    access: permissionJson.disputeRead,
    searchOptions: [("View dispute operations", "")],
  })
}

let customers = permissionJson => {
  SubLevelLink({
    name: "Customers",
    link: `/customers`,
    access: permissionJson.customerRead,
    searchOptions: [("View customers", "")],
  })
}

let operations = (isOperationsEnabled, ~permissionJson) => {
  let payments = payments(permissionJson)
  let refunds = refunds(permissionJson)
  let disputes = disputes(permissionJson)
  let customers = customers(permissionJson)

  isOperationsEnabled
    ? Section({
        name: "Operations",
        icon: "hswitch-operations",
        showSection: true,
        links: [payments, refunds, disputes, customers],
      })
    : emptyComponent
}

let paymentProcessor = (isLiveMode, permissionJson) => {
  SubLevelLink({
    name: "Payment Processor",
    link: `/connectors`,
    access: permissionJson.merchantConnectorAccountRead,
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
    access: permissionJson.merchantConnectorAccountRead,
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
    access: permissionJson.merchantConnectorAccountRead,
    searchOptions: [],
  })
}

let connectors = (
  isConnectorsEnabled,
  ~isLiveMode,
  ~isFrmEnabled,
  ~isPayoutsEnabled,
  ~permissionJson,
) => {
  let connectorLinkArray = [paymentProcessor(isLiveMode, permissionJson)]

  if isPayoutsEnabled {
    connectorLinkArray->Array.push(payoutConnectors(~permissionJson))->ignore
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

let analytics = (isAnalyticsEnabled, userJourneyAnalyticsFlag, ~permissionJson) => {
  isAnalyticsEnabled
    ? Section({
        name: "Analytics",
        icon: "analytics",
        showSection: permissionJson.analytics === Access,
        links: userJourneyAnalyticsFlag
          ? [paymentAnalytcis, refundAnalytics, userJourneyAnalytics]
          : [paymentAnalytcis, refundAnalytics],
      })
    : emptyComponent
}
let routing = permissionJson => {
  SubLevelLink({
    name: "Routing",
    link: `/routing`,
    access: permissionJson.routingRead,
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
    access: permissionJson.threeDsDecisionManagerRead,
    searchOptions: [("Configure 3ds", "")],
  })
}
let surcharge = permissionJson => {
  SubLevelLink({
    name: "Surcharge",
    link: `/surcharge`,
    access: permissionJson.surchargeDecisionManagerRead,
    searchOptions: [("Add Surcharge", "")],
  })
}

let workflow = (isWorkflowEnabled, isSurchargeEnabled, ~permissionJson) => {
  let routing = routing(permissionJson)
  let threeDs = threeDs(permissionJson)
  let surcharge = surcharge(permissionJson)

  isWorkflowEnabled
    ? Section({
        name: "Workflow",
        icon: "3ds",
        showSection: true,
        links: isSurchargeEnabled ? [routing, threeDs, surcharge] : [routing, threeDs],
      })
    : emptyComponent
}

let userManagement = permissionJson => {
  SubLevelLink({
    name: "Team",
    link: `/users`,
    access: permissionJson.usersRead,
    searchOptions: [("View team management", "")],
  })
}

let accountSettings = permissionJson => {
  // Because it has delete sample data

  SubLevelLink({
    name: "Account Settings",
    link: `/account-settings`,
    access: permissionJson.merchantAccountWrite,
    searchOptions: [
      ("View profile", "/profile"),
      ("Change password", "/profile"),
      ("Manage your personal profile and preferences", "/profile"),
    ],
  })
}

let businessDetails = permissionJson => {
  SubLevelLink({
    name: "Business Details",
    link: `/business-details`,
    access: permissionJson.merchantAccountRead,
    searchOptions: [("Configure business details", "")],
  })
}

let businessProfiles = permissionJson => {
  SubLevelLink({
    name: "Business Profiles",
    link: `/business-profiles`,
    access: permissionJson.merchantAccountRead,
    searchOptions: [("Configure business profiles", "")],
  })
}
let settings = (~isSampleDataEnabled, ~isBusinessProfileEnabled, ~permissionJson) => {
  let settingsLinkArray = [businessDetails(permissionJson)]

  if isBusinessProfileEnabled {
    settingsLinkArray->Array.push(businessProfiles(permissionJson))->ignore
  }
  if isSampleDataEnabled {
    settingsLinkArray->Array.push(accountSettings(permissionJson))->ignore
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
    access: permissionJson.apiKeyRead,
    searchOptions: [("View API Keys", "")],
  })
}

let systemMetric = permissionJson => {
  SubLevelLink({
    name: "System Metrics",
    link: `/developer-system-metrics`,
    access: permissionJson.analytics,
    iconTag: "betaTag",
    searchOptions: [("View System Metrics", "")],
  })
}

let paymentSettings = permissionJson => {
  SubLevelLink({
    name: "Payment Settings",
    link: `/payment-settings`,
    access: permissionJson.merchantAccountRead,
    searchOptions: [("View payment settings", ""), ("View webhooks", ""), ("View return url", "")],
  })
}

let developers = (isDevelopersEnabled, userRole, systemMetrics, ~permissionJson) => {
  let isInternalUser = userRole->String.includes("internal_")
  let apiKeys = apiKeys(permissionJson)
  let paymentSettings = paymentSettings(permissionJson)
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
  let userRole = HSLocalStorage.getFromUserDetails("user_role")
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let permissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

  let {
    productionAccess,
    frm,
    payOut,
    recon,
    default,
    sampleData,
    businessProfile,
    systemMetrics,
    userJourneyAnalytics: userJourneyAnalyticsFlag,
    surcharge: isSurchargeEnabled,
    isLiveMode,
  } = featureFlagDetails

  let sidebar = [
    productionAccess->productionAccessComponent,
    default->home,
    default->operations(~permissionJson),
    default->connectors(~isLiveMode, ~isFrmEnabled=frm, ~isPayoutsEnabled=payOut, ~permissionJson),
    default->analytics(userJourneyAnalyticsFlag, ~permissionJson),
    default->workflow(isSurchargeEnabled, ~permissionJson),
    recon->reconTag(isReconEnabled),
    default->developers(userRole, systemMetrics, ~permissionJson),
    settings(
      ~isBusinessProfileEnabled=businessProfile,
      ~isSampleDataEnabled=sampleData,
      ~permissionJson,
    ),
  ]
  sidebar
}
