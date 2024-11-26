type entity = [#Organization | #Merchant | #Profile]
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
  mutable transactionEntity: entity,
  mutable analyticsEntity: entity,
}

type userInfoProviderTypes = {
  userInfo: userInfo,
  setUserInfoData: userInfo => unit,
  getUserInfoData: unit => userInfo,
  checkUserEntity: array<entity> => bool,
  updateOptionalUserInfoRef: userInfo => unit,
  userInfoFromRef: userInfo,
}
