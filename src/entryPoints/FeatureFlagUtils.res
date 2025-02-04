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
  sampleData: bool,
  frm: bool,
  payOut: bool,
  recon: bool,
  testProcessors: bool,
  feedback: bool,
  generateReport: bool,
  mixpanel: bool,
  mixpanelToken: string,
  surcharge: bool,
  disputeEvidenceUpload: bool,
  paypalAutomaticFlow: bool,
  threedsAuthenticator: bool,
  globalSearch: bool,
  globalSearchFilters: bool,
  disputeAnalytics: bool,
  configurePmts: bool,
  branding: bool,
  granularity: bool,
  complianceCertificate: bool,
  pmAuthenticationProcessor: bool,
  performanceMonitor: bool,
  newAnalytics: bool,
  newAnalyticsSmartRetries: bool,
  newAnalyticsRefunds: bool,
  newAnalyticsFilters: bool,
  downTime: bool,
  taxProcessor: bool,
  xFeatureRoute: bool,
  tenantUser: bool,
  clickToPay: bool,
  devThemeFeature: bool,
  devReconv2Product: bool,
  devRecoveryV2Product: bool,
  devVaultV2Product: bool,
  maintainenceAlert: string,
  forceCookies: bool,
  authenticationAnalytics: bool,
  devModularityV2: bool,
}

let featureFlagType = (featureFlags: JSON.t) => {
  open LogicUtils
  let dict = featureFlags->getDictFromJsonObject->getDictfromDict("features")

  {
    default: dict->getBool("default", true),
    testLiveToggle: dict->getBool("test_live_toggle", false),
    email: dict->getBool("email", false),
    isLiveMode: dict->getBool("is_live_mode", false),
    auditTrail: dict->getBool("audit_trail", false),
    sampleData: dict->getBool("sample_data", false),
    frm: dict->getBool("frm", false),
    payOut: dict->getBool("payout", false),
    recon: dict->getBool("recon", false),
    testProcessors: dict->getBool("test_processors", false),
    clickToPay: dict->getBool("dev_click_to_pay", false),
    feedback: dict->getBool("feedback", false),
    generateReport: dict->getBool("generate_report", false),
    mixpanel: dict->getBool("mixpanel", false),
    mixpanelToken: dict->getString("mixpanel_token", ""),
    surcharge: dict->getBool("surcharge", false),
    disputeEvidenceUpload: dict->getBool("dispute_evidence_upload", false),
    paypalAutomaticFlow: dict->getBool("paypal_automatic_flow", false),
    threedsAuthenticator: dict->getBool("threeds_authenticator", false),
    globalSearch: dict->getBool("global_search", false),
    globalSearchFilters: dict->getBool("global_search_filters", false),
    disputeAnalytics: dict->getBool("dispute_analytics", false),
    configurePmts: dict->getBool("configure_pmts", false),
    branding: dict->getBool("branding", false),
    granularity: dict->getBool("granularity", false),
    complianceCertificate: dict->getBool("compliance_certificate", false),
    pmAuthenticationProcessor: dict->getBool("pm_authentication_processor", false),
    performanceMonitor: dict->getBool("performance_monitor", false),
    newAnalytics: dict->getBool("new_analytics", false),
    newAnalyticsSmartRetries: dict->getBool("new_analytics_smart_retries", false),
    newAnalyticsRefunds: dict->getBool("new_analytics_refunds", false),
    newAnalyticsFilters: dict->getBool("new_analytics_filters", false),
    downTime: dict->getBool("down_time", false),
    taxProcessor: dict->getBool("tax_processor", false),
    xFeatureRoute: dict->getBool("x_feature_route", false),
    tenantUser: dict->getBool("tenant_user", false),
    devThemeFeature: dict->getBool("dev_theme_feature", false),
    devReconv2Product: dict->getBool("dev_recon_v2_product", false),
    devRecoveryV2Product: dict->getBool("dev_recovery_v2_product", false),
    devVaultV2Product: dict->getBool("dev_vault_v2_product", false),
    maintainenceAlert: dict->getString("maintainence_alert", ""),
    forceCookies: dict->getBool("force_cookies", false),
    authenticationAnalytics: dict->getBool("authentication_analytics", false),
    devModularityV2: dict->getBool("dev_modularity_v2", false),
  }
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
