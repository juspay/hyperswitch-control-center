open SidebarTypes
open PermissionUtils

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
        access: Access,
      })
    : emptyComponent

let payments = permissionList => {
  let paymentPermission = [PaymentRead]
  let accessValue = getAccessValue(~permissionValue=paymentPermission, ~permissionList)

  SubLevelLink({
    name: "Payments",
    link: `/payments`,
    access: accessValue,
    searchOptions: [("View payment operations", "")],
  })
}

let refunds = permissionList => {
  let refundPermission = [RefundRead]
  let accessValue = getAccessValue(~permissionValue=refundPermission, ~permissionList)

  SubLevelLink({
    name: "Refunds",
    link: `/refunds`,
    access: accessValue,
    searchOptions: [("View refund operations", "")],
  })
}

let disputes = permissionList => {
  let disputePermission = [DisputeRead]
  let accessValue = getAccessValue(~permissionValue=disputePermission, ~permissionList)

  SubLevelLink({
    name: "Disputes",
    link: `/disputes`,
    access: accessValue,
    searchOptions: [("View dispute operations", "")],
  })
}

let customers = permissionList => {
  let customersPermission = [CustomerRead]
  let accessValue = getAccessValue(~permissionValue=customersPermission, ~permissionList)
  SubLevelLink({
    name: "Customers",
    link: `/customers`,
    access: accessValue,
    searchOptions: [("View customers", "")],
  })
}

