open UserInfoTypes

let defaultValueOfUserInfo = {
  email: "",
  isTwoFactorAuthSetup: false,
  merchantId: "",
  name: "",
  orgId: "",
  recoveryCodesLeft: None,
  roleId: "",
  verificationDaysLeft: None,
  profileId: "",
  userEntity: #Merchant,
  transactionEntity: #Merchant,
  analyticsEntity: #Merchant,
}

let entityMapper = entity => {
  switch entity->String.toLowerCase {
  | "internal" => #Internal
  | "organization" => #Organization
  | "merchant" => #Merchant
  | "profile" => #Profile
  | _ => #Merchant
  }
}

let defaultValueOfUserInfoProvider = {
  userInfo: defaultValueOfUserInfo,
  setUserInfoData: _ => (),
  getUserInfoData: _ => defaultValueOfUserInfo,
  checkUserEntity: _ => false,
}
open LogicUtils
let itemMapper = dict => {
  email: dict->getString("email", defaultValueOfUserInfo.email),
  isTwoFactorAuthSetup: dict->getBool(
    "is_two_factor_auth_setup",
    defaultValueOfUserInfo.isTwoFactorAuthSetup,
  ),
  merchantId: dict->getString("merchant_id", defaultValueOfUserInfo.merchantId),
  name: dict->getString("name", defaultValueOfUserInfo.name),
  orgId: dict->getString("org_id", defaultValueOfUserInfo.orgId),
  recoveryCodesLeft: dict->getOptionInt("recovery_codes_left"),
  roleId: dict->getString("role_id", defaultValueOfUserInfo.email),
  verificationDaysLeft: dict->getOptionInt("verification_days_left"),
  profileId: dict->getString("profile_id", ""),
  userEntity: dict->getString("entity_type", "")->entityMapper,
  transactionEntity: dict->getString("entity_type", "")->entityMapper,
  analyticsEntity: dict->getString("entity_type", "")->entityMapper,
}
