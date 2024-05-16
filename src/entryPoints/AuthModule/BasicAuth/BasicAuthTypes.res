type basicAuthInfo = {
  token: option<string>,
  merchant_id: option<string>,
  name: option<string>,
  email: option<string>,
  flow_type: option<string>,
  user_role: option<string>,
  verification_days_left: option<bool>,
  merchants: option<array<JSON.t>>,
}

type flowType = MERCHANT_SELECT | DASHBOARD_ENTRY | ERROR