let operations = (isOperationsEnabled, customersModule, ~permissionList) => {
  let payments = payments(permissionList)
  let refunds = refunds(permissionList)
  let disputes = disputes(permissionList)
  let customers = customers(permissionList)

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

let connectors = (isConnectorsEnabled, isLiveMode, ~permissionList) => {
  let connectorPermission = [MerchantConnectorAccountRead]
  let accessValue = getAccessValue(~permissionValue=connectorPermission, ~permissionList)
  isConnectorsEnabled
    ? Link({
        name: "Processors",
        link: `/connectors`,
        icon: "connectors",
        access: accessValue,
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

let analytics = (isAnalyticsEnabled, userJourneyAnalyticsFlag, ~permissionList) => {
  let analyticsPermission = [Analytics]
  let accessValue = getAccessValue(~permissionValue=analyticsPermission, ~permissionList)

  isAnalyticsEnabled
    ? Section({
        name: "Analytics",
        icon: "analytics",
        showSection: accessValue === Access,
        links: userJourneyAnalyticsFlag
          ? [paymentAnalytcis, refundAnalytics, userJourneyAnalytics]
          : [paymentAnalytcis, refundAnalytics],
      })
    : emptyComponent
}
let routing = permissionList => {
  let routingPermission = [RoutingRead]
  let accessValue = getAccessValue(~permissionValue=routingPermission, ~permissionList)
  SubLevelLink({
    name: "Routing",
    link: `/routing`,
    access: accessValue,
    searchOptions: [
      ("Manage default routing configuration", "/default"),
      ("Create new volume based routing", "/volume"),
      ("Create new rule based routing", "/rule"),
      ("Manage smart routing", ""),
    ],
  })
}

let threeDs = permissionList => {
  let threeDsPermission = [ThreeDsDecisionManagerRead]
  let accessValue = getAccessValue(~permissionValue=threeDsPermission, ~permissionList)
  SubLevelLink({
    name: "3DS Decision Manager",
    link: `/3ds`,
    access: accessValue,
    searchOptions: [("Configure 3ds", "")],
  })
}
let surcharge = permissionList => {
  let surchargePermission = [SurchargeDecisionManagerRead]
  let accessValue = getAccessValue(~permissionValue=surchargePermission, ~permissionList)
  SubLevelLink({
    name: "Surcharge",
    link: `/surcharge`,
    access: accessValue,
    searchOptions: [("Add Surcharge", "")],
  })
}

let workflow = (isWorkflowEnabled, isSurchargeEnabled, ~permissionList) => {
  let routing = routing(permissionList)
  let threeDs = threeDs(permissionList)
  let surcharge = surcharge(permissionList)

  isWorkflowEnabled
    ? Section({
        name: "Workflow",
        icon: "3ds",
        showSection: true,
        links: isSurchargeEnabled ? [routing, threeDs, surcharge] : [routing, threeDs],
      })
    : emptyComponent
}

let userManagement = permissionList => {
  let userPermission = [UsersRead]
  let accessValue = getAccessValue(~permissionValue=userPermission, ~permissionList)
  SubLevelLink({
    name: "Team",
    link: `/users`,
    access: accessValue,
    searchOptions: [("View team management", "")],
  })
}

let accountSettings = permissionList => {
  // Because it has delete sample data
  let merchantAccountPermission = [MerchantAccountWrite]
  let accessValue = getAccessValue(~permissionValue=merchantAccountPermission, ~permissionList)

  SubLevelLink({
    name: "Account Settings",
    link: `/account-settings`,
    access: accessValue,
    searchOptions: [
      ("View profile", "/profile"),
      ("Change password", "/profile"),
      ("Manage your personal profile and preferences", "/profile"),
    ],
  })
}

let businessDetails = permissionList => {
  let merchantAccountPermission = [MerchantAccountRead]
  let accessValue = getAccessValue(~permissionValue=merchantAccountPermission, ~permissionList)

  SubLevelLink({
    name: "Business Details",
    link: `/business-details`,
    access: accessValue,
    searchOptions: [("Configure business details", "")],
  })
}

let businessProfiles = permissionList => {
  let merchantAccountPermission = [MerchantAccountRead]
  let accessValue = getAccessValue(~permissionValue=merchantAccountPermission, ~permissionList)
  SubLevelLink({
    name: "Business Profiles",
    link: `/business-profiles`,
    access: accessValue,
    searchOptions: [("Configure business profiles", "")],
  })
}
let settings = (
  ~isSampleDataEnabled,
  ~isUserManagementEnabled,
  ~isBusinessProfileEnabled,
  ~permissionList,
) => {
  let settingsLinkArray = [businessDetails(permissionList)]

  if isBusinessProfileEnabled {
    settingsLinkArray->Array.push(businessProfiles(permissionList))->ignore
  }
  if isSampleDataEnabled {
    settingsLinkArray->Array.push(accountSettings(permissionList))->ignore
  }
  if isUserManagementEnabled {
    settingsLinkArray->Array.push(userManagement(permissionList))->ignore
  }

  Section({
    name: "Settings",
    icon: "hswitch-settings",
    showSection: true,
    links: settingsLinkArray,
  })
}

let apiKeys = permissionList => {
  let apiKeyPermission = [ApiKeyRead]
  let accessValue = getAccessValue(~permissionValue=apiKeyPermission, ~permissionList)

  SubLevelLink({
    name: "API Keys",
    link: `/developer-api-keys`,
    access: accessValue,
    searchOptions: [("View API Keys", "")],
  })
}

let systemMetric = permissionList => {
  let analyticsPermission = [Analytics]
  let accessValue = getAccessValue(~permissionValue=analyticsPermission, ~permissionList)

  SubLevelLink({
    name: "System Metrics",
    link: `/developer-system-metrics`,
    access: accessValue,
    iconTag: "betaTag",
    searchOptions: [("View System Metrics", "")],
  })
}

let paymentSettings = permissionList => {
  let merchantAccountPermission = [MerchantAccountRead]
  let accessValue = getAccessValue(~permissionValue=merchantAccountPermission, ~permissionList)

  SubLevelLink({
    name: "Payment Settings",
    link: `/payment-settings`,
    access: accessValue,
    searchOptions: [("View payment settings", ""), ("View webhooks", ""), ("View return url", "")],
  })
}

let developers = (isDevelopersEnabled, userRole, systemMetrics, ~permissionList) => {
  let isInternalUser = userRole->String.includes("internal_")
  let apiKeys = apiKeys(permissionList)
  let paymentSettings = paymentSettings(permissionList)
  let systemMetric = systemMetric(permissionList)

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

let fraudAndRisk = (isfraudAndRiskEnabled, ~permissionList) => {
  let connectorPermission = [MerchantConnectorAccountRead]
  let accessValue = getAccessValue(~permissionValue=connectorPermission, ~permissionList)

  isfraudAndRiskEnabled
    ? Link({
        name: "Fraud & Risk",
        icon: "shield-alt",
        link: `/fraud-risk-management`,
        access: accessValue,
        searchOptions: [],
      })
    : emptyComponent
}

let payoutConnectors = (isPayoutConnectorsEnabled, ~permissionList) => {
  let connectorPermission = [MerchantConnectorAccountRead]
  let accessValue = getAccessValue(~permissionValue=connectorPermission, ~permissionList)

  isPayoutConnectorsEnabled
    ? Link({
        name: "Payout Processors",
        link: `/payoutconnectors`,
        icon: "connectors",
        access: accessValue,
        searchOptions: HSwitchUtils.getSearchOptionsForProcessors(
          ~processorList=ConnectorUtils.payoutConnectorList,
          ~getNameFromString=ConnectorUtils.getConnectorNameString,
        ),
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
  // let permissionList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let permissionList = [
    // PaymentRead,
    PaymentWrite,
    RefundRead,
    RefundWrite,
    ApiKeyRead,
    ApiKeyWrite,
    MerchantAccountRead,
    MerchantAccountWrite,
    // MerchantConnectorAccountRead,
    ForexRead,
    MerchantConnectorAccountWrite,
    RoutingRead,
    RoutingWrite,
    ThreeDsDecisionManagerWrite,
    ThreeDsDecisionManagerRead,
    SurchargeDecisionManagerWrite,
    SurchargeDecisionManagerRead,
    DisputeRead,
    DisputeWrite,
    MandateRead,
    MandateWrite,
    CustomerRead,
    CustomerWrite,
    FileRead,
    FileWrite,
    Analytics,
    UsersRead,
    UsersWrite,
  ]

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
    default->operations(customersModule, ~permissionList),
    default->analytics(userJourneyAnalyticsFlag, ~permissionList),
    default->connectors(isLiveMode, ~permissionList),
    default->workflow(isSurchargeEnabled, ~permissionList),
    frm->fraudAndRisk(~permissionList),
    payOut->payoutConnectors(~permissionList),
    recon->reconTag(isReconEnabled),
    default->developers(userRole, systemMetrics, ~permissionList),
    settings(
      ~isUserManagementEnabled=userManagement,
      ~isBusinessProfileEnabled=businessProfile,
      ~isSampleDataEnabled=sampleData,
      ~permissionList,
    ),
  ]
  sidebar
}
