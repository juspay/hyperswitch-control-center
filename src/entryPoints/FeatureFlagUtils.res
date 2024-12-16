type config = {
  orgIds: array<string>,
  merchantIds: array<string>,
  profileIds: array<string>,
}
type merchantSpecificConfig = {newAnalytics: config}
type featureFlag = {
  default: bool,
  testLiveToggle: bool,
  email: bool,
  isLiveMode: bool,
  auditTrail: bool,
  systemMetrics: bool,
  sampleData: bool,
  frm: bool,
  payOut: bool,
  recon: bool,
  testProcessors: bool,
  feedback: bool,
  generateReport: bool,
  mixpanel: bool,
  mixpanelToken: string,
  userJourneyAnalytics: bool,
  authenticationAnalytics: bool,
  surcharge: bool,
  disputeEvidenceUpload: bool,
  paypalAutomaticFlow: bool,
  threedsAuthenticator: bool,
  globalSearch: bool,
  globalSearchFilters: bool,
  disputeAnalytics: bool,
  configurePmts: bool,
  branding: bool,
  liveUsersCounter: bool,
  granularity: bool,
  complianceCertificate: bool,
  pmAuthenticationProcessor: bool,
  performanceMonitor: bool,
  newAnalytics: bool,
  newAnalyticsSmartRetries: bool,
  newAnalyticsRefunds: bool,
  downTime: bool,
  taxProcessor: bool,
  xFeatureRoute: bool,
  tenantUser: bool,
}

let featureFlagType = (featureFlags: JSON.t) => {
  open LogicUtils
  let dict = featureFlags->getDictFromJsonObject->getDictfromDict("features")
  let typedFeatureFlag: featureFlag = {
    default: dict->getBool("default", true),
    testLiveToggle: dict->getBool("test_live_toggle", false),
    email: dict->getBool("email", false),
    isLiveMode: dict->getBool("is_live_mode", false),
    auditTrail: dict->getBool("audit_trail", false),
    systemMetrics: dict->getBool("system_metrics", false),
    sampleData: dict->getBool("sample_data", false),
    frm: dict->getBool("frm", false),
    payOut: dict->getBool("payout", false),
    recon: dict->getBool("recon", false),
    testProcessors: dict->getBool("test_processors", false),
    feedback: dict->getBool("feedback", false),
    generateReport: dict->getBool("generate_report", false),
    mixpanel: dict->getBool("mixpanel", false),
    mixpanelToken: dict->getString("mixpanel_token", ""),
    userJourneyAnalytics: dict->getBool("user_journey_analytics", false),
    authenticationAnalytics: dict->getBool("authentication_analytics", false),
    surcharge: dict->getBool("surcharge", false),
    disputeEvidenceUpload: dict->getBool("dispute_evidence_upload", false),
    paypalAutomaticFlow: dict->getBool("paypal_automatic_flow", false),
    threedsAuthenticator: dict->getBool("threeds_authenticator", false),
    globalSearch: dict->getBool("global_search", false),
    globalSearchFilters: dict->getBool("global_search_filters", false),
    disputeAnalytics: dict->getBool("dispute_analytics", false),
    configurePmts: dict->getBool("configure_pmts", false),
    branding: dict->getBool("branding", false),
    liveUsersCounter: dict->getBool("live_users_counter", false),
    granularity: dict->getBool("granularity", false),
    complianceCertificate: dict->getBool("compliance_certificate", false),
    pmAuthenticationProcessor: dict->getBool("pm_authentication_processor", false),
    performanceMonitor: dict->getBool("performance_monitor", false),
    newAnalytics: dict->getBool("new_analytics", false),
    newAnalyticsSmartRetries: dict->getBool("new_analytics_smart_retries", false),
    newAnalyticsRefunds: dict->getBool("new_analytics_refunds", false),
    downTime: dict->getBool("down_time", false),
    taxProcessor: dict->getBool("tax_processor", false),
    xFeatureRoute: dict->getBool("x_feature_route", false),
    tenantUser: dict->getBool("tenant_user", false),
  }
  typedFeatureFlag
}

let configMapper = dict => {
  open LogicUtils
  {
    orgIds: dict->getStrArrayFromDict("org_ids", []),
    merchantIds: dict->getStrArrayFromDict("merchant_ids", []),
    profileIds: dict->getStrArrayFromDict("profile_ids", []),
  }
}

let merchantSpecificConfig = (config: JSON.t) => {
  open LogicUtils
  let dict = config->getDictFromJsonObject
  {
    newAnalytics: dict->getDictfromDict("new_analytics")->configMapper,
  }
}
