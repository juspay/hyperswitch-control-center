type config = {
  orgId: option<string>,
  merchantId: option<string>,
  profileId: option<string>,
}
type merchantSpecificConfig = {newAnalytics: config, devReconEngineV1: config}
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
  debitRouting: bool,
  devReconv2Product: bool,
  devRecoveryV2Product: bool,
  devVaultV2Product: bool,
  devAltPaymentMethods: bool,
  devHypersenseV2Product: bool,
  devModularityV2: bool,
  maintenanceAlert: string,
  forceCookies: bool,
  authenticationAnalytics: bool,
  devIntelligentRoutingV2: bool,
  googlePayDecryptionFlow: bool,
  devWebhooks: bool,
  sampleDataAnalytics: bool,
  threedsExemptionRules: bool,
  paymentSettingsV2: bool,
  acquirerConfigSettings: bool,
  exploreRecipes: bool,
  devOmpChart: bool,
  devOrchestrationV2Product: bool,
  devReconEngineV1: bool,
  devAiChatBot: bool,
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
    debitRouting: dict->getBool("dev_debit_routing", false),
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
    devReconv2Product: dict->getBool("dev_recon_v2_product", false),
    devRecoveryV2Product: dict->getBool("dev_recovery_v2_product", false),
    devVaultV2Product: dict->getBool("dev_vault_v2_product", false),
    devHypersenseV2Product: dict->getBool("dev_hypersense_v2_product", false),
    maintenanceAlert: dict->getString("maintenance_alert", ""),
    forceCookies: dict->getBool("force_cookies", false),
    authenticationAnalytics: dict->getBool("authentication_analytics", false),
    devModularityV2: dict->getBool("dev_modularity_v2", false),
    devAltPaymentMethods: dict->getBool("dev_alt_payment_methods", false),
    devIntelligentRoutingV2: dict->getBool("dev_intelligent_routing_v2", false),
    googlePayDecryptionFlow: dict->getBool("google_pay_decryption_flow", false),
    devWebhooks: dict->getBool("dev_webhooks", false),
    sampleDataAnalytics: dict->getBool("sample_data_analytics", false),
    acquirerConfigSettings: dict->getBool("acquirer_config_settings", false),
    paymentSettingsV2: dict->getBool("payment_settings_v2", false),
    exploreRecipes: dict->getBool("explore_recipes", false),
    threedsExemptionRules: dict->getBool("threeds_exemption", false),
    devOmpChart: dict->getBool("dev_omp_chart", false),
    devOrchestrationV2Product: dict->getBool("dev_orchestration_v2_product", false),
    devReconEngineV1: dict->getBool("dev_recon_engine_v1", false),
    devAiChatBot: dict->getBool("dev_ai_chat_bot", false),
  }
}

let configMapper = dict => {
  open LogicUtils
  {
    orgId: dict->getOptionString("org_id"),
    merchantId: dict->getOptionString("merchant_id"),
    profileId: dict->getOptionString("profile_id"),
  }
}

let merchantSpecificConfig = (config: JSON.t) => {
  open LogicUtils
  let dict = config->getDictFromJsonObject

  let blacklistDict = dict->getDictfromDict("blacklist")
  let newAnalyticsBlacklist = blacklistDict->getDictfromDict("new_analytics")->configMapper

  let whitelistDict = dict->getDictfromDict("whitelist")
  let devReconEngineV1Whitelist =
    whitelistDict->getDictfromDict("dev_recon_engine_v1")->configMapper

  {
    newAnalytics: newAnalyticsBlacklist,
    devReconEngineV1: devReconEngineV1Whitelist,
  }
}
