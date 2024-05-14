type basicAuthInfo = {
  token: option<string>,
  merchantId: option<string>,
  username: option<string>,
  email: option<string>,
  flowType: option<string>,
  userRole: option<string>,
  verificationDaysLeft: option<bool>,
  acceptInviteData: option<array<JSON.t>>,
}

type flowType = MERCHANT_SELECT | DASHBOARD_ENTRY | ERROR
