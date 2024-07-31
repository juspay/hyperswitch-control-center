open UserInfoTypes

let defaultValue = {
  email: "",
  is_two_factor_auth_setup: false,
  merchant_id: "",
  name: "",
  org_id: "",
  recovery_codes_left: None,
  role_id: "",
  verification_days_left: None,
}
open LogicUtils
let itemMapper = dict => {
  email: dict->getString("email", defaultValue.email),
  is_two_factor_auth_setup: dict->getBool("email", defaultValue.is_two_factor_auth_setup),
  merchant_id: dict->getString("merchant_id", defaultValue.merchant_id),
  name: dict->getString("name", defaultValue.name),
  org_id: dict->getString("org_id", defaultValue.org_id),
  recovery_codes_left: dict->getOptionInt("recovery_codes_left"),
  role_id: dict->getString("role_id", defaultValue.email),
  verification_days_left: dict->getOptionInt("verification_days_left"),
}
