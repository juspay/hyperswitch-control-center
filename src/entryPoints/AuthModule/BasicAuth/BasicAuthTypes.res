type basicAuthInfo = {
  token: option<string>,
  merchantId: option<string>,
  username: option<string>,
  email: option<string>,
  flowType: option<string>,
  userRole: option<string>,
  verificationDaysLeft: option<bool>,
}

type modeType = TestButtonMode | LiveButtonMode

type flowType = MERCHANT_SELECT | DASHBOARD_ENTRY | ERROR
