type featureFlag = {
  default: bool,
  productionAccess: bool,
  testLiveToggle: bool,
  magicLink: bool,
  quickStart: bool,
  openSDK: bool,
  switchMerchant: bool,
  testLiveMode: bool,
  auditTrail: bool,
  systemMetrics: bool,
  sampleData: bool,
  frm: bool,
  payOut: bool,
  recon: bool,
  userManagement: bool,
  testProcessors: bool,
  feedback: bool,
  generateReport: bool,
  businessProfile: bool,
  mixPanel: bool,
  verifyConnector: bool,
  forgetPassword: bool,
}

let featureFlagType = (featureFlags: Js.Json.t) => {
  open LogicUtils
  let dict = featureFlags->getDictFromJsonObject
  let typedFeatureFlag: featureFlag = {
    default: dict->getBool("default", true),
    productionAccess: dict->getBool("production_access", false),
    testLiveToggle: dict->getBool("test_live_toggle", false),
    magicLink: dict->getBool("magic_link", false),
    quickStart: dict->getBool("quick_start", false),
    openSDK: dict->getBool("open_sdk", false),
    switchMerchant: dict->getBool("switch_merchant", false),
    testLiveMode: dict->getBool("test_live_mode", false),
    auditTrail: dict->getBool("audit_trail", false),
    systemMetrics: dict->getBool("system_metrics", false),
    sampleData: dict->getBool("sample_data", false),
    frm: dict->getBool("frm", false),
    payOut: dict->getBool("payout", false),
    recon: dict->getBool("recon", false),
    userManagement: dict->getBool("user_management", false),
    testProcessors: dict->getBool("test_processors", false),
    feedback: dict->getBool("feedback", false),
    generateReport: dict->getBool("generate_report", false),
    businessProfile: dict->getBool("business_profile", false),
    mixPanel: dict->getBool("mixpanel", false),
    verifyConnector: dict->getBool("verify_connector", false),
    forgetPassword: dict->getBool("forgot_password", false),
  }
  typedFeatureFlag
}
