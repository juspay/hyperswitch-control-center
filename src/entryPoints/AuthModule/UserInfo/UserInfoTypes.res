type userInfo = {
  email: string,
  is_two_factor_auth_setup: bool,
  merchant_id: string,
  name: string,
  org_id: string,
  recovery_codes_left: option<int>,
  role_id: string,
  verification_days_left: option<int>,
}
