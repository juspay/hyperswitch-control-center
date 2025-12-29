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
  themeId: "",
  version: V1,
}

let defaultApplicationState: providerStateType = {
  commonInfo: {
    orgId: "",
    profileId: "",
    merchantId: "",
    version: V1,
  },
  details: DashboardUser(defaultValueOfUserInfo),
}

let entityMapper = entity => {
  switch entity->String.toLowerCase {
  | "tenant" => #Tenant
  | "organization" => #Organization
  | "merchant" => #Merchant
  | "profile" => #Profile
  | _ => #Merchant
  }
}

let transactionEntityMapper = entity => {
  switch entity->String.toLowerCase {
  | "merchant" => #Merchant
  | "profile" => #Profile
  | _ => #Merchant
  }
}

let analyticsEntityMapper = entity => {
  switch entity->String.toLowerCase {
  | "tenant"
  | "organization" =>
    #Organization
  | "merchant" => #Merchant
  | "profile" => #Profile
  | _ => #Merchant
  }
}

let versionMapper = version =>
  switch version->String.toLowerCase {
  | "v2" => V2
  | _ => V1
  }

let defaultValueOfUserInfoProvider = {
  state: defaultApplicationState,
  resolvedUserInfo: defaultValueOfUserInfo,
  setApplicationState: _ => (),
  setUpdatedDashboardUserInfo: _ => (),
  checkUserEntity: _ => false,
}
open LogicUtils
let itemMapperToDashboardUserType = dict => {
  email: dict->getString("email", defaultValueOfUserInfo.email),
  isTwoFactorAuthSetup: dict->getBool(
    "is_two_factor_auth_setup",
    defaultValueOfUserInfo.isTwoFactorAuthSetup,
  ),
  merchantId: dict->getString("merchant_id", defaultValueOfUserInfo.merchantId),
  name: dict->getString("name", defaultValueOfUserInfo.name),
  orgId: dict->getString("org_id", defaultValueOfUserInfo.orgId),
  recoveryCodesLeft: dict->getOptionInt("recovery_codes_left"),
  roleId: dict->getString("role_id", defaultValueOfUserInfo.roleId),
  verificationDaysLeft: dict->getOptionInt("verification_days_left"),
  profileId: dict->getString("profile_id", ""),
  userEntity: dict->getString("entity_type", "")->entityMapper,
  analyticsEntity: dict->getString("entity_type", "")->analyticsEntityMapper,
  transactionEntity: dict->getString("entity_type", "")->transactionEntityMapper,
  themeId: dict->getString("theme_id", ""),
  version: dict->getString("version", "v1")->versionMapper,
}

let convertValueToDashboardApplicationState = dict => {
  {
    commonInfo: {
      orgId: dict->getString("org_id", ""),
      profileId: dict->getString("profile_id", ""),
      merchantId: dict->getString("merchant_id", ""),
      version: dict->getString("version", "v1")->versionMapper,
    },
    details: DashboardUser(dict->itemMapperToDashboardUserType),
  }
}

let convertValueToEmbeddableApplicationState = dict => {
  {
    commonInfo: {
      orgId: dict->getString("org_id", ""),
      profileId: dict->getString("profile_id", ""),
      merchantId: dict->getString("merchant_id", ""),
      version: dict->getString("version", "v1")->versionMapper,
    },
    details: EmbeddableUser,
  }
}
