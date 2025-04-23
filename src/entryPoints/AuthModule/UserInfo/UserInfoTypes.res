type entity = [#Tenant | #Organization | #Merchant | #Profile]
type version = V1 | V2
type userInfo = {
  email: string,
  isTwoFactorAuthSetup: bool,
  merchantId: string,
  name: string,
  orgId: string,
  recoveryCodesLeft: option<int>,
  roleId: string,
  verificationDaysLeft: option<int>,
  profileId: string,
  userEntity: entity,
  themeId: string,
  mutable transactionEntity: entity,
  mutable analyticsEntity: entity,
  version: version,
}

type userInfoProviderTypes = {
  userInfo: userInfo,
  setUserInfoData: userInfo => unit,
  getUserInfoData: unit => userInfo,
  checkUserEntity: array<entity> => bool,
}
