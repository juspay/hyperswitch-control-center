open UserInfoTypes

let defaultValue = {
  email: "",
  isTwoFactorAuthSetup: false,
  merchantId: "",
  name: "",
  orgId: "",
  recoveryCodesLeft: None,
  roleId: "",
  verificationDaysLeft: None,
}
open LogicUtils
let itemMapper = dict => {
  email: dict->getString("email", defaultValue.email),
  isTwoFactorAuthSetup: dict->getBool("email", defaultValue.isTwoFactorAuthSetup),
  merchantId: dict->getString("merchant_id", defaultValue.merchantId),
  name: dict->getString("name", defaultValue.name),
  orgId: dict->getString("org_id", defaultValue.orgId),
  recoveryCodesLeft: dict->getOptionInt("recovery_codes_left"),
  roleId: dict->getString("role_id", defaultValue.email),
  verificationDaysLeft: dict->getOptionInt("verification_days_left"),
}
